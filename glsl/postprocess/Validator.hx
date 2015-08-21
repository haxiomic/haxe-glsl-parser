/*
	Todo
*/

package glsl.postprocess;

import glsl.SyntaxTree.Node;

using glsl.SyntaxTree.NodeTypeHelper;


class Validator{
	//- need to account for version from the start
	//- consider stream validation so nodes are passed in as they are created

	/* Errors */
	//only allowed type_qualifier is CONST, and only then if INOUT or OUT are not used
	//qualifiers are not allowed on function returns
	//check for reserved keywords (instead of tokenizer)
	//prototypes must be global (as well as function definitions)
	//disallow recursive functions

	/* Warnings */
	//allowed iteration statements (while is forbidden in webgl)
	//for-loop restrictions
	//	There is one loop index.
	//	The loop index has type int or float.
	//	The for statement has the form: for ( init-declaration ; condition ; expression ) statement
	//	init-declaration has the form: type-specifier identifier = constant-expression
	//		(Consequently the loop variable cannot be a global variable.)
	//  condition has the form: loop_index relational_operator constant_expression
	//		where relational_operator is one of: > >= < <= == or !=
	//	for_header has one of the following forms:
	//		loop_index++
	//		loop_index--
	//		loop_index += constant_expression
	//		loop_index -= constant_expression
	//	Within the body of the loop, the loop index is not statically assigned to nor is it used as the argument to a function out or inout parameter.
	//non-constant expressions in global variables
	//	In webgl, global variables can be non constant and involve uniforms, math functions, however this is a bug!
	//	GLSL ES spec requires global variables have constant definitions, so it's bad practice to use in webgl

	//...
	// For more, see appendix A in spec
	//(search through reference validator for full set)

	//state machine
	static var tree:Node;
	static var currentNode:Node;

	public static function validateAST(tree:Node){
		Validator.tree = tree;
		Validator.currentNode = tree;
		/*
			@! todo
				- iterate tree in execution order
				- type checking
		*/
	}

	//@! once complete, break away into iterator helper
	//each node needs a state control object?
	static function nextNode():Node{
		switch currentNode.safeNodeType(){
			case RootNode(n):
			case TypeSpecifierNode(n):
			case StructSpecifierNode(n):
			case StructFieldDeclarationNode(n):
			case StructDeclaratorNode(n):
			case ExpressionNode(n):
			case IdentifierNode(n):
			case PrimitiveNode(n):
			case BinaryExpressionNode(n):
			case UnaryExpressionNode(n):
			case SequenceExpressionNode(n):
			case ConditionalExpressionNode(n):
			case AssignmentExpressionNode(n):
			case FieldSelectionExpressionNode(n):
			case ArrayElementSelectionExpressionNode(n):
			case FunctionCallNode(n):
			case ConstructorNode(n):
			case DeclarationNode(n):
			case PrecisionDeclarationNode(n):
			case VariableDeclarationNode(n):
			case DeclaratorNode(n):
			case ParameterDeclarationNode(n):
			case FunctionDefinitionNode(n):
			case FunctionPrototypeNode(n):
			case FunctionHeaderNode(n):
			case StatementNode(n):
			case CompoundStatementNode(n):
			case DeclarationStatementNode(n):
			case ExpressionStatementNode(n):
			case IterationStatementNode(n):
			case WhileStatementNode(n):
			case DoWhileStatementNode(n):
			case ForStatementNode(n):
			case IfStatementNode(n):
			case JumpStatementNode(n):
			case ReturnStatementNode(n):
			//non-spec
			case PreprocessorDirectiveNode(n):
		}
		
		throw 'cannot determine next node';
	}
}
