/*
	GLSL Eval

	- Eval's purpose is to evaluate an expression and return a Primitive
	- Eval should never modify the ast
	- For now, Eval supports only constant expressions in the global scope

	@author George Corney

	#Todo
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
*/

package glslparser;

import glslparser.AST;
using AST.TypeEnumHelper;

class Eval{
	static public var builtInVariables:Map<String, GLSLVariableDeclaration> = [
		'gl_MaxVertexAttribs'             => createBuiltInConst('gl_MaxVertexAttribs', 8),
		'gl_MaxVertexUniformVectors'      => createBuiltInConst('gl_MaxVertexUniformVectors', 128),
		'gl_MaxVaryingVectors'            => createBuiltInConst('gl_MaxVaryingVectors', 8),
		'gl_MaxVertexTextureImageUnits'   => createBuiltInConst('gl_MaxVertexTextureImageUnits', 0),
		'gl_MaxCombinedTextureImageUnits' => createBuiltInConst('gl_MaxCombinedTextureImageUnits', 8),
		'gl_MaxTextureImageUnits'         => createBuiltInConst('gl_MaxTextureImageUnits', 8),
		'gl_MaxFragmentUniformVectors'    => createBuiltInConst('gl_MaxFragmentUniformVectors', 16),
		'gl_MaxDrawBuffers'               => createBuiltInConst('gl_MaxDrawBuffers', 1)
	];

	static public var userDefinedVariables:Map<String, GLSLVariableDeclaration> = new Map<String, GLSLVariableDeclaration>();
	static public var userDefinedTypes:Map<DataType, GLSLStructDefinition> = new Map<DataType, GLSLStructDefinition>();

	static public var warnings:Array<String> = new Array<String>();

	static public function evaluateConstantExpr(expr:Expression):GLSLPrimitiveInstance{
		switch (expr.toTypeEnum()) {
			case LiteralNode(n): return LiteralInstance(n.value, n.dataType);
			case ConstructorNode(n):
			 	//#! construct instance
			case IdentifierNode(n):
			case BinaryExpressionNode(n):
			case UnaryExpressionNode(n):
			case SequenceExpressionNode(n):
			case ConditionalExpressionNode(n):
			case AssignmentExpressionNode(n):
			case FieldSelectionExpressionNode(n):
			case ArrayElementSelectionExpressionNode(n):
			default:
		}

		warn('cannot resolve expression $expr');
		return null;
	}

	static public function defineUserType(specifier:StructSpecifier){
		var userType = GLSLStructDefinition.fromStructSpecifier(specifier);
		userDefinedTypes.set(DataType.USER_TYPE(specifier.name), userType);
		return userType;
	}

	static public function reset(){
		warnings = new Array<String>();
	}

	static function createBuiltInConst(name:String, value:Dynamic):GLSLVariableDeclaration{
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
		warnings.push('Eval warning: $msg');
	}

	static function error(msg){
		throw 'Eval error: $msg';
	}
}

enum GLSLPrimitiveInstance{
	LiteralInstance(v:Dynamic, t:DataType);
	// ComplexInstance(instance:GLSLInstance);
}

typedef GLSLVariableDeclaration = {
	var name:String;
	var value:GLSLPrimitiveInstance;
	var dataType:DataType;
	var qualifier:TypeQualifier;
	var precision:PrecisionQualifier;
	var invariant:Bool;
	@:optional var arraySize:Int;
}

//Definitions
typedef GLSLFieldDefinition = {
	var dataType:DataType;
	var name:String;
	@:optional var arraySize:Int;
}

@:access(glslparser.Eval)
class GLSLStructDefinition{
	public var name:String;
	public var fields:Array<GLSLFieldDefinition>;

	public function new(name:String, fields:Array<GLSLFieldDefinition>){
		this.name = name;
		this.fields = fields;
	}

	public function createInstance(?constructionParams:Array<GLSLPrimitiveInstance>):GLSLStructInstance{
		return new GLSLStructInstance(this, constructionParams);
	}

	static public function fromStructSpecifier(specifier:StructSpecifier){
		//convert declarations to fields
		var fields = new Array<GLSLFieldDefinition>();

		//create field definitions in order
		for(i in 0...specifier.structDeclarations.length){
			var d = specifier.structDeclarations[i];
			var type = d.typeSpecifier.dataType;
			for(j in 0...d.declarators.length){
				var dr = d.declarators[j];

				var field:GLSLFieldDefinition = {dataType: type, name: dr.name};

				//add arraySize field if the declarator defines it
				switch dr.toTypeEnum(){
					case StructArrayDeclaratorNode(n):
						//resolve array expression
						var arraySizePrimitive = Eval.evaluateConstantExpr(n.arraySizeExpression);
						switch arraySizePrimitive{
							case LiteralInstance(v, INT):
								field.arraySize = v;
							default:
								Eval.error('array size must an integer expression');
						}
					default:
				}

				fields.push(field);
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

class GLSLInstance{}

@:access(glslparser.Eval)
class GLSLStructInstance extends GLSLInstance implements GLSLFieldAccess{
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
		//fuzzy typing
		//what happens if not all parameters are set?
		for(i in 0...constructionParams.length){
			var c = constructionParams[i];
			var f = fields.get(fieldName(i));
			//#!
		}
	}
	
	public function accessField(name:String){
		return fields.get(name).value;
	}

	inline function fieldName(i:Int):String{
		return type.fields[i].name;
	}
}