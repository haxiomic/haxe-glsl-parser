/*
	GLSL Eval
	- For now, Eval supports only constant expressions in the global scope

	@author George Corney

	#Todo
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
	- Arrays: const should be stored as VariableDefinition which includes array behavior

	- should support reserved operations but emit a warning
*/

package glslparser;

import glslparser.AST;
using AST.TypeEnumHelper;

class Eval{
	static public var builtInVariables:Map<String, GLSLVariable> = [
		'gl_MaxVertexAttribs'             => createBuiltInConst('gl_MaxVertexAttribs', 8),
		'gl_MaxVertexUniformVectors'      => createBuiltInConst('gl_MaxVertexUniformVectors', 128),
		'gl_MaxVaryingVectors'            => createBuiltInConst('gl_MaxVaryingVectors', 8),
		'gl_MaxVertexTextureImageUnits'   => createBuiltInConst('gl_MaxVertexTextureImageUnits', 0),
		'gl_MaxCombinedTextureImageUnits' => createBuiltInConst('gl_MaxCombinedTextureImageUnits', 8),
		'gl_MaxTextureImageUnits'         => createBuiltInConst('gl_MaxTextureImageUnits', 8),
		'gl_MaxFragmentUniformVectors'    => createBuiltInConst('gl_MaxFragmentUniformVectors', 16),
		'gl_MaxDrawBuffers'               => createBuiltInConst('gl_MaxDrawBuffers', 1)
	];
	static public var builtInTypes:Map<DataType, GLSLTypeDef> = new Map<DataType, GLSLTypeDef>();

	static public var userDefinedTypes:Map<DataType, GLSLTypeDef> = new Map<DataType, GLSLTypeDef>();
	static public var userDefinedVariables:Map<String, GLSLVariable> = new Map<String, GLSLVariable>();

	static public var warnings:Array<String> = new Array<String>();

	static public function reset(){
		userDefinedVariables = new Map<String, GLSLVariable>();
		userDefinedTypes = new Map<DataType, GLSLTypeDef>();
		warnings = [];
	}

	static public function evaluateConstantExpr(expr:Expression):GLSLPrimitiveInstance{
		switch expr.toTypeEnum() {
			case LiteralNode(n): 
				return LiteralInstance(n.value, n.dataType);

			case ConstructorNode(n):
				var type = getType(n.dataType);

			 	if(type != null){
					var constructionParams:Array<GLSLPrimitiveInstance> = [];
					for(i in 0...n.parameters.length)
						constructionParams[i] = evaluateConstantExpr(n.parameters[i]);
					return ComplexInstance(type.createInstance(constructionParams), n.dataType);
				}

			case IdentifierNode(n):
				var v:GLSLVariable = getVariable(n.name);

				if(v != null){
					switch v.qualifier {
						case TypeQualifier.CONST: 
							return v.value;
						default:
							warn('using non-constant variable ${v.name} in constant expression'); 
							return v.value;
					}
				}

			case BinaryExpressionNode(n):
				var lprim = evaluateConstantExpr(n.left);
				var rprim = evaluateConstantExpr(n.right);
				var result = Operations.binaryFunctions.get(n.op)(lprim, rprim);
				if(result != null) return result;

			case UnaryExpressionNode(n):
				var result = Operations.unaryFunctions.get(n.op)(n.arg, n.isPrefix);
				if(result != null) return result;

			case SequenceExpressionNode(n):
			case ConditionalExpressionNode(n):
			case AssignmentExpressionNode(n):
			case FieldSelectionExpressionNode(n):
			case ArrayElementSelectionExpressionNode(n):
			case null | _:
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

		//if TypeSpecifier is Struct Definition, evaluate it
		//#! should we check if it's already defined?
		switch declaration.typeSpecifier.toTypeEnum() {
			case StructSpecifierNode(n): evalulateStructSpecifier(n);
			default:
		}

		for(dr in declaration.declarators){
			//dr may potentially have no name (case of only a struct declaration)
			//in this case, skip it
			if(dr.name == null || dr.name == '') continue;

			var variable:GLSLVariable = {
				name: dr.name,
				dataType: declaration.typeSpecifier.dataType,
				qualifier: declaration.typeSpecifier.qualifier,
				precision: declaration.typeSpecifier.precision,
				invariant: dr.invariant
			}

			//set value if there's an initializer
			if(dr.initializer != null){
				variable.value = evaluateConstantExpr(dr.initializer);
			}

			//add array size if necessary
			if(dr.arraySizeExpression != null){
				var arraySizePrimitive = Eval.evaluateConstantExpr(dr.arraySizeExpression);
				switch arraySizePrimitive {
					case LiteralInstance(v, INT):
						variable.arraySize = v;
					default:
						error('array size must an integer expression');
				}
			}

			userDefinedVariables.set(dr.name, variable);
			declared.push(variable);
		}

		return declared;
	}

	static function setValue(expr:Expression, value:GLSLPrimitiveInstance){
		//change value in memory if possible
		switch expr.toTypeEnum(){
			case IdentifierNode(n):
				var v = Eval.getVariable(n.name);
				if(!v.qualifier.equals(CONST)){
					return v.value = value;
				}else{
					Eval.warn('trying to change the value of a constant variable $v');
				}

			case FieldSelectionExpressionNode(n):
				//#!
			case ArrayElementSelectionExpressionNode(n):
				//#!
			default:
				Eval.error('cannot alter value of $expr');
		}

		return null;
	}

	static function getVariable(name:String){
		var v:GLSLVariable = userDefinedVariables.get(name);
		if(v == null) v = builtInVariables.get(name);
		return v;
	}

	static function getType(dataType:DataType){
		var type:GLSLTypeDef = null;
		if(dataType.match(USER_TYPE(_)))
			type = userDefinedTypes.get(dataType);
		else
			type = builtInTypes.get(dataType);
		return type;
	}

	static function createBuiltInConst(name:String, value:Dynamic):GLSLVariable{
		var dataType:DataType = null;
		switch (Type.typeof(value)) {
			case Type.ValueType.TInt: dataType = INT;
			case Type.ValueType.TFloat: dataType = FLOAT;
			case Type.ValueType.TBool: dataType = BOOL;
			default:
		}
		var inst:GLSLPrimitiveInstance = LiteralInstance(value, dataType);
		return {
			name: name,
			value: inst,
			dataType: dataType,
			qualifier: TypeQualifier.CONST,
			precision: PrecisionQualifier.MEDIUM_PRECISION,
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

	static var unaryFunctions:Map<UnaryOperator, Expression->Bool->GLSLPrimitiveInstance> = [
		INC_OP => increment,
		DEC_OP => decrement,
		PLUS => plus,
		DASH => minus
	/*	#! missing
		BANG;
		TILDE;
	*/
	];

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
	static function increment(argExpr:Expression, isPrefix:Bool){
		//perform increment on primitive
		var argPrim = Eval.evaluateConstantExpr(argExpr);
		var primBefore = argPrim;
		var result:GLSLPrimitiveInstance = null;
		switch(argPrim){
			case LiteralInstance(v, INT):
				result = LiteralInstance(v+1, INT);
			case LiteralInstance(v, FLOAT):
				result = LiteralInstance(v+1, FLOAT);
			default:
				result = null;
		}

		Eval.setValue(argExpr, result);

		return isPrefix ? result : primBefore;
	}

	static function decrement(argExpr:Expression, isPrefix:Bool){
		//perform decrement on primitive
		var argPrim = Eval.evaluateConstantExpr(argExpr);
		var primBefore = argPrim;
		var result:GLSLPrimitiveInstance = null;
		switch(argPrim){
			case LiteralInstance(v, INT):
				result = LiteralInstance(v-1, INT);
			case LiteralInstance(v, FLOAT):
				result = LiteralInstance(v-1, FLOAT);
			default:
				result = null;
		}

		Eval.setValue(argExpr, result);

		return isPrefix ? result : primBefore;	
	}

	static function plus(argExpr:Expression, isPrefix:Bool){
		var arg = Eval.evaluateConstantExpr(argExpr);
		switch({arg: arg, isPrefix: isPrefix}){
			case {arg: LiteralInstance(_, INT), isPrefix: true} 	|
				 {arg: LiteralInstance(_, FLOAT), isPrefix: true}	|
				 {arg: ComplexInstance(_, _), isPrefix: true}:
				return arg;
			case {arg: _, isPrefix: true}:
				Eval.error('operation +$arg not supported');
			case {arg: _, isPrefix: false}:
				Eval.error('operation $arg+ not supported');
		}
		return null;
	}

	static function minus(argExpr:Expression, isPrefix:Bool){
		var arg = Eval.evaluateConstantExpr(argExpr);
		switch({arg: arg, isPrefix: isPrefix}){
			case {arg: LiteralInstance(v, INT), isPrefix: true}:
				return LiteralInstance(-v, INT);
			case {arg: LiteralInstance(v, FLOAT), isPrefix: true}:
				return LiteralInstance(-v, FLOAT);
			case {arg: _, isPrefix: true}:
				Eval.error('operation -$arg not supported');
			case {arg: _, isPrefix: false}:
				Eval.error('operation $arg- not supported');
		}
		return null;
	}
}

enum GLSLPrimitiveInstance{
	LiteralInstance(v:Dynamic, t:DataType);
	ComplexInstance(instance:GLSLInstance, t:DataType);
}

typedef GLSLFieldDef = {
	var name:String;
	var dataType:DataType;
	var qualifier:TypeQualifier;
	var precision:PrecisionQualifier;
	@:optional var arraySize:Int;
};

typedef GLSLVariable = {
	> GLSLFieldDef,
	@:optional var value:GLSLPrimitiveInstance;
	var invariant:Bool;
}

interface GLSLTypeDef{
	public function createInstance(?constructionParams:Array<GLSLPrimitiveInstance>):GLSLInstance;
}

@:access(glslparser.Eval)
class GLSLStructDefinition implements GLSLTypeDef{
	public var name:String;
	public var fields:Array<GLSLFieldDef>;

	public function new(name:String, fields:Array<GLSLFieldDef>){
		this.name = name;
		this.fields = fields;
	}

	public function createInstance(?constructionParams:Array<GLSLPrimitiveInstance>):GLSLStructInstance{
		return new GLSLStructInstance(this, constructionParams);
	}

	static public function fromStructSpecifier(specifier:StructSpecifier){
		//convert declarations to fields
		var fields = new Array<GLSLFieldDef>();

		//create field definitions in order
		for(i in 0...specifier.structDeclarations.length){
			var d = specifier.structDeclarations[i];
			var typeSpec = d.typeSpecifier;

			for(j in 0...d.declarators.length){

				//create field def and push
				switch d.declarators[j].toTypeEnum() {
					case StructDeclaratorNode(n):
						var field:GLSLFieldDef = {
							name: n.name,
							dataType: typeSpec.dataType, 
							qualifier: typeSpec.qualifier,
							precision: typeSpec.precision
						};

						//add array size if necessary
						if(n.arraySizeExpression != null){
							var arraySizePrimitive = Eval.evaluateConstantExpr(n.arraySizeExpression);
							switch arraySizePrimitive {
								case LiteralInstance(v, INT):
									field.arraySize = v;
								default:
									Eval.error('array size must an integer expression');
							}
						}

						fields.push(field);
					default:
				}

			}
		}

		return new GLSLStructDefinition(specifier.name, fields);
	}
}


//Instances
interface GLSLFieldAccess{
	public function accessField(name:String):GLSLPrimitiveInstance;
}

interface GLSLArrayAccess{
	public function accessIndex(i:Int):GLSLPrimitiveInstance;
}

typedef GLSLFieldInstance = {
	var dataType:DataType;
	var value:GLSLPrimitiveInstance;
	@:optional var arraySize:Int;
}

interface GLSLInstance{
	//#! type?
	//#! performOperation()?
}

@:access(glslparser.Eval)
class GLSLStructInstance implements GLSLInstance implements GLSLFieldAccess{
	var type:GLSLStructDefinition;
	var fields:Map<String, GLSLFieldInstance>;

	public function new(type:GLSLStructDefinition, ?constructionParams:Array<GLSLPrimitiveInstance>){
		this.type = type;

		fields =  new Map<String, GLSLFieldInstance>();

		//create fields
		for(i in 0...type.fields.length){
			var f = type.fields[i];
			var fieldInst = {
				dataType: f.dataType,
				arraySize: f.arraySize,
				value: null
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
		//what happens if not all parameters are set?
		for(i in 0...constructionParams.length){
			var c = constructionParams[i];
			var f = fields.get(fieldName(i));

			//get param dataType
			var dataType:DataType = null;
			switch c {
				case LiteralInstance(_, t) | ComplexInstance(_, t): dataType = t;
			}

			if(dataType.equals(f.dataType)){
				f.value = c;
			}else{
				Eval.error('structure constructor arguments do not match structure fields');
			}
		}
	}
	
	public function accessField(name:String){
		return fields.get(name).value;
	}

	inline function fieldName(i:Int):String{
		return type.fields[i].name;
	}
}