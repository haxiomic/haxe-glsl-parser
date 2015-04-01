package glslparser.eval;

import glslparser.eval.Eval;

using glslparser.eval.helpers.GLSLInstanceHelper;

@:access(glslparser.eval.Eval)
class GLSLStructInstance implements IGLSLComplexInstance{
	var typeDefinition:GLSLStructDefinition;
	var fields:Map<String, GLSLVariable>;

	public function new(typeDefinition:GLSLStructDefinition, ?constructionParams:Array<GLSLInstance>){
		this.typeDefinition = typeDefinition;

		fields = new Map<String, GLSLVariable>();

		//create fields
		for(i in 0...typeDefinition.fields.length){
			var f = typeDefinition.fields[i];

			var field:GLSLVariable = {
				name: f.name,
				dataType: f.dataType,
				qualifier: f.qualifier,
				precision: f.precision,
				invariant: f.invariant,
				arraySize: f.arraySize,
				value: null,
			};

			fields.set(f.name, field);
		}

		if(constructionParams != null)
			construct(constructionParams);
	}

	public function construct(constructionParams:Array<GLSLInstance>){
		//strict parameter-field match
		if(constructionParams.length != typeDefinition.fields.length){
			Eval.error('number of constructor parameters does not match the number of structure fields');
			return;
		}

		for(i in 0...constructionParams.length){
			var c = constructionParams[i];
			var f = fields.get(fieldName(i));

			if(!c.getDataType().equals(f.dataType)){
				Eval.warn('structure constructor arguments types do not match structure field\'s');
			}

			f.value = c;
		}
	}
	
	public function accessField(name:String):GLSLVariable{
		return fields.get(name);
	}

	inline function fieldName(i:Int):String{
		return typeDefinition.fields[i].name;
	}
}