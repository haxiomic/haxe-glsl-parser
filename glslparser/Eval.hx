/*
	//#! need to account for scoping!

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

class Eval{
	static var variables:Map<String, GLSLConstantValue>;

	static public function evaluateConstantExpressions(ast:Node):Void{
		variables = new Map<String, GLSLConstantValue>();
		iterate(ast);
	}

	static function iterate(node:Dynamic){
		
		switch (Type.getClass(node)) {
			case Array: var _ = cast(node, Array<Dynamic>);
				for(i in 0..._.length) iterate(_[i]);

			case VariableDeclaration: var _ = cast(node, VariableDeclaration);
				iterate(_.typeSpecifier);
				if(_.typeSpecifier.qualifier == CONST){
					for(i in 0..._.declarators.length) defineConst(_.declarators[i]);
				}

			case StructSpecifier: var _ = cast(node, StructSpecifier);
				iterate(_.structDeclarations);

			default:
				trace('default case');
		}

	}

	//collapses constant expression down to singular expression
	static function resolveExpression(expr:Expression):GLSLConstantValue{
		switch (Type.getClass(expr)) {
			//fully resolved expressions
			case Literal: var _ = cast(expr, Literal<Dynamic>);
				return _;

			case FunctionCall: var _ = cast(expr, FunctionCall);
				return _;

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

	static function resolveBinaryExpression(binExpr:BinaryExpression):GLSLConstantValue{
		var left = resolveExpression(binExpr.left);
		var right = resolveExpression(binExpr.right);
		var op = binExpr.op;

		var leftType:GLSLBasicType = left;
		var rightType:GLSLBasicType = right;

		switch (BinOp(leftType, rightType, op)) {
			//STAR
			case BinOp(LiteralType(INT, lv), LiteralType(INT, rv), STAR):
				var r:Int = Math.floor(lv * rv);
				return new Literal(r, glslFloatInt(r), INT);
			case BinOp(LiteralType(FLOAT, lv), LiteralType(FLOAT, rv), STAR):
				var r:Float = lv * rv;
				return new Literal(r, glslFloatString(r), FLOAT);
			//SLASH
			case BinOp(LiteralType(INT, lv), LiteralType(INT, rv), SLASH):
				var r:Int = Math.floor(lv / rv);
				return new Literal(r, glslFloatInt(r), INT);
			case BinOp(LiteralType(FLOAT, lv), LiteralType(FLOAT, rv), SLASH):
				var r:Float = lv / rv;
				return new Literal(r, glslFloatString(r), FLOAT);
			//PERCENT
			case BinOp(LiteralType(INT, lv), LiteralType(INT, rv), PERCENT):
				var r:Int = Math.floor(lv % rv);
				return new Literal(r, glslFloatInt(r), INT);
			case BinOp(LiteralType(FLOAT, lv), LiteralType(FLOAT, rv), PERCENT):
				var r:Float = Math.floor(lv % rv);
				return new Literal(r, glslFloatString(r), FLOAT);
			//PLUS
			case BinOp(LiteralType(INT, lv), LiteralType(INT, rv), PLUS):
				var r:Int = Math.floor(lv + rv);
				return new Literal(r, glslFloatInt(r), INT);
			case BinOp(LiteralType(FLOAT, lv), LiteralType(FLOAT, rv), PLUS):
				var r:Float = lv + rv;
				return new Literal(r, glslFloatString(r), FLOAT);
			//DASH
			case BinOp(LiteralType(INT, lv), LiteralType(INT, rv), DASH):
				var r:Int = Math.floor(lv - rv);
				return new Literal(r, glslFloatInt(r), INT);
			case BinOp(LiteralType(FLOAT, lv), LiteralType(FLOAT, rv), DASH):
				var r:Float = lv - rv;
				return new Literal(r, glslFloatString(r), FLOAT);
			//LEFT_ANGLE
			case BinOp(LiteralType(INT, lv), LiteralType(INT, rv), LEFT_ANGLE):
				var r:Bool = lv < rv;
				return new Literal(r, glslBoolString(r), BOOL);
			case BinOp(LiteralType(FLOAT, lv), LiteralType(FLOAT, rv), LEFT_ANGLE):
				var r:Bool = lv < rv;
				return new Literal(r, glslBoolString(r), BOOL);
			//RIGHT_ANGLE
			case BinOp(LiteralType(INT, lv), LiteralType(INT, rv), RIGHT_ANGLE):
				var r:Bool = lv > rv;
				return new Literal(r, glslBoolString(r), BOOL);
			case BinOp(LiteralType(FLOAT, lv), LiteralType(FLOAT, rv), RIGHT_ANGLE):
				var r:Bool = lv > rv;
				return new Literal(r, glslBoolString(r), BOOL);
			//LE_OP
			case BinOp(LiteralType(INT, lv), LiteralType(INT, rv), LE_OP):
				var r:Bool = lv <= rv;
				return new Literal(r, glslBoolString(r), BOOL);
			case BinOp(LiteralType(FLOAT, lv), LiteralType(FLOAT, rv), LE_OP):
				var r:Bool = lv <= rv;
				return new Literal(r, glslBoolString(r), BOOL);
			//GE_OP
			case BinOp(LiteralType(INT, lv), LiteralType(INT, rv), GE_OP):
				var r:Bool = lv >= rv;
				return new Literal(r, glslBoolString(r), BOOL);
			case BinOp(LiteralType(FLOAT, lv), LiteralType(FLOAT, rv), GE_OP):
				var r:Bool = lv >= rv;
				return new Literal(r, glslBoolString(r), BOOL);
			//EQ_OP
			case BinOp(LiteralType(INT, lv), LiteralType(INT, rv), EQ_OP):
				var r:Bool = lv == rv;
				return new Literal(r, glslBoolString(r), BOOL);
			case BinOp(LiteralType(FLOAT, lv), LiteralType(FLOAT, rv), EQ_OP):
				var r:Bool = lv == rv;
				return new Literal(r, glslBoolString(r), BOOL);
			case BinOp(LiteralType(BOOL, lv), LiteralType(BOOL, rv), EQ_OP):
				var r:Bool = lv == rv;
				return new Literal(r, glslBoolString(r), BOOL);
			//NE_OP
			case BinOp(LiteralType(INT, lv), LiteralType(INT, rv), NE_OP):
				var r:Bool = lv != rv;
				return new Literal(r, glslBoolString(r), BOOL);
			case BinOp(LiteralType(FLOAT, lv), LiteralType(FLOAT, rv), NE_OP):
				var r:Bool = lv != rv;
				return new Literal(r, glslBoolString(r), BOOL);
			//LEFT_OP
			case BinOp(LiteralType(INT, lv), LiteralType(INT, rv), LEFT_OP):
				var r:Int = Math.floor(lv << rv);
				return new Literal(r, glslFloatInt(r), INT);
			//RIGHT_OP
			case BinOp(LiteralType(INT, lv), LiteralType(INT, rv), RIGHT_OP):
				var r:Int = Math.floor(lv >> rv);
				return new Literal(r, glslFloatInt(r), INT);
			//AMPERSAND
			case BinOp(LiteralType(INT, lv), LiteralType(INT, rv), AMPERSAND):
				var r:Int = Math.floor(lv & rv);
				return new Literal(r, glslFloatInt(r), INT);
			//CARET
			case BinOp(LiteralType(INT, lv), LiteralType(INT, rv), CARET):
				var r:Int = Math.floor(lv ^ rv);
				return new Literal(r, glslFloatInt(r), INT);
			//VERTICAL_BAR
			case BinOp(LiteralType(INT, lv), LiteralType(INT, rv), VERTICAL_BAR):
				var r:Int = Math.floor(lv | rv);
				return new Literal(r, glslFloatInt(r), INT);
			//AND_OP
			case BinOp(LiteralType(BOOL, lv), LiteralType(BOOL, rv), AND_OP):
				var r:Bool = lv && rv;
				return new Literal(r, glslBoolString(r), BOOL);
			//XOR_OP
			case BinOp(LiteralType(BOOL, lv), LiteralType(BOOL, rv), XOR_OP):
				var r:Bool = !lv != !rv;
				return new Literal(r, glslBoolString(r), BOOL);
			//OR_OP
			case BinOp(LiteralType(BOOL, lv), LiteralType(BOOL, rv), OR_OP):
				var r:Bool = lv || rv;
				return new Literal(r, glslBoolString(r), BOOL);
			default:
		}

		error('could not resolve binary expression $left $op $rightType'); //#! needs improving
		return null;
	}

	static function defineType(specifier:StructSpecifier){
		trace('#! define type $specifier');
	}

	static function defineConst(declarator:Declarator){
		trace('define const ${declarator.name}');
		//#! need to check if the result has the correct type
		variables.set(declarator.name, resolveExpression(declarator.initializer));
		trace(variables);
	}

	//Utils
	static function glslFloatString(f:Float){
		var str = Std.string(f);
		var rx = ~/\./g;
		if(!rx.match(str)) str += '.0';
		return str;
	}

	static function glslFloatInt(i:Int){
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

enum OpType{
	BinOp(l:GLSLBasicType, r:GLSLBasicType, op:BinaryOperator);
}
 
enum GLSLBasicType{
	LiteralType(t:TypeClass, v:Dynamic);
	FunctionCallType;
}

@:access(glslparser.Eval)
abstract GLSLConstantValue(Expression) to Expression{
	public inline function new(expr:Expression){
		if(!isFullyresolved(expr))
			Eval.error('cannot create GLSLConstantValue; expression is not fully resolved. $expr');

		this = expr;
	}

	static function isFullyresolved(expr:Expression):Bool{
		switch (Type.getClass(expr)) {
			case Literal: return true;
			case FunctionCall: var _ = cast(expr, FunctionCall);
				return _.constructor;
		}

		return false;
	}

	@:to function toGLSLBasicType():GLSLBasicType{
		if(Type.getClass(this) == Literal){
			var _ = cast(this, Literal<Dynamic>);
			return LiteralType(_.typeClass, _.value);
		}else if(Type.getClass(this) == FunctionCall){
			var _ = cast(this, FunctionCall);
			Eval.error('FunctionCallType not supported yet');
			return FunctionCallType;
		}

		Eval.error('unrecognized GLSLConstantValue: $this');
		return null;
	}

	@:from static function fromExpression(expr:Expression) return new GLSLConstantValue(expr);
}