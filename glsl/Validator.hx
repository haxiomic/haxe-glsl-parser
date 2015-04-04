/*
	Todo
*/

package glsl;

import glsl.SyntaxTree.Node;


class Validator{
	//only allowed type_qualifier is CONST, and only then if INOUT or OUT are not used
	//qualifiers are not allowed on function returns
	//check for reserved keywords (instead of tokenizer)
	//...
	//(search through reference validator)

	public static function validateAST(tree:Node){
		/*
			@! todo
		*/
	}
}
