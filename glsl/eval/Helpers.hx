package glsl.eval;

import glsl.SyntaxTree;
import glsl.eval.Eval;

class GLSLInstanceHelper{

	static public function getDataType(p:GLSLInstance):DataType{
		return switch p {
			case PrimitiveInstance(_, t): t;
			case CompositeInstance(_, t): t;
			default: null;
		}
	}
	
}

@:access(glsl.eval.Eval)
class DataTypeHelper{

	static public function construct(dataType:DataType, ?value:Dynamic):GLSLInstance{
		switch dataType{
			case INT, FLOAT:
				return PrimitiveInstance((value != null ? value : 0), dataType);
			case BOOL:
				return PrimitiveInstance((value != null ? value : false), dataType);
			case USER_TYPE(n):
				var typeDefinition = Eval.userDefinedTypes.get(dataType);

				var constructionParams:Array<GLSLInstance>;
				if(value != null){
					constructionParams = value;
				}else{
					//create empty fields
					constructionParams = [];
					for(i in 0...typeDefinition.fields.length){
						var f = typeDefinition.fields[i];
						constructionParams.push(construct(f.dataType, null));
					}
				}

				return CompositeInstance(typeDefinition.createInstance(constructionParams), dataType);

			//@! support for other types
			case null, _:
				Eval.error('cannot construct type $dataType');
		}
		return null;
	}
	
}