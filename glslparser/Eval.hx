/*
	#! need to account for scoping!
	#! create Constructor class

	#Expressions
	Literal
	FunctionCall

	Identifier
	BinaryExpression
	UnaryExpression
	SequenceExpression
	ConditionalExpression
	AssignmentExpression
	FieldSelectionExpression
*/

package glslparser;

import glslparser.AST;
import haxe.macro.Expr;

class Eval {
	static var builtInConstants:Map<String, GLSLBasicExpr> = [
		'gl_MaxVertexAttribs'             => new GLSLBasicExpr(new Literal<Int>(8, INT)),
		'gl_MaxVertexUniformVectors'      => new GLSLBasicExpr(new Literal<Int>(128, INT)),
		'gl_MaxVaryingVectors'            => new GLSLBasicExpr(new Literal<Int>(8, INT)),
		'gl_MaxVertexTextureImageUnits'   => new GLSLBasicExpr(new Literal<Int>(0, INT)),
		'gl_MaxCombinedTextureImageUnits' => new GLSLBasicExpr(new Literal<Int>(8, INT)),
		'gl_MaxTextureImageUnits'         => new GLSLBasicExpr(new Literal<Int>(8, INT)),
		'gl_MaxFragmentUniformVectors'    => new GLSLBasicExpr(new Literal<Int>(16, INT)),
		'gl_MaxDrawBuffers'               => new GLSLBasicExpr(new Literal<Int>(1, INT))
	];
	static var builtInTypes:Map<TypeClass, GLSLCompositeType>;

	static var userDefinedConstants:Map<String, GLSLBasicExpr>;
	static var userDefinedTypes:Map<TypeClass, GLSLCompositeType>;

	static public function evaluateConstantExpressions(ast:Node):Void{
		//init state machine
		userDefinedConstants = new Map<String, GLSLBasicExpr>();
		userDefinedTypes = new Map<TypeClass, GLSLCompositeType>();

		iterate(ast);
	}

	static function getConstant(name:String){
		if(userDefinedConstants.exists(name)) return userDefinedConstants.get(name);
		if(builtInConstants.exists(name)) return builtInConstants.get(name);
		return null;
	}

	static function getType(typeClass:TypeClass){
		if(userDefinedTypes.exists(typeClass)) return userDefinedTypes.get(typeClass);
		if(builtInTypes.exists(typeClass)) return builtInTypes.get(typeClass);
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
						if(!initExpr.typeClass.equals(_.typeSpecifier.typeClass))
							error('type mismatch'); //#! needs more info, should we even be testing for this here, rather than in a separate validation phase?
					}
				}

			case StructSpecifier: var _ = cast(node, StructSpecifier);
				defineType(_);
				iterate(_.structDeclarations);

			case StructDeclaration: var _ = cast(node, StructDeclaration);
				iterate(_.typeSpecifier);


			default:
				trace('default case');
		}

	}

	//collapses constant expression down to singular expression
	static function resolveExpression(expr:Expression):GLSLBasicExpr{
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

			case FieldSelectionExpression: var _ = cast(expr, FieldSelectionExpression);
				try{
					var e = cast(resolveExpression(_.left), Constructor);
					var typeDefinition = userDefinedTypes.get(e.typeClass);
					return typeDefinition.accessField(_.field.name, e.parameters);
				}catch(error:Dynamic){
					warn('could not access field ${_.field.name}'); //#! needs more info
				}

		}

		error('cannot resolve expression $expr');
		return null;
	}

	static function resolveBinaryExpression(binExpr:BinaryExpression):GLSLBasicExpr{
		var left = resolveExpression(binExpr.left);
		var right = resolveExpression(binExpr.right);
		var op = binExpr.op;

		var leftType:GLSLBasicType = left;
		var rightType:GLSLBasicType = right;

		switch (BinaryOp(leftType, rightType, op)) {
			//STAR
			case BinaryOp(LiteralType(INT, lv), LiteralType(INT, rv), STAR):
				var r:Int = Math.floor(lv * rv);
				return new Literal<Int>(r, INT);
			case BinaryOp(LiteralType(FLOAT, lv), LiteralType(FLOAT, rv), STAR):
				var r:Float = lv * rv;
				return new Literal<Float>(r, FLOAT);
			//SLASH
			case BinaryOp(LiteralType(INT, lv), LiteralType(INT, rv), SLASH):
				var r:Int = Math.floor(lv / rv);
				return new Literal<Int>(r, INT);
			case BinaryOp(LiteralType(FLOAT, lv), LiteralType(FLOAT, rv), SLASH):
				var r:Float = lv / rv;
				return new Literal<Float>(r, FLOAT);
			//PERCENT
			case BinaryOp(LiteralType(INT, lv), LiteralType(INT, rv), PERCENT):
				var r:Int = Math.floor(lv % rv);
				return new Literal<Int>(r, INT);
			case BinaryOp(LiteralType(FLOAT, lv), LiteralType(FLOAT, rv), PERCENT):
				var r:Float = Math.floor(lv % rv);
				return new Literal<Float>(r, FLOAT);
			//PLUS
			case BinaryOp(LiteralType(INT, lv), LiteralType(INT, rv), PLUS):
				var r:Int = Math.floor(lv + rv);
				return new Literal<Int>(r, INT);
			case BinaryOp(LiteralType(FLOAT, lv), LiteralType(FLOAT, rv), PLUS):
				var r:Float = lv + rv;
				return new Literal<Float>(r, FLOAT);
			//DASH
			case BinaryOp(LiteralType(INT, lv), LiteralType(INT, rv), DASH):
				var r:Int = Math.floor(lv - rv);
				return new Literal<Int>(r, INT);
			case BinaryOp(LiteralType(FLOAT, lv), LiteralType(FLOAT, rv), DASH):
				var r:Float = lv - rv;
				return new Literal<Float>(r, FLOAT);
			//LEFT_ANGLE
			case BinaryOp(LiteralType(INT, lv), LiteralType(INT, rv), LEFT_ANGLE):
				var r:Bool = lv < rv;
				return new Literal<Bool>(r, BOOL);
			case BinaryOp(LiteralType(FLOAT, lv), LiteralType(FLOAT, rv), LEFT_ANGLE):
				var r:Bool = lv < rv;
				return new Literal<Bool>(r, BOOL);
			//RIGHT_ANGLE
			case BinaryOp(LiteralType(INT, lv), LiteralType(INT, rv), RIGHT_ANGLE):
				var r:Bool = lv > rv;
				return new Literal<Bool>(r, BOOL);
			case BinaryOp(LiteralType(FLOAT, lv), LiteralType(FLOAT, rv), RIGHT_ANGLE):
				var r:Bool = lv > rv;
				return new Literal<Bool>(r, BOOL);
			//LE_OP
			case BinaryOp(LiteralType(INT, lv), LiteralType(INT, rv), LE_OP):
				var r:Bool = lv <= rv;
				return new Literal<Bool>(r, BOOL);
			case BinaryOp(LiteralType(FLOAT, lv), LiteralType(FLOAT, rv), LE_OP):
				var r:Bool = lv <= rv;
				return new Literal<Bool>(r, BOOL);
			//GE_OP
			case BinaryOp(LiteralType(INT, lv), LiteralType(INT, rv), GE_OP):
				var r:Bool = lv >= rv;
				return new Literal<Bool>(r, BOOL);
			case BinaryOp(LiteralType(FLOAT, lv), LiteralType(FLOAT, rv), GE_OP):
				var r:Bool = lv >= rv;
				return new Literal<Bool>(r, BOOL);
			//EQ_OP
			case BinaryOp(LiteralType(INT, lv), LiteralType(INT, rv), EQ_OP):
				var r:Bool = lv == rv;
				return new Literal<Bool>(r, BOOL);
			case BinaryOp(LiteralType(FLOAT, lv), LiteralType(FLOAT, rv), EQ_OP):
				var r:Bool = lv == rv;
				return new Literal<Bool>(r, BOOL);
			case BinaryOp(LiteralType(BOOL, lv), LiteralType(BOOL, rv), EQ_OP):
				var r:Bool = lv == rv;
				return new Literal<Bool>(r, BOOL);
			//NE_OP
			case BinaryOp(LiteralType(INT, lv), LiteralType(INT, rv), NE_OP):
				var r:Bool = lv != rv;
				return new Literal<Bool>(r, BOOL);
			case BinaryOp(LiteralType(FLOAT, lv), LiteralType(FLOAT, rv), NE_OP):
				var r:Bool = lv != rv;
				return new Literal<Bool>(r, BOOL);
			//LEFT_OP
			case BinaryOp(LiteralType(INT, lv), LiteralType(INT, rv), LEFT_OP):
				var r:Int = Math.floor(lv << rv);
				return new Literal<Int>(r, INT);
			//RIGHT_OP
			case BinaryOp(LiteralType(INT, lv), LiteralType(INT, rv), RIGHT_OP):
				var r:Int = Math.floor(lv >> rv);
				return new Literal<Int>(r, INT);
			//AMPERSAND
			case BinaryOp(LiteralType(INT, lv), LiteralType(INT, rv), AMPERSAND):
				var r:Int = Math.floor(lv & rv);
				return new Literal<Int>(r, INT);
			//CARET
			case BinaryOp(LiteralType(INT, lv), LiteralType(INT, rv), CARET):
				var r:Int = Math.floor(lv ^ rv);
				return new Literal<Int>(r, INT);
			//VERTICAL_BAR
			case BinaryOp(LiteralType(INT, lv), LiteralType(INT, rv), VERTICAL_BAR):
				var r:Int = Math.floor(lv | rv);
				return new Literal<Int>(r, INT);
			//AND_OP
			case BinaryOp(LiteralType(BOOL, lv), LiteralType(BOOL, rv), AND_OP):
				var r:Bool = lv && rv;
				return new Literal<Bool>(r, BOOL);
			//XOR_OP
			case BinaryOp(LiteralType(BOOL, lv), LiteralType(BOOL, rv), XOR_OP):
				var r:Bool = !lv != !rv;
				return new Literal<Bool>(r, BOOL);
			//OR_OP
			case BinaryOp(LiteralType(BOOL, lv), LiteralType(BOOL, rv), OR_OP):
				var r:Bool = lv || rv;
				return new Literal<Bool>(r, BOOL);
			default:
		}

		error('could not resolve binary expression $left $op $rightType'); //#! needs improving
		return null;
	}

	static function resolveUnaryExpression(unExpr:UnaryExpression):GLSLBasicExpr{
		var arg = resolveExpression(unExpr.arg);
		var op = unExpr.op;

		var argType:GLSLBasicType = arg;

		// switch (UnaryOp(argType, unExpr.op, unExpr.isPrefix)) {
		// 	case UnaryOp(INT, INC_OP, isPrefix):
		// 		// alter arg?
		// 		// return new Literal<Int>(r, INT);

		// }

		error('could not resolve unary expression $unExpr'); //#! needs improving
		return null;
	}

	static function defineType(specifier:StructSpecifier){
		userDefinedTypes.set(TypeClass.USER_TYPE(specifier.name), GLSLCompositeType.fromStructSpecifier(specifier));
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
	LiteralType(t:TypeClass, v:Dynamic);
	ConstructorType;
}

@:access(glslparser.Eval)
abstract GLSLBasicExpr(Expression) to Expression{
	public var typeClass(get, never):TypeClass;

	public inline function new(expr:Expression){
		if(!isFullyResolved(expr))
			Eval.error('cannot create GLSLBasicExpr; expression is not fully resolved. $expr');

		this = cast expr;
	}

	function get_typeClass():TypeClass return cast(this, TypedExpression).typeClass;

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
			return LiteralType(_.typeClass, _.value);
		}else if(Type.getClass(this) == Constructor){
			var _ = cast(this, Constructor);
			Eval.error('FunctionCallType not supported yet');
			return ConstructorType;
		}

		Eval.error('unrecognized GLSLBasicExpr: $this');
		return null;
	}

	@:from static function fromExpression(expr:Expression) return new GLSLBasicExpr(expr);
}

typedef GLSLTypeField = {
	var typeClass:TypeClass;
	var name:String;
	@:optional var arraySize:Int;
}

@:access(glslparser.Eval)
class GLSLCompositeType{
	var fields:Array<GLSLTypeField>;
	var supportsSwizzling:Bool;

	public function new(fields:Array<GLSLTypeField>, supportsSwizzling:Bool = false){
		this.fields = fields;
		this.supportsSwizzling = supportsSwizzling;
	}

	public function accessField(name:String, params:Array<Expression>){
		var paramIndex = -1;
		for(i in 0...fields.length){
			if(fields[i].name == name){
				paramIndex = i;
				break;
			}
		}

		if(paramIndex == -1){
			Eval.warn('could not access field name $name'); //#! needs more info
			return null;
		}
		return params[paramIndex];
	}

	static public function fromStructSpecifier(specifier:StructSpecifier){
		//convert declarations to fields
		var fields = new Array<GLSLTypeField>();
		for(i in 0...specifier.structDeclarations.length){
			var d = specifier.structDeclarations[i];
			var type = d.typeSpecifier.typeClass;
			for(j in 0...d.declarators.length){
				var dr = d.declarators[j];

				var field:GLSLTypeField = {typeClass: type, name: dr.name};

				if(Type.getClass(dr) == StructArrayDeclarator){
					//resolve array expression
					var basicArrayExpr = Eval.resolveExpression(cast(dr, StructArrayDeclarator).arraySizeExpression);
					if(!basicArrayExpr.typeClass.equals(TypeClass.INT))
						Eval.error('array size must an integer expression');

					field.arraySize = cast(basicArrayExpr, Literal<Dynamic>).value;
				}

				fields.push(field);
			}
		}

		return new GLSLCompositeType(fields);
	}
}

class GLSLCompositeTypeInstance{}

class GLSLBuiltInType extends GLSLCompositeType{} //#! maybe