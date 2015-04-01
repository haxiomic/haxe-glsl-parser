package glsl.eval.helpers;

import glsl.SyntaxTree;
import glsl.eval.Eval;

class GLSLInstanceHelper{

	static public function getDataType(p:GLSLInstance):DataType{
		return switch p {
			case PrimitiveInstance(_, t): t;
			case CompositeInstance(_, t): t;
			default: null;
		}
	}
	
}