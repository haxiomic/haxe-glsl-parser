//#! Recursive decent that contains left-recursion! Need a new approach!

package glslparser;
import glslparser.Tokenizer.Token;
import glslparser.Tokenizer.TokenType;


//Convenience abstract to allow treating Arrays as Bools for cases where it's helpful to do: if(array) ...
@:forward
abstract SequenceResults(Array<Dynamic>) from Array<Dynamic>{
	public inline function new() this = [];
	@:to function toBool():Bool return this != null;
	@:arrayAccess public inline function get(i:Int) return this[i];
}

enum RuleElement{
	Rule(ruleFunction:Void->Dynamic);
	Token(type:TokenType);
}

typedef Node = {};


class Parser
{
	//state machine data
	static var tokens:Array<Token>;

	static var i:Int;

	static public function parseTokens(tokens:Array<Token>){
		Parser.tokens = tokens;
		i = 0;

		var ast = [];
		while(i < tokens.length){
			var coreNode = rule_translation_unit();
			if(coreNode != null)
				ast.push(coreNode);
		}

		return ast;
	}

	//token and node look ahead - these functions alone are responsible for managing the current index
	static function readToken():Token{//reads and advances
		var token = tokens[i++];
		if(token == null) return null;
		if(token.type == WHITESPACE || token.type == BLOCK_COMMENT || token.type == LINE_COMMENT)
			return readToken();
		return token;
	}

	static function tryToken(type:TokenType):Token{
		var i_before = i;
		var token = readToken();
		if(token == null) return null;
		if(token.type == type) return token;
		i = i_before;
		return null;
	}

	static function tryRule(ruleFunction:Void->Dynamic){
		//responsible for tracking index
		var i_before = i;
		var result = ruleFunction();
		if(result != null) return result;
		i = i_before;
		return null;
	}

	static function trySequence(sequence:Array<RuleElement>):SequenceResults{ //sequence is an array of either Void->Dynamic or TokenType
		var i_before = i;
		var results:Dynamic = [];
		for (j in 0...sequence.length) {

			var result:Dynamic;
			switch (sequence[j]) {
				case Rule(ruleFunction):
					result = tryRule(ruleFunction);
				case Token(type):
					result = tryToken(type);
			}

			if(result == null){ //sequence not matched
				i = i_before;
				return null;
			}

			results.push(result);
		}

		return results; //array of Dynamics or Tokens
	}

	//Error Reporting
	static function warn(msg){
		trace('Parser Warning: '+msg);
	}

	static function error(msg){
		throw 'Parser Error: '+msg;
	}

/* --------- Rule functions --------- */
	static var r;//convenience variable
	static function rule_variable_identifier(){
		trace("trying rule: variable_identifier");
		if(r = trySequence([Token(IDENTIFIER)])) return buildResult_variable_identifier(r, 0);
		trace("failed variable_identifier");
		return null;
	}

	static function rule_primary_expression(){
		trace("trying rule: primary_expression");
		if(r = trySequence([Token(LEFT_PAREN),Rule(rule_expression),Token(RIGHT_PAREN)])) return buildResult_primary_expression(r, 4);
		if(r = trySequence([Token(BOOLCONSTANT)])) return buildResult_primary_expression(r, 3);
		if(r = trySequence([Token(FLOATCONSTANT)])) return buildResult_primary_expression(r, 2);
		if(r = trySequence([Token(INTCONSTANT)])) return buildResult_primary_expression(r, 1);
		if(r = trySequence([Rule(rule_variable_identifier)])) return buildResult_primary_expression(r, 0);
		trace("failed primary_expression");
		return null;
	}

	static function rule_postfix_expression(){
		trace("trying rule: postfix_expression");
		if(r = trySequence([Rule(rule_postfix_expression),Token(DEC_OP)])) return buildResult_postfix_expression(r, 5);
		if(r = trySequence([Rule(rule_postfix_expression),Token(INC_OP)])) return buildResult_postfix_expression(r, 4);
		if(r = trySequence([Rule(rule_postfix_expression),Token(DOT),Token(FIELD_SELECTION)])) return buildResult_postfix_expression(r, 3);
		if(r = trySequence([Rule(rule_function_call)])) return buildResult_postfix_expression(r, 2);
		if(r = trySequence([Rule(rule_postfix_expression),Token(LEFT_BRACKET),Rule(rule_integer_expression),Token(RIGHT_BRACKET)])) return buildResult_postfix_expression(r, 1);
		if(r = trySequence([Rule(rule_primary_expression)])) return buildResult_postfix_expression(r, 0);
		trace("failed postfix_expression");
		return null;
	}

	static function rule_integer_expression(){
		trace("trying rule: integer_expression");
		if(r = trySequence([Rule(rule_expression)])) return buildResult_integer_expression(r, 0);
		trace("failed integer_expression");
		return null;
	}

	static function rule_function_call(){
		trace("trying rule: function_call");
		if(r = trySequence([Rule(rule_function_call_generic)])) return buildResult_function_call(r, 0);
		trace("failed function_call");
		return null;
	}

	static function rule_function_call_generic(){
		trace("trying rule: function_call_generic");
		if(r = trySequence([Rule(rule_function_call_header_no_parameters),Token(RIGHT_PAREN)])) return buildResult_function_call_generic(r, 1);
		if(r = trySequence([Rule(rule_function_call_header_with_parameters),Token(RIGHT_PAREN)])) return buildResult_function_call_generic(r, 0);
		trace("failed function_call_generic");
		return null;
	}

	static function rule_function_call_header_no_parameters(){
		trace("trying rule: function_call_header_no_parameters");
		if(r = trySequence([Rule(rule_function_call_header)])) return buildResult_function_call_header_no_parameters(r, 1);
		if(r = trySequence([Rule(rule_function_call_header),Token(VOID)])) return buildResult_function_call_header_no_parameters(r, 0);
		trace("failed function_call_header_no_parameters");
		return null;
	}

	static function rule_function_call_header_with_parameters(){
		trace("trying rule: function_call_header_with_parameters");
		if(r = trySequence([Rule(rule_function_call_header_with_parameters),Token(COMMA),Rule(rule_assignment_expression)])) return buildResult_function_call_header_with_parameters(r, 1);
		if(r = trySequence([Rule(rule_function_call_header),Rule(rule_assignment_expression)])) return buildResult_function_call_header_with_parameters(r, 0);
		trace("failed function_call_header_with_parameters");
		return null;
	}

	static function rule_function_call_header(){
		trace("trying rule: function_call_header");
		if(r = trySequence([Rule(rule_function_identifier),Token(LEFT_PAREN)])) return buildResult_function_call_header(r, 0);
		trace("failed function_call_header");
		return null;
	}

	static function rule_function_identifier(){
		trace("trying rule: function_identifier");
		if(r = trySequence([Token(IDENTIFIER)])) return buildResult_function_identifier(r, 1);
		if(r = trySequence([Rule(rule_constructor_identifier)])) return buildResult_function_identifier(r, 0);
		trace("failed function_identifier");
		return null;
	}

	static function rule_constructor_identifier(){
		trace("trying rule: constructor_identifier");
		if(r = trySequence([Token(TYPE_NAME)])) return buildResult_constructor_identifier(r, 15);
		if(r = trySequence([Token(MAT4)])) return buildResult_constructor_identifier(r, 14);
		if(r = trySequence([Token(MAT3)])) return buildResult_constructor_identifier(r, 13);
		if(r = trySequence([Token(MAT2)])) return buildResult_constructor_identifier(r, 12);
		if(r = trySequence([Token(IVEC4)])) return buildResult_constructor_identifier(r, 11);
		if(r = trySequence([Token(IVEC3)])) return buildResult_constructor_identifier(r, 10);
		if(r = trySequence([Token(IVEC2)])) return buildResult_constructor_identifier(r, 9);
		if(r = trySequence([Token(BVEC4)])) return buildResult_constructor_identifier(r, 8);
		if(r = trySequence([Token(BVEC3)])) return buildResult_constructor_identifier(r, 7);
		if(r = trySequence([Token(BVEC2)])) return buildResult_constructor_identifier(r, 6);
		if(r = trySequence([Token(VEC4)])) return buildResult_constructor_identifier(r, 5);
		if(r = trySequence([Token(VEC3)])) return buildResult_constructor_identifier(r, 4);
		if(r = trySequence([Token(VEC2)])) return buildResult_constructor_identifier(r, 3);
		if(r = trySequence([Token(BOOL)])) return buildResult_constructor_identifier(r, 2);
		if(r = trySequence([Token(INT)])) return buildResult_constructor_identifier(r, 1);
		if(r = trySequence([Token(FLOAT)])) return buildResult_constructor_identifier(r, 0);
		trace("failed constructor_identifier");
		return null;
	}

	static function rule_unary_expression(){
		trace("trying rule: unary_expression");
		if(r = trySequence([Rule(rule_unary_operator),Rule(rule_unary_expression)])) return buildResult_unary_expression(r, 3);
		if(r = trySequence([Token(DEC_OP),Rule(rule_unary_expression)])) return buildResult_unary_expression(r, 2);
		if(r = trySequence([Token(INC_OP),Rule(rule_unary_expression)])) return buildResult_unary_expression(r, 1);
		if(r = trySequence([Rule(rule_postfix_expression)])) return buildResult_unary_expression(r, 0);
		trace("failed unary_expression");
		return null;
	}

	static function rule_unary_operator(){
		trace("trying rule: unary_operator");
		if(r = trySequence([Token(TILDE)])) return buildResult_unary_operator(r, 3);
		if(r = trySequence([Token(BANG)])) return buildResult_unary_operator(r, 2);
		if(r = trySequence([Token(DASH)])) return buildResult_unary_operator(r, 1);
		if(r = trySequence([Token(PLUS)])) return buildResult_unary_operator(r, 0);
		trace("failed unary_operator");
		return null;
	}

	static function rule_multiplicative_expression(){
		trace("trying rule: multiplicative_expression");
		if(r = trySequence([Rule(rule_multiplicative_expression),Token(PERCENT),Rule(rule_unary_expression)])) return buildResult_multiplicative_expression(r, 3);
		if(r = trySequence([Rule(rule_multiplicative_expression),Token(SLASH),Rule(rule_unary_expression)])) return buildResult_multiplicative_expression(r, 2);
		if(r = trySequence([Rule(rule_multiplicative_expression),Token(STAR),Rule(rule_unary_expression)])) return buildResult_multiplicative_expression(r, 1);
		if(r = trySequence([Rule(rule_unary_expression)])) return buildResult_multiplicative_expression(r, 0);
		trace("failed multiplicative_expression");
		return null;
	}

	static function rule_additive_expression(){
		trace("trying rule: additive_expression");
		if(r = trySequence([Rule(rule_additive_expression),Token(DASH),Rule(rule_multiplicative_expression)])) return buildResult_additive_expression(r, 2);
		if(r = trySequence([Rule(rule_additive_expression),Token(PLUS),Rule(rule_multiplicative_expression)])) return buildResult_additive_expression(r, 1);
		if(r = trySequence([Rule(rule_multiplicative_expression)])) return buildResult_additive_expression(r, 0);
		trace("failed additive_expression");
		return null;
	}

	static function rule_shift_expression(){
		trace("trying rule: shift_expression");
		if(r = trySequence([Rule(rule_shift_expression),Token(RIGHT_OP),Rule(rule_additive_expression)])) return buildResult_shift_expression(r, 2);
		if(r = trySequence([Rule(rule_shift_expression),Token(LEFT_OP),Rule(rule_additive_expression)])) return buildResult_shift_expression(r, 1);
		if(r = trySequence([Rule(rule_additive_expression)])) return buildResult_shift_expression(r, 0);
		trace("failed shift_expression");
		return null;
	}

	static function rule_relational_expression(){
		trace("trying rule: relational_expression");
		if(r = trySequence([Rule(rule_relational_expression),Token(GE_OP),Rule(rule_shift_expression)])) return buildResult_relational_expression(r, 4);
		if(r = trySequence([Rule(rule_relational_expression),Token(LE_OP),Rule(rule_shift_expression)])) return buildResult_relational_expression(r, 3);
		if(r = trySequence([Rule(rule_relational_expression),Token(RIGHT_ANGLE),Rule(rule_shift_expression)])) return buildResult_relational_expression(r, 2);
		if(r = trySequence([Rule(rule_relational_expression),Token(LEFT_ANGLE),Rule(rule_shift_expression)])) return buildResult_relational_expression(r, 1);
		if(r = trySequence([Rule(rule_shift_expression)])) return buildResult_relational_expression(r, 0);
		trace("failed relational_expression");
		return null;
	}

	static function rule_equality_expression(){
		trace("trying rule: equality_expression");
		if(r = trySequence([Rule(rule_equality_expression),Token(NE_OP),Rule(rule_relational_expression)])) return buildResult_equality_expression(r, 2);
		if(r = trySequence([Rule(rule_equality_expression),Token(EQ_OP),Rule(rule_relational_expression)])) return buildResult_equality_expression(r, 1);
		if(r = trySequence([Rule(rule_relational_expression)])) return buildResult_equality_expression(r, 0);
		trace("failed equality_expression");
		return null;
	}

	static function rule_and_expression(){
		trace("trying rule: and_expression");
		if(r = trySequence([Rule(rule_and_expression),Token(AMPERSAND),Rule(rule_equality_expression)])) return buildResult_and_expression(r, 1);
		if(r = trySequence([Rule(rule_equality_expression)])) return buildResult_and_expression(r, 0);
		trace("failed and_expression");
		return null;
	}

	static function rule_exclusive_or_expression(){
		trace("trying rule: exclusive_or_expression");
		if(r = trySequence([Rule(rule_exclusive_or_expression),Token(CARET),Rule(rule_and_expression)])) return buildResult_exclusive_or_expression(r, 1);
		if(r = trySequence([Rule(rule_and_expression)])) return buildResult_exclusive_or_expression(r, 0);
		trace("failed exclusive_or_expression");
		return null;
	}

	static function rule_inclusive_or_expression(){
		trace("trying rule: inclusive_or_expression");
		if(r = trySequence([Rule(rule_inclusive_or_expression),Token(VERTICAL_BAR),Rule(rule_exclusive_or_expression)])) return buildResult_inclusive_or_expression(r, 1);
		if(r = trySequence([Rule(rule_exclusive_or_expression)])) return buildResult_inclusive_or_expression(r, 0);
		trace("failed inclusive_or_expression");
		return null;
	}

	static function rule_logical_and_expression(){
		trace("trying rule: logical_and_expression");
		if(r = trySequence([Rule(rule_logical_and_expression),Token(AND_OP),Rule(rule_inclusive_or_expression)])) return buildResult_logical_and_expression(r, 1);
		if(r = trySequence([Rule(rule_inclusive_or_expression)])) return buildResult_logical_and_expression(r, 0);
		trace("failed logical_and_expression");
		return null;
	}

	static function rule_logical_xor_expression(){
		trace("trying rule: logical_xor_expression");
		if(r = trySequence([Rule(rule_logical_xor_expression),Token(XOR_OP),Rule(rule_logical_and_expression)])) return buildResult_logical_xor_expression(r, 1);
		if(r = trySequence([Rule(rule_logical_and_expression)])) return buildResult_logical_xor_expression(r, 0);
		trace("failed logical_xor_expression");
		return null;
	}

	static function rule_logical_or_expression(){
		trace("trying rule: logical_or_expression");
		if(r = trySequence([Rule(rule_logical_or_expression),Token(OR_OP),Rule(rule_logical_xor_expression)])) return buildResult_logical_or_expression(r, 1);
		if(r = trySequence([Rule(rule_logical_xor_expression)])) return buildResult_logical_or_expression(r, 0);
		trace("failed logical_or_expression");
		return null;
	}

	static function rule_conditional_expression(){
		trace("trying rule: conditional_expression");
		if(r = trySequence([Rule(rule_logical_or_expression),Token(QUESTION),Rule(rule_expression),Token(COLON),Rule(rule_assignment_expression)])) return buildResult_conditional_expression(r, 1);
		if(r = trySequence([Rule(rule_logical_or_expression)])) return buildResult_conditional_expression(r, 0);
		trace("failed conditional_expression");
		return null;
	}

	static function rule_assignment_expression(){
		trace("trying rule: assignment_expression");
		if(r = trySequence([Rule(rule_unary_expression),Rule(rule_assignment_operator),Rule(rule_assignment_expression)])) return buildResult_assignment_expression(r, 1);
		if(r = trySequence([Rule(rule_conditional_expression)])) return buildResult_assignment_expression(r, 0);
		trace("failed assignment_expression");
		return null;
	}

	static function rule_assignment_operator(){
		trace("trying rule: assignment_operator");
		if(r = trySequence([Token(OR_ASSIGN)])) return buildResult_assignment_operator(r, 10);
		if(r = trySequence([Token(XOR_ASSIGN)])) return buildResult_assignment_operator(r, 9);
		if(r = trySequence([Token(AND_ASSIGN)])) return buildResult_assignment_operator(r, 8);
		if(r = trySequence([Token(RIGHT_ASSIGN)])) return buildResult_assignment_operator(r, 7);
		if(r = trySequence([Token(LEFT_ASSIGN)])) return buildResult_assignment_operator(r, 6);
		if(r = trySequence([Token(SUB_ASSIGN)])) return buildResult_assignment_operator(r, 5);
		if(r = trySequence([Token(ADD_ASSIGN)])) return buildResult_assignment_operator(r, 4);
		if(r = trySequence([Token(MOD_ASSIGN)])) return buildResult_assignment_operator(r, 3);
		if(r = trySequence([Token(DIV_ASSIGN)])) return buildResult_assignment_operator(r, 2);
		if(r = trySequence([Token(MUL_ASSIGN)])) return buildResult_assignment_operator(r, 1);
		if(r = trySequence([Token(EQUAL)])) return buildResult_assignment_operator(r, 0);
		trace("failed assignment_operator");
		return null;
	}

	static function rule_expression(){
		trace("trying rule: expression");
		if(r = trySequence([Rule(rule_expression),Token(COMMA),Rule(rule_assignment_expression)])) return buildResult_expression(r, 1);
		if(r = trySequence([Rule(rule_assignment_expression)])) return buildResult_expression(r, 0);
		trace("failed expression");
		return null;
	}

	static function rule_constant_expression(){
		trace("trying rule: constant_expression");
		if(r = trySequence([Rule(rule_conditional_expression)])) return buildResult_constant_expression(r, 0);
		trace("failed constant_expression");
		return null;
	}

	static function rule_declaration(){
		trace("trying rule: declaration");
		if(r = trySequence([Token(PRECISION),Rule(rule_precision_qualifier),Rule(rule_type_specifier_no_prec),Token(SEMICOLON)])) return buildResult_declaration(r, 2);
		if(r = trySequence([Rule(rule_init_declarator_list),Token(SEMICOLON)])) return buildResult_declaration(r, 1);
		if(r = trySequence([Rule(rule_function_prototype),Token(SEMICOLON)])) return buildResult_declaration(r, 0);
		trace("failed declaration");
		return null;
	}

	static function rule_function_prototype(){
		trace("trying rule: function_prototype");
		if(r = trySequence([Rule(rule_function_declarator),Token(RIGHT_PAREN)])) return buildResult_function_prototype(r, 0);
		trace("failed function_prototype");
		return null;
	}

	static function rule_function_declarator(){
		trace("trying rule: function_declarator");
		if(r = trySequence([Rule(rule_function_header_with_parameters)])) return buildResult_function_declarator(r, 1);
		if(r = trySequence([Rule(rule_function_header)])) return buildResult_function_declarator(r, 0);
		trace("failed function_declarator");
		return null;
	}

	static function rule_function_header_with_parameters(){
		trace("trying rule: function_header_with_parameters");
		if(r = trySequence([Rule(rule_function_header_with_parameters),Token(COMMA),Rule(rule_parameter_declaration)])) return buildResult_function_header_with_parameters(r, 1);
		if(r = trySequence([Rule(rule_function_header),Rule(rule_parameter_declaration)])) return buildResult_function_header_with_parameters(r, 0);
		trace("failed function_header_with_parameters");
		return null;
	}

	static function rule_function_header(){
		trace("trying rule: function_header");
		if(r = trySequence([Rule(rule_fully_specified_type),Token(IDENTIFIER),Token(LEFT_PAREN)])) return buildResult_function_header(r, 0);
		trace("failed function_header");
		return null;
	}

	static function rule_parameter_declarator(){
		trace("trying rule: parameter_declarator");
		if(r = trySequence([Rule(rule_type_specifier),Token(IDENTIFIER),Token(LEFT_BRACKET),Rule(rule_constant_expression),Token(RIGHT_BRACKET)])) return buildResult_parameter_declarator(r, 1);
		if(r = trySequence([Rule(rule_type_specifier),Token(IDENTIFIER)])) return buildResult_parameter_declarator(r, 0);
		trace("failed parameter_declarator");
		return null;
	}

	static function rule_parameter_declaration(){
		trace("trying rule: parameter_declaration");
		if(r = trySequence([Rule(rule_parameter_qualifier),Rule(rule_parameter_type_specifier)])) return buildResult_parameter_declaration(r, 3);
		if(r = trySequence([Rule(rule_type_qualifier),Rule(rule_parameter_qualifier),Rule(rule_parameter_type_specifier)])) return buildResult_parameter_declaration(r, 2);
		if(r = trySequence([Rule(rule_parameter_qualifier),Rule(rule_parameter_declarator)])) return buildResult_parameter_declaration(r, 1);
		if(r = trySequence([Rule(rule_type_qualifier),Rule(rule_parameter_qualifier),Rule(rule_parameter_declarator)])) return buildResult_parameter_declaration(r, 0);
		trace("failed parameter_declaration");
		return null;
	}

	static function rule_parameter_qualifier(){
		trace("trying rule: parameter_qualifier");
		if(r = trySequence([Token(INOUT)])) return buildResult_parameter_qualifier(r, 3);
		if(r = trySequence([Token(OUT)])) return buildResult_parameter_qualifier(r, 2);
		if(r = trySequence([Token(IN)])) return buildResult_parameter_qualifier(r, 1);
		return buildResult_parameter_qualifier(r, 0);
		trace("failed parameter_qualifier");
	}

	static function rule_parameter_type_specifier(){
		trace("trying rule: parameter_type_specifier");
		if(r = trySequence([Rule(rule_type_specifier),Token(LEFT_BRACKET),Rule(rule_constant_expression),Token(RIGHT_BRACKET)])) return buildResult_parameter_type_specifier(r, 1);
		if(r = trySequence([Rule(rule_type_specifier)])) return buildResult_parameter_type_specifier(r, 0);
		trace("failed parameter_type_specifier");
		return null;
	}

	static function rule_init_declarator_list(){
		trace("trying rule: init_declarator_list");
		if(r = trySequence([Rule(rule_init_declarator_list),Token(COMMA),Token(IDENTIFIER),Token(EQUAL),Rule(rule_initializer)])) return buildResult_init_declarator_list(r, 3);
		if(r = trySequence([Rule(rule_init_declarator_list),Token(COMMA),Token(IDENTIFIER),Token(LEFT_BRACKET),Rule(rule_constant_expression),Token(RIGHT_BRACKET)])) return buildResult_init_declarator_list(r, 2);
		if(r = trySequence([Rule(rule_init_declarator_list),Token(COMMA),Token(IDENTIFIER)])) return buildResult_init_declarator_list(r, 1);
		if(r = trySequence([Rule(rule_single_declaration)])) return buildResult_init_declarator_list(r, 0);
		trace("failed init_declarator_list");
		return null;
	}

	static function rule_single_declaration(){
		trace("trying rule: single_declaration");
		if(r = trySequence([Token(INVARIANT),Token(IDENTIFIER)])) return buildResult_single_declaration(r, 4);
		if(r = trySequence([Rule(rule_fully_specified_type),Token(IDENTIFIER),Token(EQUAL),Rule(rule_initializer)])) return buildResult_single_declaration(r, 3);
		if(r = trySequence([Rule(rule_fully_specified_type),Token(IDENTIFIER),Token(LEFT_BRACKET),Rule(rule_constant_expression),Token(RIGHT_BRACKET)])) return buildResult_single_declaration(r, 2);
		if(r = trySequence([Rule(rule_fully_specified_type),Token(IDENTIFIER)])) return buildResult_single_declaration(r, 1);
		if(r = trySequence([Rule(rule_fully_specified_type)])) return buildResult_single_declaration(r, 0);
		trace("failed single_declaration");
		return null;
	}

	static function rule_fully_specified_type(){
		trace("trying rule: fully_specified_type");
		if(r = trySequence([Rule(rule_type_qualifier),Rule(rule_type_specifier)])) return buildResult_fully_specified_type(r, 1);
		if(r = trySequence([Rule(rule_type_specifier)])) return buildResult_fully_specified_type(r, 0);
		trace("failed fully_specified_type");
		return null;
	}

	static function rule_type_qualifier(){
		trace("trying rule: type_qualifier");
		if(r = trySequence([Token(UNIFORM)])) return buildResult_type_qualifier(r, 4);
		if(r = trySequence([Token(INVARIANT),Token(VARYING)])) return buildResult_type_qualifier(r, 3);
		if(r = trySequence([Token(VARYING)])) return buildResult_type_qualifier(r, 2);
		if(r = trySequence([Token(ATTRIBUTE)])) return buildResult_type_qualifier(r, 1);
		if(r = trySequence([Token(CONST)])) return buildResult_type_qualifier(r, 0);
		trace("failed type_qualifier");
		return null;
	}

	static function rule_type_specifier(){
		trace("trying rule: type_specifier");
		if(r = trySequence([Rule(rule_precision_qualifier),Rule(rule_type_specifier_no_prec)])) return buildResult_type_specifier(r, 1);
		if(r = trySequence([Rule(rule_type_specifier_no_prec)])) return buildResult_type_specifier(r, 0);
		trace("failed type_specifier");
		return null;
	}

	static function rule_type_specifier_no_prec(){
		trace("trying rule: type_specifier_no_prec");
		if(r = trySequence([Token(TYPE_NAME)])) return buildResult_type_specifier_no_prec(r, 19);
		if(r = trySequence([Rule(rule_struct_specifier)])) return buildResult_type_specifier_no_prec(r, 18);
		if(r = trySequence([Token(SAMPLERCUBE)])) return buildResult_type_specifier_no_prec(r, 17);
		if(r = trySequence([Token(SAMPLER2D)])) return buildResult_type_specifier_no_prec(r, 16);
		if(r = trySequence([Token(MAT4)])) return buildResult_type_specifier_no_prec(r, 15);
		if(r = trySequence([Token(MAT3)])) return buildResult_type_specifier_no_prec(r, 14);
		if(r = trySequence([Token(MAT2)])) return buildResult_type_specifier_no_prec(r, 13);
		if(r = trySequence([Token(IVEC4)])) return buildResult_type_specifier_no_prec(r, 12);
		if(r = trySequence([Token(IVEC3)])) return buildResult_type_specifier_no_prec(r, 11);
		if(r = trySequence([Token(IVEC2)])) return buildResult_type_specifier_no_prec(r, 10);
		if(r = trySequence([Token(BVEC4)])) return buildResult_type_specifier_no_prec(r, 9);
		if(r = trySequence([Token(BVEC3)])) return buildResult_type_specifier_no_prec(r, 8);
		if(r = trySequence([Token(BVEC2)])) return buildResult_type_specifier_no_prec(r, 7);
		if(r = trySequence([Token(VEC4)])) return buildResult_type_specifier_no_prec(r, 6);
		if(r = trySequence([Token(VEC3)])) return buildResult_type_specifier_no_prec(r, 5);
		if(r = trySequence([Token(VEC2)])) return buildResult_type_specifier_no_prec(r, 4);
		if(r = trySequence([Token(BOOL)])) return buildResult_type_specifier_no_prec(r, 3);
		if(r = trySequence([Token(INT)])) return buildResult_type_specifier_no_prec(r, 2);
		if(r = trySequence([Token(FLOAT)])) return buildResult_type_specifier_no_prec(r, 1);
		if(r = trySequence([Token(VOID)])) return buildResult_type_specifier_no_prec(r, 0);
		trace("failed type_specifier_no_prec");
		return null;
	}

	static function rule_precision_qualifier(){
		trace("trying rule: precision_qualifier");
		if(r = trySequence([Token(LOW_PRECISION)])) return buildResult_precision_qualifier(r, 2);
		if(r = trySequence([Token(MEDIUM_PRECISION)])) return buildResult_precision_qualifier(r, 1);
		if(r = trySequence([Token(HIGH_PRECISION)])) return buildResult_precision_qualifier(r, 0);
		trace("failed precision_qualifier");
		return null;
	}

	static function rule_struct_specifier(){
		trace("trying rule: struct_specifier");
		if(r = trySequence([Token(STRUCT),Token(LEFT_BRACE),Rule(rule_struct_declaration_list),Token(RIGHT_BRACE)])) return buildResult_struct_specifier(r, 1);
		if(r = trySequence([Token(STRUCT),Token(IDENTIFIER),Token(LEFT_BRACE),Rule(rule_struct_declaration_list),Token(RIGHT_BRACE)])) return buildResult_struct_specifier(r, 0);
		trace("failed struct_specifier");
		return null;
	}

	static function rule_struct_declaration_list(){
		trace("trying rule: struct_declaration_list");
		if(r = trySequence([Rule(rule_struct_declaration_list),Rule(rule_struct_declaration)])) return buildResult_struct_declaration_list(r, 1);
		if(r = trySequence([Rule(rule_struct_declaration)])) return buildResult_struct_declaration_list(r, 0);
		trace("failed struct_declaration_list");
		return null;
	}

	static function rule_struct_declaration(){
		trace("trying rule: struct_declaration");
		if(r = trySequence([Rule(rule_type_specifier),Rule(rule_struct_declarator_list),Token(SEMICOLON)])) return buildResult_struct_declaration(r, 0);
		trace("failed struct_declaration");
		return null;
	}

	static function rule_struct_declarator_list(){
		trace("trying rule: struct_declarator_list");
		if(r = trySequence([Rule(rule_struct_declarator_list),Token(COMMA),Rule(rule_struct_declarator)])) return buildResult_struct_declarator_list(r, 1);
		if(r = trySequence([Rule(rule_struct_declarator)])) return buildResult_struct_declarator_list(r, 0);
		trace("failed struct_declarator_list");
		return null;
	}

	static function rule_struct_declarator(){
		trace("trying rule: struct_declarator");
		if(r = trySequence([Token(IDENTIFIER),Token(LEFT_BRACKET),Rule(rule_constant_expression),Token(RIGHT_BRACKET)])) return buildResult_struct_declarator(r, 1);
		if(r = trySequence([Token(IDENTIFIER)])) return buildResult_struct_declarator(r, 0);
		trace("failed struct_declarator");
		return null;
	}

	static function rule_initializer(){
		trace("trying rule: initializer");
		if(r = trySequence([Rule(rule_assignment_expression)])) return buildResult_initializer(r, 0);
		trace("failed initializer");
		return null;
	}

	static function rule_declaration_statement(){
		trace("trying rule: declaration_statement");
		if(r = trySequence([Rule(rule_declaration)])) return buildResult_declaration_statement(r, 0);
		trace("failed declaration_statement");
		return null;
	}

	static function rule_statement_no_new_scope(){
		trace("trying rule: statement_no_new_scope");
		if(r = trySequence([Rule(rule_simple_statement)])) return buildResult_statement_no_new_scope(r, 1);
		if(r = trySequence([Rule(rule_compound_statement_with_scope)])) return buildResult_statement_no_new_scope(r, 0);
		trace("failed statement_no_new_scope");
		return null;
	}

	static function rule_simple_statement(){
		trace("trying rule: simple_statement");
		if(r = trySequence([Rule(rule_jump_statement)])) return buildResult_simple_statement(r, 4);
		if(r = trySequence([Rule(rule_iteration_statement)])) return buildResult_simple_statement(r, 3);
		if(r = trySequence([Rule(rule_selection_statement)])) return buildResult_simple_statement(r, 2);
		if(r = trySequence([Rule(rule_expression_statement)])) return buildResult_simple_statement(r, 1);
		if(r = trySequence([Rule(rule_declaration_statement)])) return buildResult_simple_statement(r, 0);
		trace("failed simple_statement");
		return null;
	}

	static function rule_compound_statement_with_scope(){
		trace("trying rule: compound_statement_with_scope");
		if(r = trySequence([Token(LEFT_BRACE),Rule(rule_statement_list),Token(RIGHT_BRACE)])) return buildResult_compound_statement_with_scope(r, 1);
		if(r = trySequence([Token(LEFT_BRACE),Token(RIGHT_BRACE)])) return buildResult_compound_statement_with_scope(r, 0);
		trace("failed compound_statement_with_scope");
		return null;
	}

	static function rule_statement_with_scope(){
		trace("trying rule: statement_with_scope");
		if(r = trySequence([Rule(rule_simple_statement)])) return buildResult_statement_with_scope(r, 1);
		if(r = trySequence([Rule(rule_compound_statement_no_new_scope)])) return buildResult_statement_with_scope(r, 0);
		trace("failed statement_with_scope");
		return null;
	}

	static function rule_compound_statement_no_new_scope(){
		trace("trying rule: compound_statement_no_new_scope");
		if(r = trySequence([Token(LEFT_BRACE),Rule(rule_statement_list),Token(RIGHT_BRACE)])) return buildResult_compound_statement_no_new_scope(r, 1);
		if(r = trySequence([Token(LEFT_BRACE),Token(RIGHT_BRACE)])) return buildResult_compound_statement_no_new_scope(r, 0);
		trace("failed compound_statement_no_new_scope");
		return null;
	}

	static function rule_statement_list(){
		trace("trying rule: statement_list");
		if(r = trySequence([Rule(rule_statement_list),Rule(rule_statement_no_new_scope)])) return buildResult_statement_list(r, 1);
		if(r = trySequence([Rule(rule_statement_no_new_scope)])) return buildResult_statement_list(r, 0);
		trace("failed statement_list");
		return null;
	}

	static function rule_expression_statement(){
		trace("trying rule: expression_statement");
		if(r = trySequence([Rule(rule_expression),Token(SEMICOLON)])) return buildResult_expression_statement(r, 1);
		if(r = trySequence([Token(SEMICOLON)])) return buildResult_expression_statement(r, 0);
		trace("failed expression_statement");
		return null;
	}

	static function rule_selection_statement(){
		trace("trying rule: selection_statement");
		if(r = trySequence([Token(IF),Token(LEFT_PAREN),Rule(rule_expression),Token(RIGHT_PAREN),Rule(rule_selection_rest_statement)])) return buildResult_selection_statement(r, 0);
		trace("failed selection_statement");
		return null;
	}

	static function rule_selection_rest_statement(){
		trace("trying rule: selection_rest_statement");
		if(r = trySequence([Rule(rule_statement_with_scope)])) return buildResult_selection_rest_statement(r, 1);
		if(r = trySequence([Rule(rule_statement_with_scope),Token(ELSE),Rule(rule_statement_with_scope)])) return buildResult_selection_rest_statement(r, 0);
		trace("failed selection_rest_statement");
		return null;
	}

	static function rule_condition(){
		trace("trying rule: condition");
		if(r = trySequence([Rule(rule_fully_specified_type),Token(IDENTIFIER),Token(EQUAL),Rule(rule_initializer)])) return buildResult_condition(r, 1);
		if(r = trySequence([Rule(rule_expression)])) return buildResult_condition(r, 0);
		trace("failed condition");
		return null;
	}

	static function rule_iteration_statement(){
		trace("trying rule: iteration_statement");
		if(r = trySequence([Token(FOR),Token(LEFT_PAREN),Rule(rule_for_init_statement),Rule(rule_for_rest_statement),Token(RIGHT_PAREN),Rule(rule_statement_no_new_scope)])) return buildResult_iteration_statement(r, 2);
		if(r = trySequence([Token(DO),Rule(rule_statement_with_scope),Token(WHILE),Token(LEFT_PAREN),Rule(rule_expression),Token(RIGHT_PAREN),Token(SEMICOLON)])) return buildResult_iteration_statement(r, 1);
		if(r = trySequence([Token(WHILE),Token(LEFT_PAREN),Rule(rule_condition),Token(RIGHT_PAREN),Rule(rule_statement_no_new_scope)])) return buildResult_iteration_statement(r, 0);
		trace("failed iteration_statement");
		return null;
	}

	static function rule_for_init_statement(){
		trace("trying rule: for_init_statement");
		if(r = trySequence([Rule(rule_declaration_statement)])) return buildResult_for_init_statement(r, 1);
		if(r = trySequence([Rule(rule_expression_statement)])) return buildResult_for_init_statement(r, 0);
		trace("failed for_init_statement");
		return null;
	}

	static function rule_conditionopt(){
		trace("trying rule: conditionopt");
		if(r = trySequence([Rule(rule_condition)])) return buildResult_conditionopt(r, 1);
		return buildResult_conditionopt(r, 0);
		trace("failed conditionopt");
	}

	static function rule_for_rest_statement(){
		trace("trying rule: for_rest_statement");
		if(r = trySequence([Rule(rule_conditionopt),Token(SEMICOLON),Rule(rule_expression)])) return buildResult_for_rest_statement(r, 1);
		if(r = trySequence([Rule(rule_conditionopt),Token(SEMICOLON)])) return buildResult_for_rest_statement(r, 0);
		trace("failed for_rest_statement");
		return null;
	}

	static function rule_jump_statement(){
		trace("trying rule: jump_statement");
		if(r = trySequence([Token(DISCARD),Token(SEMICOLON)])) return buildResult_jump_statement(r, 4);
		if(r = trySequence([Token(RETURN),Rule(rule_expression),Token(SEMICOLON)])) return buildResult_jump_statement(r, 3);
		if(r = trySequence([Token(RETURN),Token(SEMICOLON)])) return buildResult_jump_statement(r, 2);
		if(r = trySequence([Token(BREAK),Token(SEMICOLON)])) return buildResult_jump_statement(r, 1);
		if(r = trySequence([Token(CONTINUE),Token(SEMICOLON)])) return buildResult_jump_statement(r, 0);
		trace("failed jump_statement");
		return null;
	}

	static function rule_translation_unit(){
		trace("trying rule: translation_unit");
		if(r = trySequence([Rule(rule_external_declaration),Rule(rule_translation_unit)])) return buildResult_translation_unit(r, 1);
		if(r = trySequence([Rule(rule_external_declaration)])) return buildResult_translation_unit(r, 0);
		trace("failed translation_unit");
		return null;
	}

	static function rule_external_declaration(){
		trace("trying rule: external_declaration");
		if(r = trySequence([Rule(rule_declaration)])) return buildResult_external_declaration(r, 1);
		if(r = trySequence([Rule(rule_function_definition)])) return buildResult_external_declaration(r, 0);
		trace("failed external_declaration");
		return null;
	}

	static function rule_function_definition(){
		trace("trying rule: function_definition");
		if(r = trySequence([Rule(rule_function_prototype),Rule(rule_compound_statement_no_new_scope)])) return buildResult_function_definition(r, 0);
		trace("failed function_definition");
		return null;
	}

/* --------- Build result functions --------- */
	static function buildResult_variable_identifier(r:SequenceResults, sequenceIndex:Int){
		trace("building result for variable_identifier");
		switch (sequenceIndex) {
			case 0: // IDENTIFIER
		}
		return {};
	}

	static function buildResult_primary_expression(r:SequenceResults, sequenceIndex:Int){
		trace("building result for primary_expression");
		switch (sequenceIndex) {
			case 0: // variable_identifier
			case 1: // INTCONSTANT
			case 2: // FLOATCONSTANT
			case 3: // BOOLCONSTANT
			case 4: // LEFT_PAREN expression RIGHT_PAREN
		}
		return {};
	}

	static function buildResult_postfix_expression(r:SequenceResults, sequenceIndex:Int){
		trace("building result for postfix_expression");
		switch (sequenceIndex) {
			case 0: // primary_expression
			case 1: // postfix_expression LEFT_BRACKET integer_expression RIGHT_BRACKET
			case 2: // function_call
			case 3: // postfix_expression DOT FIELD_SELECTION
			case 4: // postfix_expression INC_OP
			case 5: // postfix_expression DEC_OP
		}
		return {};
	}

	static function buildResult_integer_expression(r:SequenceResults, sequenceIndex:Int){
		trace("building result for integer_expression");
		switch (sequenceIndex) {
			case 0: // expression
		}
		return {};
	}

	static function buildResult_function_call(r:SequenceResults, sequenceIndex:Int){
		trace("building result for function_call");
		switch (sequenceIndex) {
			case 0: // function_call_generic
		}
		return {};
	}

	static function buildResult_function_call_generic(r:SequenceResults, sequenceIndex:Int){
		trace("building result for function_call_generic");
		switch (sequenceIndex) {
			case 0: // function_call_header_with_parameters RIGHT_PAREN
			case 1: // function_call_header_no_parameters RIGHT_PAREN
		}
		return {};
	}

	static function buildResult_function_call_header_no_parameters(r:SequenceResults, sequenceIndex:Int){
		trace("building result for function_call_header_no_parameters");
		switch (sequenceIndex) {
			case 0: // function_call_header VOID
			case 1: // function_call_header
		}
		return {};
	}

	static function buildResult_function_call_header_with_parameters(r:SequenceResults, sequenceIndex:Int){
		trace("building result for function_call_header_with_parameters");
		switch (sequenceIndex) {
			case 0: // function_call_header assignment_expression
			case 1: // function_call_header_with_parameters COMMA assignment_expression
		}
		return {};
	}

	static function buildResult_function_call_header(r:SequenceResults, sequenceIndex:Int){
		trace("building result for function_call_header");
		switch (sequenceIndex) {
			case 0: // function_identifier LEFT_PAREN
		}
		return {};
	}

	static function buildResult_function_identifier(r:SequenceResults, sequenceIndex:Int){
		trace("building result for function_identifier");
		switch (sequenceIndex) {
			case 0: // constructor_identifier
			case 1: // IDENTIFIER
		}
		return {};
	}

	static function buildResult_constructor_identifier(r:SequenceResults, sequenceIndex:Int){
		trace("building result for constructor_identifier");
		switch (sequenceIndex) {
			case 0: // FLOAT
			case 1: // INT
			case 2: // BOOL
			case 3: // VEC2
			case 4: // VEC3
			case 5: // VEC4
			case 6: // BVEC2
			case 7: // BVEC3
			case 8: // BVEC4
			case 9: // IVEC2
			case 10: // IVEC3
			case 11: // IVEC4
			case 12: // MAT2
			case 13: // MAT3
			case 14: // MAT4
			case 15: // TYPE_NAME
		}
		return {};
	}

	static function buildResult_unary_expression(r:SequenceResults, sequenceIndex:Int){
		trace("building result for unary_expression");
		switch (sequenceIndex) {
			case 0: // postfix_expression
			case 1: // INC_OP unary_expression
			case 2: // DEC_OP unary_expression
			case 3: // unary_operator unary_expression
		}
		return {};
	}

	static function buildResult_unary_operator(r:SequenceResults, sequenceIndex:Int){
		trace("building result for unary_operator");
		switch (sequenceIndex) {
			case 0: // PLUS
			case 1: // DASH
			case 2: // BANG
			case 3: // TILDE
		}
		return {};
	}

	static function buildResult_multiplicative_expression(r:SequenceResults, sequenceIndex:Int){
		trace("building result for multiplicative_expression");
		switch (sequenceIndex) {
			case 0: // unary_expression
			case 1: // multiplicative_expression STAR unary_expression
			case 2: // multiplicative_expression SLASH unary_expression
			case 3: // multiplicative_expression PERCENT unary_expression
		}
		return {};
	}

	static function buildResult_additive_expression(r:SequenceResults, sequenceIndex:Int){
		trace("building result for additive_expression");
		switch (sequenceIndex) {
			case 0: // multiplicative_expression
			case 1: // additive_expression PLUS multiplicative_expression
			case 2: // additive_expression DASH multiplicative_expression
		}
		return {};
	}

	static function buildResult_shift_expression(r:SequenceResults, sequenceIndex:Int){
		trace("building result for shift_expression");
		switch (sequenceIndex) {
			case 0: // additive_expression
			case 1: // shift_expression LEFT_OP additive_expression
			case 2: // shift_expression RIGHT_OP additive_expression
		}
		return {};
	}

	static function buildResult_relational_expression(r:SequenceResults, sequenceIndex:Int){
		trace("building result for relational_expression");
		switch (sequenceIndex) {
			case 0: // shift_expression
			case 1: // relational_expression LEFT_ANGLE shift_expression
			case 2: // relational_expression RIGHT_ANGLE shift_expression
			case 3: // relational_expression LE_OP shift_expression
			case 4: // relational_expression GE_OP shift_expression
		}
		return {};
	}

	static function buildResult_equality_expression(r:SequenceResults, sequenceIndex:Int){
		trace("building result for equality_expression");
		switch (sequenceIndex) {
			case 0: // relational_expression
			case 1: // equality_expression EQ_OP relational_expression
			case 2: // equality_expression NE_OP relational_expression
		}
		return {};
	}

	static function buildResult_and_expression(r:SequenceResults, sequenceIndex:Int){
		trace("building result for and_expression");
		switch (sequenceIndex) {
			case 0: // equality_expression
			case 1: // and_expression AMPERSAND equality_expression
		}
		return {};
	}

	static function buildResult_exclusive_or_expression(r:SequenceResults, sequenceIndex:Int){
		trace("building result for exclusive_or_expression");
		switch (sequenceIndex) {
			case 0: // and_expression
			case 1: // exclusive_or_expression CARET and_expression
		}
		return {};
	}

	static function buildResult_inclusive_or_expression(r:SequenceResults, sequenceIndex:Int){
		trace("building result for inclusive_or_expression");
		switch (sequenceIndex) {
			case 0: // exclusive_or_expression
			case 1: // inclusive_or_expression VERTICAL_BAR exclusive_or_expression
		}
		return {};
	}

	static function buildResult_logical_and_expression(r:SequenceResults, sequenceIndex:Int){
		trace("building result for logical_and_expression");
		switch (sequenceIndex) {
			case 0: // inclusive_or_expression
			case 1: // logical_and_expression AND_OP inclusive_or_expression
		}
		return {};
	}

	static function buildResult_logical_xor_expression(r:SequenceResults, sequenceIndex:Int){
		trace("building result for logical_xor_expression");
		switch (sequenceIndex) {
			case 0: // logical_and_expression
			case 1: // logical_xor_expression XOR_OP logical_and_expression
		}
		return {};
	}

	static function buildResult_logical_or_expression(r:SequenceResults, sequenceIndex:Int){
		trace("building result for logical_or_expression");
		switch (sequenceIndex) {
			case 0: // logical_xor_expression
			case 1: // logical_or_expression OR_OP logical_xor_expression
		}
		return {};
	}

	static function buildResult_conditional_expression(r:SequenceResults, sequenceIndex:Int){
		trace("building result for conditional_expression");
		switch (sequenceIndex) {
			case 0: // logical_or_expression
			case 1: // logical_or_expression QUESTION expression COLON assignment_expression
		}
		return {};
	}

	static function buildResult_assignment_expression(r:SequenceResults, sequenceIndex:Int){
		trace("building result for assignment_expression");
		switch (sequenceIndex) {
			case 0: // conditional_expression
			case 1: // unary_expression assignment_operator assignment_expression
		}
		return {};
	}

	static function buildResult_assignment_operator(r:SequenceResults, sequenceIndex:Int){
		trace("building result for assignment_operator");
		switch (sequenceIndex) {
			case 0: // EQUAL
			case 1: // MUL_ASSIGN
			case 2: // DIV_ASSIGN
			case 3: // MOD_ASSIGN
			case 4: // ADD_ASSIGN
			case 5: // SUB_ASSIGN
			case 6: // LEFT_ASSIGN
			case 7: // RIGHT_ASSIGN
			case 8: // AND_ASSIGN
			case 9: // XOR_ASSIGN
			case 10: // OR_ASSIGN
		}
		return {};
	}

	static function buildResult_expression(r:SequenceResults, sequenceIndex:Int){
		trace("building result for expression");
		switch (sequenceIndex) {
			case 0: // assignment_expression
			case 1: // expression COMMA assignment_expression
		}
		return {};
	}

	static function buildResult_constant_expression(r:SequenceResults, sequenceIndex:Int){
		trace("building result for constant_expression");
		switch (sequenceIndex) {
			case 0: // conditional_expression
		}
		return {};
	}

	static function buildResult_declaration(r:SequenceResults, sequenceIndex:Int){
		trace("building result for declaration");
		switch (sequenceIndex) {
			case 0: // function_prototype SEMICOLON
			case 1: // init_declarator_list SEMICOLON
			case 2: // PRECISION precision_qualifier type_specifier_no_prec SEMICOLON
		}
		return {};
	}

	static function buildResult_function_prototype(r:SequenceResults, sequenceIndex:Int){
		trace("building result for function_prototype");
		switch (sequenceIndex) {
			case 0: // function_declarator RIGHT_PAREN
		}
		return {};
	}

	static function buildResult_function_declarator(r:SequenceResults, sequenceIndex:Int){
		trace("building result for function_declarator");
		switch (sequenceIndex) {
			case 0: // function_header
			case 1: // function_header_with_parameters
		}
		return {};
	}

	static function buildResult_function_header_with_parameters(r:SequenceResults, sequenceIndex:Int){
		trace("building result for function_header_with_parameters");
		switch (sequenceIndex) {
			case 0: // function_header parameter_declaration
			case 1: // function_header_with_parameters COMMA parameter_declaration
		}
		return {};
	}

	static function buildResult_function_header(r:SequenceResults, sequenceIndex:Int){
		trace("building result for function_header");
		switch (sequenceIndex) {
			case 0: // fully_specified_type IDENTIFIER LEFT_PAREN
		}
		return {};
	}

	static function buildResult_parameter_declarator(r:SequenceResults, sequenceIndex:Int){
		trace("building result for parameter_declarator");
		switch (sequenceIndex) {
			case 0: // type_specifier IDENTIFIER
			case 1: // type_specifier IDENTIFIER LEFT_BRACKET constant_expression RIGHT_BRACKET
		}
		return {};
	}

	static function buildResult_parameter_declaration(r:SequenceResults, sequenceIndex:Int){
		trace("building result for parameter_declaration");
		switch (sequenceIndex) {
			case 0: // type_qualifier parameter_qualifier parameter_declarator
			case 1: // parameter_qualifier parameter_declarator
			case 2: // type_qualifier parameter_qualifier parameter_type_specifier
			case 3: // parameter_qualifier parameter_type_specifier
		}
		return {};
	}

	static function buildResult_parameter_qualifier(r:SequenceResults, sequenceIndex:Int){
		trace("building result for parameter_qualifier");
		switch (sequenceIndex) {
			case 0: // *empty*
			case 1: // IN
			case 2: // OUT
			case 3: // INOUT
		}
		return {};
	}

	static function buildResult_parameter_type_specifier(r:SequenceResults, sequenceIndex:Int){
		trace("building result for parameter_type_specifier");
		switch (sequenceIndex) {
			case 0: // type_specifier
			case 1: // type_specifier LEFT_BRACKET constant_expression RIGHT_BRACKET
		}
		return {};
	}

	static function buildResult_init_declarator_list(r:SequenceResults, sequenceIndex:Int){
		trace("building result for init_declarator_list");
		switch (sequenceIndex) {
			case 0: // single_declaration
			case 1: // init_declarator_list COMMA IDENTIFIER
			case 2: // init_declarator_list COMMA IDENTIFIER LEFT_BRACKET constant_expression RIGHT_BRACKET
			case 3: // init_declarator_list COMMA IDENTIFIER EQUAL initializer
		}
		return {};
	}

	static function buildResult_single_declaration(r:SequenceResults, sequenceIndex:Int){
		trace("building result for single_declaration");
		switch (sequenceIndex) {
			case 0: // fully_specified_type
			case 1: // fully_specified_type IDENTIFIER
			case 2: // fully_specified_type IDENTIFIER LEFT_BRACKET constant_expression RIGHT_BRACKET
			case 3: // fully_specified_type IDENTIFIER EQUAL initializer
			case 4: // INVARIANT IDENTIFIER
		}
		return {};
	}

	static function buildResult_fully_specified_type(r:SequenceResults, sequenceIndex:Int){
		trace("building result for fully_specified_type");
		switch (sequenceIndex) {
			case 0: // type_specifier
			case 1: // type_qualifier type_specifier
		}
		return {};
	}

	static function buildResult_type_qualifier(r:SequenceResults, sequenceIndex:Int){
		trace("building result for type_qualifier");
		switch (sequenceIndex) {
			case 0: // CONST
			case 1: // ATTRIBUTE
			case 2: // VARYING
			case 3: // INVARIANT VARYING
			case 4: // UNIFORM
		}
		return {};
	}

	static function buildResult_type_specifier(r:SequenceResults, sequenceIndex:Int){
		trace("building result for type_specifier");
		switch (sequenceIndex) {
			case 0: // type_specifier_no_prec
			case 1: // precision_qualifier type_specifier_no_prec
		}
		return {};
	}

	static function buildResult_type_specifier_no_prec(r:SequenceResults, sequenceIndex:Int){
		trace("building result for type_specifier_no_prec");
		switch (sequenceIndex) {
			case 0: // VOID
			case 1: // FLOAT
			case 2: // INT
			case 3: // BOOL
			case 4: // VEC2
			case 5: // VEC3
			case 6: // VEC4
			case 7: // BVEC2
			case 8: // BVEC3
			case 9: // BVEC4
			case 10: // IVEC2
			case 11: // IVEC3
			case 12: // IVEC4
			case 13: // MAT2
			case 14: // MAT3
			case 15: // MAT4
			case 16: // SAMPLER2D
			case 17: // SAMPLERCUBE
			case 18: // struct_specifier
			case 19: // TYPE_NAME
		}
		return {};
	}

	static function buildResult_precision_qualifier(r:SequenceResults, sequenceIndex:Int){
		trace("building result for precision_qualifier");
		switch (sequenceIndex) {
			case 0: // HIGH_PRECISION
			case 1: // MEDIUM_PRECISION
			case 2: // LOW_PRECISION
		}
		return {};
	}

	static function buildResult_struct_specifier(r:SequenceResults, sequenceIndex:Int){
		trace("building result for struct_specifier");
		switch (sequenceIndex) {
			case 0: // STRUCT IDENTIFIER LEFT_BRACE struct_declaration_list RIGHT_BRACE
			case 1: // STRUCT LEFT_BRACE struct_declaration_list RIGHT_BRACE
		}
		return {};
	}

	static function buildResult_struct_declaration_list(r:SequenceResults, sequenceIndex:Int){
		trace("building result for struct_declaration_list");
		switch (sequenceIndex) {
			case 0: // struct_declaration
			case 1: // struct_declaration_list struct_declaration
		}
		return {};
	}

	static function buildResult_struct_declaration(r:SequenceResults, sequenceIndex:Int){
		trace("building result for struct_declaration");
		switch (sequenceIndex) {
			case 0: // type_specifier struct_declarator_list SEMICOLON
		}
		return {};
	}

	static function buildResult_struct_declarator_list(r:SequenceResults, sequenceIndex:Int){
		trace("building result for struct_declarator_list");
		switch (sequenceIndex) {
			case 0: // struct_declarator
			case 1: // struct_declarator_list COMMA struct_declarator
		}
		return {};
	}

	static function buildResult_struct_declarator(r:SequenceResults, sequenceIndex:Int){
		trace("building result for struct_declarator");
		switch (sequenceIndex) {
			case 0: // IDENTIFIER
			case 1: // IDENTIFIER LEFT_BRACKET constant_expression RIGHT_BRACKET
		}
		return {};
	}

	static function buildResult_initializer(r:SequenceResults, sequenceIndex:Int){
		trace("building result for initializer");
		switch (sequenceIndex) {
			case 0: // assignment_expression
		}
		return {};
	}

	static function buildResult_declaration_statement(r:SequenceResults, sequenceIndex:Int){
		trace("building result for declaration_statement");
		switch (sequenceIndex) {
			case 0: // declaration
		}
		return {};
	}

	static function buildResult_statement_no_new_scope(r:SequenceResults, sequenceIndex:Int){
		trace("building result for statement_no_new_scope");
		switch (sequenceIndex) {
			case 0: // compound_statement_with_scope
			case 1: // simple_statement
		}
		return {};
	}

	static function buildResult_simple_statement(r:SequenceResults, sequenceIndex:Int){
		trace("building result for simple_statement");
		switch (sequenceIndex) {
			case 0: // declaration_statement
			case 1: // expression_statement
			case 2: // selection_statement
			case 3: // iteration_statement
			case 4: // jump_statement
		}
		return {};
	}

	static function buildResult_compound_statement_with_scope(r:SequenceResults, sequenceIndex:Int){
		trace("building result for compound_statement_with_scope");
		switch (sequenceIndex) {
			case 0: // LEFT_BRACE RIGHT_BRACE
			case 1: // LEFT_BRACE statement_list RIGHT_BRACE
		}
		return {};
	}

	static function buildResult_statement_with_scope(r:SequenceResults, sequenceIndex:Int){
		trace("building result for statement_with_scope");
		switch (sequenceIndex) {
			case 0: // compound_statement_no_new_scope
			case 1: // simple_statement
		}
		return {};
	}

	static function buildResult_compound_statement_no_new_scope(r:SequenceResults, sequenceIndex:Int){
		trace("building result for compound_statement_no_new_scope");
		switch (sequenceIndex) {
			case 0: // LEFT_BRACE RIGHT_BRACE
			case 1: // LEFT_BRACE statement_list RIGHT_BRACE
		}
		return {};
	}

	static function buildResult_statement_list(r:SequenceResults, sequenceIndex:Int){
		trace("building result for statement_list");
		switch (sequenceIndex) {
			case 0: // statement_no_new_scope
			case 1: // statement_list statement_no_new_scope
		}
		return {};
	}

	static function buildResult_expression_statement(r:SequenceResults, sequenceIndex:Int){
		trace("building result for expression_statement");
		switch (sequenceIndex) {
			case 0: // SEMICOLON
			case 1: // expression SEMICOLON
		}
		return {};
	}

	static function buildResult_selection_statement(r:SequenceResults, sequenceIndex:Int){
		trace("building result for selection_statement");
		switch (sequenceIndex) {
			case 0: // IF LEFT_PAREN expression RIGHT_PAREN selection_rest_statement
		}
		return {};
	}

	static function buildResult_selection_rest_statement(r:SequenceResults, sequenceIndex:Int){
		trace("building result for selection_rest_statement");
		switch (sequenceIndex) {
			case 0: // statement_with_scope ELSE statement_with_scope
			case 1: // statement_with_scope
		}
		return {};
	}

	static function buildResult_condition(r:SequenceResults, sequenceIndex:Int){
		trace("building result for condition");
		switch (sequenceIndex) {
			case 0: // expression
			case 1: // fully_specified_type IDENTIFIER EQUAL initializer
		}
		return {};
	}

	static function buildResult_iteration_statement(r:SequenceResults, sequenceIndex:Int){
		trace("building result for iteration_statement");
		switch (sequenceIndex) {
			case 0: // WHILE LEFT_PAREN condition RIGHT_PAREN statement_no_new_scope
			case 1: // DO statement_with_scope WHILE LEFT_PAREN expression RIGHT_PAREN SEMICOLON
			case 2: // FOR LEFT_PAREN for_init_statement for_rest_statement RIGHT_PAREN statement_no_new_scope
		}
		return {};
	}

	static function buildResult_for_init_statement(r:SequenceResults, sequenceIndex:Int){
		trace("building result for for_init_statement");
		switch (sequenceIndex) {
			case 0: // expression_statement
			case 1: // declaration_statement
		}
		return {};
	}

	static function buildResult_conditionopt(r:SequenceResults, sequenceIndex:Int){
		trace("building result for conditionopt");
		switch (sequenceIndex) {
			case 0: // *empty*
			case 1: // condition
		}
		return {};
	}

	static function buildResult_for_rest_statement(r:SequenceResults, sequenceIndex:Int){
		trace("building result for for_rest_statement");
		switch (sequenceIndex) {
			case 0: // conditionopt SEMICOLON
			case 1: // conditionopt SEMICOLON expression
		}
		return {};
	}

	static function buildResult_jump_statement(r:SequenceResults, sequenceIndex:Int){
		trace("building result for jump_statement");
		switch (sequenceIndex) {
			case 0: // CONTINUE SEMICOLON
			case 1: // BREAK SEMICOLON
			case 2: // RETURN SEMICOLON
			case 3: // RETURN expression SEMICOLON
			case 4: // DISCARD SEMICOLON
		}
		return {};
	}

	static function buildResult_translation_unit(r:SequenceResults, sequenceIndex:Int){
		trace("building result for translation_unit");
		switch (sequenceIndex) {
			case 0: // external_declaration
			case 1: // external_declaration translation_unit
		}
		return {};
	}

	static function buildResult_external_declaration(r:SequenceResults, sequenceIndex:Int){
		trace("building result for external_declaration");
		switch (sequenceIndex) {
			case 0: // function_definition
			case 1: // declaration
		}
		return {};
	}

	static function buildResult_function_definition(r:SequenceResults, sequenceIndex:Int){
		trace("building result for function_definition");
		switch (sequenceIndex) {
			case 0: // function_prototype compound_statement_no_new_scope
		}
		return {};
	}

}