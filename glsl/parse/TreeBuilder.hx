/*
	TreeBuilder is responsible for constructing the abstract syntax tree by creation
	and concatenation of notes in accordance with the grammar rules of the language
	
	Using ruleset GLSL_ES_100_PP_scope: GLES 1.00 modified to accept preprocessor tokens as translation_units and statements

	@author George Corney
*/

package glsl.parse;

import glsl.token.Tokenizer.Token;
import glsl.token.Tokenizer.TokenType;
import glsl.SyntaxTree;

typedef MinorType = Dynamic;


@:access(glsl.parse.Parser)
class TreeBuilder{

	static var i(get, null):Int;
	static var stack(get, null):Parser.Stack;

	static var ruleno;
	static var parseContext:ParseContext;
	static var lastToken:Token;

	static public function init(){
		ruleno = -1;
		parseContext = new ParseContext();
	}

	static public function processToken(t:Token){
		//check if identifier refers to a user defined type
		//if so, change the token's type to TYPE_NAME
		if(t.type.equals(TokenType.IDENTIFIER)){
			switch parseContext.searchScope(t.data) {
				case ParseContext.Object.USER_TYPE(_):
					trace('replacing with TYPE_NAME for ${t.data}');
					//ensure the previous token isn't a TYPE_NAME (ie to cases like S S = S();)
					var prevent = lastToken != null && lastToken.type.equals(TokenType.TYPE_NAME);
					if(!prevent){
						t.type = TokenType.TYPE_NAME;
					}
				case null, _:
			}
		}

		lastToken = t;
		return t;
	}

	static public function buildRule(ruleno:Int):MinorType{
		TreeBuilder.ruleno = ruleno; //set class ruleno so it can be accessed by other functions

		switch(ruleno){
			case 0: return new Root(untyped a(1)); //root ::= translation_unit

			/* Expressions */
			case 1: return new Identifier(t(1).data);//variable_identifier ::= IDENTIFIER
			case 2: return s(1); //primary_expression ::= variable_identifier
			case 3: var l = new Primitive<Int>(Std.parseInt(t(1).data), DataType.INT); l.raw = t(1).data; return l; //primary_expression ::= INTCONSTANT
			case 4: var l = new Primitive<Float>(Std.parseFloat(t(1).data), DataType.FLOAT); l.raw = t(1).data; return l; //primary_expression ::= FLOATCONSTANT
			case 5: var l = new Primitive<Bool>(t(1).data == 'true', DataType.BOOL); l.raw = t(1).data; return l; //primary_expression ::= BOOLCONSTANT
			case 6: e(2).enclosed = true; return s(2); //primary_expression ::= LEFT_PAREN expression RIGHT_PAREN
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
			case 19: cast(n(1), ExpressionParameters).parameters.push(untyped n(2)); return s(1); //function_call_header_with_parameters ::= function_call_header assignment_expression
			case 20: cast(n(1), ExpressionParameters).parameters.push(untyped n(3)); return s(1); //function_call_header_with_parameters ::= function_call_header_with_parameters COMMA assignment_expression
			case 21: return s(1); //function_call_header ::= function_identifier LEFT_PAREN
			case 22: return new Constructor(untyped ev(1)); //function_identifier ::= constructor_identifier
			case 23: return new FunctionCall(t(1).data); //function_identifier ::= IDENTIFIER
			case 24: return DataType.FLOAT; //constructor_identifier ::= FLOAT
			case 25: return DataType.INT; //constructor_identifier ::= INT
			case 26: return DataType.BOOL; //constructor_identifier ::= BOOL
			case 27: return DataType.VEC2; //constructor_identifier ::= VEC2
			case 28: return DataType.VEC3; //constructor_identifier ::= VEC3
			case 29: return DataType.VEC4; //constructor_identifier ::= VEC4
			case 30: return DataType.BVEC2; //constructor_identifier ::= BVEC2
			case 31: return DataType.BVEC3; //constructor_identifier ::= BVEC3
			case 32: return DataType.BVEC4; //constructor_identifier ::= BVEC4
			case 33: return DataType.IVEC2; //constructor_identifier ::= IVEC2
			case 34: return DataType.IVEC3; //constructor_identifier ::= IVEC3
			case 35: return DataType.IVEC4; //constructor_identifier ::= IVEC4
			case 36: return DataType.MAT2; //constructor_identifier ::= MAT2
			case 37: return DataType.MAT3; //constructor_identifier ::= MAT3
			case 38: return DataType.MAT4; //constructor_identifier ::= MAT4
			case 39: return DataType.USER_TYPE(t(1).data); //constructor_identifier ::= TYPE_NAME
			case 40: return s(1); //unary_expression ::= postfix_expression
			case 41: return new UnaryExpression(UnaryOperator.INC_OP, e(2), true); //unary_expression ::= INC_OP unary_expression
			case 42: return new UnaryExpression(UnaryOperator.DEC_OP, e(2), true); //unary_expression ::= DEC_OP unary_expression
			case 43: return new UnaryExpression(untyped ev(1), e(2), true); //unary_expression ::= unary_operator unary_expression
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
			case 56: return new BinaryExpression(BinaryOperator.LEFT_OP, untyped n(1), untyped n(3)); //shift_expression ::= shift_expression LEFT_OP additive_expression
			case 57: return new BinaryExpression(BinaryOperator.RIGHT_OP, untyped n(1), untyped n(3)); //shift_expression ::= shift_expression RIGHT_OP additive_expression
			case 58: return s(1); //relational_expression ::= shift_expression
			case 59: return new BinaryExpression(BinaryOperator.LEFT_ANGLE, untyped n(1), untyped n(3)); //relational_expression ::= relational_expression LEFT_ANGLE shift_expression
			case 60: return new BinaryExpression(BinaryOperator.RIGHT_ANGLE, untyped n(1), untyped n(3)); //relational_expression ::= relational_expression RIGHT_ANGLE shift_expression
			case 61: return new BinaryExpression(BinaryOperator.LE_OP, untyped n(1), untyped n(3)); //relational_expression ::= relational_expression LE_OP shift_expression
			case 62: return new BinaryExpression(BinaryOperator.GE_OP, untyped n(1), untyped n(3)); //relational_expression ::= relational_expression GE_OP shift_expression
			case 63: return s(1); //equality_expression ::= relational_expression
			case 64: return new BinaryExpression(BinaryOperator.EQ_OP, untyped n(1), untyped n(3)); //equality_expression ::= equality_expression EQ_OP relational_expression
			case 65: return new BinaryExpression(BinaryOperator.NE_OP, untyped n(1), untyped n(3)); //equality_expression ::= equality_expression NE_OP relational_expression
			case 66: return s(1); //and_expression ::= equality_expression
			case 67: return new BinaryExpression(BinaryOperator.AMPERSAND, untyped n(1), untyped n(3)); //and_expression ::= and_expression AMPERSAND equality_expression
			case 68: return s(1); //exclusive_or_expression ::= and_expression
			case 69: return new BinaryExpression(BinaryOperator.CARET, untyped n(1), untyped n(3)); //exclusive_or_expression ::= exclusive_or_expression CARET and_expression
			case 70: return s(1); //inclusive_or_expression ::= exclusive_or_expression
			case 71: return new BinaryExpression(BinaryOperator.VERTICAL_BAR, untyped n(1), untyped n(3)); //inclusive_or_expression ::= inclusive_or_expression VERTICAL_BAR exclusive_or_expression
			case 72: return s(1); //logical_and_expression ::= inclusive_or_expression
			case 73: return new BinaryExpression(BinaryOperator.AND_OP, untyped n(1), untyped n(3)); //logical_and_expression ::= logical_and_expression AND_OP inclusive_or_expression
			case 74: return s(1); //logical_xor_expression ::= logical_and_expression
			case 75: return new BinaryExpression(BinaryOperator.XOR_OP, untyped n(1), untyped n(3)); //logical_xor_expression ::= logical_xor_expression XOR_OP logical_and_expression
			case 76: return s(1); //logical_or_expression ::= logical_xor_expression
			case 77: return new BinaryExpression(BinaryOperator.OR_OP, untyped n(1), untyped n(3)); //logical_or_expression ::= logical_or_expression OR_OP logical_xor_expression
			case 78: return s(1); //conditional_expression ::= logical_or_expression
			case 79: return new ConditionalExpression(untyped n(1), untyped n(3), untyped n(5)); //conditional_expression ::= logical_or_expression QUESTION expression COLON assignment_expression
			case 80: return s(1); //assignment_expression ::= conditional_expression
			case 81: return new AssignmentExpression(untyped ev(2), untyped n(1), untyped n(3)); //assignment_expression ::= unary_expression assignment_operator assignment_expression
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


			/* Function Prototype & Header */
			case 95: return s(1); //constant_expression ::= conditional_expression
			case 96: return new FunctionPrototype(untyped s(1)); //declaration ::= function_prototype SEMICOLON
			case 97: return s(1); //declaration ::= init_declarator_list SEMICOLON
			case 98: return new PrecisionDeclaration(untyped ev(2), cast(n(3), TypeSpecifier).dataType); //declaration ::= PRECISION precision_qualifier type_specifier_no_prec SEMICOLON
			case 99: return s(1); //function_prototype ::= function_declarator RIGHT_PAREN
			case 100: return s(1); //function_declarator ::= function_header
			case 101: return s(1); //function_declarator ::= function_header_with_parameters
			case 102: var fh = cast(n(1), FunctionHeader); //function_header_with_parameters ::= function_header parameter_declaration
						fh.parameters.push(untyped n(2));
						return fh;
			case 103: var fh = cast(n(1), FunctionHeader); //function_header_with_parameters ::= function_header_with_parameters COMMA parameter_declaration
						fh.parameters.push(untyped n(3));
						return fh; 
			case 104: return new FunctionHeader(t(2).data, untyped n(1)); //function_header ::= fully_specified_type IDENTIFIER LEFT_PAREN


			/* Function Parameters
			*	a separate parameter_declarator class is sidestepped for simplicity
			*	parameter_declarator is combined with parameter_type_specifier into a single ParameterDeclaration
			*/
			case 105: return new ParameterDeclaration(t(2).data, untyped n(1)); //parameter_declarator ::= type_specifier IDENTIFIER
			case 106: return new ParameterDeclaration(t(2).data, untyped n(1), null, e(4)); //parameter_declarator ::= type_specifier IDENTIFIER LEFT_BRACKET constant_expression RIGHT_BRACKET
			case 107: var pd = cast(n(3), ParameterDeclaration); //parameter_declaration ::= type_qualifier parameter_qualifier parameter_declarator
						pd.parameterQualifier = untyped ev(2);

						if(ev(1).equals(Instructions.SET_INVARIANT_VARYING)){
							//even though invariant varying isn't allowed, set anyway and catch in the validator
							pd.typeSpecifier.storage = StorageQualifier.VARYING;
							pd.typeSpecifier.invariant = true;
						}else{
							pd.typeSpecifier.storage = untyped ev(1);
						}
						return pd;
			case 108: var pd = cast(n(2), ParameterDeclaration); //parameter_declaration ::= parameter_qualifier parameter_declarator
						pd.parameterQualifier = untyped ev(1);
						return pd;
			case 109: var pd = cast(n(3), ParameterDeclaration); //parameter_declaration ::= type_qualifier parameter_qualifier parameter_type_specifier
						pd.parameterQualifier = untyped ev(2);

						if(ev(1).equals(Instructions.SET_INVARIANT_VARYING)){
							//even though invariant varying isn't allowed, set anyway and catch in the validator
							pd.typeSpecifier.storage = StorageQualifier.VARYING;
							pd.typeSpecifier.invariant = true;
						}else{
							pd.typeSpecifier.storage = untyped ev(1);
						}
						return pd;
			case 110: var pd = cast(n(2), ParameterDeclaration); //parameter_declaration ::= parameter_qualifier parameter_type_specifier
						pd.parameterQualifier = untyped ev(1);
						return pd;
			case 111: return null; //parameter_qualifier ::=
			case 112: return ParameterQualifier.IN;//parameter_qualifier ::= IN
			case 113: return ParameterQualifier.OUT;//parameter_qualifier ::= OUT
			case 114: return ParameterQualifier.INOUT;//parameter_qualifier ::= INOUT
			case 115: return new ParameterDeclaration(null, untyped n(1)); //parameter_type_specifier ::= type_specifier
			case 116: return new ParameterDeclaration(null, untyped n(1), null, e(3));//parameter_type_specifier ::= type_specifier LEFT_BRACKET constant_expression RIGHT_BRACKET


			/* Declarations */
			case 117: return s(1); //init_declarator_list ::= single_declaration
			case 118: //init_declarator_list ::= init_declarator_list COMMA IDENTIFIER
						var declarator = new Declarator(t(3).data, null, null);
						cast(n(1), VariableDeclaration).declarators.push(declarator);
						parseContext.variableDeclaration(declarator);
						return s(1);
			case 119: //init_declarator_list ::= init_declarator_list COMMA IDENTIFIER LEFT_BRACKET constant_expression RIGHT_BRACKET
						var declarator = new Declarator(t(3).data, null, e(5));
						cast(n(1), VariableDeclaration).declarators.push(declarator);
						parseContext.variableDeclaration(declarator);
						return s(1);
			case 120: //init_declarator_list ::= init_declarator_list COMMA IDENTIFIER EQUAL initializer
						var declarator = new Declarator(t(3).data, e(5), null);
						cast(n(1), VariableDeclaration).declarators.push(declarator);
						parseContext.variableDeclaration(declarator);
						return s(1);
			case 121: return new VariableDeclaration(untyped n(1), []); //single_declaration ::= fully_specified_type
			case 122: //single_declaration ::= fully_specified_type IDENTIFIER
						var declarator = new Declarator(t(2).data, null, null);
						parseContext.variableDeclaration(declarator);
						return new VariableDeclaration(untyped n(1), [declarator]);
			case 123: //single_declaration ::= fully_specified_type IDENTIFIER LEFT_BRACKET constant_expression RIGHT_BRACKET
						var declarator = new Declarator(t(2).data, null, e(4));
						parseContext.variableDeclaration(declarator);
						return new VariableDeclaration(untyped n(1), [declarator]);
			case 124: //single_declaration ::= fully_specified_type IDENTIFIER EQUAL initializer
						var declarator = new Declarator(t(2).data, e(4), null);
						parseContext.variableDeclaration(declarator);
						return new VariableDeclaration(untyped n(1), [declarator]);
			case 125: //single_declaration ::= INVARIANT IDENTIFIER
						var declarator = new Declarator(t(2).data, null, null);
						parseContext.variableDeclaration(declarator);
						return new VariableDeclaration(new TypeSpecifier(null, null, null, true), [declarator]);
			case 126: return s(1); //fully_specified_type ::= type_specifier
			case 127: var ts = cast(n(2), TypeSpecifier); //fully_specified_type ::= type_qualifier type_specifier
						if(ev(1).equals(Instructions.SET_INVARIANT_VARYING)){
							ts.storage = StorageQualifier.VARYING;
							ts.invariant = true;
						}else{
							ts.storage = untyped ev(1);
						}
						return s(2);
			case 128: return StorageQualifier.CONST; //type_qualifier ::= CONST
			case 129: return StorageQualifier.ATTRIBUTE; //type_qualifier ::= ATTRIBUTE
			case 130: return StorageQualifier.VARYING; //type_qualifier ::= VARYING
			case 131: return Instructions.SET_INVARIANT_VARYING; //type_qualifier ::= INVARIANT VARYING
			case 132: return StorageQualifier.UNIFORM; //type_qualifier ::= UNIFORM
			case 133: return s(1); //type_specifier ::= type_specifier_no_prec
			case 134: var ts = cast(n(2), TypeSpecifier); ts.precision = untyped ev(1); return ts; //type_specifier ::= precision_qualifier type_specifier_no_prec
			case 135: return new TypeSpecifier(DataType.VOID); //type_specifier_no_prec ::= VOID
			case 136: return new TypeSpecifier(DataType.FLOAT); //type_specifier_no_prec ::= FLOAT
			case 137: return new TypeSpecifier(DataType.INT); //type_specifier_no_prec ::= INT
			case 138: return new TypeSpecifier(DataType.BOOL); //type_specifier_no_prec ::= BOOL
			case 139: return new TypeSpecifier(DataType.VEC2); //type_specifier_no_prec ::= VEC2
			case 140: return new TypeSpecifier(DataType.VEC3); //type_specifier_no_prec ::= VEC3
			case 141: return new TypeSpecifier(DataType.VEC4); //type_specifier_no_prec ::= VEC4
			case 142: return new TypeSpecifier(DataType.BVEC2); //type_specifier_no_prec ::= BVEC2
			case 143: return new TypeSpecifier(DataType.BVEC3); //type_specifier_no_prec ::= BVEC3
			case 144: return new TypeSpecifier(DataType.BVEC4); //type_specifier_no_prec ::= BVEC4
			case 145: return new TypeSpecifier(DataType.IVEC2); //type_specifier_no_prec ::= IVEC2
			case 146: return new TypeSpecifier(DataType.IVEC3); //type_specifier_no_prec ::= IVEC3
			case 147: return new TypeSpecifier(DataType.IVEC4); //type_specifier_no_prec ::= IVEC4
			case 148: return new TypeSpecifier(DataType.MAT2); //type_specifier_no_prec ::= MAT2
			case 149: return new TypeSpecifier(DataType.MAT3); //type_specifier_no_prec ::= MAT3
			case 150: return new TypeSpecifier(DataType.MAT4); //type_specifier_no_prec ::= MAT4
			case 151: return new TypeSpecifier(DataType.SAMPLER2D); //type_specifier_no_prec ::= SAMPLER2D
			case 152: return new TypeSpecifier(DataType.SAMPLERCUBE); //type_specifier_no_prec ::= SAMPLERCUBE
			case 153: return s(1); //type_specifier_no_prec ::= struct_specifier
			case 154: return new TypeSpecifier(DataType.USER_TYPE(t(1).data)); //type_specifier_no_prec ::= TYPE_NAME
			case 155: return PrecisionQualifier.HIGH_PRECISION; //precision_qualifier ::= HIGH_PRECISION
			case 156: return PrecisionQualifier.MEDIUM_PRECISION; //precision_qualifier ::= MEDIUM_PRECISION
			case 157: return PrecisionQualifier.LOW_PRECISION; //precision_qualifier ::= LOW_PRECISION
			case 158: //struct_specifier ::= STRUCT IDENTIFIER LEFT_BRACE struct_declaration_list RIGHT_BRACE
						var ss = new StructSpecifier(t(2).data, untyped a(4));
						parseContext.typeDefinition(ss);
						return ss;
			case 159: //struct_specifier ::= STRUCT LEFT_BRACE struct_declaration_list RIGHT_BRACE
						var ss = new StructSpecifier(null, untyped a(3));
						return ss;
			case 160: return [n(1)]; //struct_declaration_list ::= struct_declaration
			case 161: a(1).push(n(2)); return s(1); //struct_declaration_list ::= struct_declaration_list struct_declaration
			case 162: return new StructFieldDeclaration(untyped n(1), untyped a(2)); //struct_declaration ::= type_specifier struct_declarator_list SEMICOLON
			case 163: return [n(1)]; //struct_declarator_list ::= struct_declarator
			case 164: a(1).push(n(3)); return s(1); //struct_declarator_list ::= struct_declarator_list COMMA struct_declarator
			case 165: return new StructDeclarator(t(1).data); //struct_declarator ::= IDENTIFIER
			case 166: return new StructDeclarator(t(1).data, e(3)); //struct_declarator ::= IDENTIFIER LEFT_BRACKET constant_expression RIGHT_BRACKET
			case 167: return s(1); //initializer ::= assignment_expression


			/* Statements */
			case 168: return new DeclarationStatement(untyped n(1)); //declaration_statement ::= declaration
			case 169: return s(1); //statement ::= compound_statement_with_scope
			case 170: return s(1); //statement ::= simple_statement
			case 171: return s(1); //statement_no_new_scope ::= compound_statement_no_new_scope
			case 172: return s(1); //statement_no_new_scope ::= simple_statement
			case 173: return s(2); //statement_with_scope ::= scope_push compound_statement_no_new_scope scope_pop
			case 174: return s(2); //statement_with_scope ::= scope_push simple_statement scope_pop
			case 175: return s(1); //simple_statement ::= declaration_statement
			case 176: return s(1); //simple_statement ::= expression_statement
			case 177: return s(1); //simple_statement ::= selection_statement
			case 178: return s(1); //simple_statement ::= iteration_statement
			case 179: return s(1); //simple_statement ::= jump_statement
			case 180: return s(1); //simple_statement ::= preprocessor_directive
			case 181: return new CompoundStatement([]); //compound_statement_with_scope ::= LEFT_BRACE RIGHT_BRACE
			case 182: return new CompoundStatement(untyped a(3)); //compound_statement_with_scope ::= LEFT_BRACE scope_push statement_list scope_pop RIGHT_BRACE
			case 183: return new CompoundStatement([]); //compound_statement_no_new_scope ::= LEFT_BRACE RIGHT_BRACE
			case 184: return new CompoundStatement(untyped a(2)); //compound_statement_no_new_scope ::= LEFT_BRACE statement_list RIGHT_BRACE
			case 185: return [n(1)]; //statement_list ::= statement
			case 186: a(1).push(n(2)); return s(1); //statement_list ::= statement_list statement
			case 187: return new ExpressionStatement(null); //expression_statement ::= SEMICOLON
			case 188: return new ExpressionStatement(e(1)); //expression_statement ::= expression SEMICOLON
			case 189: return new IfStatement(e(3), a(5)[0], a(5)[1]); //selection_statement ::= IF LEFT_PAREN expression RIGHT_PAREN selection_rest_statement
			case 190: return [n(1), n(3)]; //selection_rest_statement ::= statement_with_scope ELSE statement_with_scope
			case 191: return [n(1), null]; //selection_rest_statement ::= statement_with_scope
			case 192: return s(1); //condition ::= expression
			case 193: //condition ::= fully_specified_type IDENTIFIER EQUAL initializer
						var declarator = new Declarator(t(2).data, e(4), null);
						parseContext.variableDeclaration(declarator);
						return new VariableDeclaration(untyped n(1), [declarator]);
			case 194: return new WhileStatement(e(4), untyped n(6)); //iteration_statement ::= WHILE LEFT_PAREN scope_push condition RIGHT_PAREN statement_no_new_scope scope_pop
			case 195: return new DoWhileStatement(e(5), untyped n(2)); //iteration_statement ::= DO statement_with_scope WHILE LEFT_PAREN expression RIGHT_PAREN SEMICOLON
			case 196: return new ForStatement(untyped n(4), a(5)[0], a(5)[1], untyped n(7)); //iteration_statement ::= FOR LEFT_PAREN scope_push for_init_statement for_rest_statement RIGHT_PAREN statement_no_new_scope scope_pop
			case 197: return s(1); //for_init_statement ::= expression_statement
			case 198: return s(1); //for_init_statement ::= declaration_statement
			case 199: return s(1); //conditionopt ::= condition
			case 200: return null; //conditionopt ::=
			case 201: return [e(1), null]; //for_rest_statement ::= conditionopt SEMICOLON
			case 202: return [e(1), e(3)]; //for_rest_statement ::= conditionopt SEMICOLON expression
			case 203: return new JumpStatement(JumpMode.CONTINUE); //jump_statement ::= CONTINUE SEMICOLON
			case 204: return new JumpStatement(JumpMode.BREAK); //jump_statement ::= BREAK SEMICOLON
			case 205: return new ReturnStatement(null); //jump_statement ::= RETURN SEMICOLON
			case 206: return new ReturnStatement(untyped n(2)); //jump_statement ::= RETURN expression SEMICOLON
			case 207: return new JumpStatement(JumpMode.DISCARD); //jump_statement ::= DISCARD SEMICOLON
			case 208: return [n(1)]; //translation_unit ::= external_declaration
			case 209: a(1).push(untyped n(2)); return s(1); //translation_unit ::= translation_unit external_declaration
			case 210: cast(n(1), Declaration).external = true; return s(1); //external_declaration ::= function_definition
			case 211: cast(n(1), Declaration).external = true; return s(1); //external_declaration ::= declaration
			case 212: cast(n(1), Declaration).external = true; return s(1); //external_declaration ::= preprocessor_directive
			case 213: return new FunctionDefinition(untyped n(1), untyped n(3)); //function_definition ::= function_prototype scope_push compound_statement_no_new_scope scope_pop
						//@! parameters need to be added to parseContext
			case 214: return new PreprocessorDirective(t(1).data); //preprocessor_directive ::= PREPROCESSOR_DIRECTIVE
			case 215: parseContext.scopePush(); return null; //scope_push ::=
			case 216: parseContext.scopePop(); return null; //scope_pop ::=
		}
		
		Parser.warn('unhandled reduce rule number $ruleno');
		return null;
	}

	//Access rule symbols from left to right
	//s(1) gives the left most symbol
	static function s(n:Int){
		if(n <= 0) return null;
		//nrhs is the number of symbols in rule
		var j = Parser.ruleInfo[ruleno].nrhs - n;
		return stack[i - j].minor;
	}

	//Convenience functions for casting minor
	static inline function n(m:Int):Node 
		return untyped s(m);
	static inline function t(m:Int):Token
		return untyped s(m);
	static inline function e(m:Int):Expression
		return untyped s(m);
	static inline function ev(m:Int):EnumValue
		return s(m) != null ? untyped s(m) : null;
	static inline function a(m):Array<Dynamic>
		return untyped s(m);

	static inline function get_i() return Parser.i;
	static inline function get_stack() return Parser.stack;	
}

enum Instructions{
	SET_INVARIANT_VARYING;
}