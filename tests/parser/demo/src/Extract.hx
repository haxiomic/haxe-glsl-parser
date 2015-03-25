package;

import glslparser.AST;
import glslparser.AST.TranslationUnit;
import glslparser.Eval;

using glslparser.AST.TypeEnumHelper;

class Extract{

	static public function extractGlobalVariables(ast:Root):{
			types: Map<DataType, GLSLTypeDef>,
			variables: Map<String, GLSLVariable>
		}{
		Eval.reset();

		function iterate(node:Node){
			switch node.toTypeEnum() {
				case RootNode(n):
					for(d in n.declarations) iterate(d);

				case VariableDeclarationNode(n):
					var v = Eval.evaluateVariableDeclaration(n);
					trace(v);

				default:
					trace('default ${node.nodeName}');
			}
		}

		iterate(ast);

		//copy Eval state
		var userDefinedTypes = new Map<DataType, GLSLTypeDef>();
		var userDefinedVariables = new Map<String, GLSLVariable>();

		for(key in Eval.userDefinedTypes.keys()){
			userDefinedTypes.set(key, Eval.userDefinedTypes.get(key));
		}

		for(key in Eval.userDefinedVariables.keys()){
			userDefinedVariables.set(key, Eval.userDefinedVariables.get(key));
		}

		return {
			types: userDefinedTypes,
			variables: userDefinedVariables
		};
	}


}