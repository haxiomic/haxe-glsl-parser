package glslparser.eval;

import glslparser.eval.Eval;

interface IGLSLFieldAccess{
	public function accessField(name:String):GLSLVariable;
}