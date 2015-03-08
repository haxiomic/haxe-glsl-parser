package glslparser;

//#! also add node location (+lenght)? (Computed from the subnode's positions)
//Define leaf type that is a proxy for a token?

//unfinished types
typedef BinaryOperator = Dynamic; 



class Node{
	public function new(){};
}

class Expression extends Node{

}

class Literal<T> extends Node{
	var value:T;
}

class BinaryExpression extends Node{
	var op:BinaryOperator;
	var left:Expression;
	var right:Expression;
}


@:access(glslparser.Parser)
class ParserAST{

	static public function reduce(ruleno:Int){
		ParserAST.ruleno = ruleno; //set class ruleno so it can be accessed by other functions

		//many rules should result in a simple pass forward of the node

		switch(ruleno){
			case 0: return s(1); //root ::= translation_unit
			case 1: trace('(1) variable_identifier ${debug_allSymbols()}'); //variable_identifier ::= IDENTIFIER
			case 2: return s(1); //primary_expression ::= variable_identifier
			case 3: trace('(3) primary_expression ${debug_allSymbols()}');//primary_expression ::= INTCONSTANT
			case 4: trace('(4) primary_expression ${debug_allSymbols()}'); //primary_expression ::= FLOATCONSTANT
			case 5: trace('(5) primary_expression ${debug_allSymbols()}'); //primary_expression ::= BOOLCONSTANT
			case 6: trace('(6) primary_expression ${debug_allSymbols()}');//primary_expression ::= LEFT_PAREN expression RIGHT_PAREN
			case 7: return s(1); //postfix_expression ::= primary_expression
			case 8: trace('(8) postfix_expression ${debug_allSymbols()}'); //postfix_expression ::= postfix_expression LEFT_BRACKET integer_expression RIGHT_BRACKET
			case 9: return s(1); //postfix_expression ::= function_call
			case 10: trace('(10) postfix_expression ${debug_allSymbols()}'); //postfix_expression ::= postfix_expression DOT FIELD_SELECTION
			case 11: trace('(11) postfix_expression ${debug_allSymbols()}'); //postfix_expression ::= postfix_expression INC_OP
			case 12: trace('(12) postfix_expression ${debug_allSymbols()}'); //postfix_expression ::= postfix_expression DEC_OP
			case 13: return s(1); //integer_expression ::= expression
			case 14: return s(1); //function_call ::= function_call_generic
			case 15: trace('(15) function_call_generic ${debug_allSymbols()}'); //function_call_generic ::= function_call_header_with_parameters RIGHT_PAREN
			case 16: trace('(16) function_call_generic ${debug_allSymbols()}'); //function_call_generic ::= function_call_header_no_parameters RIGHT_PAREN
			case 17: trace('(17) function_call_header_no_parameters ${debug_allSymbols()}'); //function_call_header_no_parameters ::= function_call_header VOID
			case 18: return s(1); //function_call_header_no_parameters ::= function_call_header
			case 19: trace('(19) function_call_header_with_parameters ${debug_allSymbols()}'); //function_call_header_with_parameters ::= function_call_header assignment_expression
			case 20: trace('(20) function_call_header_with_parameters ${debug_allSymbols()}'); //function_call_header_with_parameters ::= function_call_header_with_parameters COMMA assignment_expression
			case 21: trace('(21) function_call_header ${debug_allSymbols()}'); //function_call_header ::= function_identifier LEFT_PAREN
			case 22: return s(1); //function_identifier ::= constructor_identifier
			case 23: trace('(23) function_identifier ${debug_allSymbols()}'); //function_identifier ::= IDENTIFIER
			case 24: trace('(24) constructor_identifier ${debug_allSymbols()}'); //constructor_identifier ::= FLOAT
			case 25: trace('(25) constructor_identifier ${debug_allSymbols()}'); //constructor_identifier ::= INT
			case 26: trace('(26) constructor_identifier ${debug_allSymbols()}'); //constructor_identifier ::= BOOL
			case 27: trace('(27) constructor_identifier ${debug_allSymbols()}'); //constructor_identifier ::= VEC2
			case 28: trace('(28) constructor_identifier ${debug_allSymbols()}'); //constructor_identifier ::= VEC3
			case 29: trace('(29) constructor_identifier ${debug_allSymbols()}'); //constructor_identifier ::= VEC4
			case 30: trace('(30) constructor_identifier ${debug_allSymbols()}'); //constructor_identifier ::= BVEC2
			case 31: trace('(31) constructor_identifier ${debug_allSymbols()}'); //constructor_identifier ::= BVEC3
			case 32: trace('(32) constructor_identifier ${debug_allSymbols()}'); //constructor_identifier ::= BVEC4
			case 33: trace('(33) constructor_identifier ${debug_allSymbols()}'); //constructor_identifier ::= IVEC2
			case 34: trace('(34) constructor_identifier ${debug_allSymbols()}'); //constructor_identifier ::= IVEC3
			case 35: trace('(35) constructor_identifier ${debug_allSymbols()}'); //constructor_identifier ::= IVEC4
			case 36: trace('(36) constructor_identifier ${debug_allSymbols()}'); //constructor_identifier ::= MAT2
			case 37: trace('(37) constructor_identifier ${debug_allSymbols()}'); //constructor_identifier ::= MAT3
			case 38: trace('(38) constructor_identifier ${debug_allSymbols()}'); //constructor_identifier ::= MAT4
			case 39: trace('(39) constructor_identifier ${debug_allSymbols()}'); //constructor_identifier ::= TYPE_NAME
			case 40: return s(1); //unary_expression ::= postfix_expression
			case 41: trace('(41) unary_expression ${debug_allSymbols()}'); //unary_expression ::= INC_OP unary_expression
			case 42: trace('(42) unary_expression ${debug_allSymbols()}'); //unary_expression ::= DEC_OP unary_expression
			case 43: trace('(43) unary_expression ${debug_allSymbols()}'); //unary_expression ::= unary_operator unary_expression
			case 44: trace('(44) unary_operator ${debug_allSymbols()}'); //unary_operator ::= PLUS
			case 45: trace('(45) unary_operator ${debug_allSymbols()}'); //unary_operator ::= DASH
			case 46: trace('(46) unary_operator ${debug_allSymbols()}'); //unary_operator ::= BANG
			case 47: trace('(47) unary_operator ${debug_allSymbols()}'); //unary_operator ::= TILDE
			case 48: return s(1); //multiplicative_expression ::= unary_expression
			case 49: trace('(49) multiplicative_expression ${debug_allSymbols()}'); //multiplicative_expression ::= multiplicative_expression STAR unary_expression
			case 50: trace('(50) multiplicative_expression ${debug_allSymbols()}'); //multiplicative_expression ::= multiplicative_expression SLASH unary_expression
			case 51: trace('(51) multiplicative_expression ${debug_allSymbols()}'); //multiplicative_expression ::= multiplicative_expression PERCENT unary_expression
			case 52: return s(1); //additive_expression ::= multiplicative_expression
			case 53: trace('(53) additive_expression ${debug_allSymbols()}'); //additive_expression ::= additive_expression PLUS multiplicative_expression
			case 54: trace('(54) additive_expression ${debug_allSymbols()}'); //additive_expression ::= additive_expression DASH multiplicative_expression
			case 55: return s(1); //shift_expression ::= additive_expression
			case 56: trace('(56) shift_expression ${debug_allSymbols()}'); //shift_expression ::= shift_expression LEFT_OP additive_expression
			case 57: trace('(57) shift_expression ${debug_allSymbols()}'); //shift_expression ::= shift_expression RIGHT_OP additive_expression
			case 58: return s(1); //relational_expression ::= shift_expression
			case 59: trace('(59) relational_expression ${debug_allSymbols()}'); //relational_expression ::= relational_expression LEFT_ANGLE shift_expression
			case 60: trace('(60) relational_expression ${debug_allSymbols()}'); //relational_expression ::= relational_expression RIGHT_ANGLE shift_expression
			case 61: trace('(61) relational_expression ${debug_allSymbols()}'); //relational_expression ::= relational_expression LE_OP shift_expression
			case 62: trace('(62) relational_expression ${debug_allSymbols()}'); //relational_expression ::= relational_expression GE_OP shift_expression
			case 63: return s(1); //equality_expression ::= relational_expression
			case 64: trace('(64) equality_expression ${debug_allSymbols()}'); //equality_expression ::= equality_expression EQ_OP relational_expression
			case 65: trace('(65) equality_expression ${debug_allSymbols()}'); //equality_expression ::= equality_expression NE_OP relational_expression
			case 66: return s(1); //and_expression ::= equality_expression
			case 67: trace('(67) and_expression ${debug_allSymbols()}'); //and_expression ::= and_expression AMPERSAND equality_expression
			case 68: return s(1); //exclusive_or_expression ::= and_expression
			case 69: trace('(69) exclusive_or_expression ${debug_allSymbols()}'); //exclusive_or_expression ::= exclusive_or_expression CARET and_expression
			case 70: return s(1); //inclusive_or_expression ::= exclusive_or_expression
			case 71: trace('(71) inclusive_or_expression ${debug_allSymbols()}'); //inclusive_or_expression ::= inclusive_or_expression VERTICAL_BAR exclusive_or_expression
			case 72: return s(1); //logical_and_expression ::= inclusive_or_expression
			case 73: trace('(73) logical_and_expression ${debug_allSymbols()}'); //logical_and_expression ::= logical_and_expression AND_OP inclusive_or_expression
			case 74: return s(1); //logical_xor_expression ::= logical_and_expression
			case 75: trace('(75) logical_xor_expression ${debug_allSymbols()}'); //logical_xor_expression ::= logical_xor_expression XOR_OP logical_and_expression
			case 76: return s(1); //logical_or_expression ::= logical_xor_expression
			case 77: trace('(77) logical_or_expression ${debug_allSymbols()}'); //logical_or_expression ::= logical_or_expression OR_OP logical_xor_expression
			case 78: return s(1); //conditional_expression ::= logical_or_expression
			case 79: trace('(79) conditional_expression ${debug_allSymbols()}'); //conditional_expression ::= logical_or_expression QUESTION expression COLON assignment_expression
			case 80: return s(1); //assignment_expression ::= conditional_expression
			case 81: trace('(81) assignment_expression ${debug_allSymbols()}'); //assignment_expression ::= unary_expression assignment_operator assignment_expression
			case 82: trace('(82) assignment_operator ${debug_allSymbols()}'); //assignment_operator ::= EQUAL
			case 83: trace('(83) assignment_operator ${debug_allSymbols()}'); //assignment_operator ::= MUL_ASSIGN
			case 84: trace('(84) assignment_operator ${debug_allSymbols()}'); //assignment_operator ::= DIV_ASSIGN
			case 85: trace('(85) assignment_operator ${debug_allSymbols()}'); //assignment_operator ::= MOD_ASSIGN
			case 86: trace('(86) assignment_operator ${debug_allSymbols()}'); //assignment_operator ::= ADD_ASSIGN
			case 87: trace('(87) assignment_operator ${debug_allSymbols()}'); //assignment_operator ::= SUB_ASSIGN
			case 88: trace('(88) assignment_operator ${debug_allSymbols()}'); //assignment_operator ::= LEFT_ASSIGN
			case 89: trace('(89) assignment_operator ${debug_allSymbols()}'); //assignment_operator ::= RIGHT_ASSIGN
			case 90: trace('(90) assignment_operator ${debug_allSymbols()}'); //assignment_operator ::= AND_ASSIGN
			case 91: trace('(91) assignment_operator ${debug_allSymbols()}'); //assignment_operator ::= XOR_ASSIGN
			case 92: trace('(92) assignment_operator ${debug_allSymbols()}'); //assignment_operator ::= OR_ASSIGN
			case 93: return s(1); //expression ::= assignment_expression
			case 94: trace('(94) expression ${debug_allSymbols()}'); //expression ::= expression COMMA assignment_expression
			case 95: return s(1); //constant_expression ::= conditional_expression
			case 96: trace('(96) declaration ${debug_allSymbols()}'); //declaration ::= function_prototype SEMICOLON
			case 97: trace('(97) declaration ${debug_allSymbols()}'); //declaration ::= init_declarator_list SEMICOLON
			case 98: trace('(98) declaration ${debug_allSymbols()}'); //declaration ::= PRECISION precision_qualifier type_specifier_no_prec SEMICOLON
			case 99: trace('(99) function_prototype ${debug_allSymbols()}'); //function_prototype ::= function_declarator RIGHT_PAREN
			case 100: return s(1); //function_declarator ::= function_header
			case 101: return s(1); //function_declarator ::= function_header_with_parameters
			case 102: trace('(102) function_header_with_parameters ${debug_allSymbols()}'); //function_header_with_parameters ::= function_header parameter_declaration
			case 103: trace('(103) function_header_with_parameters ${debug_allSymbols()}'); //function_header_with_parameters ::= function_header_with_parameters COMMA parameter_declaration
			case 104: trace('(104) function_header ${debug_allSymbols()}'); //function_header ::= fully_specified_type IDENTIFIER LEFT_PAREN
			case 105: trace('(105) parameter_declarator ${debug_allSymbols()}'); //parameter_declarator ::= type_specifier IDENTIFIER
			case 106: trace('(106) parameter_declarator ${debug_allSymbols()}'); //parameter_declarator ::= type_specifier IDENTIFIER LEFT_BRACKET constant_expression RIGHT_BRACKET
			case 107: trace('(107) parameter_declaration ${debug_allSymbols()}'); //parameter_declaration ::= type_qualifier parameter_qualifier parameter_declarator
			case 108: trace('(108) parameter_declaration ${debug_allSymbols()}'); //parameter_declaration ::= parameter_qualifier parameter_declarator
			case 109: trace('(109) parameter_declaration ${debug_allSymbols()}'); //parameter_declaration ::= type_qualifier parameter_qualifier parameter_type_specifier
			case 110: trace('(110) parameter_declaration ${debug_allSymbols()}'); //parameter_declaration ::= parameter_qualifier parameter_type_specifier
			case 111: trace('(111) parameter_qualifier ${debug_allSymbols()}'); //parameter_qualifier ::=
			case 112: trace('(112) parameter_qualifier ${debug_allSymbols()}'); //parameter_qualifier ::= IN
			case 113: trace('(113) parameter_qualifier ${debug_allSymbols()}'); //parameter_qualifier ::= OUT
			case 114: trace('(114) parameter_qualifier ${debug_allSymbols()}'); //parameter_qualifier ::= INOUT
			case 115: return s(1); //parameter_type_specifier ::= type_specifier
			case 116: trace('(116) parameter_type_specifier ${debug_allSymbols()}'); //parameter_type_specifier ::= type_specifier LEFT_BRACKET constant_expression RIGHT_BRACKET
			case 117: return s(1); //init_declarator_list ::= single_declaration
			case 118: trace('(118) init_declarator_list ${debug_allSymbols()}'); //init_declarator_list ::= init_declarator_list COMMA IDENTIFIER
			case 119: trace('(119) init_declarator_list ${debug_allSymbols()}'); //init_declarator_list ::= init_declarator_list COMMA IDENTIFIER LEFT_BRACKET constant_expression RIGHT_BRACKET
			case 120: trace('(120) init_declarator_list ${debug_allSymbols()}'); //init_declarator_list ::= init_declarator_list COMMA IDENTIFIER EQUAL initializer
			case 121: return s(1); //single_declaration ::= fully_specified_type
			case 122: trace('(122) single_declaration ${debug_allSymbols()}'); //single_declaration ::= fully_specified_type IDENTIFIER
			case 123: trace('(123) single_declaration ${debug_allSymbols()}'); //single_declaration ::= fully_specified_type IDENTIFIER LEFT_BRACKET constant_expression RIGHT_BRACKET
			case 124: trace('(124) single_declaration ${debug_allSymbols()}'); //single_declaration ::= fully_specified_type IDENTIFIER EQUAL initializer
			case 125: trace('(125) single_declaration ${debug_allSymbols()}'); //single_declaration ::= INVARIANT IDENTIFIER
			case 126: return s(1); //fully_specified_type ::= type_specifier
			case 127: trace('(127) fully_specified_type ${debug_allSymbols()}'); //fully_specified_type ::= type_qualifier type_specifier
			case 128: trace('(128) type_qualifier ${debug_allSymbols()}'); //type_qualifier ::= CONST
			case 129: trace('(129) type_qualifier ${debug_allSymbols()}'); //type_qualifier ::= ATTRIBUTE
			case 130: trace('(130) type_qualifier ${debug_allSymbols()}'); //type_qualifier ::= VARYING
			case 131: trace('(131) type_qualifier ${debug_allSymbols()}'); //type_qualifier ::= INVARIANT VARYING
			case 132: trace('(132) type_qualifier ${debug_allSymbols()}'); //type_qualifier ::= UNIFORM
			case 133: return s(1); //type_specifier ::= type_specifier_no_prec
			case 134: trace('(134) type_specifier ${debug_allSymbols()}'); //type_specifier ::= precision_qualifier type_specifier_no_prec
			case 135: trace('(135) type_specifier_no_prec ${debug_allSymbols()}'); //type_specifier_no_prec ::= VOID
			case 136: trace('(136) type_specifier_no_prec ${debug_allSymbols()}'); //type_specifier_no_prec ::= FLOAT
			case 137: trace('(137) type_specifier_no_prec ${debug_allSymbols()}'); //type_specifier_no_prec ::= INT
			case 138: trace('(138) type_specifier_no_prec ${debug_allSymbols()}'); //type_specifier_no_prec ::= BOOL
			case 139: trace('(139) type_specifier_no_prec ${debug_allSymbols()}'); //type_specifier_no_prec ::= VEC2
			case 140: trace('(140) type_specifier_no_prec ${debug_allSymbols()}'); //type_specifier_no_prec ::= VEC3
			case 141: trace('(141) type_specifier_no_prec ${debug_allSymbols()}'); //type_specifier_no_prec ::= VEC4
			case 142: trace('(142) type_specifier_no_prec ${debug_allSymbols()}'); //type_specifier_no_prec ::= BVEC2
			case 143: trace('(143) type_specifier_no_prec ${debug_allSymbols()}'); //type_specifier_no_prec ::= BVEC3
			case 144: trace('(144) type_specifier_no_prec ${debug_allSymbols()}'); //type_specifier_no_prec ::= BVEC4
			case 145: trace('(145) type_specifier_no_prec ${debug_allSymbols()}'); //type_specifier_no_prec ::= IVEC2
			case 146: trace('(146) type_specifier_no_prec ${debug_allSymbols()}'); //type_specifier_no_prec ::= IVEC3
			case 147: trace('(147) type_specifier_no_prec ${debug_allSymbols()}'); //type_specifier_no_prec ::= IVEC4
			case 148: trace('(148) type_specifier_no_prec ${debug_allSymbols()}'); //type_specifier_no_prec ::= MAT2
			case 149: trace('(149) type_specifier_no_prec ${debug_allSymbols()}'); //type_specifier_no_prec ::= MAT3
			case 150: trace('(150) type_specifier_no_prec ${debug_allSymbols()}'); //type_specifier_no_prec ::= MAT4
			case 151: trace('(151) type_specifier_no_prec ${debug_allSymbols()}'); //type_specifier_no_prec ::= SAMPLER2D
			case 152: trace('(152) type_specifier_no_prec ${debug_allSymbols()}'); //type_specifier_no_prec ::= SAMPLERCUBE
			case 153: return s(1); //type_specifier_no_prec ::= struct_specifier
			case 154: trace('(154) type_specifier_no_prec ${debug_allSymbols()}'); //type_specifier_no_prec ::= TYPE_NAME
			case 155: trace('(155) precision_qualifier ${debug_allSymbols()}'); //precision_qualifier ::= HIGH_PRECISION
			case 156: trace('(156) precision_qualifier ${debug_allSymbols()}'); //precision_qualifier ::= MEDIUM_PRECISION
			case 157: trace('(157) precision_qualifier ${debug_allSymbols()}'); //precision_qualifier ::= LOW_PRECISION
			case 158: trace('(158) struct_specifier ${debug_allSymbols()}'); //struct_specifier ::= STRUCT IDENTIFIER LEFT_BRACE struct_declaration_list RIGHT_BRACE
			case 159: trace('(159) struct_specifier ${debug_allSymbols()}'); //struct_specifier ::= STRUCT LEFT_BRACE struct_declaration_list RIGHT_BRACE
			case 160: return s(1); //struct_declaration_list ::= struct_declaration
			case 161: trace('(161) struct_declaration_list ${debug_allSymbols()}'); //struct_declaration_list ::= struct_declaration_list struct_declaration
			case 162: trace('(162) struct_declaration ${debug_allSymbols()}'); //struct_declaration ::= type_specifier struct_declarator_list SEMICOLON
			case 163: return s(1); //struct_declarator_list ::= struct_declarator
			case 164: trace('(164) struct_declarator_list ${debug_allSymbols()}'); //struct_declarator_list ::= struct_declarator_list COMMA struct_declarator
			case 165: trace('(165) struct_declarator ${debug_allSymbols()}'); //struct_declarator ::= IDENTIFIER
			case 166: trace('(166) struct_declarator ${debug_allSymbols()}'); //struct_declarator ::= IDENTIFIER LEFT_BRACKET constant_expression RIGHT_BRACKET
			case 167: return s(1); //initializer ::= assignment_expression
			case 168: return s(1); //declaration_statement ::= declaration
			case 169: return s(1); //statement_no_new_scope ::= compound_statement_with_scope
			case 170: return s(1); //statement_no_new_scope ::= simple_statement
			case 171: return s(1); //simple_statement ::= declaration_statement
			case 172: return s(1); //simple_statement ::= expression_statement
			case 173: return s(1); //simple_statement ::= selection_statement
			case 174: return s(1); //simple_statement ::= iteration_statement
			case 175: return s(1); //simple_statement ::= jump_statement
			case 176: trace('(176) compound_statement_with_scope ${debug_allSymbols()}'); //compound_statement_with_scope ::= LEFT_BRACE RIGHT_BRACE
			case 177: trace('(177) compound_statement_with_scope ${debug_allSymbols()}'); //compound_statement_with_scope ::= LEFT_BRACE statement_list RIGHT_BRACE
			case 178: return s(1); //statement_with_scope ::= compound_statement_no_new_scope
			case 179: return s(1); //statement_with_scope ::= simple_statement
			case 180: trace('(180) compound_statement_no_new_scope ${debug_allSymbols()}'); //compound_statement_no_new_scope ::= LEFT_BRACE RIGHT_BRACE
			case 181: trace('(181) compound_statement_no_new_scope ${debug_allSymbols()}'); //compound_statement_no_new_scope ::= LEFT_BRACE statement_list RIGHT_BRACE
			case 182: return s(1); //statement_list ::= statement_no_new_scope
			case 183: trace('(183) statement_list ${debug_allSymbols()}'); //statement_list ::= statement_list statement_no_new_scope
			case 184: trace('(184) expression_statement ${debug_allSymbols()}'); //expression_statement ::= SEMICOLON
			case 185: trace('(185) expression_statement ${debug_allSymbols()}'); //expression_statement ::= expression SEMICOLON
			case 186: trace('(186) selection_statement ${debug_allSymbols()}'); //selection_statement ::= IF LEFT_PAREN expression RIGHT_PAREN selection_rest_statement
			case 187: trace('(187) selection_rest_statement ${debug_allSymbols()}'); //selection_rest_statement ::= statement_with_scope ELSE statement_with_scope
			case 188: return s(1); //selection_rest_statement ::= statement_with_scope
			case 189: return s(1); //condition ::= expression
			case 190: trace('(190) condition ${debug_allSymbols()}'); //condition ::= fully_specified_type IDENTIFIER EQUAL initializer
			case 191: trace('(191) iteration_statement ${debug_allSymbols()}'); //iteration_statement ::= WHILE LEFT_PAREN condition RIGHT_PAREN statement_no_new_scope
			case 192: trace('(192) iteration_statement ${debug_allSymbols()}'); //iteration_statement ::= DO statement_with_scope WHILE LEFT_PAREN expression RIGHT_PAREN SEMICOLON
			case 193: trace('(193) iteration_statement ${debug_allSymbols()}'); //iteration_statement ::= FOR LEFT_PAREN for_init_statement for_rest_statement RIGHT_PAREN statement_no_new_scope
			case 194: return s(1); //for_init_statement ::= expression_statement
			case 195: return s(1); //for_init_statement ::= declaration_statement
			case 196: return s(1); //conditionopt ::= condition
			case 197: trace('(197) conditionopt ${debug_allSymbols()}'); //conditionopt ::=
			case 198: trace('(198) for_rest_statement ${debug_allSymbols()}'); //for_rest_statement ::= conditionopt SEMICOLON
			case 199: trace('(199) for_rest_statement ${debug_allSymbols()}'); //for_rest_statement ::= conditionopt SEMICOLON expression
			case 200: trace('(200) jump_statement ${debug_allSymbols()}'); //jump_statement ::= CONTINUE SEMICOLON
			case 201: trace('(201) jump_statement ${debug_allSymbols()}'); //jump_statement ::= BREAK SEMICOLON
			case 202: trace('(202) jump_statement ${debug_allSymbols()}'); //jump_statement ::= RETURN SEMICOLON
			case 203: trace('(203) jump_statement ${debug_allSymbols()}'); //jump_statement ::= RETURN expression SEMICOLON
			case 204: trace('(204) jump_statement ${debug_allSymbols()}'); //jump_statement ::= DISCARD SEMICOLON
			case 205: return s(1); //translation_unit ::= external_declaration
			case 206: trace('(206) translation_unit ${debug_allSymbols()}'); //translation_unit ::= translation_unit external_declaration
			case 207: return s(1); //external_declaration ::= function_definition
			case 208: return s(1); //external_declaration ::= declaration
			case 209: trace('(209) function_definition ${debug_allSymbols()}'); //function_definition ::= function_prototype compound_statement_no_new_scope
		}

		return cast {type: glslparser.Tokenizer.TokenType.RESERVED_KEYWORD, data: 'r:'+ruleno};//#!
	}

	//#! list .data of symbols of current rule
	static function debug_allSymbols():String{
		var len = Parser.ruleInfo[ruleno].nrhs;
		var symbols = [for(n in 1...len+1) Std.string(s(n))];
		return [for(n in 1...len+1) Std.string( s(n).data ) ].join(', ');
	}

	//Access rule tokens from left to right
	//s(1) gives the left most symbol
	static inline function s(n:Int){
		if(n <= 0) return null;
		//nrhs is the number of symbols in rule
		var j = Parser.ruleInfo[ruleno].nrhs - n;
		return stack[i - j].minor;
	}

	static var i(get, null):Int;
	static var stack(get, null):Parser.Stack;
	static inline function get_i() return Parser.i;
	static inline function get_stack() return Parser.stack;
	
	static var ruleno;
}