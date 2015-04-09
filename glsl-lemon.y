%start_symbol root

root ::= translation_unit.

variable_identifier ::= IDENTIFIER.
primary_expression ::= variable_identifier.
primary_expression ::= INTCONSTANT.
primary_expression ::= FLOATCONSTANT.
primary_expression ::= BOOLCONSTANT.
primary_expression ::= LEFT_PAREN expression RIGHT_PAREN.
postfix_expression ::= primary_expression.
postfix_expression ::= postfix_expression LEFT_BRACKET integer_expression RIGHT_BRACKET.
postfix_expression ::= function_call.
postfix_expression ::= postfix_expression DOT FIELD_SELECTION.
postfix_expression ::= postfix_expression INC_OP.
postfix_expression ::= postfix_expression DEC_OP.
integer_expression ::= expression.
function_call ::= function_call_generic.
function_call_generic ::= function_call_header_with_parameters RIGHT_PAREN.
function_call_generic ::= function_call_header_no_parameters RIGHT_PAREN.
function_call_header_no_parameters ::= function_call_header VOID.
function_call_header_no_parameters ::= function_call_header.
function_call_header_with_parameters ::= function_call_header assignment_expression.
function_call_header_with_parameters ::= function_call_header_with_parameters COMMA assignment_expression.
function_call_header ::= function_identifier LEFT_PAREN.
function_identifier ::= constructor_identifier.
function_identifier ::= IDENTIFIER.
constructor_identifier ::= FLOAT.
constructor_identifier ::= INT.
constructor_identifier ::= BOOL.
constructor_identifier ::= VEC2.
constructor_identifier ::= VEC3.
constructor_identifier ::= VEC4.
constructor_identifier ::= BVEC2.
constructor_identifier ::= BVEC3.
constructor_identifier ::= BVEC4.
constructor_identifier ::= IVEC2.
constructor_identifier ::= IVEC3.
constructor_identifier ::= IVEC4.
constructor_identifier ::= MAT2.
constructor_identifier ::= MAT3.
constructor_identifier ::= MAT4.
constructor_identifier ::= TYPE_NAME.
unary_expression ::= postfix_expression.
unary_expression ::= INC_OP unary_expression.
unary_expression ::= DEC_OP unary_expression.
unary_expression ::= unary_operator unary_expression.
unary_operator ::= PLUS.
unary_operator ::= DASH.
unary_operator ::= BANG.
unary_operator ::= TILDE.
multiplicative_expression ::= unary_expression.
multiplicative_expression ::= multiplicative_expression STAR unary_expression.
multiplicative_expression ::= multiplicative_expression SLASH unary_expression.
multiplicative_expression ::= multiplicative_expression PERCENT unary_expression.
additive_expression ::= multiplicative_expression.
additive_expression ::= additive_expression PLUS multiplicative_expression.
additive_expression ::= additive_expression DASH multiplicative_expression.
shift_expression ::= additive_expression.
shift_expression ::= shift_expression LEFT_OP additive_expression.
shift_expression ::= shift_expression RIGHT_OP additive_expression.
relational_expression ::= shift_expression.
relational_expression ::= relational_expression LEFT_ANGLE shift_expression.
relational_expression ::= relational_expression RIGHT_ANGLE shift_expression.
relational_expression ::= relational_expression LE_OP shift_expression.
relational_expression ::= relational_expression GE_OP shift_expression.
equality_expression ::= relational_expression.
equality_expression ::= equality_expression EQ_OP relational_expression.
equality_expression ::= equality_expression NE_OP relational_expression.
and_expression ::= equality_expression.
and_expression ::= and_expression AMPERSAND equality_expression.
exclusive_or_expression ::= and_expression.
exclusive_or_expression ::= exclusive_or_expression CARET and_expression.
inclusive_or_expression ::= exclusive_or_expression.
inclusive_or_expression ::= inclusive_or_expression VERTICAL_BAR exclusive_or_expression.
logical_and_expression ::= inclusive_or_expression.
logical_and_expression ::= logical_and_expression AND_OP inclusive_or_expression.
logical_xor_expression ::= logical_and_expression.
logical_xor_expression ::= logical_xor_expression XOR_OP logical_and_expression.
logical_or_expression ::= logical_xor_expression.
logical_or_expression ::= logical_or_expression OR_OP logical_xor_expression.
conditional_expression ::= logical_or_expression.
conditional_expression ::= logical_or_expression QUESTION expression COLON assignment_expression.
assignment_expression ::= conditional_expression.
assignment_expression ::= unary_expression assignment_operator assignment_expression.
assignment_operator ::= EQUAL.
assignment_operator ::= MUL_ASSIGN.
assignment_operator ::= DIV_ASSIGN.
assignment_operator ::= MOD_ASSIGN.
assignment_operator ::= ADD_ASSIGN.
assignment_operator ::= SUB_ASSIGN.
assignment_operator ::= LEFT_ASSIGN.
assignment_operator ::= RIGHT_ASSIGN.
assignment_operator ::= AND_ASSIGN.
assignment_operator ::= XOR_ASSIGN.
assignment_operator ::= OR_ASSIGN.
expression ::= assignment_expression.
expression ::= expression COMMA assignment_expression.
constant_expression ::= conditional_expression.
declaration ::= function_prototype SEMICOLON.
declaration ::= init_declarator_list SEMICOLON.
declaration ::= PRECISION precision_qualifier type_specifier_no_prec SEMICOLON.
function_prototype ::= function_declarator RIGHT_PAREN.
function_declarator ::= function_header.
function_declarator ::= function_header_with_parameters.
function_header_with_parameters ::= function_header parameter_declaration.
function_header_with_parameters ::= function_header_with_parameters COMMA parameter_declaration.
function_header ::= fully_specified_type IDENTIFIER LEFT_PAREN.
parameter_declarator ::= type_specifier IDENTIFIER.
parameter_declarator ::= type_specifier IDENTIFIER LEFT_BRACKET constant_expression RIGHT_BRACKET.
parameter_declaration ::= type_qualifier parameter_qualifier parameter_declarator.
parameter_declaration ::= parameter_qualifier parameter_declarator.
parameter_declaration ::= type_qualifier parameter_qualifier parameter_type_specifier.
parameter_declaration ::= parameter_qualifier parameter_type_specifier.
parameter_qualifier ::= .
parameter_qualifier ::= IN.
parameter_qualifier ::= OUT.
parameter_qualifier ::= INOUT.
parameter_type_specifier ::= type_specifier.
parameter_type_specifier ::= type_specifier LEFT_BRACKET constant_expression RIGHT_BRACKET.
init_declarator_list ::= single_declaration.
init_declarator_list ::= init_declarator_list COMMA IDENTIFIER.
init_declarator_list ::= init_declarator_list COMMA IDENTIFIER LEFT_BRACKET constant_expression RIGHT_BRACKET.
init_declarator_list ::= init_declarator_list COMMA IDENTIFIER EQUAL initializer.
single_declaration ::= fully_specified_type.
single_declaration ::= fully_specified_type IDENTIFIER.
single_declaration ::= fully_specified_type IDENTIFIER LEFT_BRACKET constant_expression RIGHT_BRACKET.
single_declaration ::= fully_specified_type IDENTIFIER EQUAL initializer.
single_declaration ::= INVARIANT IDENTIFIER.
fully_specified_type ::= type_specifier.
fully_specified_type ::= type_qualifier type_specifier.
type_qualifier ::= CONST.
type_qualifier ::= ATTRIBUTE.
type_qualifier ::= VARYING.
type_qualifier ::= INVARIANT VARYING.
type_qualifier ::= UNIFORM.
type_specifier ::= type_specifier_no_prec.
type_specifier ::= precision_qualifier type_specifier_no_prec.
type_specifier_no_prec ::= VOID.
type_specifier_no_prec ::= FLOAT.
type_specifier_no_prec ::= INT.
type_specifier_no_prec ::= BOOL.
type_specifier_no_prec ::= VEC2.
type_specifier_no_prec ::= VEC3.
type_specifier_no_prec ::= VEC4.
type_specifier_no_prec ::= BVEC2.
type_specifier_no_prec ::= BVEC3.
type_specifier_no_prec ::= BVEC4.
type_specifier_no_prec ::= IVEC2.
type_specifier_no_prec ::= IVEC3.
type_specifier_no_prec ::= IVEC4.
type_specifier_no_prec ::= MAT2.
type_specifier_no_prec ::= MAT3.
type_specifier_no_prec ::= MAT4.
type_specifier_no_prec ::= SAMPLER2D.
type_specifier_no_prec ::= SAMPLERCUBE.
type_specifier_no_prec ::= struct_specifier.
type_specifier_no_prec ::= TYPE_NAME.
precision_qualifier ::= HIGH_PRECISION.
precision_qualifier ::= MEDIUM_PRECISION.
precision_qualifier ::= LOW_PRECISION.
struct_specifier ::= STRUCT IDENTIFIER LEFT_BRACE struct_declaration_list RIGHT_BRACE.
struct_specifier ::= STRUCT LEFT_BRACE struct_declaration_list RIGHT_BRACE.
struct_declaration_list ::= struct_declaration.
struct_declaration_list ::= struct_declaration_list struct_declaration.
struct_declaration ::= type_specifier struct_declarator_list SEMICOLON.
struct_declarator_list ::= struct_declarator.
struct_declarator_list ::= struct_declarator_list COMMA struct_declarator.
struct_declarator ::= IDENTIFIER.
struct_declarator ::= IDENTIFIER LEFT_BRACKET constant_expression RIGHT_BRACKET.
initializer ::= assignment_expression.
declaration_statement ::= declaration.
statement_no_new_scope ::= compound_statement_with_scope.
statement_no_new_scope ::= simple_statement.
simple_statement ::= declaration_statement.
simple_statement ::= expression_statement.
simple_statement ::= selection_statement.
simple_statement ::= iteration_statement.
simple_statement ::= jump_statement.
simple_statement ::= preprocessor_directive.
compound_statement_with_scope ::= LEFT_BRACE RIGHT_BRACE.
compound_statement_with_scope ::= LEFT_BRACE statement_list RIGHT_BRACE.
statement_with_scope ::= compound_statement_no_new_scope.
statement_with_scope ::= simple_statement.
compound_statement_no_new_scope ::= LEFT_BRACE RIGHT_BRACE.
compound_statement_no_new_scope ::= LEFT_BRACE statement_list RIGHT_BRACE.
statement_list ::= statement_no_new_scope.
statement_list ::= statement_list statement_no_new_scope.
expression_statement ::= SEMICOLON.
expression_statement ::= expression SEMICOLON.
selection_statement ::= IF LEFT_PAREN expression RIGHT_PAREN selection_rest_statement.
selection_rest_statement ::= statement_with_scope ELSE statement_with_scope.
selection_rest_statement ::= statement_with_scope.
condition ::= expression.
condition ::= fully_specified_type IDENTIFIER EQUAL initializer.
iteration_statement ::= WHILE LEFT_PAREN condition RIGHT_PAREN statement_no_new_scope.
iteration_statement ::= DO statement_with_scope WHILE LEFT_PAREN expression RIGHT_PAREN SEMICOLON.
iteration_statement ::= FOR LEFT_PAREN for_init_statement for_rest_statement RIGHT_PAREN statement_no_new_scope.
for_init_statement ::= expression_statement.
for_init_statement ::= declaration_statement.
conditionopt ::= condition.
conditionopt ::= .
for_rest_statement ::= conditionopt SEMICOLON.
for_rest_statement ::= conditionopt SEMICOLON expression.
jump_statement ::= CONTINUE SEMICOLON.
jump_statement ::= BREAK SEMICOLON.
jump_statement ::= RETURN SEMICOLON.
jump_statement ::= RETURN expression SEMICOLON.
jump_statement ::= DISCARD SEMICOLON.
translation_unit ::= external_declaration.
translation_unit ::= translation_unit external_declaration.
external_declaration ::= function_definition.
external_declaration ::= declaration.
external_declaration ::= preprocessor_directive.
function_definition ::= function_prototype compound_statement_no_new_scope.
preprocessor_directive ::= PREPROCESSOR_DIRECTIVE.
