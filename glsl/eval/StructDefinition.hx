package glsl.eval;

import glsl.SyntaxTree;
import glsl.eval.Eval;

using SyntaxTree.NodeEnumHelper;

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

	static public function fromStructSpecifier(specifier:StructSpecifier){
		//convert declarations to fields
		var fields = new Array<VariableDefinition>();

		//create field definitions in order
		for(i in 0...specifier.structDeclarations.length){
			var d = specifier.structDeclarations[i];
			var typeSpec = d.typeSpecifier;

			for(j in 0...d.declarators.length){

				//create field def and push
				switch d.declarators[j].toEnum() {
					case StructDeclaratorNode(n):
						var field:VariableDefinition = {
							name: n.name,
							dataType: typeSpec.dataType, 
							qualifier: typeSpec.qualifier,
							precision: typeSpec.precision,
							invariant: typeSpec.invariant
						};

						//add array size if necessary
						if(n.arraySizeExpression != null){
							var arraySizePrimitive = Eval.evaluateExpr(n.arraySizeExpression, true);
							switch arraySizePrimitive {
								case PrimitiveInstance(v, INT):
									field.arraySize = v;
								case null, _:
									Eval.error('array size must an integer expression');
							}
						}

						fields.push(field);
					case null, _:
				}

			}
		}

		return new StructDefinition(specifier.name, fields);
	}
}