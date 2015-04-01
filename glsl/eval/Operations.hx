package glsl.eval;

import glsl.SyntaxTree;
import glsl.eval.Eval;

using glsl.eval.helpers.GLSLInstanceHelper;

@:publicFields
@:access(glsl.eval.Eval)
class Operations{

	static var binaryFunctions:Map<BinaryOperator, GLSLInstance->GLSLInstance->GLSLInstance> = [
		STAR => multiply,
		SLASH => divide,
		PERCENT => modulo,
		PLUS => add,
		DASH => subtract
	/*	@! todo
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

	static var unaryFunctions:Map<UnaryOperator, Dynamic->Bool->GLSLInstance> = [
		INC_OP => increment,
		DEC_OP => decrement,
		PLUS => plus,
		DASH => minus,
		BANG => not
	/*	@! todo
		TILDE;
	*/
	];

	// @! todo
	
	static var assignmentFunctions:Map<AssignmentOperator, Variable->GLSLInstance->GLSLInstance> = [
		EQUAL => assign
	/*	@! todo
		MUL_ASSIGN => assignMultiply,
		DIV_ASSIGN => assignDivide,
		MOD_ASSIGN => assignModulo,
		ADD_ASSIGN => assignAdd,
		SUB_ASSIGN => assignSubtract,
		LEFT_ASSIGN => 
		RIGHT_ASSIGN =>
		AND_ASSIGN =>
		XOR_ASSIGN =>
		OR_ASSIGN =>
	*/
	];
	

	//Binary Operations
	static function multiply(lhs:GLSLInstance, rhs:GLSLInstance):GLSLInstance{
		switch {lhs: lhs, rhs: rhs} {
			case {lhs: PrimitiveInstance(lv, INT), rhs: PrimitiveInstance(rv, INT)}:
				return PrimitiveInstance(lv * rv, INT);
			case {lhs: PrimitiveInstance(lv, FLOAT), rhs: PrimitiveInstance(rv, FLOAT)}:
				return PrimitiveInstance(lv * rv, FLOAT);
			default: 
				Eval.warn('could not multiply $lhs and $rhs');
		}
		return null;		
	}

	static function divide(lhs:GLSLInstance, rhs:GLSLInstance):GLSLInstance{
		switch {lhs: lhs, rhs: rhs} {
			case {lhs: PrimitiveInstance(lv, INT), rhs: PrimitiveInstance(rv, INT)}:
				return PrimitiveInstance(Math.floor(lv / rv), INT);
			case {lhs: PrimitiveInstance(lv, FLOAT), rhs: PrimitiveInstance(rv, FLOAT)}:
				return PrimitiveInstance(lv / rv, FLOAT);
			default: 
				Eval.warn('could not divide $lhs by $rhs');
		}
		return null;		
	}

	static function modulo(lhs:GLSLInstance, rhs:GLSLInstance):GLSLInstance{
		//OPERATOR RESERVED
		Eval.warn('modulo operation not supported in GLSL ES 1.0 ($lhs % $rhs)');
		switch {lhs: lhs, rhs: rhs} {
			case {lhs: PrimitiveInstance(lv, INT), rhs: PrimitiveInstance(rv, INT)}:
				return PrimitiveInstance(Math.floor(lv % rv), INT);
			case {lhs: PrimitiveInstance(lv, FLOAT), rhs: PrimitiveInstance(rv, FLOAT)}:
				return PrimitiveInstance(Math.floor(lv % rv), FLOAT);
			default: 
				Eval.warn('could not divide $lhs by $rhs');
		}			
		return null;		
	}

	static function add(lhs:GLSLInstance, rhs:GLSLInstance):GLSLInstance{
		switch {lhs: lhs, rhs: rhs} {
			case {lhs: PrimitiveInstance(lv, INT), rhs: PrimitiveInstance(rv, INT)}:
				return PrimitiveInstance(lv + rv, INT);
			case {lhs: PrimitiveInstance(lv, FLOAT), rhs: PrimitiveInstance(rv, FLOAT)}:
				return PrimitiveInstance(lv + rv, FLOAT);
			default: 
				Eval.warn('could not add $lhs and $rhs');
		}
		return null;		
	}

	static function subtract(lhs:GLSLInstance, rhs:GLSLInstance):GLSLInstance{
		switch {lhs: lhs, rhs: rhs} {
			case {lhs: PrimitiveInstance(lv, INT), rhs: PrimitiveInstance(rv, INT)}:
				return PrimitiveInstance(lv - rv, INT);
			case {lhs: PrimitiveInstance(lv, FLOAT), rhs: PrimitiveInstance(rv, FLOAT)}:
				return PrimitiveInstance(lv - rv, FLOAT);
			default: 
				Eval.warn('could not subtract $lhs by $rhs');
		}
		return null;		
	}

	//Unary Operators
	static function increment(variable:Variable, isPrefix:Bool){
		//perform increment on primitive
		var argInst = variable.value;
		var primBefore = argInst;
		var result:GLSLInstance = null;
		switch argInst {
			case PrimitiveInstance(v, INT):
				result = PrimitiveInstance(v+1, INT);
			case PrimitiveInstance(v, FLOAT):
				result = PrimitiveInstance(v+1, FLOAT);
			case null, _:
				result = null;
		}

		variable.value = result;

		return isPrefix ? result : primBefore;
	}

	static function decrement(variable:Variable, isPrefix:Bool){
		//perform decrement on primitive
		var argInst = variable.value;
		var primBefore = argInst;
		var result:GLSLInstance = null;
		switch argInst {
			case PrimitiveInstance(v, INT):
				result = PrimitiveInstance(v-1, INT);
			case PrimitiveInstance(v, FLOAT):
				result = PrimitiveInstance(v-1, FLOAT);
			case null, _:
				result = null;
		}

		variable.value = result;

		return isPrefix ? result : primBefore;	
	}

	static function plus(argInst:GLSLInstance, isPrefix:Bool){
		switch {arg: argInst, isPrefix: isPrefix} {
			case {arg: PrimitiveInstance(_, INT), isPrefix: true} 	|
				 {arg: PrimitiveInstance(_, FLOAT), isPrefix: true}	|
				 {arg: CompositeInstance(_, _), isPrefix: true}:
				return argInst;
			case {arg: _, isPrefix: true}:
				Eval.warn('operation +$argInst not supported');
			case {arg: _, isPrefix: false}:
				Eval.warn('operation $argInst+ not supported');
		}
		return null;
	}

	static function minus(argInst:GLSLInstance, isPrefix:Bool){
		switch {arg: argInst, isPrefix: isPrefix} {
			case {arg: PrimitiveInstance(v, INT), isPrefix: true}:
				return PrimitiveInstance(-v, INT);
			case {arg: PrimitiveInstance(v, FLOAT), isPrefix: true}:
				return PrimitiveInstance(-v, FLOAT);
			case {arg: _, isPrefix: true}:
				Eval.warn('operation -$argInst not supported');
			case {arg: _, isPrefix: false}:
				Eval.warn('operation $argInst- not supported');
		}
		return null;
	}

	static function not(argInst:GLSLInstance, isPrefix:Bool){
		switch {arg: argInst, isPrefix: isPrefix} {
			case {arg: PrimitiveInstance(v, BOOL), isPrefix: true}:
				return PrimitiveInstance(!v, BOOL);
			case {arg: _, isPrefix: true}:
				Eval.warn('operation !$argInst not supported');
			case {arg: _, isPrefix: false}:
				Eval.warn('operation $argInst! not supported');
		}
		return null;
	}

	//Assignment
	static function assign(variable:Variable, value:GLSLInstance){
		//@! try variable conversion if possible?
		if(!variable.dataType.equals(value.getDataType())){
			Eval.warn('type mismatch, cannot assign ${value} to variable ${variable.name} with type ${variable.dataType}');
		}
		variable.value = value;
		return value;
	}
}