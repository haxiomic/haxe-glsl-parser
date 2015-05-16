package glsl.eval;

import glsl.SyntaxTree;
import glsl.eval.Eval;

using SyntaxTree.NodeTypeHelper;

@:access(glsl.eval.Eval)
class StructDefinition implements ITypeDefinition{
	public var name:String;
	public var fields:Array<VariableDefinition>;

	public function new(name:String, fields:Array<VariableDefinition>){
		this.name = name;
		this.fields = fields;
	}

	public function createInstance(?constructionParams:Array<GLSLInstance>):StructInstance{
		return new StructInstance(this, constructionParams);
	}
}