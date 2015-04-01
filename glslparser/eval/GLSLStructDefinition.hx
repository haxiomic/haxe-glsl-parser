package glslparser.eval;

import glslparser.AST;
import glslparser.eval.Eval;

using AST.TypeEnumHelper;

@:access(glslparser.eval.Eval)
class GLSLStructDefinition implements IGLSLTypeDefinition{
	public var name:String;
	public var fields:Array<GLSLVariableDefinition>;

	public function new(name:String, fields:Array<GLSLVariableDefinition>){
		this.name = name;
		this.fields = fields;
	}

	public function createInstance(?constructionParams:Array<GLSLInstance>):GLSLStructInstance{
		return new GLSLStructInstance(this, constructionParams);
	}

	static public function fromStructSpecifier(specifier:StructSpecifier){
		//convert declarations to fields
		var fields = new Array<GLSLVariableDefinition>();

		//create field definitions in order
		for(i in 0...specifier.structDeclarations.length){
			var d = specifier.structDeclarations[i];
			var typeSpec = d.typeSpecifier;

			for(j in 0...d.declarators.length){

				//create field def and push
				switch d.declarators[j].toTypeEnum() {
					case StructDeclaratorNode(n):
						var field:GLSLVariableDefinition = {
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

		return new GLSLStructDefinition(specifier.name, fields);
	}
}