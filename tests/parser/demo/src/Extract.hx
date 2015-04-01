package;

import glslparser.AST;
import glslparser.eval.Eval;
import glslparser.eval.IGLSLTypeDefinition;

using glslparser.AST.TypeEnumHelper;

class Extract{

	static public function extractGlobalVariables(ast:Root):{
			types: Map<DataType, IGLSLTypeDefinition>,
			variables: Map<String, GLSLVariable>,
			warnings: Array<String>
		}{
		Eval.reset();

		function iterate(node:Node){
			switch node.toTypeEnum() {
				case RootNode(n):
					for(d in n.declarations) iterate(d);

				case VariableDeclarationNode(n):
					var v = Eval.evaluateVariableDeclaration(n);
					
				default:
					trace('Extract default ${node.nodeName}');
			}
		}

		iterate(ast);

		//copy Eval state
		var userDefinedTypes = new Map<DataType, IGLSLTypeDefinition>();
		var userDefinedVariables = new Map<String, GLSLVariable>();
		var warnings = Eval.warnings.copy();

		for(key in Eval.userDefinedTypes.keys()){
			userDefinedTypes.set(key, Eval.userDefinedTypes.get(key));
		}

		for(key in Eval.userDefinedVariables.keys()){
			userDefinedVariables.set(key, Eval.userDefinedVariables.get(key));
		}

		return {
			types: userDefinedTypes,
			variables: userDefinedVariables,
			warnings: warnings
		};
	}


}