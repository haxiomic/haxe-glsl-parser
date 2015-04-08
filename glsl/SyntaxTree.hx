/*
	GLSL Abstract Syntax Tree
	Loosely following Mozilla Parser AST API and Mesa GLSL Compiler AST

	@author George Corney

	@! todo
	- Expression, Should be interfaces not classes
		Done:
		- Node
		- IterationStatement
		- Statement
		- Declaration
	- ! datatype printing with AST printer
*/

package glsl;

import Type.ValueType.TClass;

interface Node{}

@:publicFields
class Root implements Node{
	var declarations:TranslationUnit;
	public function new(declarations:TranslationUnit){
		this.declarations = declarations;
	}
}

@:publicFields
class TypeSpecifier implements Node{
	var dataType:DataType;
	var storage:StorageQualifier;
	var precision:PrecisionQualifier;
	var invariant:Bool;
	function new(dataType:DataType, ?storage:StorageQualifier, ?precision:PrecisionQualifier, invariant:Bool = false){
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
	function new(typeSpecifier:TypeSpecifier, declarators:StructDeclaratorList){
		this.typeSpecifier = typeSpecifier;
		this.declarators = declarators;
	}
}

typedef StructDeclaratorList = Array<StructDeclarator>;

@:publicFields
class StructDeclarator implements Node{
	var name:String;
	var arraySizeExpression:Expression;
	function new(name:String, ?arraySizeExpression:Expression){
		this.name = name;
		this.arraySizeExpression = arraySizeExpression;
	}
}


@:publicFields//Expressions
interface Expression extends Node{
	var parenWrap:Bool;
}

interface TypedExpression{
	var dataType:DataType;
}

@:publicFields
class Identifier implements Expression{
	var name:String;
	var parenWrap:Bool = false;
	function new(name:String) {
		this.name = name;
	}
}

@:publicFields
class Primitive<T> implements Expression implements TypedExpression{
	var value(default, set):T;
	var raw:String;
	var dataType:DataType;
	var parenWrap:Bool = false;
	function new(value:T, dataType:DataType){
		this.dataType = dataType;
		this.value = value;
	}

	private function set_value(v:T):T{
		switch(dataType){
			case INT: raw = glsl.printer.Utils.glslIntString(cast v);
			case FLOAT: raw = glsl.printer.Utils.glslFloatString(cast v);
			case BOOL: raw = glsl.printer.Utils.glslBoolString(cast v);
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
	var parenWrap:Bool = false;
	function new(op:BinaryOperator, left:Expression, right:Expression){
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
	var parenWrap:Bool = false;
	function new(op:UnaryOperator, arg:Expression, isPrefix:Bool){
		this.op = op;
		this.arg = arg;
		this.isPrefix = isPrefix;
	}
}

@:publicFields
class SequenceExpression implements Expression{
	var expressions:Array<Expression>;
	var parenWrap:Bool = false;
	function new(expressions:Array<Expression>){
		this.expressions = expressions;
	}
}

@:publicFields
class ConditionalExpression implements Expression{
	var test:Expression;
	var consequent:Expression;
	var alternate:Expression;
	var parenWrap:Bool = false;
	function new(test:Expression, consequent:Expression, alternate:Expression){
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
	var parenWrap:Bool = false;
	function new(op:AssignmentOperator, left:Expression, right:Expression){
		this.op = op;
		this.left = left;
		this.right = right;
	}
}

@:publicFields
class FieldSelectionExpression implements Expression{
	var left:Expression;
	var field:Identifier;
	var parenWrap:Bool = false;
	function new(left:Expression, field:Identifier){
		this.left = left;
		this.field = field;
	}
}

@:publicFields
class ArrayElementSelectionExpression implements Expression{
	var left:Expression;
	var arrayIndexExpression:Expression;
	var parenWrap:Bool = false;
	function new(left:Expression, arrayIndexExpression:Expression){
		this.left = left;
		this.arrayIndexExpression = arrayIndexExpression;
	}
}

@:publicFields
class FunctionCall implements Expression{
	var name:String;
	var parameters:Array<Expression>;
	var parenWrap:Bool = false;
	function new(name:String, ?parameters:Array<Expression>){
		this.name = name;
		this.parameters = parameters != null ? parameters : [];
	}
}


@:publicFields//@! could use tighter binding between name and dataType
class Constructor extends FunctionCall implements TypedExpression{
	var dataType:DataType;
	function new(dataType:DataType, ?parameters:Array<Expression>){
		this.dataType = dataType;
		var name = switch (this.dataType) {
			case USER_TYPE(n): n;
			case _: this.dataType.getName().toLowerCase();
		}
		super(name, parameters);
	}
}


@:publicFields//Declarations
interface Declaration extends Node{
	var external:Bool;
}

typedef TranslationUnit = Array<Declaration>;

@:publicFields
class PrecisionDeclaration implements Declaration{
	var precision:PrecisionQualifier;
	var dataType:DataType;
	var external:Bool = false;
	function new(precision:PrecisionQualifier, dataType:DataType){
		this.precision = precision;
		this.dataType = dataType;
	}
}

@:publicFields
class FunctionPrototype implements Declaration{
	var header:FunctionHeader;
	var external:Bool = false;
	function new(header:FunctionHeader){
		this.header = header;
	}
}

@:publicFields
class VariableDeclaration implements Declaration{
	var typeSpecifier:TypeSpecifier;
	var declarators:Array<Declarator>;
	var external:Bool = false;
	function new(typeSpecifier:TypeSpecifier, declarators:Array<Declarator>){
		this.typeSpecifier = typeSpecifier;
		this.declarators = declarators;
	}
}

@:publicFields
class Declarator implements Node{
	var name:String;
	var initializer:Expression;
	var arraySizeExpression:Expression;
	function new(name:String, ?initializer:Expression, ?arraySizeExpression:Expression){
		this.name = name;
		this.initializer = initializer;
		this.arraySizeExpression = arraySizeExpression;
	}
}

@:publicFields
class ParameterDeclaration implements Node{
	var name:String;
	var parameterQualifier:ParameterQualifier;
	var typeSpecifier:TypeSpecifier;
	var arraySizeExpression:Expression;
	function new(name:String, typeSpecifier:TypeSpecifier, ?parameterQualifier:ParameterQualifier, ?arraySizeExpression:Expression){
		this.name = name;
		this.typeSpecifier = typeSpecifier;
		this.parameterQualifier = parameterQualifier;
		this.arraySizeExpression = arraySizeExpression;
	}
}

//in the syntax, FunctionDefinition is actually an external_declaration rather than a declaration

@:publicFields//in this form, they've been combined and to .global is used to signify an external_declaration
class FunctionDefinition implements Declaration{
	var header:FunctionHeader;
	var body:CompoundStatement;
	var external:Bool = true;
	function new(header:FunctionHeader, body:CompoundStatement){
		this.header = header;
		this.body = body;
	}
}

@:publicFields
class FunctionHeader implements Node{
	var name:String;
	var returnType:TypeSpecifier;
	var parameters:Array<ParameterDeclaration>;
	function new(name:String, returnType:TypeSpecifier, ?parameters:Array<ParameterDeclaration>){
		this.name = name;
		this.returnType = returnType;
		this.parameters = parameters != null ? parameters : [];
	}
}


@:publicFields//Statements
interface Statement extends Node{
	var newScope:Bool;
}

typedef StatementList = Array<Statement>;

@:publicFields
class CompoundStatement implements Statement{
	var statementList:StatementList;
	var newScope:Bool;
	function new(statementList:StatementList, newScope:Bool){
		this.statementList = statementList;
		this.newScope = newScope;
	}
}

@:publicFields
class DeclarationStatement implements Statement{
	var declaration:Declaration;
	var newScope:Bool;
	function new(declaration:Declaration){
		this.declaration = declaration;
		this.newScope = false;
	}
}

@:publicFields
class ExpressionStatement implements Statement{
	var expression:Expression;
	var newScope:Bool;
	function new(expression:Expression){
		this.expression = expression;
		this.newScope = false;
	}
}

@:publicFields
class IfStatement implements Statement{
	var test:Expression;
	var consequent:Statement;
	var alternate:Statement;
	var newScope:Bool;
	function new(test:Expression, consequent:Statement, alternate:Statement){
		this.test = test;
		this.consequent = consequent;
		this.alternate = alternate;
		this.newScope = false;
	}
}

@:publicFields
class JumpStatement implements Statement{
	var mode:JumpMode;
	var newScope:Bool;
	function new(mode:JumpMode){
		this.mode = mode;
		this.newScope = false;
	}
}

@:publicFields
class ReturnStatement extends JumpStatement{
	var returnExpression:Expression;
	function new(returnExpression:Expression){
		this.returnExpression = returnExpression;
		super(RETURN);
	}
}

interface IterationStatement extends Statement{
	var body:Statement;
	var newScope:Bool;
}

@:publicFields
class WhileStatement implements IterationStatement{
	var test:Expression;
	var body:Statement;
	var newScope:Bool;
	function new(test:Expression, body:Statement){
		this.test = test;
		this.body = body;
		this.newScope = false;
	}
}

@:publicFields
class DoWhileStatement implements IterationStatement{
	var test:Expression;
	var body:Statement;
	var newScope:Bool;
	function new(test:Expression, body:Statement){
		this.test = test;
		this.body = body;
		this.newScope = false;
	}
}

@:publicFields
class ForStatement implements IterationStatement{
	var init:Statement;
	var test:Expression;
	var update:Expression;
	var body:Statement;
	var newScope:Bool;
	function new(init:Statement, test:Expression, update:Expression, body:Statement){
		this.init = init;
		this.test = test;
		this.update = update;
		this.body = body;
		this.newScope = false;
	}
}

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


enum NodeEnum{
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
}

@:publicFields
class NodeEnumHelper{
	static public function toEnum(n:Node):NodeEnum{
		return switch (Type.typeof(n)) {
			case TClass(Root)                            : RootNode(untyped n);
			case TClass(TypeSpecifier)                   : TypeSpecifierNode(untyped n);
			case TClass(StructSpecifier)                 : StructSpecifierNode(untyped n);
			case TClass(StructFieldDeclaration)          : StructFieldDeclarationNode(untyped n);
			case TClass(StructDeclarator)                : StructDeclaratorNode(untyped n);
			case TClass(Expression)                      : ExpressionNode(untyped n);
			case TClass(Identifier)                      : IdentifierNode(untyped n);
			case TClass(Primitive)                       : PrimitiveNode(untyped n);
			case TClass(BinaryExpression)                : BinaryExpressionNode(untyped n);
			case TClass(UnaryExpression)                 : UnaryExpressionNode(untyped n);
			case TClass(SequenceExpression)              : SequenceExpressionNode(untyped n);
			case TClass(ConditionalExpression)           : ConditionalExpressionNode(untyped n);
			case TClass(AssignmentExpression)            : AssignmentExpressionNode(untyped n);
			case TClass(FieldSelectionExpression)        : FieldSelectionExpressionNode(untyped n);
			case TClass(ArrayElementSelectionExpression) : ArrayElementSelectionExpressionNode(untyped n);
			case TClass(FunctionCall)                    : FunctionCallNode(untyped n);
			case TClass(Constructor)                     : ConstructorNode(untyped n);
			case TClass(Declaration)                     : DeclarationNode(untyped n);
			case TClass(PrecisionDeclaration)            : PrecisionDeclarationNode(untyped n);
			case TClass(VariableDeclaration)             : VariableDeclarationNode(untyped n);
			case TClass(Declarator)                      : DeclaratorNode(untyped n);
			case TClass(ParameterDeclaration)            : ParameterDeclarationNode(untyped n);
			case TClass(FunctionDefinition)              : FunctionDefinitionNode(untyped n);
			case TClass(FunctionPrototype)               : FunctionPrototypeNode(untyped n);
			case TClass(FunctionHeader)                  : FunctionHeaderNode(untyped n);
			case TClass(Statement)                       : StatementNode(untyped n);
			case TClass(CompoundStatement)               : CompoundStatementNode(untyped n);
			case TClass(DeclarationStatement)            : DeclarationStatementNode(untyped n);
			case TClass(ExpressionStatement)             : ExpressionStatementNode(untyped n);
			case TClass(IterationStatement)              : IterationStatementNode(untyped n);
			case TClass(WhileStatement)                  : WhileStatementNode(untyped n);
			case TClass(DoWhileStatement)                : DoWhileStatementNode(untyped n);
			case TClass(ForStatement)                    : ForStatementNode(untyped n);
			case TClass(IfStatement)                     : IfStatementNode(untyped n);
			case TClass(JumpStatement)                   : JumpStatementNode(untyped n);
			case TClass(ReturnStatement)                 : ReturnStatementNode(untyped n);
			case null, _: null; //unrecognized node
		}
	}
}