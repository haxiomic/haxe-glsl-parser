package;

import glsl.SyntaxTree;
import glsl.eval.Eval;
import glsl.eval.ITypeDefinition;

using glsl.SyntaxTree.NodeTypeHelper;

class Extract{

	static public function extractGlobalVariables(ast:Root):{
			types: Map<DataType, ITypeDefinition>,
			variables: Map<String, Variable>,
			warnings: Array<String>
		}{
		Eval.reset();

		function iterate(node:Node){
			switch node.safeNodeType() {
				case RootNode(n):
					for(d in n.declarations) iterate(d);

				case VariableDeclarationNode(n):
					var v = Eval.evaluateVariableDeclaration(n);
					
				default:
					// trace('Extract unknown: ${node.nodeName}');
			}
		}

		iterate(ast);

		//copy Eval state
		var userDefinedTypes = new Map<DataType, ITypeDefinition>();
		var userDefinedVariables = new Map<String, Variable>();
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