/*
	Todo
*/

package glsl.postprocess;

import glsl.SyntaxTree.Node;

using glsl.SyntaxTree.NodeEnumHelper;


class Validator{
	//- need to account for version from the start
	//- consider stream validation so nodes are passed in as they are created

	//only allowed type_qualifier is CONST, and only then if INOUT or OUT are not used
	//qualifiers are not allowed on function returns
	//check for reserved keywords (instead of tokenizer)
	//allowed iteration statements (while is forbidden)
	//prototypes must be global
	//disallow recursive functions
	//certain loop types are forbidden
	//...
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
		switch currentNode.toEnum(){
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
