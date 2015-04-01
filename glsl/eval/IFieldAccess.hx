package glsl.eval;

import glsl.eval.Eval;

interface IFieldAccess{
	public function accessField(name:String):Variable;
}