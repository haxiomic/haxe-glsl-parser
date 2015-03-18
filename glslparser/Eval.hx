/*
	#Todo
	- need to account for scoping!
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
	- a VariableDefintion encapsulates a GLSLPrimitiveExpr
*/

package glslparser;

import glslparser.AST;
import haxe.macro.Expr;

class Eval{
	static var builtInConstants:Map<String, GLSLPrimitiveExpr> = [
		'gl_MaxVertexAttribs'             => new GLSLPrimitiveExpr(new Literal<Int>(8, INT)),
		'gl_MaxVertexUniformVectors'      => new GLSLPrimitiveExpr(new Literal<Int>(128, INT)),
		'gl_MaxVaryingVectors'            => new GLSLPrimitiveExpr(new Literal<Int>(8, INT)),
		'gl_MaxVertexTextureImageUnits'   => new GLSLPrimitiveExpr(new Literal<Int>(0, INT)),
		'gl_MaxCombinedTextureImageUnits' => new GLSLPrimitiveExpr(new Literal<Int>(8, INT)),
		'gl_MaxTextureImageUnits'         => new GLSLPrimitiveExpr(new Literal<Int>(8, INT)),
		'gl_MaxFragmentUniformVectors'    => new GLSLPrimitiveExpr(new Literal<Int>(16, INT)),
		'gl_MaxDrawBuffers'               => new GLSLPrimitiveExpr(new Literal<Int>(1, INT))
	];
	static var builtInTypes:Map<DataType, GLSLBuiltInType> = [
		VEC2  => new GLSLBuiltInType(FLOAT, 2),
		VEC3  => new GLSLBuiltInType(FLOAT, 3),
		VEC4  => new GLSLBuiltInType(FLOAT, 4),
		BVEC2 => new GLSLBuiltInType(BOOL, 2),
		BVEC3 => new GLSLBuiltInType(BOOL, 3),
		BVEC4 => new GLSLBuiltInType(BOOL, 4),
		IVEC2 => new GLSLBuiltInType(INT, 2),
		IVEC3 => new GLSLBuiltInType(INT, 3),
		IVEC4 => new GLSLBuiltInType(INT, 4),
		MAT2  => new GLSLBuiltInType(MAT2, 2*2),
		MAT3  => new GLSLBuiltInType(MAT3, 3*3),
		MAT4  => new GLSLBuiltInType(MAT4, 4*4),
	];

	static var userDefinedConstants:Map<String, GLSLPrimitiveExpr>;
	static var userDefinedTypes:Map<DataType, GLSLStructType>;

	static public function evaluateConstantExpressions(ast:Node):Void{
		//init state machine
		userDefinedConstants = new Map<String, GLSLPrimitiveExpr>();
		userDefinedTypes = new Map<DataType, GLSLStructType>();

		iterate(ast);
	}

	static function getConstant(name:String){
		if(userDefinedConstants.exists(name)) return userDefinedConstants.get(name);
		if(builtInConstants.exists(name)) return builtInConstants.get(name);
		return null;
	}

	static function getType(dataType:DataType){
		if(userDefinedTypes.exists(dataType)) return userDefinedTypes.get(dataType);
		// if(builtInTypes.exists(dataType)) return builtInTypes.get(dataType);
		return null;
	}

	static function iterate(node:Dynamic){
		
		switch (Type.getClass(node)) {
			case Array: var _ = cast(node, Array<Dynamic>);
				for(i in 0..._.length) iterate(_[i]);

			case VariableDeclaration: var _ = cast(node, VariableDeclaration);
				iterate(_.typeSpecifier);
				if(_.typeSpecifier.qualifier == CONST){
					for(i in 0..._.declarators.length){
						var initExpr = defineConst(_.declarators[i]);
						if(!initExpr.dataType.equals(_.typeSpecifier.dataType))
							warn('type mismatch'); //#! needs more info, should we even be testing for this here, rather than in a separate validation phase?
					}
				}

			case StructSpecifier: var _ = cast(node, StructSpecifier);
				defineType(_);
				iterate(_.structDeclarations);

			case StructDeclaration: var _ = cast(node, StructDeclaration);
				iterate(_.typeSpecifier);


			default:
				// trace('default case'); //#!
		}

	}

	//collapses constant expression down to singular expression
	static function resolveExpression(expr:Expression):GLSLPrimitiveExpr{
		switch (Type.getClass(expr)) {
			//fully resolved expressions
			case Literal: var _ = cast(expr, Literal<Dynamic>);
				return _;

			case Constructor: var _ = cast(expr, Constructor);
				//resolve parameters
				for(i in 0..._.parameters.length)
					_.parameters[i] = resolveExpression(_.parameters[i]);
				return _;

			// case FunctionCall: var _ = cast(expr, FunctionCall);
				//cannot handle function call

			//not fully resolved
			case Identifier: var _ = cast(expr, Identifier);
				var e = getConstant(_.name);
				if(e == null) warn('${_.name} has not been defined in this scope');
				return resolveExpression(e);

			case BinaryExpression: var _ = cast(expr, BinaryExpression);
				return resolveBinaryExpression(_);

			case UnaryExpression: var _ = cast(expr, UnaryExpression);

			case SequenceExpression: var _ = cast(expr, SequenceExpression);

			case ConditionalExpression: var _ = cast(expr, ConditionalExpression);

			case AssignmentExpression: var _ = cast(expr, AssignmentExpression);
				//#need to resolving the unary left expression as well as the right

			case FieldSelectionExpression: var _ = cast(expr, FieldSelectionExpression);
				// try{
				// 	var left = cast(resolveExpression(_.left), Constructor);
				// 	var typeDefinition = getType(left.dataType);
				// 	return typeDefinition.accessField(_.field.name, left.parameters);
				// }catch(error:Dynamic){
				// 	warn(error);
				// 	warn('could not access field ${_.field.name}'); //#! needs more info
				// }

			case ArrayElementSelectionExpression: var _ = cast(expr, ArrayElementSelectionExpression);
				//in general this can act on any variable including consts but in glsl es it's restricted to complex types
				// try{
				// 	var a = resolveExpression(_.arrayIndexExpression);
				// 	if(a.dataType != INT){
				// 		Eval.warn('array size must an integer expression');
				// 		return null;
				// 	}
				// 	var av = cast(a, Literal<Dynamic>);
				// 	//assume the left expression is a constructor since ES 1.0 does not allow array initialization
				// 	var left = cast(resolveExpression(_.left), Constructor);
				// 	var typeDefinition = builtInTypes.get(left.dataType); //array access is not possible on structs
				// 	return typeDefinition.accessIndex(av.value, left.parameters);
				// }catch(error:Dynamic){
				// 	warn(error);
				// 	warn('array access not possible'); //#! needs more info
				// }

		}

		warn('cannot resolve expression $expr');
		return null;
	}

	static function resolveBinaryExpression(binExpr:BinaryExpression):GLSLPrimitiveExpr{
		var left = resolveExpression(binExpr.left);
		var right = resolveExpression(binExpr.right);
		var op = binExpr.op;

		var leftType:GLSLBasicType = left;
		var rightType:GLSLBasicType = right;

		switch (BinaryOp(leftType, rightType, op)) {
			//STAR
			case BinaryOp(LiteralType(INT, lv), LiteralType(INT, rv), STAR):
				return new Literal<Int>(Math.floor(lv * rv), INT);
			case BinaryOp(LiteralType(FLOAT, lv), LiteralType(FLOAT, rv), STAR):
				return new Literal<Float>(lv * rv, FLOAT);
			//SLASH
			case BinaryOp(LiteralType(INT, lv), LiteralType(INT, rv), SLASH):
				return new Literal<Int>(Math.floor(lv / rv), INT);
			case BinaryOp(LiteralType(FLOAT, lv), LiteralType(FLOAT, rv), SLASH):
				return new Literal<Float>(lv / rv, FLOAT);
			//PERCENT
			case BinaryOp(LiteralType(INT, lv), LiteralType(INT, rv), PERCENT):
				return new Literal<Int>(Math.floor(lv % rv), INT);
			case BinaryOp(LiteralType(FLOAT, lv), LiteralType(FLOAT, rv), PERCENT):
				return new Literal<Float>(Math.floor(lv % rv), FLOAT);
			//PLUS
			case BinaryOp(LiteralType(INT, lv), LiteralType(INT, rv), PLUS):
				return new Literal<Int>(Math.floor(lv + rv), INT);
			case BinaryOp(LiteralType(FLOAT, lv), LiteralType(FLOAT, rv), PLUS):
				return new Literal<Float>(lv + rv, FLOAT);
			//DASH
			case BinaryOp(LiteralType(INT, lv), LiteralType(INT, rv), DASH):
				return new Literal<Int>(Math.floor(lv - rv), INT);
			case BinaryOp(LiteralType(FLOAT, lv), LiteralType(FLOAT, rv), DASH):
				return new Literal<Float>(lv - rv, FLOAT);
			//LEFT_ANGLE
			case BinaryOp(LiteralType(INT, lv), LiteralType(INT, rv), LEFT_ANGLE):
				return new Literal<Bool>(lv < rv, BOOL);
			case BinaryOp(LiteralType(FLOAT, lv), LiteralType(FLOAT, rv), LEFT_ANGLE):
				return new Literal<Bool>(lv < rv, BOOL);
			//RIGHT_ANGLE
			case BinaryOp(LiteralType(INT, lv), LiteralType(INT, rv), RIGHT_ANGLE):
				return new Literal<Bool>(lv > rv, BOOL);
			case BinaryOp(LiteralType(FLOAT, lv), LiteralType(FLOAT, rv), RIGHT_ANGLE):
				return new Literal<Bool>(lv > rv, BOOL);
			//LE_OP
			case BinaryOp(LiteralType(INT, lv), LiteralType(INT, rv), LE_OP):
				return new Literal<Bool>(lv <= rv, BOOL);
			case BinaryOp(LiteralType(FLOAT, lv), LiteralType(FLOAT, rv), LE_OP):
				return new Literal<Bool>(lv <= rv, BOOL);
			//GE_OP
			case BinaryOp(LiteralType(INT, lv), LiteralType(INT, rv), GE_OP):
				return new Literal<Bool>(lv >= rv, BOOL);
			case BinaryOp(LiteralType(FLOAT, lv), LiteralType(FLOAT, rv), GE_OP):
				return new Literal<Bool>(lv >= rv, BOOL);
			//EQ_OP
			case BinaryOp(LiteralType(INT, lv), LiteralType(INT, rv), EQ_OP):
				return new Literal<Bool>(lv == rv, BOOL);
			case BinaryOp(LiteralType(FLOAT, lv), LiteralType(FLOAT, rv), EQ_OP):
				return new Literal<Bool>(lv == rv, BOOL);
			case BinaryOp(LiteralType(BOOL, lv), LiteralType(BOOL, rv), EQ_OP):
				return new Literal<Bool>(lv == rv, BOOL);
			//NE_OP
			case BinaryOp(LiteralType(INT, lv), LiteralType(INT, rv), NE_OP):
				return new Literal<Bool>(lv != rv, BOOL);
			case BinaryOp(LiteralType(FLOAT, lv), LiteralType(FLOAT, rv), NE_OP):
				return new Literal<Bool>(lv != rv, BOOL);
			//LEFT_OP
			case BinaryOp(LiteralType(INT, lv), LiteralType(INT, rv), LEFT_OP):
				return new Literal<Int>(Math.floor(lv << rv), INT);
			//RIGHT_OP
			case BinaryOp(LiteralType(INT, lv), LiteralType(INT, rv), RIGHT_OP):
				return new Literal<Int>(Math.floor(lv >> rv), INT);
			//AMPERSAND
			case BinaryOp(LiteralType(INT, lv), LiteralType(INT, rv), AMPERSAND):
				return new Literal<Int>(Math.floor(lv & rv), INT);
			//CARET
			case BinaryOp(LiteralType(INT, lv), LiteralType(INT, rv), CARET):
				return new Literal<Int>(Math.floor(lv ^ rv), INT);
			//VERTICAL_BAR
			case BinaryOp(LiteralType(INT, lv), LiteralType(INT, rv), VERTICAL_BAR):
				return new Literal<Int>(Math.floor(lv | rv), INT);
			//AND_OP
			case BinaryOp(LiteralType(BOOL, lv), LiteralType(BOOL, rv), AND_OP):
				return new Literal<Bool>(lv && rv, BOOL);
			//XOR_OP
			case BinaryOp(LiteralType(BOOL, lv), LiteralType(BOOL, rv), XOR_OP):
				return new Literal<Bool>(!lv != !rv, BOOL);
			//OR_OP
			case BinaryOp(LiteralType(BOOL, lv), LiteralType(BOOL, rv), OR_OP):
				return new Literal<Bool>(lv || rv, BOOL);
			default:
		}

		warn('could not resolve binary expression $left $op $rightType'); //#! needs improving
		return null;
	}

	static function resolveUnaryExpression(unExpr:UnaryExpression):GLSLPrimitiveExpr{
		var arg = resolveExpression(unExpr.arg);
		var op = unExpr.op;

		var argType:GLSLBasicType = arg;

		// switch (UnaryOp(argType, unExpr.op, unExpr.isPrefix)) {
		// 	case UnaryOp(INT, INC_OP, isPrefix):
		// 		// alter arg?
		// 		// return new Literal<Int>(r, INT);

		// }

		warn('could not resolve unary expression $unExpr'); //#! needs improving
		return null;
	}

	static function defineType(specifier:StructSpecifier){
		userDefinedTypes.set(DataType.USER_TYPE(specifier.name), GLSLStructType.fromStructSpecifier(specifier));
		// trace('defining user type ${specifier.name}');
	}

	static function defineConst(declarator:Declarator){
		var resolvedExpr = resolveExpression(declarator.initializer);
		declarator.initializer = resolvedExpr;
		userDefinedConstants.set(declarator.name, resolvedExpr);
		// trace('defining const ${declarator.name} as $resolvedExpr');
		return resolvedExpr;
	}

	//Error Reporting
	static function warn(msg){
		trace('Eval warning: $msg');
	}

	static function error(msg){
		throw 'Eval error: $msg';
	}
}

enum OperationType{
	BinaryOp(l:GLSLBasicType, r:GLSLBasicType, op:BinaryOperator);
	UnaryOp(arg:GLSLBasicType, op:UnaryOperator, isPrefix:Bool);
}
 
enum GLSLBasicType{
	LiteralType(t:DataType, v:Dynamic);
	ConstructorType;
}


//A primitive expression is an expression that can be no resolved no further
//eg: an int, bool, float or a complex type constructor
@:access(glslparser.Eval)
abstract GLSLPrimitiveExpr(Expression) to Expression{
	public var dataType(get, never):DataType;

	public inline function new(expr:Expression){
		if(!isFullyResolved(expr))
			Eval.error('cannot create GLSLPrimitiveExpr; expression is not fully resolved. $expr');

		this = cast expr;
	}

	function get_dataType():DataType return cast(this, TypedExpression).dataType;

	static function isFullyResolved(expr:Expression):Bool{
		switch (Type.getClass(expr)) {
			case Literal: return true;
			case Constructor: var _ = cast(expr, Constructor);
				for(p in _.parameters){ //ensure parameters are resolved 
					if(!isFullyResolved(p)) return false;
				}
				return true;
		}

		return false;
	}

	@:to function toGLSLBasicType():GLSLBasicType{
		if(Type.getClass(this) == Literal){
			var _ = cast(this, Literal<Dynamic>);
			return LiteralType(_.dataType, _.value);
		}else if(Type.getClass(this) == Constructor){
			var _ = cast(this, Constructor);
			Eval.error('FunctionCallType not supported yet');
			return ConstructorType;
		}

		Eval.error('unrecognized GLSLPrimitiveExpr: $this');
		return null;
	}

	@:from static function fromExpression(expr:Expression) return new GLSLPrimitiveExpr(expr);
}

typedef GLSLFieldDefinition = {
	var dataType:DataType;
	var name:String;
	@:optional var arraySize:Int;
}

typedef GLSLFieldInstance = {
	var dataType:DataType;
	var value:GLSLPrimitiveExpr;
	@:optional var arraySize:Int;
}

interface GLSLFieldAccess{
	public function accessField(name:String):GLSLPrimitiveExpr;
}

interface GLSLArrayAccess{
	public function accessIndex(i:Int):GLSLPrimitiveExpr;
}

@:access(glslparser.Eval)
class GLSLStructType{
	public var fields:Array<GLSLFieldDefinition>;

	public function new(fields:Array<GLSLFieldDefinition>){
		this.fields = fields;
	}

	public function createInstance(?constructionParams:Array<Expression>):GLSLStructInstance{
		return new GLSLStructInstance(this, constructionParams);
	}

	static public function fromStructSpecifier(specifier:StructSpecifier){
		//convert declarations to fields
		var fields = new Array<GLSLFieldDefinition>();
		for(i in 0...specifier.structDeclarations.length){
			var d = specifier.structDeclarations[i];
			var type = d.typeSpecifier.dataType;
			for(j in 0...d.declarators.length){
				var dr = d.declarators[j];

				var field:GLSLFieldDefinition = {dataType: type, name: dr.name};

				if(Type.getClass(dr) == StructArrayDeclarator){
					//resolve array expression
					var basicArrayExpr = Eval.resolveExpression(cast(dr, StructArrayDeclarator).arraySizeExpression);
					if(!basicArrayExpr.dataType.equals(DataType.INT))
						Eval.error('array size must an integer expression');
						
					field.arraySize = cast(basicArrayExpr, Literal<Dynamic>).value;
				}

				fields.push(field);
			}
		}

		return new GLSLStructType(fields);
	}
}

class GLSLBuiltInType {
	var fieldsType:DataType;
	var fieldsCount:Int;

	public function new(fieldsType:DataType, fieldsCount:Int){
		this.fieldsType = fieldsType;
		this.fieldsCount = fieldsCount;
	}
}



@:access(glslparser.Eval)
class GLSLStructInstance implements GLSLFieldAccess{
	var type:GLSLStructType;
	var fields:Map<String, GLSLFieldInstance>;

	public function new(type:GLSLStructType, ?constructionParams:Array<Expression>){
		this.type = type;

		//create fields
		for(i in 0...type.fields.length){
			var f = type.fields[i];
			fields.set(f.name, {
				dataType: f.dataType,
				arraySize: f.arraySize,
				value: null
			});
		}

		if(constructionParams != null)
			construct(constructionParams);
	}

	public function construct(constructionParams:Array<Expression>){
		//fuzzy typing
		//what happens if not all parameters are set?
	}
	
	public function accessField(name:String){
		return fields.get(name).value;
	}
}


@:access(glslparser.Eval)
class GLSLBuiltInInstance implements GLSLFieldAccess implements GLSLArrayAccess{
	public function accessField(string:String){
		//{x, y, z, w}
		//{r, g, b, a}
		//{s, t, p, q}
		//No more than 4 components can be selected.

		//need to create a construction routine to handle filling the type from the construction params,
		//must be able to deal with constructions like
		//mat3 m3x3 = mat3(m2x2);
		return null;
	}

	public function accessIndex(i:Int):GLSLPrimitiveExpr{
		//return rows for mat and fields for vec
		return null;
	}
}