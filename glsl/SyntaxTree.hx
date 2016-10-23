/*
	GLSL Abstract Syntax Tree
	Loosely following Mozilla Parser AST API and Mesa GLSL Compiler AST

	@author George Corney

	@! todo
		automatically build enum from all classes that implement Node
*/

package glsl;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type.ClassType;
import Type.ValueType.TClass;

interface Node{
	var nodeType:NodeType;
}

@:publicFields
class Root implements Node{
	var declarations:TranslationUnit;
	var nodeType:NodeType;
	public function new(declarations:TranslationUnit){
		this.nodeType = RootNode(this);
		this.declarations = declarations;
	}
}

@:publicFields
class TypeSpecifier implements Node{
	var dataType:DataType;
	var storage:StorageQualifier;
	var precision:PrecisionQualifier;
	var invariant:Bool;
	var nodeType:NodeType;
	function new(dataType:DataType, ?storage:StorageQualifier, ?precision:PrecisionQualifier, invariant:Bool = false){
		this.nodeType = TypeSpecifierNode(this);
		this.dataType = dataType;
		this.storage = storage;
		this.precision = precision;
		this.invariant = invariant;
	}
}

@:publicFields
class StructSpecifier extends TypeSpecifier{
	var fieldDeclarations:StructFieldDeclarationList;
	var name:String;
	function new(name:String, fieldDeclarations:StructFieldDeclarationList){
		this.nodeType = StructSpecifierNode(this);
		this.name = name;
		this.fieldDeclarations = fieldDeclarations;
		super(USER_TYPE(name));
	}
}

typedef StructFieldDeclarationList = Array<StructFieldDeclaration>;

@:publicFields
class StructFieldDeclaration implements Node{
	var typeSpecifier:TypeSpecifier;
	var declarators:StructDeclaratorList;
	var nodeType:NodeType;
	function new(typeSpecifier:TypeSpecifier, declarators:StructDeclaratorList){
		this.nodeType = StructFieldDeclarationNode(this);
		this.typeSpecifier = typeSpecifier;
		this.declarators = declarators;
	}
}

typedef StructDeclaratorList = Array<StructDeclarator>;

@:publicFields
class StructDeclarator implements Node{
	var name:String;
	var arraySizeExpression:Expression;
	var nodeType:NodeType;
	function new(name:String, ?arraySizeExpression:Expression){
		this.nodeType = StructDeclaratorNode(this);
		this.name = name;
		this.arraySizeExpression = arraySizeExpression;
	}
}


interface Expression extends Node{
	var enclosed:Bool;
}

interface TypedExpression{
	var dataType:DataType;
}

@:publicFields
class Identifier implements Expression{
	var name:String;
	var enclosed:Bool = false;
	var nodeType:NodeType;
	function new(name:String) {
		this.nodeType = IdentifierNode(this);
		this.name = name;
	}
}

@:publicFields
class Primitive<T> implements Expression implements TypedExpression{
	var value(default, set):T;
	var raw:String;
	var dataType:DataType;
	var enclosed:Bool = false;
	var nodeType:NodeType;
	function new(value:T, dataType:DataType){
		this.nodeType = PrimitiveNode(this);
		this.dataType = dataType;
		this.value = value;
	}

	private function set_value(v:T):T{
		switch(dataType){
			case INT: raw = glsl.print.Utils.intString(cast v);
			case FLOAT: raw = glsl.print.Utils.floatString(cast v);
			case BOOL: raw = glsl.print.Utils.boolString(cast v);
			default: raw = '';
		}
		return value = v;
	}

}

@:publicFields
class BinaryExpression implements Expression{
	var op:BinaryOperator;
	var left:Expression;
	var right:Expression;
	var enclosed:Bool = false;
	var nodeType:NodeType;
	function new(op:BinaryOperator, left:Expression, right:Expression){
		this.nodeType = BinaryExpressionNode(this);
		this.op = op;
		this.left = left;
		this.right = right;
	}
}

@:publicFields
class UnaryExpression implements Expression{
	var op:UnaryOperator;
	var arg:Expression;
	var isPrefix:Bool;
	var enclosed:Bool = false;
	var nodeType:NodeType;
	function new(op:UnaryOperator, arg:Expression, isPrefix:Bool){
		this.nodeType = UnaryExpressionNode(this);
		this.op = op;
		this.arg = arg;
		this.isPrefix = isPrefix;
	}
}

@:publicFields
class SequenceExpression implements Expression{
	var expressions:Array<Expression>;
	var enclosed:Bool = false;
	var nodeType:NodeType;
	function new(expressions:Array<Expression>){
		this.nodeType = SequenceExpressionNode(this);
		this.expressions = expressions;
	}
}

@:publicFields
class ConditionalExpression implements Expression{
	var test:Expression;
	var consequent:Expression;
	var alternate:Expression;
	var enclosed:Bool = false;
	var nodeType:NodeType;
	function new(test:Expression, consequent:Expression, alternate:Expression){
		this.nodeType = ConditionalExpressionNode(this);
		this.test = test;
		this.consequent = consequent;
		this.alternate = alternate;
	}
}

@:publicFields
class AssignmentExpression implements Expression{
	var op:AssignmentOperator;
	var left:Expression;
	var right:Expression;
	var enclosed:Bool = false;
	var nodeType:NodeType;
	function new(op:AssignmentOperator, left:Expression, right:Expression){
		this.nodeType = AssignmentExpressionNode(this);
		this.op = op;
		this.left = left;
		this.right = right;
	}
}

@:publicFields
class FieldSelectionExpression implements Expression{
	var left:Expression;
	var field:Identifier;
	var enclosed:Bool = false;
	var nodeType:NodeType;
	function new(left:Expression, field:Identifier){
		this.nodeType = FieldSelectionExpressionNode(this);
		this.left = left;
		this.field = field;
	}
}

@:publicFields
class ArrayElementSelectionExpression implements Expression{
	var left:Expression;
	var arrayIndexExpression:Expression;
	var enclosed:Bool = false;
	var nodeType:NodeType;
	function new(left:Expression, arrayIndexExpression:Expression){
		this.nodeType = ArrayElementSelectionExpressionNode(this);
		this.left = left;
		this.arrayIndexExpression = arrayIndexExpression;
	}
}

interface ExpressionParameters{
	var parameters:Array<Expression>;
}

@:publicFields
class FunctionCall implements Expression implements ExpressionParameters{
	var name:String;
	var parameters:Array<Expression>;
	var enclosed:Bool = false;
	var nodeType:NodeType;
	function new(name:String, ?parameters:Array<Expression>){
		this.nodeType = FunctionCallNode(this);
		this.name = name;
		this.parameters = parameters != null ? parameters : [];
	}
}


@:publicFields
class Constructor implements Expression implements ExpressionParameters implements TypedExpression{
	var dataType:DataType;
	var parameters:Array<Expression>;
	var enclosed:Bool = false;
	var nodeType:NodeType;
	function new(dataType:DataType, ?parameters:Array<Expression>){
		this.nodeType = ConstructorNode(this);
		this.dataType = dataType;
		this.parameters = parameters != null ? parameters : [];
	}
}

interface Declaration extends Node{
	var external:Bool;
}

typedef TranslationUnit = Array<Declaration>;

@:publicFields
class PrecisionDeclaration implements Declaration{
	var precision:PrecisionQualifier;
	var dataType:DataType;
	var external:Bool = false;
	var nodeType:NodeType;
	function new(precision:PrecisionQualifier, dataType:DataType){
		this.nodeType = PrecisionDeclarationNode(this);
		this.precision = precision;
		this.dataType = dataType;
	}
}

@:publicFields
class FunctionPrototype implements Declaration{
	var header:FunctionHeader;
	var external:Bool = false;
	var nodeType:NodeType;
	function new(header:FunctionHeader){
		this.nodeType = FunctionPrototypeNode(this);
		this.header = header;
	}
}

@:publicFields
class VariableDeclaration implements Declaration{
	var typeSpecifier:TypeSpecifier;
	var declarators:Array<Declarator>;
	var external:Bool = false;
	var nodeType:NodeType;
	function new(typeSpecifier:TypeSpecifier, declarators:Array<Declarator>){
		this.nodeType = VariableDeclarationNode(this);
		this.typeSpecifier = typeSpecifier;
		this.declarators = declarators;
	}
}

@:publicFields
class Declarator implements Node{
	var name:String;
	var initializer:Expression;
	var arraySizeExpression:Expression;
	var nodeType:NodeType;
	function new(name:String, ?initializer:Expression, ?arraySizeExpression:Expression){
		this.nodeType = DeclaratorNode(this);
		this.name = name;
		this.initializer = initializer;
		this.arraySizeExpression = arraySizeExpression;
	}
}

@:publicFields
class ParameterDeclaration extends Declarator{
	var parameterQualifier:ParameterQualifier;
	var typeSpecifier:TypeSpecifier;
	function new(name:String, typeSpecifier:TypeSpecifier, ?parameterQualifier:ParameterQualifier, ?arraySizeExpression:Expression){
		this.nodeType = ParameterDeclarationNode(this);
		super(name, null, arraySizeExpression);
		this.typeSpecifier = typeSpecifier;
		this.parameterQualifier = parameterQualifier;
	}
}

//in the syntax, FunctionDefinition is actually an external_declaration rather than a declaration

@:publicFields//in this form, they've been combined and to .external is used to signify an external_declaration
class FunctionDefinition implements Declaration{
	var header:FunctionHeader;
	var body:CompoundStatement;
	var external:Bool = true;
	var nodeType:NodeType;
	function new(header:FunctionHeader, body:CompoundStatement){
		this.nodeType = FunctionDefinitionNode(this);
		this.header = header;
		this.body = body;
	}
}

@:publicFields
class FunctionHeader implements Node{
	var name:String;
	var returnType:TypeSpecifier;
	var parameters:Array<ParameterDeclaration>;
	var nodeType:NodeType;
	function new(name:String, returnType:TypeSpecifier, ?parameters:Array<ParameterDeclaration>){
		this.nodeType = FunctionHeaderNode(this);
		this.name = name;
		this.returnType = returnType;
		this.parameters = parameters != null ? parameters : [];
	}
}

interface Statement extends Node{}

typedef StatementList = Array<Statement>;

@:publicFields
class CompoundStatement implements Statement{
	var statementList:StatementList;
	var nodeType:NodeType;
	function new(statementList:StatementList){
		this.nodeType = CompoundStatementNode(this);
		this.statementList = statementList;
	}
}

@:publicFields
class DeclarationStatement implements Statement{
	var declaration:Declaration;
	var nodeType:NodeType;
	function new(declaration:Declaration){
		this.nodeType = DeclarationStatementNode(this);
		this.declaration = declaration;
	}
}

@:publicFields
class ExpressionStatement implements Statement{
	var expression:Expression;
	var nodeType:NodeType;
	function new(expression:Expression){
		this.nodeType = ExpressionStatementNode(this);
		this.expression = expression;
	}
}

@:publicFields
class IfStatement implements Statement{
	var test:Expression;
	var consequent:Statement;
	var alternate:Statement;
	var nodeType:NodeType;
	function new(test:Expression, consequent:Statement, alternate:Statement){
		this.nodeType = IfStatementNode(this);
		this.test = test;
		this.consequent = consequent;
		this.alternate = alternate;
	}
}

@:publicFields
class JumpStatement implements Statement{
	var mode:JumpMode;
	var nodeType:NodeType;
	function new(mode:JumpMode){
		this.nodeType = JumpStatementNode(this);
		this.mode = mode;
	}
}

@:publicFields
class ReturnStatement extends JumpStatement{
	var returnExpression:Expression;
	function new(returnExpression:Expression){
		this.nodeType = ReturnStatementNode(this);
		this.returnExpression = returnExpression;
		super(RETURN);
	}
}

interface IterationStatement extends Statement{
	var body:Statement;
}

@:publicFields
class WhileStatement implements IterationStatement{
	var test:Expression;
	var body:Statement;
	var nodeType:NodeType;
	function new(test:Expression, body:Statement){
		this.nodeType = WhileStatementNode(this);
		this.test = test;
		this.body = body;
	}
}

@:publicFields
class DoWhileStatement implements IterationStatement{
	var test:Expression;
	var body:Statement;
	var nodeType:NodeType;
	function new(test:Expression, body:Statement){
		this.nodeType = DoWhileStatementNode(this);
		this.test = test;
		this.body = body;
	}
}

@:publicFields
class ForStatement implements IterationStatement{
	var init:Statement;
	var test:Expression;
	var update:Expression;
	var body:Statement;
	var nodeType:NodeType;
	function new(init:Statement, test:Expression, update:Expression, body:Statement){
		this.nodeType = ForStatementNode(this);
		this.init = init;
		this.test = test;
		this.update = update;
		this.body = body;
	}
}

//non-spec preprocessor directive support to allow code to pass through parser unharmed
@:publicFields
class PreprocessorDirective implements Declaration implements Statement{
	var content:String;
	var external:Bool = true;
	var nodeType:NodeType;
	function new(content:String){
		this.nodeType = PreprocessorDirectiveNode(this);
		this.content = content;
	}
}

//Enums
enum BinaryOperator{
	STAR;
	SLASH;
	PERCENT;
	PLUS;
	DASH;
	LEFT_OP;
	RIGHT_OP;
	LEFT_ANGLE;
	RIGHT_ANGLE;
	LE_OP;
	GE_OP;
	EQ_OP;
	NE_OP;
	AMPERSAND;
	CARET;
	VERTICAL_BAR;
	AND_OP;
	XOR_OP;
	OR_OP;
}

enum UnaryOperator{
	INC_OP;
	DEC_OP;
	PLUS;
	DASH;
	BANG;
	TILDE;
}

enum AssignmentOperator{
	EQUAL;
	MUL_ASSIGN;
	DIV_ASSIGN;
	MOD_ASSIGN;
	ADD_ASSIGN;
	SUB_ASSIGN;
	LEFT_ASSIGN;
	RIGHT_ASSIGN;
	AND_ASSIGN;
	XOR_ASSIGN;
	OR_ASSIGN;
}

enum PrecisionQualifier{
	HIGH_PRECISION;
	MEDIUM_PRECISION;
	LOW_PRECISION;
}

enum JumpMode{
	CONTINUE;
	BREAK;
	RETURN;
	DISCARD;
}

enum DataType{
	VOID;
	FLOAT;
	INT;
	BOOL;
	VEC2;
	VEC3;
	VEC4;
	BVEC2;
	BVEC3;
	BVEC4;
	IVEC2;
	IVEC3;
	IVEC4;
	MAT2;
	MAT3;
	MAT4;
	SAMPLER2D;
	SAMPLERCUBE;
	USER_TYPE(name:String);
}

enum ParameterQualifier{
	IN;
	OUT;
	INOUT;
}

enum StorageQualifier{
	CONST;
	ATTRIBUTE;
	VARYING;
	UNIFORM;
}


enum NodeType{
	RootNode(n:Root);
	TypeSpecifierNode(n:TypeSpecifier);
	StructSpecifierNode(n:StructSpecifier);
	StructFieldDeclarationNode(n:StructFieldDeclaration);
	StructDeclaratorNode(n:StructDeclarator);
	ExpressionNode(n:Expression);
	IdentifierNode(n:Identifier);
	PrimitiveNode(n:Primitive<Dynamic>);
	BinaryExpressionNode(n:BinaryExpression);
	UnaryExpressionNode(n:UnaryExpression);
	SequenceExpressionNode(n:SequenceExpression);
	ConditionalExpressionNode(n:ConditionalExpression);
	AssignmentExpressionNode(n:AssignmentExpression);
	FieldSelectionExpressionNode(n:FieldSelectionExpression);
	ArrayElementSelectionExpressionNode(n:ArrayElementSelectionExpression);
	FunctionCallNode(n:FunctionCall);
	ConstructorNode(n:Constructor);
	DeclarationNode(n:Declaration);
	PrecisionDeclarationNode(n:PrecisionDeclaration);
	VariableDeclarationNode(n:VariableDeclaration);
	DeclaratorNode(n:Declarator);
	ParameterDeclarationNode(n:ParameterDeclaration);
	FunctionDefinitionNode(n:FunctionDefinition);
	FunctionPrototypeNode(n:FunctionPrototype);
	FunctionHeaderNode(n:FunctionHeader);
	StatementNode(n:Statement);
	CompoundStatementNode(n:CompoundStatement);
	DeclarationStatementNode(n:DeclarationStatement);
	ExpressionStatementNode(n:ExpressionStatement);
	IterationStatementNode(n:IterationStatement);
	WhileStatementNode(n:WhileStatement);
	DoWhileStatementNode(n:DoWhileStatement);
	ForStatementNode(n:ForStatement);
	IfStatementNode(n:IfStatement);
	JumpStatementNode(n:JumpStatement);
	ReturnStatementNode(n:ReturnStatement);
	//non-spec
	PreprocessorDirectiveNode(n:PreprocessorDirective);
}

class NodeTypeHelper{
	//returns nodeType with null safety
	static public function safeNodeType(n:Node):NodeType{
		return n != null ? n.nodeType : null;
	}
}

#if macro
class NodeBuildMacro{
	static var touched:Array<String> = [];

	macro static public function build():Array<Field>{
		var fields = Context.getBuildFields();
		var localClass = Context.getLocalClass().get();

		//ignore interfaces
		if(localClass.isInterface) return fields;
		//get class name
		var className = localClass.name;
		//have we operated on this type before?
		if(touched.indexOf(getClassId(localClass)) != -1) return fields;

		//for automatically generating fields
		// var nodeTypeField:Field = {
		// 	pos: Context.currentPos(),
		// 	name: 'nodeType',
		// 	meta: null,
		// 	kind: FProp('default', 'null', TPath({
		// 		pack: ['glsl'],
		// 		name: 'NodeType'
		// 	}), null),
		// 	doc: null,
		// 	access: [APublic]
		// };
		// fields.push(nodeTypeField);

		for(f in fields) switch f{
			case {name: 'new', kind: FFun({expr: { expr: EBlock(exprArray) }})}:
				exprArray.push(macro nodeType = $i{className + 'Node'}(this));
			default:
		}

		//mark class as touched
		touched.push(getClassId(localClass));

		return fields;
	}

	static inline function getClassId(c:ClassType):String{
		return c.name +'.'+ c.module;
	}
}
#end