/*
	GLSL Abstract Syntax Tree
	Design guided by Mozilla Parser AST API and Mesa GLSL Compiler AST

	@author George Corney

	//#! add node position and length
	//#! define more binary expression subclasses
*/

package glslparser;

@:publicFields
class Node{
	var nodeTypeName:String;
	function new(){
		this.nodeTypeName = Type.getClassName(Type.getClass(this)).split('.').pop();
	}
}

class TypeSpecifier extends Node{
	var typeName:String;
	var typeClass:TypeClass;
	var qualifier:TypeQualifier;
	var precision:PrecisionQualifier;
	function new(typeClass:TypeClass, typeName:String, ?qualifier:TypeQualifier, ?precision:PrecisionQualifier){
		this.typeName = typeName;
		this.typeClass = typeClass;
		this.qualifier = qualifier;
		this.precision = precision;
		super();
	}
}

class StructSpecifier extends TypeSpecifier{
	var structDeclarations:StructDeclarationList;
	function new(name:String, structDeclarations:StructDeclarationList){
		this.structDeclarations = structDeclarations;
		super(STRUCT, name);
	}
}

typedef StructDeclarationList = Array<StructDeclaration>;


class StructDeclaration extends Node{ //#! extend Declaration? Is global meaningful here?
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
	function new(name:String){
		this.name = name;
		super();
	}
}

class StructArrayDeclarator extends StructDeclarator{
	var arraySizeExpression:Expression;
	function new(name:String, arraySizeExpression:Expression){
		this.arraySizeExpression = arraySizeExpression;
		super(name);
	}
}

//Expressions
class Expression extends Node{
	var parenWrap:Bool;
}

class Identifier extends Expression{
	var name:String;
	function new(name:String) {
		this.name = name;
		super();
	}
}

class Literal<T> extends Expression{
	var value:T;
	var raw:String;
	var typeClass:TypeClass;
	function new(value:T, raw:String, typeClass:TypeClass){
		this.value = value;
		this.raw = raw;
		this.typeClass = typeClass;
		super();
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
	function new(name, ?parameters){
		this.name = name;
		this.parameters = parameters != null ? parameters : [];
		super();
	}
}

class FunctionHeader extends Expression{
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


//Declarations
class Declaration extends Expression{
	var global:Bool;
}

typedef TranslationUnit = Array<Declaration>;

class PrecisionDeclaration extends Declaration{
	var precision:PrecisionQualifier;
	var typeSpecifier:TypeSpecifier;
	function new(precision:PrecisionQualifier, typeSpecifier:TypeSpecifier){
		this.precision = precision;
		this.typeSpecifier = typeSpecifier;
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
	var invariant:Bool;
	var initializer:Expression;
	function new(name:String, ?initializer:Expression, invariant:Bool = false){
		this.name = name;
		this.initializer = initializer;
		this.invariant = invariant;
		super();
	}
}

class ArrayDeclarator extends Declarator{
	var arraySizeExpression:Expression;
	function new(name:String, arraySizeExpression:Expression){
		this.arraySizeExpression = arraySizeExpression;
		super(name, null, false);
	}
}

class ParameterDeclaration extends Declaration{
	var name:String;
	var parameterQualifier:ParameterQualifier;
	var typeQualifier:TypeQualifier;
	var typeSpecifier:TypeSpecifier;
	var arraySizeExpression:Expression;
	function new(name:String, typeSpecifier:TypeSpecifier, ?parameterQualifier:ParameterQualifier, ?typeQualifier:TypeQualifier, ?arraySizeExpression:Expression){
		this.name = name;
		this.typeSpecifier = typeSpecifier;
		this.parameterQualifier = parameterQualifier;
		this.typeQualifier = typeQualifier;
		this.arraySizeExpression = arraySizeExpression;
		super();
	}
}

class FunctionDefinition extends Declaration{
	var header:FunctionHeader;
	var body:CompoundStatement;
	function new(header:FunctionHeader, body:CompoundStatement){
		this.header = header;
		this.body = body;
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
	function new(statementList:StatementList, newScope:Bool = false){
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
	var returnValue:Expression;
	function new(returnValue:Expression){
		this.returnValue = returnValue;
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

enum TypeClass{
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
	STRUCT;
	TYPE_NAME;
}

enum ParameterQualifier{
	IN;
	OUT;
	INOUT;
}

enum TypeQualifier{
	CONST;
	ATTRIBUTE;
	VARYING;
	INVARIANT_VARYING;
	UNIFORM;
}