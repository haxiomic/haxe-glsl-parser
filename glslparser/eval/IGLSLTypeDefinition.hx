package glslparser.eval;

import glslparser.eval.Eval;

interface IGLSLTypeDefinition{
	public function createInstance(?constructionParams:Array<GLSLInstance>):IGLSLComplexInstance;
}