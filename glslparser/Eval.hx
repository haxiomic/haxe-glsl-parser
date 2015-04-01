/*
	GLSL Eval
	- For now, Eval supports only constant expressions

	@author George Corney

	#Notes
	- could we do away with GLSLAccesss and use GLSLVariable instead?
		Sure, but how do we deal with array access?
		Perhaps arrays are arrays of variables?
	- setValue, getValue should take not of constant:Bool
	- generally, Eval should be as error tolerant as possible, but warn as much as possible
	- stance on type checking?
		Yes, it should absolutely type check - in fact, it should auto cast where possible,
		but explicitly warn (or even throw if error sensitivity is high). This is become some
		implementations auto cast whereas other's do not

	#Todo
	- move Eval to eval/Eval, split up classes
	- new operator approach with search?
	- better errors and warnings
	- should allow use of, but warn on reserved operations and symbols
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
	- basic type .len?
	- handle basic conversion in constructors, constructs seem to be completely type flexible!
	- Arrays: const should be stored as VariableDefinition which includes array behavior
	- Scoping
	- should support reserved operations but emit a warning
*/

package glslparser;

import glslparser.AST;
using AST.TypeEnumHelper;
using Eval.GLSLPrimitiveInstanceHelper;
using Eval.DataTypeHelper;

class Eval{
	static public var builtInVariables:Map<String, GLSLVariable> = [
		'gl_MaxVertexAttribs'             => createConst('gl_MaxVertexAttribs'             , 8),
		'gl_MaxVertexUniformVectors'      => createConst('gl_MaxVertexUniformVectors'      , 128),
		'gl_MaxVaryingVectors'            => createConst('gl_MaxVaryingVectors'            , 8),
		'gl_MaxVertexTextureImageUnits'   => createConst('gl_MaxVertexTextureImageUnits'   , 0),
		'gl_MaxCombinedTextureImageUnits' => createConst('gl_MaxCombinedTextureImageUnits' , 8),
		'gl_MaxTextureImageUnits'         => createConst('gl_MaxTextureImageUnits'         , 8),
		'gl_MaxFragmentUniformVectors'    => createConst('gl_MaxFragmentUniformVectors'    , 16),
		'gl_MaxDrawBuffers'               => createConst('gl_MaxDrawBuffers'               , 1)
	];
	static public var builtInTypes:Map<DataType, GLSLTypeDef> = new Map<DataType, GLSLTypeDef>();

	static public var userDefinedTypes:Map<DataType, GLSLStructDefinition> = new Map<DataType, GLSLStructDefinition>();
	static public var userDefinedVariables:Map<String, GLSLVariable> = new Map<String, GLSLVariable>();

	static public var warnings:Array<String> = new Array<String>();

	static public function reset(){
		userDefinedVariables = new Map<String, GLSLVariable>();
		userDefinedTypes = new Map<DataType, GLSLStructDefinition>();
		warnings = [];
	}

	static public function evaluateExpr(expr:Expression, constant:Bool = false):GLSLPrimitiveInstance{

		trace('evaluateExpr '+(constant ? 'constant' : '')+' $expr'); //#! debug

		switch expr.toTypeEnum() {
			case LiteralNode(n): 
				return LiteralInstance(n.value, n.dataType);

			case ConstructorNode(n):
				var type = getType(n.dataType);

			 	if(type != null){
					var constructionParams:Array<GLSLPrimitiveInstance> = [];
					for(i in 0...n.parameters.length)
						constructionParams[i] = evaluateExpr(n.parameters[i], constant);
					return ComplexInstance(type.createInstance(constructionParams), n.dataType);
				}

			case IdentifierNode(n):
				var v:GLSLVariable = getVariable(n.name);

				if(v != null){
					if(constant && !v.qualifier.equals(TypeQualifier.CONST))
						warn('using non-constant variable ${v.name} in constant expression'); 

					return v.value;		
				}else{
					warn('no variable named \'${n.name}\' has been defined');
					return null;
				}

			case BinaryExpressionNode(n):
				var lprim = evaluateExpr(n.left, constant);
				var rprim = evaluateExpr(n.right, constant);
				var result = Operations.binaryFunctions.get(n.op)(lprim, rprim);
				if(result != null) return result;

			case UnaryExpressionNode(n):
				var arg:Dynamic = null;

				//evaluating the argument ensures it's a constant expression if required
				var argPrim = evaluateExpr(n.arg, constant);
				if(argPrim == null){
					warn('cannot perform unary expression on null');
					return null;
				}
				//INC_OP and DEC_OP require GLSLVariables
				switch n.op {
					case INC_OP, DEC_OP:
						arg = switch n.arg.toTypeEnum(){
							case IdentifierNode(n):
								getVariable(n.name);
							case FieldSelectionExpressionNode(n):
								var leftPrim = evaluateExpr(n.left, constant);
								switch leftPrim {
									case ComplexInstance(v, _):
										v.accessField(n.field.name);
									case null, _:
										warn('field access cannot be performed on $leftPrim');
										null;
								}
							// case ArrayElementSelectionExpressionNode(n): //#!
							case null, _:
								warn('invalid expression $n.arg for unary operator');
								null;
						}
					default:
						arg = argPrim;
				}
				var result = Operations.unaryFunctions.get(n.op)(arg, n.isPrefix);
				if(result != null) return result;

			case SequenceExpressionNode(n): //#!
				warn('Eval doesn\'t yet support sequence expressions');

			case ConditionalExpressionNode(n):
				var testResult = evaluateExpr(n.test, constant);
				switch testResult {
					case LiteralInstance(v, BOOL):
						return v ? evaluateExpr(n.consequent, constant) : evaluateExpr(n.alternate, constant);
					case null, _:
						warn('conditional expression test must evaluate to boolean value');
						return null;
				}

			case AssignmentExpressionNode(n): //#!
				warn('Eval doesn\'t yet support assignment expressions');

			case FieldSelectionExpressionNode(n):
				var leftPrim = evaluateExpr(n.left, constant);
				switch leftPrim {
					case ComplexInstance(v, _):
						return v.accessField(n.field.name).value;
					case null, _:
						warn('field access cannot be performed on $leftPrim');
						return null;
				}

			case ArrayElementSelectionExpressionNode(n): //#!
				warn('Eval doesn\'t yet support array element selection');

			case FunctionCallNode(n): //#!
				warn('Eval doesn\'t yet support function calls');
			case null, _:
		}

		warn('cannot resolve expression $expr');
		return null;
	}

	static public function evalulateStructSpecifier(specifier:StructSpecifier):GLSLStructDefinition{
		var userType = GLSLStructDefinition.fromStructSpecifier(specifier);
		userDefinedTypes.set(DataType.USER_TYPE(specifier.name), userType);
		return userType;
	}

	static public function evaluateVariableDeclaration(declaration:VariableDeclaration):Array<GLSLVariable>{
		var declared:Array<GLSLVariable> = [];

		//if TypeSpecifier is StructDefinition, evaluate it
		switch declaration.typeSpecifier.toTypeEnum() {
			case StructSpecifierNode(n): evalulateStructSpecifier(n);
			case null, _:
		}

		for(dr in declaration.declarators){
			//dr may potentially have no name (case of only a struct declaration)
			//in this case, skip it
			if(dr.name == null || dr.name == '') continue;

			var variable:GLSLVariable;

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
				qualifier: declaration.typeSpecifier.qualifier,
				precision: declaration.typeSpecifier.precision,
				invariant: declaration.typeSpecifier.invariant,
				value: null
			}

			var isConstant = declaration.typeSpecifier.qualifier.equals(TypeQualifier.CONST);

			//set value if there's an initializer
			if(dr.initializer != null){
				var value = evaluateExpr(dr.initializer, isConstant);
				//check data types match
				if(!value.getDataType().equals(variable.dataType)){
					warn('type mismatch between variable of type ${variable.dataType} and value of type ${value.getDataType()}');
				}
				variable.value = value;
			}else{
				if(isConstant) warn('variables with qualifier \'const\' must be initialized');
				//initialize to 0 state or false
				variable.value = variable.dataType.construct(null);
			}

			//add array size if necessary
			if(dr.arraySizeExpression != null){
				var arraySizePrimitive = evaluateExpr(dr.arraySizeExpression, true);
				switch arraySizePrimitive {
					case LiteralInstance(v, INT):
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

	static function getVariable(name:String){
		var v:GLSLVariable = userDefinedVariables.get(name);
		if(v == null) v = builtInVariables.get(name);
		return v;
	}

	static function getType(dataType:DataType){
		var type:GLSLTypeDef = null;
		if(dataType.match(USER_TYPE(_))){
			type = userDefinedTypes.get(dataType);
		}else{
			type = builtInTypes.get(dataType);
		}
		return type;
	}

	static function createConst(name:String, value:Dynamic, ?precision:PrecisionQualifier):GLSLVariable{
		if(precision == null) precision = PrecisionQualifier.MEDIUM_PRECISION;
		var dataType:DataType = null;
		switch (Type.typeof(value)) {
			case Type.ValueType.TInt: dataType = INT;
			case Type.ValueType.TFloat: dataType = FLOAT;
			case Type.ValueType.TBool: dataType = BOOL;
			case null, _:
		}
		var inst:GLSLPrimitiveInstance = LiteralInstance(value, dataType);
		return {
			name: name,
			value: inst,
			dataType: dataType,
			qualifier: TypeQualifier.CONST,
			precision: precision,
			invariant: false
		}
	}

	//Error Reporting
	static function warn(msg){
		trace('Eval warning: $msg');//#!
		warnings.push('Eval warning: $msg');
	}

	static function error(msg){
		throw 'Eval error: $msg';
	}
}

@:publicFields
@:access(glslparser.Eval)
class Operations{
	static var binaryFunctions:Map<BinaryOperator, GLSLPrimitiveInstance->GLSLPrimitiveInstance->GLSLPrimitiveInstance> = [
		STAR => multiply,
		SLASH => divide,
		PERCENT => modulo,
		PLUS => add,
		DASH => subtract
	/*	#! missing
		LEFT_OP;
		RIGHT_OP;
		LEFT_ANGLE;
		RIGHT_ANGLE;
		LE_OP;
		GE_OP;
		EQ_OP;
		NE_OP;
		AMPERSAND;
		CARET;
		VERTICAL_BAR;
		AND_OP;
		XOR_OP;
		OR_OP;
	*/
	];

	static var unaryFunctions:Map<UnaryOperator, Dynamic->Bool->GLSLPrimitiveInstance> = [
		INC_OP => increment,
		DEC_OP => decrement,
		PLUS => plus,
		DASH => minus
	/*	#! missing
		BANG;
		TILDE;
	*/
	];

	// #! todo
	// static var assignmentFunctions

	//Binary Operations
	static function multiply(lhs:GLSLPrimitiveInstance, rhs:GLSLPrimitiveInstance):GLSLPrimitiveInstance{
		switch ({lhs: lhs, rhs: rhs}) {
			case {lhs: LiteralInstance(lv, INT), rhs: LiteralInstance(rv, INT)}:
				return LiteralInstance(lv * rv, INT);
			case {lhs: LiteralInstance(lv, FLOAT), rhs: LiteralInstance(rv, FLOAT)}:
				return LiteralInstance(lv * rv, FLOAT);
			default: 
				Eval.error('could not multiply $lhs and $rhs');
		}
		return null;		
	}

	static function divide(lhs:GLSLPrimitiveInstance, rhs:GLSLPrimitiveInstance):GLSLPrimitiveInstance{
		switch ({lhs: lhs, rhs: rhs}) {
			case {lhs: LiteralInstance(lv, INT), rhs: LiteralInstance(rv, INT)}:
				return LiteralInstance(Math.floor(lv / rv), INT);
			case {lhs: LiteralInstance(lv, FLOAT), rhs: LiteralInstance(rv, FLOAT)}:
				return LiteralInstance(lv / rv, FLOAT);
			default: 
				Eval.error('could not divide $lhs by $rhs');
		}
		return null;		
	}

	static function modulo(lhs:GLSLPrimitiveInstance, rhs:GLSLPrimitiveInstance):GLSLPrimitiveInstance{
		//OPERATOR RESERVED
		Eval.error('modulo operation not supported ($lhs % $rhs)');
		return null;		
	}

	static function add(lhs:GLSLPrimitiveInstance, rhs:GLSLPrimitiveInstance):GLSLPrimitiveInstance{
		switch ({lhs: lhs, rhs: rhs}) {
			case {lhs: LiteralInstance(lv, INT), rhs: LiteralInstance(rv, INT)}:
				return LiteralInstance(lv + rv, INT);
			case {lhs: LiteralInstance(lv, FLOAT), rhs: LiteralInstance(rv, FLOAT)}:
				return LiteralInstance(lv + rv, FLOAT);
			default: 
				Eval.error('could not add $lhs and $rhs');
		}
		return null;		
	}

	static function subtract(lhs:GLSLPrimitiveInstance, rhs:GLSLPrimitiveInstance):GLSLPrimitiveInstance{
		switch ({lhs: lhs, rhs: rhs}) {
			case {lhs: LiteralInstance(lv, INT), rhs: LiteralInstance(rv, INT)}:
				return LiteralInstance(lv - rv, INT);
			case {lhs: LiteralInstance(lv, FLOAT), rhs: LiteralInstance(rv, FLOAT)}:
				return LiteralInstance(lv - rv, FLOAT);
			default: 
				Eval.error('could not subtract $lhs by $rhs');
		}
		return null;		
	}

	//Unary Operators
	static function increment(variable:GLSLVariable, isPrefix:Bool){
		//perform increment on primitive
		var argPrim = variable.value;
		var primBefore = argPrim;
		var result:GLSLPrimitiveInstance = null;
		switch(argPrim){
			case LiteralInstance(v, INT):
				result = LiteralInstance(v+1, INT);
			case LiteralInstance(v, FLOAT):
				result = LiteralInstance(v+1, FLOAT);
			case null, _:
				result = null;
		}

		variable.value = result;

		return isPrefix ? result : primBefore;
	}

	static function decrement(variable:GLSLVariable, isPrefix:Bool){
		//perform decrement on primitive
		var argPrim = variable.value;
		var primBefore = argPrim;
		var result:GLSLPrimitiveInstance = null;
		switch(argPrim){
			case LiteralInstance(v, INT):
				result = LiteralInstance(v-1, INT);
			case LiteralInstance(v, FLOAT):
				result = LiteralInstance(v-1, FLOAT);
			case null, _:
				result = null;
		}

		variable.value = result;

		return isPrefix ? result : primBefore;	
	}

	static function plus(argPrim:GLSLPrimitiveInstance, isPrefix:Bool){
		switch({arg: argPrim, isPrefix: isPrefix}){
			case {arg: LiteralInstance(_, INT), isPrefix: true} 	|
				 {arg: LiteralInstance(_, FLOAT), isPrefix: true}	|
				 {arg: ComplexInstance(_, _), isPrefix: true}:
				return argPrim;
			case {arg: _, isPrefix: true}:
				Eval.error('operation +$argPrim not supported');
			case {arg: _, isPrefix: false}:
				Eval.error('operation $argPrim+ not supported');
		}
		return null;
	}

	static function minus(argPrim:GLSLPrimitiveInstance, isPrefix:Bool){
		switch({arg: argPrim, isPrefix: isPrefix}){
			case {arg: LiteralInstance(v, INT), isPrefix: true}:
				return LiteralInstance(-v, INT);
			case {arg: LiteralInstance(v, FLOAT), isPrefix: true}:
				return LiteralInstance(-v, FLOAT);
			case {arg: _, isPrefix: true}:
				Eval.error('operation -$argPrim not supported');
			case {arg: _, isPrefix: false}:
				Eval.error('operation $argPrim- not supported');
		}
		return null;
	}
}

class GLSLPrimitiveInstanceHelper{
	static public function getDataType(p:GLSLPrimitiveInstance):DataType{
		return switch p {
			case LiteralInstance(_, t): t;
			case ComplexInstance(_, t): t;
			default: null;
		}
	}
}

@:access(glslparser.Eval)
class DataTypeHelper{
	static public function construct(dataType:DataType, ?value:Dynamic):GLSLPrimitiveInstance{
		switch dataType{
			case INT, FLOAT:
				return LiteralInstance((value != null ? value : 0), dataType);
			case BOOL:
				return LiteralInstance((value != null ? value : false), dataType);
			case USER_TYPE(n):
				var typeDefinition = Eval.userDefinedTypes.get(dataType);

				var constructionParams:Array<GLSLPrimitiveInstance>;
				if(value != null){
					constructionParams = value;
				}else{
					//create empty fields
					constructionParams = [];
					for(i in 0...typeDefinition.fields.length){
						var f = typeDefinition.fields[i];
						constructionParams.push(construct(f.dataType, null));
					}
				}

				return ComplexInstance(typeDefinition.createInstance(constructionParams), dataType);

			//#! support for other types
			case null, _:
				Eval.error('cannot construct type $dataType');
		}
		return null;
	}
}

enum GLSLPrimitiveInstance{
	LiteralInstance(v:Dynamic, t:DataType);
	ComplexInstance(instance:GLSLInstance, t:DataType);
	// ArrayInstance, for future use
}

typedef GLSLVariableDef = {
	var name:String;
	var dataType:DataType;
	var qualifier:TypeQualifier;
	var precision:PrecisionQualifier;
	var invariant:Bool;
	@:optional var arraySize:Int;
};

typedef GLSLVariable = {
	> GLSLVariableDef,
	var value:GLSLPrimitiveInstance;}

interface GLSLTypeDef{
	public function createInstance(?constructionParams:Array<GLSLPrimitiveInstance>):GLSLInstance;
}

@:access(glslparser.Eval)
class GLSLStructDefinition implements GLSLTypeDef{
	public var name:String;
	public var fields:Array<GLSLVariableDef>;

	public function new(name:String, fields:Array<GLSLVariableDef>){
		this.name = name;
		this.fields = fields;
	}

	public function createInstance(?constructionParams:Array<GLSLPrimitiveInstance>):GLSLStructInstance{
		return new GLSLStructInstance(this, constructionParams);
	}

	static public function fromStructSpecifier(specifier:StructSpecifier){
		//convert declarations to fields
		var fields = new Array<GLSLVariableDef>();

		//create field definitions in order
		for(i in 0...specifier.structDeclarations.length){
			var d = specifier.structDeclarations[i];
			var typeSpec = d.typeSpecifier;

			for(j in 0...d.declarators.length){

				//create field def and push
				switch d.declarators[j].toTypeEnum() {
					case StructDeclaratorNode(n):
						var field:GLSLVariableDef = {
							name: n.name,
							dataType: typeSpec.dataType, 
							qualifier: typeSpec.qualifier,
							precision: typeSpec.precision,
							invariant: typeSpec.invariant
						};

						//add array size if necessary
						if(n.arraySizeExpression != null){
							var arraySizePrimitive = Eval.evaluateExpr(n.arraySizeExpression, true);
							switch arraySizePrimitive {
								case LiteralInstance(v, INT):
									field.arraySize = v;
								case null, _:
									Eval.error('array size must an integer expression');
							}
						}

						fields.push(field);
					case null, _:
				}

			}
		}

		return new GLSLStructDefinition(specifier.name, fields);
	}
}


//Instances
interface GLSLInstance{
	//#! .type? / .definition?
	//#! .performOperation()?
	public function accessField(name:String):GLSLVariable;
}

interface GLSLArrayAccess{
	public function accessIndex(i:Int):GLSLPrimitiveInstance;
}

@:access(glslparser.Eval)
class GLSLStructInstance implements GLSLInstance{
	var type:GLSLStructDefinition;
	var fields:Map<String, GLSLVariable>;

	public function new(type:GLSLStructDefinition, ?constructionParams:Array<GLSLPrimitiveInstance>){
		this.type = type;

		fields = new Map<String, GLSLVariable>();

		//create fields
		for(i in 0...type.fields.length){
			var f = type.fields[i];

			var fieldInst:GLSLVariable = {
				name: f.name,
				dataType: f.dataType,
				qualifier: f.qualifier,
				precision: f.precision,
				invariant: f.invariant,
				arraySize: f.arraySize,
				value: null,
			};

			fields.set(f.name, fieldInst);
		}

		if(constructionParams != null)
			construct(constructionParams);
	}

	public function construct(constructionParams:Array<GLSLPrimitiveInstance>){
		//strict parameter-field match
		if(constructionParams.length != type.fields.length){
			Eval.error('number of constructor parameters does not match the number of structure fields');
			return;
		}

		for(i in 0...constructionParams.length){
			var c = constructionParams[i];
			var f = fields.get(fieldName(i));

			if(!c.getDataType().equals(f.dataType)){
				Eval.warn('structure constructor arguments types do not match structure field\'s');
			}

			f.value = c;
		}
	}
	
	public function accessField(name:String):GLSLVariable{
		return fields.get(name);
	}

	inline function fieldName(i:Int):String{
		return type.fields[i].name;
	}
}