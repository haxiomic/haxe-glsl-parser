/*
	Unaltered GLSL ES 1.0 Rules
	Generated from https://www.khronos.org/files/opengles_shading_language.pdf
*/

package rulemaps;

class GLSL_ES_100{
	static public var map:Map<String, Int> = [
		'root ::= translation_unit' => 0,
		'variable_identifier ::= IDENTIFIER' => 1,
		'primary_expression ::= variable_identifier' => 2,
		'primary_expression ::= INTCONSTANT' => 3,
		'primary_expression ::= FLOATCONSTANT' => 4,
		'primary_expression ::= BOOLCONSTANT' => 5,
		'primary_expression ::= LEFT_PAREN expression RIGHT_PAREN' => 6,
		'postfix_expression ::= primary_expression' => 7,
		'postfix_expression ::= postfix_expression LEFT_BRACKET integer_expression RIGHT_BRACKET' => 8,
		'postfix_expression ::= function_call' => 9,
		'postfix_expression ::= postfix_expression DOT FIELD_SELECTION' => 10,
		'postfix_expression ::= postfix_expression INC_OP' => 11,
		'postfix_expression ::= postfix_expression DEC_OP' => 12,
		'integer_expression ::= expression' => 13,
		'function_call ::= function_call_generic' => 14,
		'function_call_generic ::= function_call_header_with_parameters RIGHT_PAREN' => 15,
		'function_call_generic ::= function_call_header_no_parameters RIGHT_PAREN' => 16,
		'function_call_header_no_parameters ::= function_call_header VOID' => 17,
		'function_call_header_no_parameters ::= function_call_header' => 18,
		'function_call_header_with_parameters ::= function_call_header assignment_expression' => 19,
		'function_call_header_with_parameters ::= function_call_header_with_parameters COMMA assignment_expression' => 20,
		'function_call_header ::= function_identifier LEFT_PAREN' => 21,
		'function_identifier ::= constructor_identifier' => 22,
		'function_identifier ::= IDENTIFIER' => 23,
		'constructor_identifier ::= FLOAT' => 24,
		'constructor_identifier ::= INT' => 25,
		'constructor_identifier ::= BOOL' => 26,
		'constructor_identifier ::= VEC2' => 27,
		'constructor_identifier ::= VEC3' => 28,
		'constructor_identifier ::= VEC4' => 29,
		'constructor_identifier ::= BVEC2' => 30,
		'constructor_identifier ::= BVEC3' => 31,
		'constructor_identifier ::= BVEC4' => 32,
		'constructor_identifier ::= IVEC2' => 33,
		'constructor_identifier ::= IVEC3' => 34,
		'constructor_identifier ::= IVEC4' => 35,
		'constructor_identifier ::= MAT2' => 36,
		'constructor_identifier ::= MAT3' => 37,
		'constructor_identifier ::= MAT4' => 38,
		'constructor_identifier ::= TYPE_NAME' => 39,
		'unary_expression ::= postfix_expression' => 40,
		'unary_expression ::= INC_OP unary_expression' => 41,
		'unary_expression ::= DEC_OP unary_expression' => 42,
		'unary_expression ::= unary_operator unary_expression' => 43,
		'unary_operator ::= PLUS' => 44,
		'unary_operator ::= DASH' => 45,
		'unary_operator ::= BANG' => 46,
		'unary_operator ::= TILDE' => 47,
		'multiplicative_expression ::= unary_expression' => 48,
		'multiplicative_expression ::= multiplicative_expression STAR unary_expression' => 49,
		'multiplicative_expression ::= multiplicative_expression SLASH unary_expression' => 50,
		'multiplicative_expression ::= multiplicative_expression PERCENT unary_expression' => 51,
		'additive_expression ::= multiplicative_expression' => 52,
		'additive_expression ::= additive_expression PLUS multiplicative_expression' => 53,
		'additive_expression ::= additive_expression DASH multiplicative_expression' => 54,
		'shift_expression ::= additive_expression' => 55,
		'shift_expression ::= shift_expression LEFT_OP additive_expression' => 56,
		'shift_expression ::= shift_expression RIGHT_OP additive_expression' => 57,
		'relational_expression ::= shift_expression' => 58,
		'relational_expression ::= relational_expression LEFT_ANGLE shift_expression' => 59,
		'relational_expression ::= relational_expression RIGHT_ANGLE shift_expression' => 60,
		'relational_expression ::= relational_expression LE_OP shift_expression' => 61,
		'relational_expression ::= relational_expression GE_OP shift_expression' => 62,
		'equality_expression ::= relational_expression' => 63,
		'equality_expression ::= equality_expression EQ_OP relational_expression' => 64,
		'equality_expression ::= equality_expression NE_OP relational_expression' => 65,
		'and_expression ::= equality_expression' => 66,
		'and_expression ::= and_expression AMPERSAND equality_expression' => 67,
		'exclusive_or_expression ::= and_expression' => 68,
		'exclusive_or_expression ::= exclusive_or_expression CARET and_expression' => 69,
		'inclusive_or_expression ::= exclusive_or_expression' => 70,
		'inclusive_or_expression ::= inclusive_or_expression VERTICAL_BAR exclusive_or_expression' => 71,
		'logical_and_expression ::= inclusive_or_expression' => 72,
		'logical_and_expression ::= logical_and_expression AND_OP inclusive_or_expression' => 73,
		'logical_xor_expression ::= logical_and_expression' => 74,
		'logical_xor_expression ::= logical_xor_expression XOR_OP logical_and_expression' => 75,
		'logical_or_expression ::= logical_xor_expression' => 76,
		'logical_or_expression ::= logical_or_expression OR_OP logical_xor_expression' => 77,
		'conditional_expression ::= logical_or_expression' => 78,
		'conditional_expression ::= logical_or_expression QUESTION expression COLON assignment_expression' => 79,
		'assignment_expression ::= conditional_expression' => 80,
		'assignment_expression ::= unary_expression assignment_operator assignment_expression' => 81,
		'assignment_operator ::= EQUAL' => 82,
		'assignment_operator ::= MUL_ASSIGN' => 83,
		'assignment_operator ::= DIV_ASSIGN' => 84,
		'assignment_operator ::= MOD_ASSIGN' => 85,
		'assignment_operator ::= ADD_ASSIGN' => 86,
		'assignment_operator ::= SUB_ASSIGN' => 87,
		'assignment_operator ::= LEFT_ASSIGN' => 88,
		'assignment_operator ::= RIGHT_ASSIGN' => 89,
		'assignment_operator ::= AND_ASSIGN' => 90,
		'assignment_operator ::= XOR_ASSIGN' => 91,
		'assignment_operator ::= OR_ASSIGN' => 92,
		'expression ::= assignment_expression' => 93,
		'expression ::= expression COMMA assignment_expression' => 94,
		'constant_expression ::= conditional_expression' => 95,
		'declaration ::= function_prototype SEMICOLON' => 96,
		'declaration ::= init_declarator_list SEMICOLON' => 97,
		'declaration ::= PRECISION precision_qualifier type_specifier_no_prec SEMICOLON' => 98,
		'function_prototype ::= function_declarator RIGHT_PAREN' => 99,
		'function_declarator ::= function_header' => 100,
		'function_declarator ::= function_header_with_parameters' => 101,
		'function_header_with_parameters ::= function_header parameter_declaration' => 102,
		'function_header_with_parameters ::= function_header_with_parameters COMMA parameter_declaration' => 103,
		'function_header ::= fully_specified_type IDENTIFIER LEFT_PAREN' => 104,
		'parameter_declarator ::= type_specifier IDENTIFIER' => 105,
		'parameter_declarator ::= type_specifier IDENTIFIER LEFT_BRACKET constant_expression RIGHT_BRACKET' => 106,
		'parameter_declaration ::= type_qualifier parameter_qualifier parameter_declarator' => 107,
		'parameter_declaration ::= parameter_qualifier parameter_declarator' => 108,
		'parameter_declaration ::= type_qualifier parameter_qualifier parameter_type_specifier' => 109,
		'parameter_declaration ::= parameter_qualifier parameter_type_specifier' => 110,
		'parameter_qualifier ::=' => 111,
		'parameter_qualifier ::= IN' => 112,
		'parameter_qualifier ::= OUT' => 113,
		'parameter_qualifier ::= INOUT' => 114,
		'parameter_type_specifier ::= type_specifier' => 115,
		'parameter_type_specifier ::= type_specifier LEFT_BRACKET constant_expression RIGHT_BRACKET' => 116,
		'init_declarator_list ::= single_declaration' => 117,
		'init_declarator_list ::= init_declarator_list COMMA IDENTIFIER' => 118,
		'init_declarator_list ::= init_declarator_list COMMA IDENTIFIER LEFT_BRACKET constant_expression RIGHT_BRACKET' => 119,
		'init_declarator_list ::= init_declarator_list COMMA IDENTIFIER EQUAL initializer' => 120,
		'single_declaration ::= fully_specified_type' => 121,
		'single_declaration ::= fully_specified_type IDENTIFIER' => 122,
		'single_declaration ::= fully_specified_type IDENTIFIER LEFT_BRACKET constant_expression RIGHT_BRACKET' => 123,
		'single_declaration ::= fully_specified_type IDENTIFIER EQUAL initializer' => 124,
		'single_declaration ::= INVARIANT IDENTIFIER' => 125,
		'fully_specified_type ::= type_specifier' => 126,
		'fully_specified_type ::= type_qualifier type_specifier' => 127,
		'type_qualifier ::= CONST' => 128,
		'type_qualifier ::= ATTRIBUTE' => 129,
		'type_qualifier ::= VARYING' => 130,
		'type_qualifier ::= INVARIANT VARYING' => 131,
		'type_qualifier ::= UNIFORM' => 132,
		'type_specifier ::= type_specifier_no_prec' => 133,
		'type_specifier ::= precision_qualifier type_specifier_no_prec' => 134,
		'type_specifier_no_prec ::= VOID' => 135,
		'type_specifier_no_prec ::= FLOAT' => 136,
		'type_specifier_no_prec ::= INT' => 137,
		'type_specifier_no_prec ::= BOOL' => 138,
		'type_specifier_no_prec ::= VEC2' => 139,
		'type_specifier_no_prec ::= VEC3' => 140,
		'type_specifier_no_prec ::= VEC4' => 141,
		'type_specifier_no_prec ::= BVEC2' => 142,
		'type_specifier_no_prec ::= BVEC3' => 143,
		'type_specifier_no_prec ::= BVEC4' => 144,
		'type_specifier_no_prec ::= IVEC2' => 145,
		'type_specifier_no_prec ::= IVEC3' => 146,
		'type_specifier_no_prec ::= IVEC4' => 147,
		'type_specifier_no_prec ::= MAT2' => 148,
		'type_specifier_no_prec ::= MAT3' => 149,
		'type_specifier_no_prec ::= MAT4' => 150,
		'type_specifier_no_prec ::= SAMPLER2D' => 151,
		'type_specifier_no_prec ::= SAMPLERCUBE' => 152,
		'type_specifier_no_prec ::= struct_specifier' => 153,
		'type_specifier_no_prec ::= TYPE_NAME' => 154,
		'precision_qualifier ::= HIGH_PRECISION' => 155,
		'precision_qualifier ::= MEDIUM_PRECISION' => 156,
		'precision_qualifier ::= LOW_PRECISION' => 157,
		'struct_specifier ::= STRUCT IDENTIFIER LEFT_BRACE struct_declaration_list RIGHT_BRACE' => 158,
		'struct_specifier ::= STRUCT LEFT_BRACE struct_declaration_list RIGHT_BRACE' => 159,
		'struct_declaration_list ::= struct_declaration' => 160,
		'struct_declaration_list ::= struct_declaration_list struct_declaration' => 161,
		'struct_declaration ::= type_specifier struct_declarator_list SEMICOLON' => 162,
		'struct_declarator_list ::= struct_declarator' => 163,
		'struct_declarator_list ::= struct_declarator_list COMMA struct_declarator' => 164,
		'struct_declarator ::= IDENTIFIER' => 165,
		'struct_declarator ::= IDENTIFIER LEFT_BRACKET constant_expression RIGHT_BRACKET' => 166,
		'initializer ::= assignment_expression' => 167,
		'declaration_statement ::= declaration' => 168,
		'statement_no_new_scope ::= compound_statement_with_scope' => 169,
		'statement_no_new_scope ::= simple_statement' => 170,
		'simple_statement ::= declaration_statement' => 171,
		'simple_statement ::= expression_statement' => 172,
		'simple_statement ::= selection_statement' => 173,
		'simple_statement ::= iteration_statement' => 174,
		'simple_statement ::= jump_statement' => 175,
		'compound_statement_with_scope ::= LEFT_BRACE RIGHT_BRACE' => 176,
		'compound_statement_with_scope ::= LEFT_BRACE statement_list RIGHT_BRACE' => 177,
		'statement_with_scope ::= compound_statement_no_new_scope' => 178,
		'statement_with_scope ::= simple_statement' => 179,
		'compound_statement_no_new_scope ::= LEFT_BRACE RIGHT_BRACE' => 180,
		'compound_statement_no_new_scope ::= LEFT_BRACE statement_list RIGHT_BRACE' => 181,
		'statement_list ::= statement_no_new_scope' => 182,
		'statement_list ::= statement_list statement_no_new_scope' => 183,
		'expression_statement ::= SEMICOLON' => 184,
		'expression_statement ::= expression SEMICOLON' => 185,
		'selection_statement ::= IF LEFT_PAREN expression RIGHT_PAREN selection_rest_statement' => 186,
		'selection_rest_statement ::= statement_with_scope ELSE statement_with_scope' => 187,
		'selection_rest_statement ::= statement_with_scope' => 188,
		'condition ::= expression' => 189,
		'condition ::= fully_specified_type IDENTIFIER EQUAL initializer' => 190,
		'iteration_statement ::= WHILE LEFT_PAREN condition RIGHT_PAREN statement_no_new_scope' => 191,
		'iteration_statement ::= DO statement_with_scope WHILE LEFT_PAREN expression RIGHT_PAREN SEMICOLON' => 192,
		'iteration_statement ::= FOR LEFT_PAREN for_init_statement for_rest_statement RIGHT_PAREN statement_no_new_scope' => 193,
		'for_init_statement ::= expression_statement' => 194,
		'for_init_statement ::= declaration_statement' => 195,
		'conditionopt ::= condition' => 196,
		'conditionopt ::=' => 197,
		'for_rest_statement ::= conditionopt SEMICOLON' => 198,
		'for_rest_statement ::= conditionopt SEMICOLON expression' => 199,
		'jump_statement ::= CONTINUE SEMICOLON' => 200,
		'jump_statement ::= BREAK SEMICOLON' => 201,
		'jump_statement ::= RETURN SEMICOLON' => 202,
		'jump_statement ::= RETURN expression SEMICOLON' => 203,
		'jump_statement ::= DISCARD SEMICOLON' => 204,
		'translation_unit ::= external_declaration' => 205,
		'translation_unit ::= translation_unit external_declaration' => 206,
		'external_declaration ::= function_definition' => 207,
		'external_declaration ::= declaration' => 208,
		'function_definition ::= function_prototype compound_statement_no_new_scope' => 209
	];
}