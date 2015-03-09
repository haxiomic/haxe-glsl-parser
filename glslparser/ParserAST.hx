package glslparser;

//#! also add node location (+lenght)? (Computed from the subnode's positions)
//Define leaf type that is a proxy for a token?
//Perhaps some sort of isGlobal bool on declarations to account for external_declaration

import glslparser.Parser.EMinorType;
import glslparser.Parser.MinorType;
import glslparser.Tokenizer.Token;
import glslparser.Tokenizer.TokenType;


//AST definitions
//Loosely following Mozilla Parser AST API 
//And guided by Mesa Compiler AST
//http://people.freedesktop.org/~chadversary/mesa/doxygen/kevin-rogovin/d7/d26/group__AST.html

//Review use and meaning of Expression

//Grouping rules into classes
/*
translation_unit:

- Expression
	expression:
	constant_expression:
	integer_expression:
	primary_expression:

	postfix_expression:

	- ConditionalExpression
		conditional_expression:

	- UnaryExpression
		unary_expression:
		postfix_expression: (unary case)

	- BinaryExpression
		multiplicative_expression:
		additive_expression:
		shift_expression:
		relational_expression:
		equality_expression:
		and_expression:
		exclusive_or_expression:
		inclusive_or_expression:

		- LogicalExpression
			logical_and_expression:
			logical_xor_expression:
			logical_or_expression:

	- CallExpression?
		function_call:
		function_call_generic:
		function_call_header_no_parameters:
		function_call_header_with_parameters:
		function_call_header:
		function_identifier:

	- AssignmentExpression
		assignment_expression:

- Declaration
	declaration:
		init_declarator_list: ?

	single_declaration:
		fully_specified_type:
		type_qualifier:
		type_specifier:
		type_specifier_no_prec:
		precision_qualifier:
		initializer:

	external_declaration:

	- FunctionPrototype
		function_prototype:
	
	- FunctionDeclaration
		function_definition:
			function_header:
				function_header_with_parameters:
				function_declarator:
				parameter_declarator:
				parameter_declaration:
				parameter_qualifier:
				parameter_type_specifier:

	- StructDeclaration
		struct_declaration:
			struct_declarator:
			struct_specifier:

	- StructDeclarationList? 
		struct_declaration_list:
			struct_declarator_list:


- Condition ?
	condition:
	conditionopt:

- StatementList ?
	statement_list:
	
- Statement
	simple_statement:
	statement_with_scope:
	statement_no_new_scope:

	- ExpressionStatement
		expression_statement:

	- DeclarationStatement
		declaration_statement:

	- IterationStatement
		iteration_statement:

		- ForStatement
			for_init_statement:
			for_rest_statement:

		- IfStatement
			selection_statement:
			selection_rest_statement:

	- JumpStatement
		- ContinueStatement
			jump_statement:
		- BreakStatement
			jump_statement:
		- ReturnStatement
			jump_statement:
		- ReturnStatement
			jump_statement:
		- DiscardStatement
			jump_statement:

	- Break

	- Compound Statement?
		compound_statement_with_scope:
		compound_statement_no_new_scope:


//Misc
- Literal
- Identifier
	variable_identifier:

	constructor_identifier: (:TokenType)

- Operator (simple type)
	unary_operator: (:TokenType)
	assignment_operator: (:TokenType)

*/

//#! unfinished types

@:publicFields
class Node{
	public function new(){
		trace(' --- New node: '+debugClassName() +' -> '+ debugString());
	}

	function debugClassName(){
		return Type.getClassName(Type.getClass(this)).split('.').pop();
	}

	function debugString(){//#!
		var m:MinorType = this;
		return Std.string(m);
	}

	// public function toGLSL():String return ''; //#!
}

class TypeSpecifier extends Node{
	var name:String;
	var typeClass:TypeClass;
	var precisionQualifier:PrecisionQualifier;
	public function new(typeClass:TypeClass, name:String, ?precisionQualifier:PrecisionQualifier){
		this.name = name;
		this.typeClass = typeClass;
		this.precisionQualifier = precisionQualifier;
		super();
	}
}

class StructSpecifier extends TypeSpecifier{
	public function new(name:String){
		super(STRUCT, name);
	}
}

class FullySpecifiedType extends Node{
	var specifier:TypeSpecifier;
	var qualifier:TypeQualifier;
	public function new(specifier:TypeSpecifier, ?qualifier:TypeQualifier){
		this.specifier = specifier;
		this.qualifier = qualifier;
		super();
	}
}

//Expressions
class Expression extends Node{
	public function new(){
		super();
	}
}

class Identifier extends Expression{
	var name:String;
	public function new(name:String) {
		this.name = name;
		super();
	}
}

class Literal<T> extends Expression{
	var value:T;
	var raw:String;
	public function new(value:T, raw:String){
		this.value = value;
		this.raw = raw;
		super();
	}
}

class BinaryExpression extends Expression{
	var op:BinaryOperator;
	var left:Expression;
	var right:Expression;

	public function new(op:BinaryOperator, left:Expression, right:Expression){
		this.op = op;
		this.left = left;
		this.right = right;
		super();
	}
}

class LogicalExpression extends BinaryExpression{}

class UnaryExpression extends Expression{
	var op:UnaryOperator;
	var arg:Node;//#! should be expression?
	var isPrefix:Bool;
	public function new(op:UnaryOperator, arg:Node, isPrefix:Bool){
		this.op = op;
		this.arg = arg;
		this.isPrefix = isPrefix;
		super();
	}
}

class ConditionalExpression extends Expression{
	var test:Expression;
	var alternate:Expression;
	var consequent:Expression;
}

class AssignmentExpression extends Expression{
	var op:AssignmentOperator;
	var left:Expression;//#! not sure
	var right:Expression;
}

class FunctionCallExpression extends Expression{
	var callee:Expression;
	var args:Expression;
}

class FunctionIdentifier extends Node{
	var name:String;
	var typeClass:ConstructableType;
	public function new(typeClass:ConstructableType, name:String){
		this.name = name;
		this.typeClass = typeClass;
		super();
	}
}

//Declarations
class Declaration extends Node{}

//Special Statements
class JumpStatement extends Node{
	var mode:JumpMode;
	public function new(mode:JumpMode){
		this.mode = mode;
		super();
	}
}

class ReturnStatement extends JumpStatement{
	var returnValue:Expression;
	public function new(returnValue:Expression){
		this.returnValue = returnValue;
		super(RETURN);
	}
}

//Base Types #! look into enum abstracts
typedef BinaryOperator = TokenType;
typedef UnaryOperator = TokenType;
typedef AssignmentOperator = TokenType;
typedef PrecisionQualifier = TokenType;
typedef ParameterQualifier = TokenType;
typedef TypeQualifier = TokenType;
typedef JumpMode = TokenType;

typedef TypeClass = TokenType;// basic types + STRUCT + TYPE_NAME
typedef ConstructableType = TokenType;// IDENTIFIER + basic types + TYPE_NAME


@:access(glslparser.Parser)
class ParserAST{
	static var i(get, null):Int;
	static var stack(get, null):Parser.Stack;
	static var ruleno;

	static public function createNode(ruleno:Int):MinorType{
		ParserAST.ruleno = ruleno; //set class ruleno so it can be accessed by other functions

		switch(ruleno){
			case 0: return s(1); //root ::= translation_unit
			case 1: return new Identifier(t(1).data);//variable_identifier ::= IDENTIFIER
			case 2: return s(1); //primary_expression ::= variable_identifier
			case 3: return new Literal<Int>(Std.parseInt(t(1).data), t(1).data);//primary_expression ::= INTCONSTANT
			case 4: return new Literal<Float>(Std.parseFloat(t(1).data), t(1).data); //primary_expression ::= FLOATCONSTANT
			case 5: return new Literal<Bool>(t(1).data == 'true', t(1).data); //primary_expression ::= BOOLCONSTANT
			case 6: //primary_expression ::= LEFT_PAREN expression RIGHT_PAREN
			case 7: return s(1); //postfix_expression ::= primary_expression
			case 8: //postfix_expression ::= postfix_expression LEFT_BRACKET integer_expression RIGHT_BRACKET
			case 9: return s(1); //postfix_expression ::= function_call
			case 10: //postfix_expression ::= postfix_expression DOT FIELD_SELECTION
			case 11: return new UnaryExpression(t(2).type, n(1), false); //postfix_expression ::= postfix_expression INC_OP
			case 12: return new UnaryExpression(t(2).type, n(1), false); //postfix_expression ::= postfix_expression DEC_OP
			case 13: return s(1); //integer_expression ::= expression
			case 14: return s(1); //function_call ::= function_call_generic
			case 15: //function_call_generic ::= function_call_header_with_parameters RIGHT_PAREN
			case 16: //function_call_generic ::= function_call_header_no_parameters RIGHT_PAREN
			case 17: //function_call_header_no_parameters ::= function_call_header VOID
			case 18: return s(1); //function_call_header_no_parameters ::= function_call_header
			case 19: //function_call_header_with_parameters ::= function_call_header assignment_expression
			case 20: //function_call_header_with_parameters ::= function_call_header_with_parameters COMMA assignment_expression
			case 21: //function_call_header ::= function_identifier LEFT_PAREN
			case 22: return new FunctionIdentifier(t(1).type, t(1).data); //function_identifier ::= constructor_identifier
			case 23: return new FunctionIdentifier(t(1).type, t(1).data); //function_identifier ::= IDENTIFIER
			case 24: return s(1);//constructor_identifier ::= FLOAT
			case 25: return s(1);//constructor_identifier ::= INT
			case 26: return s(1);//constructor_identifier ::= BOOL
			case 27: return s(1);//constructor_identifier ::= VEC2
			case 28: return s(1);//constructor_identifier ::= VEC3
			case 29: return s(1);//constructor_identifier ::= VEC4
			case 30: return s(1);//constructor_identifier ::= BVEC2
			case 31: return s(1);//constructor_identifier ::= BVEC3
			case 32: return s(1);//constructor_identifier ::= BVEC4
			case 33: return s(1);//constructor_identifier ::= IVEC2
			case 34: return s(1);//constructor_identifier ::= IVEC3
			case 35: return s(1);//constructor_identifier ::= IVEC4
			case 36: return s(1);//constructor_identifier ::= MAT2
			case 37: return s(1);//constructor_identifier ::= MAT3
			case 38: return s(1);//constructor_identifier ::= MAT4
			case 39: return s(1);//constructor_identifier ::= TYPE_NAME
			case 40: //return s(1); //unary_expression ::= postfix_expression
			case 41: return new UnaryExpression(t(1).type, n(2), true); //unary_expression ::= INC_OP unary_expression
			case 42: return new UnaryExpression(t(1).type, n(2), true); //unary_expression ::= DEC_OP unary_expression
			case 43: return new UnaryExpression(t(1).type, n(2), true); //unary_expression ::= unary_operator unary_expression
			case 44: return s(1); //unary_operator ::= PLUS
			case 45: return s(1); //unary_operator ::= DASH
			case 46: return s(1); //unary_operator ::= BANG
			case 47: return s(1); //unary_operator ::= TILDE
			case 48: return s(1); //multiplicative_expression ::= unary_expression
			case 49: //multiplicative_expression ::= multiplicative_expression STAR unary_expression
			case 50: //multiplicative_expression ::= multiplicative_expression SLASH unary_expression
			case 51: //multiplicative_expression ::= multiplicative_expression PERCENT unary_expression
			case 52: return s(1); //additive_expression ::= multiplicative_expression
			case 53: //additive_expression ::= additive_expression PLUS multiplicative_expression
			case 54: //additive_expression ::= additive_expression DASH multiplicative_expression
			case 55: return s(1); //shift_expression ::= additive_expression
			case 56: //shift_expression ::= shift_expression LEFT_OP additive_expression
			case 57: //shift_expression ::= shift_expression RIGHT_OP additive_expression
			case 58: return s(1); //relational_expression ::= shift_expression
			case 59: //relational_expression ::= relational_expression LEFT_ANGLE shift_expression
			case 60: //relational_expression ::= relational_expression RIGHT_ANGLE shift_expression
			case 61: //relational_expression ::= relational_expression LE_OP shift_expression
			case 62: //relational_expression ::= relational_expression GE_OP shift_expression
			case 63: return s(1); //equality_expression ::= relational_expression
			case 64: //equality_expression ::= equality_expression EQ_OP relational_expression
			case 65: //equality_expression ::= equality_expression NE_OP relational_expression
			case 66: return s(1); //and_expression ::= equality_expression
			case 67: //and_expression ::= and_expression AMPERSAND equality_expression
			case 68: return s(1); //exclusive_or_expression ::= and_expression
			case 69: //exclusive_or_expression ::= exclusive_or_expression CARET and_expression
			case 70: return s(1); //inclusive_or_expression ::= exclusive_or_expression
			case 71: //inclusive_or_expression ::= inclusive_or_expression VERTICAL_BAR exclusive_or_expression
			case 72: return s(1); //logical_and_expression ::= inclusive_or_expression
			case 73: //logical_and_expression ::= logical_and_expression AND_OP inclusive_or_expression
			case 74: return s(1); //logical_xor_expression ::= logical_and_expression
			case 75: //logical_xor_expression ::= logical_xor_expression XOR_OP logical_and_expression
			case 76: return s(1); //logical_or_expression ::= logical_xor_expression
			case 77: //logical_or_expression ::= logical_or_expression OR_OP logical_xor_expression
			case 78: return s(1); //conditional_expression ::= logical_or_expression
			case 79: //conditional_expression ::= logical_or_expression QUESTION expression COLON assignment_expression
			case 80: return s(1); //assignment_expression ::= conditional_expression
			case 81: //assignment_expression ::= unary_expression assignment_operator assignment_expression
			case 82: return s(1); //assignment_operator ::= EQUAL
			case 83: return s(1); //assignment_operator ::= MUL_ASSIGN
			case 84: return s(1); //assignment_operator ::= DIV_ASSIGN
			case 85: return s(1); //assignment_operator ::= MOD_ASSIGN
			case 86: return s(1); //assignment_operator ::= ADD_ASSIGN
			case 87: return s(1); //assignment_operator ::= SUB_ASSIGN
			case 88: return s(1); //assignment_operator ::= LEFT_ASSIGN
			case 89: return s(1); //assignment_operator ::= RIGHT_ASSIGN
			case 90: return s(1); //assignment_operator ::= AND_ASSIGN
			case 91: return s(1); //assignment_operator ::= XOR_ASSIGN
			case 92: return s(1); //assignment_operator ::= OR_ASSIGN
			case 93: return s(1); //expression ::= assignment_expression
			case 94: //expression ::= expression COMMA assignment_expression
			case 95: return s(1); //constant_expression ::= conditional_expression
			case 96: //declaration ::= function_prototype SEMICOLON
			case 97: //declaration ::= init_declarator_list SEMICOLON
			case 98: //declaration ::= PRECISION precision_qualifier type_specifier_no_prec SEMICOLON
			case 99: //function_prototype ::= function_declarator RIGHT_PAREN
			case 100: return s(1); //function_declarator ::= function_header
			case 101: return s(1); //function_declarator ::= function_header_with_parameters
			case 102: //function_header_with_parameters ::= function_header parameter_declaration
			case 103: //function_header_with_parameters ::= function_header_with_parameters COMMA parameter_declaration
			case 104: //function_header ::= fully_specified_type IDENTIFIER LEFT_PAREN
			case 105: //parameter_declarator ::= type_specifier IDENTIFIER
			case 106: //parameter_declarator ::= type_specifier IDENTIFIER LEFT_BRACKET constant_expression RIGHT_BRACKET
			case 107: //parameter_declaration ::= type_qualifier parameter_qualifier parameter_declarator
			case 108: //parameter_declaration ::= parameter_qualifier parameter_declarator
			case 109: //parameter_declaration ::= type_qualifier parameter_qualifier parameter_type_specifier
			case 110: //parameter_declaration ::= parameter_qualifier parameter_type_specifier
			case 111: //parameter_qualifier ::=
			case 112: return s(1);//parameter_qualifier ::= IN
			case 113: return s(1);//parameter_qualifier ::= OUT
			case 114: return s(1);//parameter_qualifier ::= INOUT
			case 115: return s(1); //parameter_type_specifier ::= type_specifier
			case 116: //parameter_type_specifier ::= type_specifier LEFT_BRACKET constant_expression RIGHT_BRACKET
			case 117: return s(1); //init_declarator_list ::= single_declaration
			case 118: //init_declarator_list ::= init_declarator_list COMMA IDENTIFIER
			case 119: //init_declarator_list ::= init_declarator_list COMMA IDENTIFIER LEFT_BRACKET constant_expression RIGHT_BRACKET
			case 120: //init_declarator_list ::= init_declarator_list COMMA IDENTIFIER EQUAL initializer
			case 121: return s(1); //single_declaration ::= fully_specified_type
			case 122: //single_declaration ::= fully_specified_type IDENTIFIER
			case 123: //single_declaration ::= fully_specified_type IDENTIFIER LEFT_BRACKET constant_expression RIGHT_BRACKET
			case 124: //single_declaration ::= fully_specified_type IDENTIFIER EQUAL initializer
			case 125: //single_declaration ::= INVARIANT IDENTIFIER
			case 126: return new FullySpecifiedType(cast n(1)); //fully_specified_type ::= type_specifier
			case 127: return new FullySpecifiedType(cast n(2), t(1).type); //fully_specified_type ::= type_qualifier type_specifier
			case 128: return s(1); //type_qualifier ::= CONST
			case 129: return s(1); //type_qualifier ::= ATTRIBUTE
			case 130: return s(1); //type_qualifier ::= VARYING
			case 131: return s(1); //type_qualifier ::= INVARIANT VARYING
			case 132: return s(1); //type_qualifier ::= UNIFORM
			case 133: return switch (s(1).type) { //type_specifier ::= type_specifier_no_prec
							case Token(tkn): new TypeSpecifier(tkn.type, tkn.data);
							case Node(n): s(1);
						}
			case 134: return switch (s(2).type) { //type_specifier ::= precision_qualifier type_specifier_no_prec
							case Token(tkn): new TypeSpecifier(tkn.type, tkn.data, t(1).type);
							case Node(n): 
								var ts = cast(n, TypeSpecifier);
								ts.precisionQualifier = t(1).type; 
								ts;
						}
			case 135: return s(1); //type_specifier_no_prec ::= VOID
			case 136: return s(1); //type_specifier_no_prec ::= FLOAT
			case 137: return s(1); //type_specifier_no_prec ::= INT
			case 138: return s(1); //type_specifier_no_prec ::= BOOL
			case 139: return s(1); //type_specifier_no_prec ::= VEC2
			case 140: return s(1); //type_specifier_no_prec ::= VEC3
			case 141: return s(1); //type_specifier_no_prec ::= VEC4
			case 142: return s(1); //type_specifier_no_prec ::= BVEC2
			case 143: return s(1); //type_specifier_no_prec ::= BVEC3
			case 144: return s(1); //type_specifier_no_prec ::= BVEC4
			case 145: return s(1); //type_specifier_no_prec ::= IVEC2
			case 146: return s(1); //type_specifier_no_prec ::= IVEC3
			case 147: return s(1); //type_specifier_no_prec ::= IVEC4
			case 148: return s(1); //type_specifier_no_prec ::= MAT2
			case 149: return s(1); //type_specifier_no_prec ::= MAT3
			case 150: return s(1); //type_specifier_no_prec ::= MAT4
			case 151: return s(1); //type_specifier_no_prec ::= SAMPLER2D
			case 152: return s(1); //type_specifier_no_prec ::= SAMPLERCUBE
			case 153: return s(1); //type_specifier_no_prec ::= struct_specifier
			case 154: return s(1); //type_specifier_no_prec ::= TYPE_NAME
			case 155: return s(1); //precision_qualifier ::= HIGH_PRECISION
			case 156: return s(1); //precision_qualifier ::= MEDIUM_PRECISION
			case 157: return s(1); //precision_qualifier ::= LOW_PRECISION
			case 158: //struct_specifier ::= STRUCT IDENTIFIER LEFT_BRACE struct_declaration_list RIGHT_BRACE
			case 159: //struct_specifier ::= STRUCT LEFT_BRACE struct_declaration_list RIGHT_BRACE
			case 160: return s(1); //struct_declaration_list ::= struct_declaration
			case 161: //struct_declaration_list ::= struct_declaration_list struct_declaration
			case 162: //struct_declaration ::= type_specifier struct_declarator_list SEMICOLON
			case 163: return s(1); //struct_declarator_list ::= struct_declarator
			case 164: //struct_declarator_list ::= struct_declarator_list COMMA struct_declarator
			case 165: //struct_declarator ::= IDENTIFIER
			case 166: //struct_declarator ::= IDENTIFIER LEFT_BRACKET constant_expression RIGHT_BRACKET
			case 167: return s(1); //initializer ::= assignment_expression
			case 168: return s(1); //declaration_statement ::= declaration
			case 169: return s(1); //statement_no_new_scope ::= compound_statement_with_scope
			case 170: return s(1); //statement_no_new_scope ::= simple_statement
			case 171: return s(1); //simple_statement ::= declaration_statement
			case 172: return s(1); //simple_statement ::= expression_statement
			case 173: return s(1); //simple_statement ::= selection_statement
			case 174: return s(1); //simple_statement ::= iteration_statement
			case 175: return s(1); //simple_statement ::= jump_statement
			case 176: //compound_statement_with_scope ::= LEFT_BRACE RIGHT_BRACE
			case 177: //compound_statement_with_scope ::= LEFT_BRACE statement_list RIGHT_BRACE
			case 178: return s(1); //statement_with_scope ::= compound_statement_no_new_scope
			case 179: return s(1); //statement_with_scope ::= simple_statement
			case 180: //compound_statement_no_new_scope ::= LEFT_BRACE RIGHT_BRACE
			case 181: //compound_statement_no_new_scope ::= LEFT_BRACE statement_list RIGHT_BRACE
			case 182: return s(1); //statement_list ::= statement_no_new_scope
			case 183: //statement_list ::= statement_list statement_no_new_scope
			case 184: //expression_statement ::= SEMICOLON
			case 185: //expression_statement ::= expression SEMICOLON
			case 186: //selection_statement ::= IF LEFT_PAREN expression RIGHT_PAREN selection_rest_statement
			case 187: //selection_rest_statement ::= statement_with_scope ELSE statement_with_scope
			case 188: return s(1); //selection_rest_statement ::= statement_with_scope
			case 189: return s(1); //condition ::= expression
			case 190: //condition ::= fully_specified_type IDENTIFIER EQUAL initializer
			case 191: //iteration_statement ::= WHILE LEFT_PAREN condition RIGHT_PAREN statement_no_new_scope
			case 192: //iteration_statement ::= DO statement_with_scope WHILE LEFT_PAREN expression RIGHT_PAREN SEMICOLON
			case 193: //iteration_statement ::= FOR LEFT_PAREN for_init_statement for_rest_statement RIGHT_PAREN statement_no_new_scope
			case 194: return s(1); //for_init_statement ::= expression_statement
			case 195: return s(1); //for_init_statement ::= declaration_statement
			case 196: return s(1); //conditionopt ::= condition
			case 197: //conditionopt ::=
			case 198: //for_rest_statement ::= conditionopt SEMICOLON
			case 199: //for_rest_statement ::= conditionopt SEMICOLON expression
			case 200: return new JumpStatement(t(1).type); //jump_statement ::= CONTINUE SEMICOLON
			case 201: return new JumpStatement(t(1).type); //jump_statement ::= BREAK SEMICOLON
			case 202: return new JumpStatement(t(1).type); //jump_statement ::= RETURN SEMICOLON
			case 203: return new ReturnStatement(cast n(2)); //jump_statement ::= RETURN expression SEMICOLON
			case 204: return new JumpStatement(t(1).type); //jump_statement ::= DISCARD SEMICOLON
			case 205: return s(1); //translation_unit ::= external_declaration
			case 206: //translation_unit ::= translation_unit external_declaration
			case 207: return s(1); //external_declaration ::= function_definition
			case 208: return s(1); //external_declaration ::= declaration
			case 209: //function_definition ::= function_prototype compound_statement_no_new_scope
		}

		trace('!!! Unhandled Rule ($ruleno) !!!');
		return null;
	}

	//#! list .data of symbols of current rule
	static function debug_allSymbols():String{
		var len = Parser.ruleInfo[ruleno].nrhs;
		var symbols = [for(n in 1...len+1) Std.string(s(n))];
		return [for(n in 1...len+1) Std.string( s(n) ) ].join(', ');
	}

	//Access rule symbols from left to right
	//s(1) gives the left most symbol
	static inline function s(n:Int){
		if(n <= 0) return null;
		//nrhs is the number of symbols in rule
		var j = Parser.ruleInfo[ruleno].nrhs - n;
		return stack[i - j].minor;
	}

	//Convenience functions for casting s().v
	static inline function n(m:Int):Node 
		return cast s(m).v;
	static inline function t(m:Int):Token
		return cast s(m).v;

	static inline function get_i() return Parser.i;
	static inline function get_stack() return Parser.stack;	
}