package glslparser.eval.helpers;

import glslparser.AST;
import glslparser.eval.Eval;

class GLSLInstanceHelper{

	static public function getDataType(p:GLSLInstance):DataType{
		return switch p {
			case PrimitiveInstance(_, t): t;
			case CompositeInstance(_, t): t;
			default: null;
		}
	}
	
}