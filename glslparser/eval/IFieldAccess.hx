package glslparser.eval;

import glslparser.eval.Eval;

interface IFieldAccess{
	public function accessField(name:String):Variable;
}