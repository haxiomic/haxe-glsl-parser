/*
	GLSL Eval
	- For now, Eval supports only constant expressions

	@author George Corney

	#Notes
	- generally, Eval should be as error tolerant as possible, but warn as much as possible
	- stance on type checking?
		Yes, it should absolutely type check - in fact, it should auto cast where possible,
		but explicitly warn (or even throw if error sensitivity is high). This is become some
		implementations auto cast whereas other's do not
	- do not warn on version specific behavior. This is the validator's job

	#Todo
	- new operator approach with search?
	- complete primitive operators
	- better errors and warnings
	- .match(pattern) doesn't seem to be working?
	- built in types
	- handle complex construction:

		mat2 m2x2 = mat2(
		   1.1, 2.1, 
		   1.2, 2.2
		);
		mat3 m3x3 = mat3(m2x2); // = mat3(
		   // 1.1, 2.1, 0.0,   
		   // 1.2, 2.2, 0.0,
		   // 0.0, 0.0, 1.0)
		mat2 mm2x2 = mat2(m3x3); // = m2x2

	- handle basic conversion in constructors, constructs seem to be completely type flexible!
	- arrays: const should be stored as VariableDefinition which includes array behavior
	- Scoping
	- Comprehend precision declarations, set precision of variables based on declaration
*/

package glsl.eval;

import glsl.SyntaxTree;
import glsl.eval.StructDefinition;

using SyntaxTree.NodeEnumHelper;
// using glsl.eval.helpers.GLSLInstanceHelper;
// using glsl.eval.helpers.DataTypeHelper;

using glsl.eval.Helpers;

class Eval{

	static public var warnings:Array<String> = new Array<String>();

	static public var builtinVariables:Map<String, Variable> = [
		'gl_MaxVertexAttribs'             => createConst('gl_MaxVertexAttribs'             , 8),
		'gl_MaxVertexUniformVectors'      => createConst('gl_MaxVertexUniformVectors'      , 128),
		'gl_MaxVaryingVectors'            => createConst('gl_MaxVaryingVectors'            , 8),
		'gl_MaxVertexTextureImageUnits'   => createConst('gl_MaxVertexTextureImageUnits'   , 0),
		'gl_MaxCombinedTextureImageUnits' => createConst('gl_MaxCombinedTextureImageUnits' , 8),
		'gl_MaxTextureImageUnits'         => createConst('gl_MaxTextureImageUnits'         , 8),
		'gl_MaxFragmentUniformVectors'    => createConst('gl_MaxFragmentUniformVectors'    , 16),
		'gl_MaxDrawBuffers'               => createConst('gl_MaxDrawBuffers'               , 1)
	];
	static public var builtinTypes:Map<DataType, ITypeDefinition> = new Map<DataType, ITypeDefinition>();

	static public var userDefinedTypes:Map<DataType, StructDefinition> = new Map<DataType, StructDefinition>();
	static public var userDefinedVariables:Map<String, Variable> = new Map<String, Variable>();

	static public function reset(){
		userDefinedVariables = new Map<String, Variable>();
		userDefinedTypes = new Map<DataType, StructDefinition>();
		warnings = [];
	}

	static public function evaluateExpr(expr:Expression, constant:Bool = false):GLSLInstance{
		
		switch expr.toEnum() {
			case PrimitiveNode(n): 
				return PrimitiveInstance(n.value, n.dataType);

			case ConstructorNode(n):
				var type = getType(n.dataType);

			 	if(type != null){
					var constructionParams:Array<GLSLInstance> = [];
					for(i in 0...n.parameters.length)
						constructionParams[i] = evaluateExpr(n.parameters[i], constant);
					return CompositeInstance(type.createInstance(constructionParams), n.dataType);
				}

			case IdentifierNode(n):
				var v:Variable = getVariable(n.name);

				if(v != null){
					if(constant && !v.storage.equals(StorageQualifier.CONST)){
						warn('using non-constant variable ${v.name} in constant expression'); 
					}

					return v.value;		
				}else{
					error('no variable named \'${n.name}\' has been defined');
					return null;
				}

			case BinaryExpressionNode(n):
				var lInst = evaluateExpr(n.left, constant);
				var rInst = evaluateExpr(n.right, constant);
				var result = Operations.binaryFunctions.get(n.op)(lInst, rInst);
				if(result != null) return result;

			case UnaryExpressionNode(n):
				//evaluating the argument ensures it's a constant expression if required
				var argVar = resolveVariable(n.arg, constant);
				var argInst = argVar != null ? argVar.value : evaluateExpr(n.arg, constant);

				//INC_OP and DEC_OP require GLSLVariables
				var arg:Dynamic = switch n.op {
					case INC_OP, DEC_OP: argVar;
					default: argInst;
				}

				if(arg == null){
					error('cannot perform unary expression on null');
					return null;
				}

				var result = Operations.unaryFunctions.get(n.op)(arg, n.isPrefix);
				if(result != null) return result;

			case SequenceExpressionNode(n):
				var currentExpression;
				for(e in n.expressions){
					currentExpression = evaluateExpr(e);
				}
				return currentExpression;

			case ConditionalExpressionNode(n):
				var testResult = evaluateExpr(n.test, constant);
				switch testResult {
					case PrimitiveInstance(v, BOOL):
						return v ? evaluateExpr(n.consequent, constant) : evaluateExpr(n.alternate, constant);
					case null, _:
						error('conditional expression test must evaluate to boolean value');
						return null;
				}

			case AssignmentExpressionNode(n):
				var leftVar = resolveVariable(n.left, constant);
				if(leftVar.storage.equals(StorageQualifier.CONST)){
					warn('cannot assign value to constant variable ${leftVar.name}');
				}

				var value = evaluateExpr(n.right);
				
				var result = Operations.assignmentFunctions.get(n.op)(leftVar, value);
				if(result != null) return result;

			case FieldSelectionExpressionNode(n):
				var leftInst = evaluateExpr(n.left, constant);
				switch leftInst {
					case CompositeInstance(v, _):
						return v.accessField(n.field.name).value;
					case null, _:
						error('field access cannot be performed on $leftInst');
						return null;
				}

			case ArrayElementSelectionExpressionNode(n): //@!
				error('Eval doesn\'t yet support array element selection');

			case FunctionCallNode(n): //@!
				error('Eval doesn\'t yet support function calls');
			case null, _:
		}

		error('cannot resolve expression $expr');
		return null;
	}

	static public function evalulateStructSpecifier(specifier:StructSpecifier):StructDefinition{
		//convert struct declarations to definition's fields
		var fields = new Array<VariableDefinition>();

		for(i in 0...specifier.fieldDeclarations.length){
			var d = specifier.fieldDeclarations[i];
			var typeSpec = d.typeSpecifier;

			for(j in 0...d.declarators.length){

				//create field def and push
				switch d.declarators[j].toEnum() {
					case StructDeclaratorNode(n):
						var field:VariableDefinition = {
							name: n.name,
							dataType: typeSpec.dataType, 
							storage: typeSpec.storage,
							precision: typeSpec.precision,
							invariant: typeSpec.invariant
						};

						//add array size if necessary
						if(n.arraySizeExpression != null){
							var arraySizePrimitive = Eval.evaluateExpr(n.arraySizeExpression, true);
							switch arraySizePrimitive {
								case PrimitiveInstance(v, INT):
									field.arraySize = v;
								case null, _:
									error('array size must an integer expression');
							}
						}

						fields.push(field);
					case null, _:
				}

			}
		}

		var userType = new StructDefinition(specifier.name, fields);

		userDefinedTypes.set(DataType.USER_TYPE(specifier.name), userType);
		return userType;
	}

	static public function evaluateVariableDeclaration(declaration:VariableDeclaration):Array<Variable>{
		var declared:Array<Variable> = [];

		//if TypeSpecifier is StructDefinition, evaluate it
		switch declaration.typeSpecifier.toEnum() {
			case StructSpecifierNode(n): evalulateStructSpecifier(n);
			case null, _:
		}

		for(dr in declaration.declarators){
			//dr may potentially have no name (case of only a struct declaration)
			//in this case, skip it
			if(dr.name == null || dr.name == '') continue;

			var variable:Variable;

			//check for redeclaration
			if((variable = getVariable(dr.name)) != null){ //variable already exists
				if(declaration.typeSpecifier.invariant){ //if invariant qualifier is set, it's not a considered redeclaration
					variable.invariant = true;
					declared.push(variable);
					continue;
				}
				warn('redeclaration of variable \'${dr.name}\' not allowed');
				continue;
			}

			variable = {
				name: dr.name,
				dataType: declaration.typeSpecifier.dataType,
				storage: declaration.typeSpecifier.storage,
				precision: declaration.typeSpecifier.precision,
				invariant: declaration.typeSpecifier.invariant,
				value: null
			}

			var isConstant = declaration.typeSpecifier.storage.equals(StorageQualifier.CONST);

			//set value if there's an initializer
			if(dr.initializer != null){
				//not all variables need to be initialized
				switch declaration.typeSpecifier.storage{
					case StorageQualifier.ATTRIBUTE, StorageQualifier.VARYING, StorageQualifier.UNIFORM:
						warn('variables with storage qualifier \'${declaration.typeSpecifier.storage} cannot be initialized\'');
					case null, _:
						//initialize by evaluating expression
						var value = evaluateExpr(dr.initializer, isConstant);
						//check data types match
						if(!value.getDataType().equals(variable.dataType)){
							warn('type mismatch between variable \'${variable.name}\' of type ${variable.dataType} and value of type ${value.getDataType()}');
						}
						variable.value = value;
				}

			}else{
				//const variables must be explicitly initialized
				//non-qualified variables are implicitly initialized to 0 state
				switch declaration.typeSpecifier.storage{
					case StorageQualifier.CONST:
						warn('variables with storage qualifier \'const\' must be initialized');
						variable.value = variable.dataType.construct(null); //0 state
					case null:
						variable.value = variable.dataType.construct(null);	//0 state
					case _:
				}
			}

			//add array size if necessary
			if(dr.arraySizeExpression != null){
				var arraySizePrimitive = evaluateExpr(dr.arraySizeExpression, true);
				switch arraySizePrimitive {
					case PrimitiveInstance(v, INT):
						variable.arraySize = v;
					case null, _:
						error('array size must an integer expression');
				}
			}

			userDefinedVariables.set(dr.name, variable);
			declared.push(variable);
		}

		return declared;
	}

	static function resolveVariable(expr:Expression, constant:Bool):Variable{
		var variable:Variable = null;

		switch expr.toEnum(){
			case IdentifierNode(n): 
				variable = getVariable(n.name);

			case FieldSelectionExpressionNode(n):
				var leftInst = evaluateExpr(n.left, constant);
				switch leftInst {
					case CompositeInstance(v, _):
						variable = v.accessField(n.field.name);
					case null, _:
						warn('field access cannot be performed on $leftInst');
				}

			// case ArrayElementSelectionExpressionNode(n): //@!

			case null, _:
		}

		if(variable == null) return null;

		if(constant && !variable.storage.equals(StorageQualifier.CONST)){
			warn('using non-constant variable ${variable.name} in constant expression');
		}

		return variable;
	}

	static function getVariable(name:String){
		var v:Variable = userDefinedVariables.get(name);
		if(v == null) v = builtinVariables.get(name);
		return v;
	}

	static function getType(dataType:DataType){
		var type:ITypeDefinition = null;
		if(dataType.match(USER_TYPE(_))){
			type = userDefinedTypes.get(dataType);
		}else{
			type = builtinTypes.get(dataType);
		}
		return type;
	}

	static function createConst(name:String, value:Dynamic, ?precision:PrecisionQualifier):Variable{
		if(precision == null) precision = PrecisionQualifier.MEDIUM_PRECISION;
		var dataType:DataType = null;
		switch (Type.typeof(value)) {
			case Type.ValueType.TInt: dataType = INT;
			case Type.ValueType.TFloat: dataType = FLOAT;
			case Type.ValueType.TBool: dataType = BOOL;
			case null, _:
		}
		var inst:GLSLInstance = PrimitiveInstance(value, dataType);
		return {
			name: name,
			value: inst,
			dataType: dataType,
			storage: StorageQualifier.CONST,
			precision: precision,
			invariant: false
		}
	}

	//Error Reporting
	static function warn(msg){
		warnings.push('Eval warning: $msg');
	}

	static function error(msg){
		throw 'Eval error: $msg';
	}
}

enum GLSLInstance{
	PrimitiveInstance(v:Dynamic, t:DataType);
	CompositeInstance(v:ICompositeInstance, t:DataType);
	// ArrayInstance, for future use
}

typedef VariableDefinition = {
	var name:String;
	var dataType:DataType;
	var storage:StorageQualifier;
	var precision:PrecisionQualifier;
	var invariant:Bool;
	@:optional var arraySize:Int;
};

typedef Variable = {
	> VariableDefinition,
	var value:GLSLInstance;
}