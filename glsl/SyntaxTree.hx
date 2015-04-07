/*
	GLSL Abstract Syntax Tree
	Loosely following Mozilla Parser AST API and Mesa GLSL Compiler AST

	@author George Corney

	@! todo
	- Node, Expression, Declaration, IterationStatement
		should be interfaces not classes
*/

package glsl;

import Type.ValueType.TClass;

@:publicFields
class Node{
	var nodeName:String;
	function new(){
		this.nodeName = Type.getClassName(Type.getClass(this)).split('.').pop();
	}
}

class Root extends Node{
	var declarations:TranslationUnit;
	public function new(declarations:TranslationUnit){
		this.declarations = declarations;
		super();
	}
}

class TypeSpecifier extends Node{
	var dataType:DataType;
	var storage:StorageQualifier;
	var precision:PrecisionQualifier;
	var invariant:Bool;
	function new(dataType:DataType, ?storage:StorageQualifier, ?precision:PrecisionQualifier, invariant:Bool = false){
		this.dataType = dataType;
		this.storage = storage;
		this.precision = precision;
		this.invariant = invariant;
		super();
	}
}

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

class StructFieldDeclaration extends Node{ //@! extend Declaration? Is global meaningful here?
	var typeSpecifier:TypeSpecifier;
	var declarators:StructDeclaratorList;
	function new(typeSpecifier:TypeSpecifier, declarators:StructDeclaratorList){
		this.typeSpecifier = typeSpecifier;
		this.declarators = declarators;
		super();
	}
}

typedef StructDeclaratorList = Array<StructDeclarator>;

class StructDeclarator extends Node{
	var name:String;
	var arraySizeExpression:Expression;
	function new(name:String, ?arraySizeExpression:Expression){
		this.name = name;
		this.arraySizeExpression = arraySizeExpression;
		super();
	}
}

//Expressions
class Expression extends Node{
	var parenWrap:Bool;
}

interface TypedExpression{
	var dataType:DataType;
}

class Identifier extends Expression{
	var name:String;
	function new(name:String) {
		this.name = name;
		super();
	}
}

class Primitive<T> extends Expression implements TypedExpression{
	var value(default, set):T;
	var raw:String;
	var dataType:DataType;

	function new(value:T, dataType:DataType){
		this.dataType = dataType;
		this.value = value;
		super();
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

class BinaryExpression extends Expression{
	var op:BinaryOperator;
	var left:Expression;
	var right:Expression;
	function new(op:BinaryOperator, left:Expression, right:Expression){
		this.op = op;
		this.left = left;
		this.right = right;
		super();
	}
}

class UnaryExpression extends Expression{
	var op:UnaryOperator;
	var arg:Expression;
	var isPrefix:Bool;
	function new(op:UnaryOperator, arg:Expression, isPrefix:Bool){
		this.op = op;
		this.arg = arg;
		this.isPrefix = isPrefix;
		super();
	}
}

class SequenceExpression extends Expression{
	var expressions:Array<Expression>;
	function new(expressions:Array<Expression>){
		this.expressions = expressions;
		super();
	}
}

class ConditionalExpression extends Expression{
	var test:Expression;
	var consequent:Expression;
	var alternate:Expression;
	function new(test:Expression, consequent:Expression, alternate:Expression){
		this.test = test;
		this.consequent = consequent;
		this.alternate = alternate;
		super();
	}
}

class AssignmentExpression extends Expression{
	var op:AssignmentOperator;
	var left:Expression;
	var right:Expression;
	function new(op:AssignmentOperator, left:Expression, right:Expression){
		this.op = op;
		this.left = left;
		this.right = right;
		super();
	}
}

class FieldSelectionExpression extends Expression{
	var left:Expression;
	var field:Identifier;
	function new(left:Expression, field:Identifier){
		this.left = left;
		this.field = field;
		super();
	}
}

class ArrayElementSelectionExpression extends Expression{
	var left:Expression;
	var arrayIndexExpression:Expression;
	function new(left:Expression, arrayIndexExpression:Expression){
		this.left = left;
		this.arrayIndexExpression = arrayIndexExpression;
		super();	
	}
}

class FunctionCall extends Expression{
	var name:String;
	var parameters:Array<Expression>;
	function new(name:String, ?parameters:Array<Expression>){
		this.name = name;
		this.parameters = parameters != null ? parameters : [];
		super();
	}
}

//@! could use tighter binding between name and dataType
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

//Declarations
class Declaration extends Expression{
	var global:Bool;
}

typedef TranslationUnit = Array<Declaration>;

class PrecisionDeclaration extends Declaration{
	var precision:PrecisionQualifier;
	var dataType:DataType;
	function new(precision:PrecisionQualifier, dataType:DataType){
		this.precision = precision;
		this.dataType = dataType;
		super();
	}
}

class FunctionPrototype extends Declaration{
	var header:FunctionHeader;
	function new(header:FunctionHeader){
		this.header = header;
		super();
	}
}

class VariableDeclaration extends Declaration{
	var typeSpecifier:TypeSpecifier;
	var declarators:Array<Declarator>;
	function new(typeSpecifier:TypeSpecifier, declarators:Array<Declarator>){
		this.typeSpecifier = typeSpecifier;
		this.declarators = declarators;
		super();
	}
}

class Declarator extends Node{
	var name:String;
	var initializer:Expression;
	var arraySizeExpression:Expression;
	function new(name:String, ?initializer:Expression, ?arraySizeExpression:Expression){
		this.name = name;
		this.initializer = initializer;
		this.arraySizeExpression = arraySizeExpression;
		super();
	}
}

class ParameterDeclaration extends Node{
	var name:String;
	var parameterQualifier:ParameterQualifier;
	var typeSpecifier:TypeSpecifier;
	var arraySizeExpression:Expression;
	function new(name:String, typeSpecifier:TypeSpecifier, ?parameterQualifier:ParameterQualifier, ?arraySizeExpression:Expression){
		this.name = name;
		this.typeSpecifier = typeSpecifier;
		this.parameterQualifier = parameterQualifier;
		this.arraySizeExpression = arraySizeExpression;
		super();
	}
}

//in the syntax, FunctionDefinition is actually an external_declaration rather than a declaration
//in this form, they've been combined and to .global is used to signify an external_declaration
class FunctionDefinition extends Declaration{
	var header:FunctionHeader;
	var body:CompoundStatement;
	function new(header:FunctionHeader, body:CompoundStatement){
		this.header = header;
		this.body = body;
		super();
	}
}

class FunctionHeader extends Node{
	var name:String;
	var returnType:TypeSpecifier;
	var parameters:Array<ParameterDeclaration>;
	function new(name:String, returnType:TypeSpecifier, ?parameters:Array<ParameterDeclaration>){
		this.name = name;
		this.returnType = returnType;
		this.parameters = parameters != null ? parameters : [];
		super();
	}
}

//Statements
class Statement extends Node{
	var newScope:Bool;
	function new(newScope:Bool){
		this.newScope = newScope;
		super();
	}
}

typedef StatementList = Array<Statement>;

class CompoundStatement extends Statement{
	var statementList:StatementList;
	function new(statementList:StatementList, newScope:Bool){
		this.statementList = statementList;
		super(newScope);
	}
}

class DeclarationStatement extends Statement{
	var declaration:Declaration;
	function new(declaration:Declaration){
		this.declaration = declaration;
		super(false);
	}
}

class ExpressionStatement extends Statement{
	var expression:Expression;
	function new(expression:Expression){
		this.expression = expression;
		super(false);
	}
}

class IterationStatement extends Statement{
	var body:Statement;
	function new(body:Statement){
		this.body = body;
		super(false);
	}
}

class WhileStatement extends IterationStatement{
	var test:Expression;
	function new(test:Expression, body:Statement){
		this.test = test;
		super(body);
	}
}

class DoWhileStatement extends IterationStatement{
	var test:Expression;
	function new(test:Expression, body:Statement){
		this.test = test;
		super(body);
	}
}

class ForStatement extends IterationStatement{
	var init:Statement;
	var test:Expression;
	var update:Expression;
	function new(init:Statement, test:Expression, update:Expression, body:Statement){
		this.init = init;
		this.test = test;
		this.update = update;
		super(body);
	}
}

class IfStatement extends Statement{
	var test:Expression;
	var consequent:Statement;
	var alternate:Statement;
	function new(test:Expression, consequent:Statement, alternate:Statement){
		this.test = test;
		this.consequent = consequent;
		this.alternate = alternate;
		super(false);
	}
}

class JumpStatement extends Statement{
	var mode:JumpMode;
	function new(mode:JumpMode){
		this.mode = mode;
		super(false);
	}
}

class ReturnStatement extends JumpStatement{
	var returnExpression:Expression;
	function new(returnExpression:Expression){
		this.returnExpression = returnExpression;
		super(RETURN);
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
			default: null; //unrecognized node
		}
	}
}