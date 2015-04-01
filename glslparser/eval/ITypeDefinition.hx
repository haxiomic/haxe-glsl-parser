package glslparser.eval;

import glslparser.eval.Eval;

interface ITypeDefinition{
	public function createInstance(?constructionParams:Array<GLSLInstance>):ICompositeInstance;
}