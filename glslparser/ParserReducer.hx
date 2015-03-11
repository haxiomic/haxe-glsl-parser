/*
	ParserReducer is responsible for constructing the abstract syntax tree by creation
	and concatenation of notes in accordance with the grammar rules of the language
	
	@author George Corney
*/

package glslparser;

import glslparser.Tokenizer.Token;
import glslparser.AST;

enum EMinorType{
	Token(t:Token);
	Node(n:Node);
	EnumValue(e:EnumValue);
	NodeArray(a:Array<Dynamic>);
}

abstract MinorType(EMinorType){
	public inline function new(e:EMinorType) this = e;

	public var v(get, never):Dynamic;
	public var type(get, never):EMinorType;

	inline function get_v() return this.getParameters()[0];

	@:to inline function get_type():EMinorType return this;

	@:from static inline function fromToken(t:Token) return new MinorType(Token(t));
	@:from static inline function fromNode(n:Node) return new MinorType(Node(n));
	@:from static inline function fromEnumValue(e:EnumValue) return new MinorType(EnumValue(e));
	@:from static inline function fromNodeArray(a:Array<Dynamic>) return new MinorType(NodeArray(a));
}

@:access(glslparser.Parser)
class ParserReducer{
	static public var result:Node;

	static var i(get, null):Int;
	static var stack(get, null):Parser.Stack;

	static var ruleno;

	static public function reduce(ruleno:Int):MinorType{
		ParserReducer.ruleno = ruleno; //set class ruleno so it can be accessed by other functions

		switch(ruleno){
			case 0: result = n(1); return s(1); //root ::= translation_unit
			case 1: return new Identifier(t(1).data);//variable_identifier ::= IDENTIFIER
			case 2: return s(1); //primary_expression ::= variable_identifier
			case 3: return new Literal<Int>(Std.parseInt(t(1).data), t(1).data, TypeClass.INT);//primary_expression ::= INTCONSTANT
			case 4: return new Literal<Float>(Std.parseFloat(t(1).data), t(1).data, TypeClass.FLOAT); //primary_expression ::= FLOATCONSTANT
			case 5: return new Literal<Bool>(t(1).data == 'true', t(1).data, TypeClass.BOOL); //primary_expression ::= BOOLCONSTANT
			case 6: e(2).parenWrap = true; return s(2); //primary_expression ::= LEFT_PAREN expression RIGHT_PAREN
			case 7: return s(1); //postfix_expression ::= primary_expression
			case 8: return new ArrayElementSelectionExpression(e(1), e(3)); //postfix_expression ::= postfix_expression LEFT_BRACKET integer_expression RIGHT_BRACKET
			case 9: return s(1); //postfix_expression ::= function_call
			case 10: return new FieldSelectionExpression(e(1), new Identifier(t(3).data)); //postfix_expression ::= postfix_expression DOT FIELD_SELECTION
			case 11: return new UnaryExpression(UnaryOperator.INC_OP, e(1), false); //postfix_expression ::= postfix_expression INC_OP
			case 12: return new UnaryExpression(UnaryOperator.DEC_OP, e(1), false); //postfix_expression ::= postfix_expression DEC_OP
			case 13: return s(1); //integer_expression ::= expression
			case 14: return s(1); //function_call ::= function_call_generic
			case 15: return s(1); //function_call_generic ::= function_call_header_with_parameters RIGHT_PAREN
			case 16: return s(1); //function_call_generic ::= function_call_header_no_parameters RIGHT_PAREN
			case 17: return s(1); //function_call_header_no_parameters ::= function_call_header VOID
			case 18: return s(1); //function_call_header_no_parameters ::= function_call_header
			case 19: cast(n(1), FunctionCall).parameters.push(cast n(2)); return s(1); //function_call_header_with_parameters ::= function_call_header assignment_expression
			case 20: cast(n(1), FunctionCall).parameters.push(cast n(3)); return s(1); //function_call_header_with_parameters ::= function_call_header_with_parameters COMMA assignment_expression
			case 21: return s(1); //function_call_header ::= function_identifier LEFT_PAREN
			case 22: return new FunctionCall(t(1).data); //function_identifier ::= constructor_identifier
			case 23: return new FunctionCall(t(1).data); //function_identifier ::= IDENTIFIER
			case 24: return s(1); //constructor_identifier ::= FLOAT
			case 25: return s(1); //constructor_identifier ::= INT
			case 26: return s(1); //constructor_identifier ::= BOOL
			case 27: return s(1); //constructor_identifier ::= VEC2
			case 28: return s(1); //constructor_identifier ::= VEC3
			case 29: return s(1); //constructor_identifier ::= VEC4
			case 30: return s(1); //constructor_identifier ::= BVEC2
			case 31: return s(1); //constructor_identifier ::= BVEC3
			case 32: return s(1); //constructor_identifier ::= BVEC4
			case 33: return s(1); //constructor_identifier ::= IVEC2
			case 34: return s(1); //constructor_identifier ::= IVEC3
			case 35: return s(1); //constructor_identifier ::= IVEC4
			case 36: return s(1); //constructor_identifier ::= MAT2
			case 37: return s(1); //constructor_identifier ::= MAT3
			case 38: return s(1); //constructor_identifier ::= MAT4
			case 39: return s(1); //constructor_identifier ::= TYPE_NAME
			case 40: return s(1); //unary_expression ::= postfix_expression
			case 41: return new UnaryExpression(UnaryOperator.INC_OP, e(2), true); //unary_expression ::= INC_OP unary_expression
			case 42: return new UnaryExpression(UnaryOperator.DEC_OP, e(2), true); //unary_expression ::= DEC_OP unary_expression
			case 43: return new UnaryExpression(cast ev(1), e(2), true); //unary_expression ::= unary_operator unary_expression
			case 44: return UnaryOperator.PLUS; //unary_operator ::= PLUS
			case 45: return UnaryOperator.DASH; //unary_operator ::= DASH
			case 46: return UnaryOperator.BANG; //unary_operator ::= BANG
			case 47: return UnaryOperator.TILDE; //unary_operator ::= TILDE
			case 48: return s(1); //multiplicative_expression ::= unary_expression
			case 49: return new BinaryExpression(BinaryOperator.STAR, e(1), e(3)); //multiplicative_expression ::= multiplicative_expression STAR unary_expression
			case 50: return new BinaryExpression(BinaryOperator.SLASH, e(1), e(3)); //multiplicative_expression ::= multiplicative_expression SLASH unary_expression
			case 51: return new BinaryExpression(BinaryOperator.PERCENT, e(1), e(3)); //multiplicative_expression ::= multiplicative_expression PERCENT unary_expression
			case 52: return s(1); //additive_expression ::= multiplicative_expression
			case 53: return new BinaryExpression(BinaryOperator.PLUS, e(1), e(3)); //additive_expression ::= additive_expression PLUS multiplicative_expression
			case 54: return new BinaryExpression(BinaryOperator.DASH, e(1), e(3)); //additive_expression ::= additive_expression DASH multiplicative_expression
			case 55: return s(1); //shift_expression ::= additive_expression
			case 56: return new BinaryExpression(BinaryOperator.LEFT_OP, cast n(1), cast n(3)); //shift_expression ::= shift_expression LEFT_OP additive_expression
			case 57: return new BinaryExpression(BinaryOperator.RIGHT_OP, cast n(1), cast n(3)); //shift_expression ::= shift_expression RIGHT_OP additive_expression
			case 58: return s(1); //relational_expression ::= shift_expression
			case 59: return new BinaryExpression(BinaryOperator.LEFT_ANGLE, cast n(1), cast n(3)); //relational_expression ::= relational_expression LEFT_ANGLE shift_expression
			case 60: return new BinaryExpression(BinaryOperator.RIGHT_ANGLE, cast n(1), cast n(3)); //relational_expression ::= relational_expression RIGHT_ANGLE shift_expression
			case 61: return new BinaryExpression(BinaryOperator.LE_OP, cast n(1), cast n(3)); //relational_expression ::= relational_expression LE_OP shift_expression
			case 62: return new BinaryExpression(BinaryOperator.GE_OP, cast n(1), cast n(3)); //relational_expression ::= relational_expression GE_OP shift_expression
			case 63: return s(1); //equality_expression ::= relational_expression
			case 64: return new BinaryExpression(BinaryOperator.EQ_OP, cast n(1), cast n(3)); //equality_expression ::= equality_expression EQ_OP relational_expression
			case 65: return new BinaryExpression(BinaryOperator.NE_OP, cast n(1), cast n(3)); //equality_expression ::= equality_expression NE_OP relational_expression
			case 66: return s(1); //and_expression ::= equality_expression
			case 67: return new BinaryExpression(BinaryOperator.AMPERSAND, cast n(1), cast n(3)); //and_expression ::= and_expression AMPERSAND equality_expression
			case 68: return s(1); //exclusive_or_expression ::= and_expression
			case 69: return new BinaryExpression(BinaryOperator.CARET, cast n(1), cast n(3)); //exclusive_or_expression ::= exclusive_or_expression CARET and_expression
			case 70: return s(1); //inclusive_or_expression ::= exclusive_or_expression
			case 71: return new BinaryExpression(BinaryOperator.VERTICAL_BAR, cast n(1), cast n(3)); //inclusive_or_expression ::= inclusive_or_expression VERTICAL_BAR exclusive_or_expression
			case 72: return s(1); //logical_and_expression ::= inclusive_or_expression
			case 73: return new BinaryExpression(BinaryOperator.AND_OP, cast n(1), cast n(3)); //logical_and_expression ::= logical_and_expression AND_OP inclusive_or_expression
			case 74: return s(1); //logical_xor_expression ::= logical_and_expression
			case 75: return new BinaryExpression(BinaryOperator.XOR_OP, cast n(1), cast n(3)); //logical_xor_expression ::= logical_xor_expression XOR_OP logical_and_expression
			case 76: return s(1); //logical_or_expression ::= logical_xor_expression
			case 77: return new BinaryExpression(BinaryOperator.OR_OP, cast n(1), cast n(3)); //logical_or_expression ::= logical_or_expression OR_OP logical_xor_expression
			case 78: return s(1); //conditional_expression ::= logical_or_expression
			case 79: return new ConditionalExpression(cast n(1), cast n(2), cast n(3)); //conditional_expression ::= logical_or_expression QUESTION expression COLON assignment_expression
			case 80: return s(1); //assignment_expression ::= conditional_expression
			case 81: return new AssignmentExpression(cast ev(2), cast n(1), cast n(3)); //assignment_expression ::= unary_expression assignment_operator assignment_expression
			case 82: return AssignmentOperator.EQUAL; //assignment_operator ::= EQUAL
			case 83: return AssignmentOperator.MUL_ASSIGN; //assignment_operator ::= MUL_ASSIGN
			case 84: return AssignmentOperator.DIV_ASSIGN; //assignment_operator ::= DIV_ASSIGN
			case 85: return AssignmentOperator.MOD_ASSIGN; //assignment_operator ::= MOD_ASSIGN
			case 86: return AssignmentOperator.ADD_ASSIGN; //assignment_operator ::= ADD_ASSIGN
			case 87: return AssignmentOperator.SUB_ASSIGN; //assignment_operator ::= SUB_ASSIGN
			case 88: return AssignmentOperator.LEFT_ASSIGN; //assignment_operator ::= LEFT_ASSIGN
			case 89: return AssignmentOperator.RIGHT_ASSIGN; //assignment_operator ::= RIGHT_ASSIGN
			case 90: return AssignmentOperator.AND_ASSIGN; //assignment_operator ::= AND_ASSIGN
			case 91: return AssignmentOperator.XOR_ASSIGN; //assignment_operator ::= XOR_ASSIGN
			case 92: return AssignmentOperator.OR_ASSIGN; //assignment_operator ::= OR_ASSIGN
			case 93: return s(1); //expression ::= assignment_expression
			case 94: //expression ::= expression COMMA assignment_expression
						if(Std.is(e(1), SequenceExpression)){
							cast(e(1), SequenceExpression).expressions.push(e(3));
							return s(1);
						}else{
							return new SequenceExpression([e(1), e(3)]);
						}
			case 95: return s(1); //constant_expression ::= conditional_expression
			case 96: return new FunctionPrototype(cast s(1)); //declaration ::= function_prototype SEMICOLON
			case 97: return s(1); //declaration ::= init_declarator_list SEMICOLON
			case 98: return new PrecisionDeclaration(cast ev(2), cast n(3)); //declaration ::= PRECISION precision_qualifier type_specifier_no_prec SEMICOLON
			case 99: return s(1); //function_prototype ::= function_declarator RIGHT_PAREN
			case 100: return s(1); //function_declarator ::= function_header
			case 101: return s(1); //function_declarator ::= function_header_with_parameters
			case 102: var fh = cast(n(1), FunctionHeader); //function_header_with_parameters ::= function_header parameter_declaration
						fh.parameters.push(cast n(2));
						return fh;
			case 103: var fh = cast(n(1), FunctionHeader); //function_header_with_parameters ::= function_header_with_parameters COMMA parameter_declaration
						fh.parameters.push(cast n(3));
						return fh; 
			case 104: return new FunctionHeader(t(2).data, cast n(1)); //function_header ::= fully_specified_type IDENTIFIER LEFT_PAREN
			case 105: return new ParameterDeclaration(t(2).data, cast n(1)); //parameter_declarator ::= type_specifier IDENTIFIER
			case 106: return new ParameterDeclaration(t(2).data, cast n(1), null, null, e(3)); //parameter_declarator ::= type_specifier IDENTIFIER LEFT_BRACKET constant_expression RIGHT_BRACKET
			case 107: var pd = cast(n(3), ParameterDeclaration); //parameter_declaration ::= type_qualifier parameter_qualifier parameter_declarator
						pd.typeQualifier = cast ev(1);
						pd.parameterQualifier = cast ev(2);
						return pd;
			case 108: var pd = cast(n(2), ParameterDeclaration); //parameter_declaration ::= parameter_qualifier parameter_declarator
						pd.parameterQualifier = cast ev(1);
						return pd;
			case 109: var pd = cast(n(3), ParameterDeclaration); //parameter_declaration ::= type_qualifier parameter_qualifier parameter_type_specifier
						pd.typeQualifier = cast ev(1);
						pd.parameterQualifier = cast ev(2);
						return pd;
			case 110: var pd = cast(n(2), ParameterDeclaration); //parameter_declaration ::= parameter_qualifier parameter_type_specifier
						pd.parameterQualifier = cast ev(1);
						return pd;
			case 111: return null; //parameter_qualifier ::=
			case 112: return ParameterQualifier.IN;//parameter_qualifier ::= IN
			case 113: return ParameterQualifier.OUT;//parameter_qualifier ::= OUT
			case 114: return ParameterQualifier.INOUT;//parameter_qualifier ::= INOUT
			case 115: return new ParameterDeclaration(null, cast n(1)); //parameter_type_specifier ::= type_specifier
			case 116: return new ParameterDeclaration(null, cast n(1), null, null, e(3));//parameter_type_specifier ::= type_specifier LEFT_BRACKET constant_expression RIGHT_BRACKET
			case 117: return s(1); //init_declarator_list ::= single_declaration
			case 118: cast(n(1), VariableDeclaration).declarators.push(new Declarator(t(3).data, null, false)); return s(1); //init_declarator_list ::= init_declarator_list COMMA IDENTIFIER
			case 119: cast(n(1), VariableDeclaration).declarators.push(new ArrayDeclarator(t(3).data, e(5))); return s(1); //init_declarator_list ::= init_declarator_list COMMA IDENTIFIER LEFT_BRACKET constant_expression RIGHT_BRACKET
			case 120: cast(n(1), VariableDeclaration).declarators.push(new Declarator(t(3).data, e(5), false)); return s(1); //init_declarator_list ::= init_declarator_list COMMA IDENTIFIER EQUAL initializer
			case 121: return new VariableDeclaration(cast n(1), [new Declarator('', null, false)]); //single_declaration ::= fully_specified_type
			case 122: return new VariableDeclaration(cast n(1), [new Declarator(t(2).data, null, false)]); //single_declaration ::= fully_specified_type IDENTIFIER
			case 123: return new VariableDeclaration(cast n(1), [new ArrayDeclarator(t(2).data, e(4))]); //single_declaration ::= fully_specified_type IDENTIFIER LEFT_BRACKET constant_expression RIGHT_BRACKET
			case 124: return new VariableDeclaration(cast n(1), [new Declarator(t(2).data, e(4), false)]); //single_declaration ::= fully_specified_type IDENTIFIER EQUAL initializer
			case 125: return new VariableDeclaration(null, [new Declarator(t(2).data, null, true)]); //single_declaration ::= INVARIANT IDENTIFIER
			case 126: return s(1); //fully_specified_type ::= type_specifier
			case 127: cast(n(2), TypeSpecifier).qualifier = cast ev(1); //fully_specified_type ::= type_qualifier type_specifier
						return s(2);
			case 128: return TypeQualifier.CONST; //type_qualifier ::= CONST
			case 129: return TypeQualifier.ATTRIBUTE; //type_qualifier ::= ATTRIBUTE
			case 130: return TypeQualifier.VARYING; //type_qualifier ::= VARYING
			case 131: return TypeQualifier.INVARIANT_VARYING; //type_qualifier ::= INVARIANT VARYING
			case 132: return TypeQualifier.UNIFORM; //type_qualifier ::= UNIFORM
			case 133: return s(1); //type_specifier ::= type_specifier_no_prec
			case 134: cast(n(1), TypeSpecifier).precision = cast ev(1); return s(1); //type_specifier ::= precision_qualifier type_specifier_no_prec
			case 135: return new TypeSpecifier(TypeClass.VOID, t(1).data); //type_specifier_no_prec ::= VOID
			case 136: return new TypeSpecifier(TypeClass.FLOAT, t(1).data); //type_specifier_no_prec ::= FLOAT
			case 137: return new TypeSpecifier(TypeClass.INT, t(1).data); //type_specifier_no_prec ::= INT
			case 138: return new TypeSpecifier(TypeClass.BOOL, t(1).data); //type_specifier_no_prec ::= BOOL
			case 139: return new TypeSpecifier(TypeClass.VEC2, t(1).data); //type_specifier_no_prec ::= VEC2
			case 140: return new TypeSpecifier(TypeClass.VEC3, t(1).data); //type_specifier_no_prec ::= VEC3
			case 141: return new TypeSpecifier(TypeClass.VEC4, t(1).data); //type_specifier_no_prec ::= VEC4
			case 142: return new TypeSpecifier(TypeClass.BVEC2, t(1).data); //type_specifier_no_prec ::= BVEC2
			case 143: return new TypeSpecifier(TypeClass.BVEC3, t(1).data); //type_specifier_no_prec ::= BVEC3
			case 144: return new TypeSpecifier(TypeClass.BVEC4, t(1).data); //type_specifier_no_prec ::= BVEC4
			case 145: return new TypeSpecifier(TypeClass.IVEC2, t(1).data); //type_specifier_no_prec ::= IVEC2
			case 146: return new TypeSpecifier(TypeClass.IVEC3, t(1).data); //type_specifier_no_prec ::= IVEC3
			case 147: return new TypeSpecifier(TypeClass.IVEC4, t(1).data); //type_specifier_no_prec ::= IVEC4
			case 148: return new TypeSpecifier(TypeClass.MAT2, t(1).data); //type_specifier_no_prec ::= MAT2
			case 149: return new TypeSpecifier(TypeClass.MAT3, t(1).data); //type_specifier_no_prec ::= MAT3
			case 150: return new TypeSpecifier(TypeClass.MAT4, t(1).data); //type_specifier_no_prec ::= MAT4
			case 151: return new TypeSpecifier(TypeClass.SAMPLER2D, t(1).data); //type_specifier_no_prec ::= SAMPLER2D
			case 152: return new TypeSpecifier(TypeClass.SAMPLERCUBE, t(1).data); //type_specifier_no_prec ::= SAMPLERCUBE
			case 153: return s(1); //type_specifier_no_prec ::= struct_specifier
			case 154: return new TypeSpecifier(TypeClass.TYPE_NAME, t(1).data); //type_specifier_no_prec ::= TYPE_NAME
			case 155: return PrecisionQualifier.HIGH_PRECISION; //precision_qualifier ::= HIGH_PRECISION
			case 156: return PrecisionQualifier.MEDIUM_PRECISION; //precision_qualifier ::= MEDIUM_PRECISION
			case 157: return PrecisionQualifier.LOW_PRECISION; //precision_qualifier ::= LOW_PRECISION
			case 158: return new StructSpecifier(t(2).data, cast a(4)); //struct_specifier ::= STRUCT IDENTIFIER LEFT_BRACE struct_declaration_list RIGHT_BRACE
			case 159: return new StructSpecifier('', cast a(3)); //struct_specifier ::= STRUCT LEFT_BRACE struct_declaration_list RIGHT_BRACE
			case 160: return [n(1)]; //struct_declaration_list ::= struct_declaration
			case 161: a(1).push(n(2)); return s(1); //struct_declaration_list ::= struct_declaration_list struct_declaration
			case 162: return new StructDeclaration(cast n(1), cast a(2)); //struct_declaration ::= type_specifier struct_declarator_list SEMICOLON
			case 163: return [n(1)]; //struct_declarator_list ::= struct_declarator
			case 164: a(1).push(n(3)); return s(1); //struct_declarator_list ::= struct_declarator_list COMMA struct_declarator
			case 165: return new StructDeclarator(t(1).data); //struct_declarator ::= IDENTIFIER
			case 166: return new StructArrayDeclarator(t(1).data, e(3)); //struct_declarator ::= IDENTIFIER LEFT_BRACKET constant_expression RIGHT_BRACKET
			case 167: return s(1); //initializer ::= assignment_expression
			case 168: return new DeclarationStatement(cast n(1)); //declaration_statement ::= declaration
			case 169: return s(1); /*#! scope change? */ //statement_no_new_scope ::= compound_statement_with_scope
			case 170: return s(1); /*#! scope change? */ //statement_no_new_scope ::= simple_statement
			case 171: return s(1); //simple_statement ::= declaration_statement
			case 172: return s(1); //simple_statement ::= expression_statement
			case 173: return s(1); //simple_statement ::= selection_statement
			case 174: return s(1); //simple_statement ::= iteration_statement
			case 175: return s(1); //simple_statement ::= jump_statement
			case 176: return new CompoundStatement([], true); //compound_statement_with_scope ::= LEFT_BRACE RIGHT_BRACE
			case 177: return new CompoundStatement(cast a(2), true); //compound_statement_with_scope ::= LEFT_BRACE statement_list RIGHT_BRACE
			case 178: return s(1); /*#! scope change? */ //statement_with_scope ::= compound_statement_no_new_scope
			case 179: return s(1); /*#! scope change? */ //statement_with_scope ::= simple_statement
			case 180: return new CompoundStatement([], false); //compound_statement_no_new_scope ::= LEFT_BRACE RIGHT_BRACE
			case 181: return new CompoundStatement(cast a(2), false); //compound_statement_no_new_scope ::= LEFT_BRACE statement_list RIGHT_BRACE
			case 182: return [n(1)]; //statement_list ::= statement_no_new_scope
			case 183: a(1).push(n(2)); return s(1); //statement_list ::= statement_list statement_no_new_scope
			case 184: return new ExpressionStatement(null); //expression_statement ::= SEMICOLON
			case 185: return new ExpressionStatement(e(1)); //expression_statement ::= expression SEMICOLON
			case 186: return new IfStatement(e(3), a(5)[0], a(5)[1]); //selection_statement ::= IF LEFT_PAREN expression RIGHT_PAREN selection_rest_statement
			case 187: return [n(1), n(3)]; //selection_rest_statement ::= statement_with_scope ELSE statement_with_scope
			case 188: return [n(1), null]; //selection_rest_statement ::= statement_with_scope
			case 189: return s(1); //condition ::= expression
			case 190: return new VariableDeclaration(cast n(1), [new Declarator(t(2).data, e(4), false)]); //condition ::= fully_specified_type IDENTIFIER EQUAL initializer
			case 191: return new WhileStatement(e(3), cast n(5)); //iteration_statement ::= WHILE LEFT_PAREN condition RIGHT_PAREN statement_no_new_scope
			case 192: return new DoWhileStatement(e(5), cast n(2)); //iteration_statement ::= DO statement_with_scope WHILE LEFT_PAREN expression RIGHT_PAREN SEMICOLON
			case 193: return new ForStatement(cast n(3), a(4)[0], a(4)[1], cast n(6)); //iteration_statement ::= FOR LEFT_PAREN for_init_statement for_rest_statement RIGHT_PAREN statement_no_new_scope
			case 194: return s(1); //for_init_statement ::= expression_statement
			case 195: return s(1); //for_init_statement ::= declaration_statement
			case 196: return s(1); //conditionopt ::= condition
			case 197: return null; //conditionopt ::=
			case 198: return [e(1), null]; //for_rest_statement ::= conditionopt SEMICOLON
			case 199: return [e(1), e(3)]; //for_rest_statement ::= conditionopt SEMICOLON expression
			case 200: return new JumpStatement(JumpMode.CONTINUE); //jump_statement ::= CONTINUE SEMICOLON
			case 201: return new JumpStatement(JumpMode.BREAK); //jump_statement ::= BREAK SEMICOLON
			case 202: return new JumpStatement(JumpMode.RETURN); //jump_statement ::= RETURN SEMICOLON
			case 203: return new ReturnStatement(cast n(2)); //jump_statement ::= RETURN expression SEMICOLON
			case 204: return new JumpStatement(JumpMode.DISCARD); //jump_statement ::= DISCARD SEMICOLON
			case 205: return [n(1)]; //translation_unit ::= external_declaration
			case 206: a(1).push(cast n(2)); return s(1); //translation_unit ::= translation_unit external_declaration
			case 207: cast(n(1), Declaration).global = true; return s(1); //external_declaration ::= function_definition
			case 208: cast(n(1), Declaration).global = true; return s(1); //external_declaration ::= declaration
			case 209: return new FunctionDefinition(cast n(1), cast n(2)); //function_definition ::= function_prototype compound_statement_no_new_scope
		}

		Parser.warn('unhandled reduce rule, ($ruleno, ${ParserDebugData.ruleName(ruleno)})');
		return null;
	}

	static public function reset(){
		result = null;
		ruleno = -1;
	}

	//Access rule symbols from left to right
	//s(1) gives the left most symbol
	static inline function s(n:Int){
		if(n <= 0) return null;
		//nrhs is the number of symbols in rule
		var j = Parser.ruleInfo[ruleno].nrhs - n;
		return stack[i - j].minor;
	}

	//Convenience functions for casting s(n).v
	static inline function n(m:Int):Node 
		return cast s(m).v;
	static inline function t(m:Int):Token
		return cast s(m).v;
	static inline function e(m:Int):Expression
		return cast(s(m).v, Expression);
	static inline function ev(m:Int):EnumValue
		return s(m) != null ? cast s(m).v : null;
	static inline function a(m):Array<Dynamic>
		return cast s(m).v;

	static inline function get_i() return Parser.i;
	static inline function get_stack() return Parser.stack;	
}