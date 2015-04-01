package glsl.eval;

import glsl.eval.Eval;

interface ITypeDefinition{
	public function createInstance(?constructionParams:Array<GLSLInstance>):ICompositeInstance;
}