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

	static var variables:Map<String, GLSLBasicExpr>;

	static public function evaluateConstantExpressions(ast:Node):Void{
		variables = new Map<String, GLSLBasicExpr>();
		iterate(ast);
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
						if(initExpr.typeName != _.typeSpecifier.typeName)
							error('type mismatch'); //#! needs more info
					}

					//#! ensure the type is correct
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

			case FunctionCall: var _ = cast(expr, FunctionCall);
				//cannot handle function call

			//not fully resolved
			case Identifier: var _ = cast(expr, Identifier);
				var e = variables.get(_.name);
				if(e == null) warn('${_.name} has not been defined in this scope');
				return resolveExpression(e);

			case BinaryExpression: var _ = cast(expr, BinaryExpression);
				return resolveBinaryExpression(_);

			case UnaryExpression: var _ = cast(expr, UnaryExpression);

			case SequenceExpression: var _ = cast(expr, SequenceExpression);

			case ConditionalExpression: var _ = cast(expr, ConditionalExpression);

			case AssignmentExpression: var _ = cast(expr, AssignmentExpression);

			case FieldSelectionExpression: var _ = cast(expr, FieldSelectionExpression);

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
				return new Literal(r, glslIntString(r), INT);
			case BinaryOp(LiteralType(FLOAT, lv), LiteralType(FLOAT, rv), STAR):
				var r:Float = lv * rv;
				return new Literal(r, glslFloatString(r), FLOAT);
			//SLASH
			case BinaryOp(LiteralType(INT, lv), LiteralType(INT, rv), SLASH):
				var r:Int = Math.floor(lv / rv);
				return new Literal(r, glslIntString(r), INT);
			case BinaryOp(LiteralType(FLOAT, lv), LiteralType(FLOAT, rv), SLASH):
				var r:Float = lv / rv;
				return new Literal(r, glslFloatString(r), FLOAT);
			//PERCENT
			case BinaryOp(LiteralType(INT, lv), LiteralType(INT, rv), PERCENT):
				var r:Int = Math.floor(lv % rv);
				return new Literal(r, glslIntString(r), INT);
			case BinaryOp(LiteralType(FLOAT, lv), LiteralType(FLOAT, rv), PERCENT):
				var r:Float = Math.floor(lv % rv);
				return new Literal(r, glslFloatString(r), FLOAT);
			//PLUS
			case BinaryOp(LiteralType(INT, lv), LiteralType(INT, rv), PLUS):
				var r:Int = Math.floor(lv + rv);
				return new Literal(r, glslIntString(r), INT);
			case BinaryOp(LiteralType(FLOAT, lv), LiteralType(FLOAT, rv), PLUS):
				var r:Float = lv + rv;
				return new Literal(r, glslFloatString(r), FLOAT);
			//DASH
			case BinaryOp(LiteralType(INT, lv), LiteralType(INT, rv), DASH):
				var r:Int = Math.floor(lv - rv);
				return new Literal(r, glslIntString(r), INT);
			case BinaryOp(LiteralType(FLOAT, lv), LiteralType(FLOAT, rv), DASH):
				var r:Float = lv - rv;
				return new Literal(r, glslFloatString(r), FLOAT);
			//LEFT_ANGLE
			case BinaryOp(LiteralType(INT, lv), LiteralType(INT, rv), LEFT_ANGLE):
				var r:Bool = lv < rv;
				return new Literal(r, glslBoolString(r), BOOL);
			case BinaryOp(LiteralType(FLOAT, lv), LiteralType(FLOAT, rv), LEFT_ANGLE):
				var r:Bool = lv < rv;
				return new Literal(r, glslBoolString(r), BOOL);
			//RIGHT_ANGLE
			case BinaryOp(LiteralType(INT, lv), LiteralType(INT, rv), RIGHT_ANGLE):
				var r:Bool = lv > rv;
				return new Literal(r, glslBoolString(r), BOOL);
			case BinaryOp(LiteralType(FLOAT, lv), LiteralType(FLOAT, rv), RIGHT_ANGLE):
				var r:Bool = lv > rv;
				return new Literal(r, glslBoolString(r), BOOL);
			//LE_OP
			case BinaryOp(LiteralType(INT, lv), LiteralType(INT, rv), LE_OP):
				var r:Bool = lv <= rv;
				return new Literal(r, glslBoolString(r), BOOL);
			case BinaryOp(LiteralType(FLOAT, lv), LiteralType(FLOAT, rv), LE_OP):
				var r:Bool = lv <= rv;
				return new Literal(r, glslBoolString(r), BOOL);
			//GE_OP
			case BinaryOp(LiteralType(INT, lv), LiteralType(INT, rv), GE_OP):
				var r:Bool = lv >= rv;
				return new Literal(r, glslBoolString(r), BOOL);
			case BinaryOp(LiteralType(FLOAT, lv), LiteralType(FLOAT, rv), GE_OP):
				var r:Bool = lv >= rv;
				return new Literal(r, glslBoolString(r), BOOL);
			//EQ_OP
			case BinaryOp(LiteralType(INT, lv), LiteralType(INT, rv), EQ_OP):
				var r:Bool = lv == rv;
				return new Literal(r, glslBoolString(r), BOOL);
			case BinaryOp(LiteralType(FLOAT, lv), LiteralType(FLOAT, rv), EQ_OP):
				var r:Bool = lv == rv;
				return new Literal(r, glslBoolString(r), BOOL);
			case BinaryOp(LiteralType(BOOL, lv), LiteralType(BOOL, rv), EQ_OP):
				var r:Bool = lv == rv;
				return new Literal(r, glslBoolString(r), BOOL);
			//NE_OP
			case BinaryOp(LiteralType(INT, lv), LiteralType(INT, rv), NE_OP):
				var r:Bool = lv != rv;
				return new Literal(r, glslBoolString(r), BOOL);
			case BinaryOp(LiteralType(FLOAT, lv), LiteralType(FLOAT, rv), NE_OP):
				var r:Bool = lv != rv;
				return new Literal(r, glslBoolString(r), BOOL);
			//LEFT_OP
			case BinaryOp(LiteralType(INT, lv), LiteralType(INT, rv), LEFT_OP):
				var r:Int = Math.floor(lv << rv);
				return new Literal(r, glslIntString(r), INT);
			//RIGHT_OP
			case BinaryOp(LiteralType(INT, lv), LiteralType(INT, rv), RIGHT_OP):
				var r:Int = Math.floor(lv >> rv);
				return new Literal(r, glslIntString(r), INT);
			//AMPERSAND
			case BinaryOp(LiteralType(INT, lv), LiteralType(INT, rv), AMPERSAND):
				var r:Int = Math.floor(lv & rv);
				return new Literal(r, glslIntString(r), INT);
			//CARET
			case BinaryOp(LiteralType(INT, lv), LiteralType(INT, rv), CARET):
				var r:Int = Math.floor(lv ^ rv);
				return new Literal(r, glslIntString(r), INT);
			//VERTICAL_BAR
			case BinaryOp(LiteralType(INT, lv), LiteralType(INT, rv), VERTICAL_BAR):
				var r:Int = Math.floor(lv | rv);
				return new Literal(r, glslIntString(r), INT);
			//AND_OP
			case BinaryOp(LiteralType(BOOL, lv), LiteralType(BOOL, rv), AND_OP):
				var r:Bool = lv && rv;
				return new Literal(r, glslBoolString(r), BOOL);
			//XOR_OP
			case BinaryOp(LiteralType(BOOL, lv), LiteralType(BOOL, rv), XOR_OP):
				var r:Bool = !lv != !rv;
				return new Literal(r, glslBoolString(r), BOOL);
			//OR_OP
			case BinaryOp(LiteralType(BOOL, lv), LiteralType(BOOL, rv), OR_OP):
				var r:Bool = lv || rv;
				return new Literal(r, glslBoolString(r), BOOL);
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
		// 		// return new Literal(r, glslBoolString(r), INT);

		// }

		error('could not resolve unary expression $unExpr'); //#! needs improving
		return null;
	}

	static function defineType(specifier:StructSpecifier){
		trace('#! define type $specifier');
	}

	static function defineConst(declarator:Declarator){
		var resolvedExpr = resolveExpression(declarator.initializer);
		variables.set(declarator.name, resolvedExpr);
		trace('defining const ${declarator.name} as $resolvedExpr');
		return resolvedExpr;
	}

	//Utils
	static function glslFloatString(f:Float){ //enforce decimal point
		var str = Std.string(f);
		var rx = ~/\./g;
		if(!rx.match(str)) str += '.0';
		return str;
	}

	static function glslIntString(i:Int){ //enforce no decimal point
		var str = Std.string(i);
		var rx = ~/(\d+)\./g;
		if(rx.match(str))str = rx.matched(1);
		if(str == "") str = "0";
		return str;
	}

	static function glslBoolString(b:Bool){
		return Std.string(b);
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
@:forward
abstract GLSLBasicExpr(TypedExpression) to Expression{
	public var typeName(get, never):String;

	public inline function new(expr:Expression){
		if(!isFullyResolved(expr) || !Std.is(expr, TypedExpression))
			Eval.error('cannot create GLSLBasicExpr; expression is not fully resolved. $expr');

		this = cast expr;
	}

	function get_typeName():String{
		if(this.typeClass != USER_TYPE)
			return this.typeClass.getName().toLowerCase();
		else return cast(this, Constructor).name;
	}

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

class GLSLCompositeType {
	var fields:Array<Dynamic>; //#! array of {name, type}

	public function new(){}

	public function accessField(name:String, swizzling:Bool = true){

	}
}