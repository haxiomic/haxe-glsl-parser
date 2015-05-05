/*
	TreeBuilder is responsible for constructing the abstract syntax tree by creation
	and concatenation of notes in accordance with the grammar rules of the language
	
	GLES-100_PP_scope

	@author George Corney
*/

package glsl.parse;

import glsl.token.Tokenizer.Token;
import glsl.token.Tokenizer.TokenType;
import glsl.SyntaxTree;

using glsl.SyntaxTree.NodeEnumHelper;
using glsl.token.TokenHelper;


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
			//ensure the previous token isn't a TYPE_NAME (ie to cases like S S = S();)
			//@! need to check we're not in a declarator list
			//@! better check last token isn't STRUCT either (although this isn't critical)
			if(!((lastToken != null) && lastToken.type.isTypeReferenceType())){
				trace('on line ${t.line} : ${t.column}');
				switch parseContext.searchScope(t.data) {
					case ParseContext.Object.USER_TYPE(_):
						trace('type change for ${t.data}, line ${t.line} : ${t.column}');
						t.type = TokenType.TYPE_NAME;
					case null, _:
				}
			}
		}

		lastToken = t;
		return t;
	}

	static public function buildRule(ruleno:Int):MinorType{
		TreeBuilder.ruleno = ruleno; //set class ruleno so it can be accessed by other functions

		switch(ruleno){
			case 0: 
				/* root ::= translation_unit */
				return new Root(untyped a(1));
			case 1: 
				/* variable_identifier ::= IDENTIFIER */
				return new Identifier(t(1).data);
			case 2, 7, 9, 13, 14, 15, 16, 17, 18, 21, 40, 48, 52, 55, 58, 63, 66, 68, 70, 72, 74, 76, 78, 80, 93, 95, 99, 100, 101, 117, 126, 133, 153, 167, 169, 171, 172, 173, 174, 175, 176, 177, 178, 179, 180, 194, 199, 200, 201: 
				/* primary_expression ::= variable_identifier */
				/* postfix_expression ::= primary_expression */
				/* postfix_expression ::= function_call */
				/* integer_expression ::= expression */
				/* function_call ::= function_call_generic */
				/* function_call_generic ::= function_call_header_with_parameters RIGHT_PAREN */
				/* function_call_generic ::= function_call_header_no_parameters RIGHT_PAREN */
				/* function_call_header_no_parameters ::= function_call_header VOID */
				/* function_call_header_no_parameters ::= function_call_header */
				/* function_call_header ::= function_identifier LEFT_PAREN */
				/* unary_expression ::= postfix_expression */
				/* multiplicative_expression ::= unary_expression */
				/* additive_expression ::= multiplicative_expression */
				/* shift_expression ::= additive_expression */
				/* relational_expression ::= shift_expression */
				/* equality_expression ::= relational_expression */
				/* and_expression ::= equality_expression */
				/* exclusive_or_expression ::= and_expression */
				/* inclusive_or_expression ::= exclusive_or_expression */
				/* logical_and_expression ::= inclusive_or_expression */
				/* logical_xor_expression ::= logical_and_expression */
				/* logical_or_expression ::= logical_xor_expression */
				/* conditional_expression ::= logical_or_expression */
				/* assignment_expression ::= conditional_expression */
				/* expression ::= assignment_expression */
				/* constant_expression ::= conditional_expression */
				/* function_prototype ::= function_declarator RIGHT_PAREN */
				/* function_declarator ::= function_header */
				/* function_declarator ::= function_header_with_parameters */
				/* init_declarator_list ::= single_declaration */
				/* fully_specified_type ::= type_specifier */
				/* type_specifier ::= type_specifier_no_prec */
				/* type_specifier_no_prec ::= struct_specifier */
				/* initializer ::= assignment_expression */
				/* statement_with_scope ::= compound_statement_with_scope */
				/* statement_pop_scope ::= compound_statement_pop_scope */
				/* statement_pop_scope ::= simple_statement scope_pop */
				/* statement_no_new_scope ::= compound_statement_no_new_scope */
				/* statement_no_new_scope ::= simple_statement */
				/* simple_statement ::= declaration_statement */
				/* simple_statement ::= expression_statement */
				/* simple_statement ::= selection_statement */
				/* simple_statement ::= iteration_statement */
				/* simple_statement ::= jump_statement */
				/* simple_statement ::= preprocessor_directive */
				/* condition ::= expression */
				/* for_init_statement ::= expression_statement */
				/* for_init_statement ::= declaration_statement */
				/* conditionopt ::= condition */
				return s(1);
			case 3: 
				/* primary_expression ::= INTCONSTANT */
				var l = new Primitive<Int>(Std.parseInt(t(1).data), DataType.INT); 
				l.raw = t(1).data;
				return l;
			case 4: 
				/* primary_expression ::= FLOATCONSTANT */
				var l = new Primitive<Float>(Std.parseFloat(t(1).data), DataType.FLOAT);
				l.raw = t(1).data;
				return l;
			case 5: 
				/* primary_expression ::= BOOLCONSTANT */
				var l = new Primitive<Bool>(t(1).data == 'true', DataType.BOOL);
				l.raw = t(1).data;
				return l;
			case 6: 
				/* primary_expression ::= LEFT_PAREN expression RIGHT_PAREN */
				e(2).enclosed = true;
				return s(2);
			case 8: 
				/* postfix_expression ::= postfix_expression LEFT_BRACKET integer_expression RIGHT_BRACKET */
				return new ArrayElementSelectionExpression(e(1), e(3));
			case 10: 
				/* postfix_expression ::= postfix_expression DOT FIELD_SELECTION */
				return new FieldSelectionExpression(e(1), new Identifier(t(3).data));
			case 11: 
				/* postfix_expression ::= postfix_expression INC_OP */
				return new UnaryExpression(UnaryOperator.INC_OP, e(1), false);
			case 12: 
				/* postfix_expression ::= postfix_expression DEC_OP */
				return new  UnaryExpression(UnaryOperator.DEC_OP, e(1), false);
			case 19: 
				/* function_call_header_with_parameters ::= function_call_header assignment_expression */
				cast(n(1), ExpressionParameters).parameters.push(untyped n(2));
				return s(1);
			case 20: 
				/* function_call_header_with_parameters ::= function_call_header_with_parameters COMMA assignment_expression */
				cast(n(1), ExpressionParameters).parameters.push(untyped n(3));
				return s(1);
			case 22: 
				/* function_identifier ::= constructor_identifier */
				return new Constructor(untyped ev(1));
			case 23: 
				/* function_identifier ::= IDENTIFIER */
				return new FunctionCall(t(1).data);
			case 24: 
				/* constructor_identifier ::= FLOAT */
				return DataType.FLOAT;
			case 25: 
				/* constructor_identifier ::= INT */
				return DataType.INT;
			case 26: 
				/* constructor_identifier ::= BOOL */
				return DataType.BOOL;
			case 27: 
				/* constructor_identifier ::= VEC2 */
				return DataType.VEC2;
			case 28: 
				/* constructor_identifier ::= VEC3 */
				return DataType.VEC3;
			case 29: 
				/* constructor_identifier ::= VEC4 */
				return DataType.VEC4;
			case 30: 
				/* constructor_identifier ::= BVEC2 */
				return DataType.BVEC2;
			case 31: 
				/* constructor_identifier ::= BVEC3 */
				return DataType.BVEC3;
			case 32: 
				/* constructor_identifier ::= BVEC4 */
				return DataType.BVEC4;
			case 33: 
				/* constructor_identifier ::= IVEC2 */
				return DataType.IVEC2;
			case 34: 
				/* constructor_identifier ::= IVEC3 */
				return DataType.IVEC3;
			case 35: 
				/* constructor_identifier ::= IVEC4 */
				return DataType.IVEC4;
			case 36: 
				/* constructor_identifier ::= MAT2 */
				return DataType.MAT2;
			case 37: 
				/* constructor_identifier ::= MAT3 */
				return DataType.MAT3;
			case 38: 
				/* constructor_identifier ::= MAT4 */
				return DataType.MAT4;
			case 39: 
				/* constructor_identifier ::= TYPE_NAME */
				return DataType.USER_TYPE(t(1).data);
			case 41: 
				/* unary_expression ::= INC_OP unary_expression */
				return new UnaryExpression(UnaryOperator.INC_OP, e(2), true);
			case 42: 
				/* unary_expression ::= DEC_OP unary_expression */
				return new UnaryExpression(UnaryOperator.DEC_OP, e(2), true);
			case 43: 
				/* unary_expression ::= unary_operator unary_expression */
				return new UnaryExpression(untyped ev(1), e(2), true);
			case 44: 
				/* unary_operator ::= PLUS */
				return UnaryOperator.PLUS;
			case 45: 
				/* unary_operator ::= DASH */
				return UnaryOperator.DASH;
			case 46: 
				/* unary_operator ::= BANG */
				return UnaryOperator.BANG;
			case 47: 
				/* unary_operator ::= TILDE */
				return UnaryOperator.TILDE;
			case 49: 
				/* multiplicative_expression ::= multiplicative_expression STAR unary_expression */
				return new BinaryExpression(BinaryOperator.STAR, e(1), e(3));
			case 50: 
				/* multiplicative_expression ::= multiplicative_expression SLASH unary_expression */
				return new BinaryExpression(BinaryOperator.SLASH, e(1), e(3));
			case 51: 
				/* multiplicative_expression ::= multiplicative_expression PERCENT unary_expression */
				return new BinaryExpression(BinaryOperator.PERCENT, e(1), e(3));
			case 53: 
				/* additive_expression ::= additive_expression PLUS multiplicative_expression */
				return new BinaryExpression(BinaryOperator.PLUS, e(1), e(3));
			case 54: 
				/* additive_expression ::= additive_expression DASH multiplicative_expression */
				return new BinaryExpression(BinaryOperator.DASH, e(1), e(3));
			case 56: 
				/* shift_expression ::= shift_expression LEFT_OP additive_expression */
				return new BinaryExpression(BinaryOperator.LEFT_OP, untyped n(1), untyped n(3));
			case 57: 
				/* shift_expression ::= shift_expression RIGHT_OP additive_expression */
				return new BinaryExpression(BinaryOperator.RIGHT_OP, untyped n(1), untyped n(3));
			case 59: 
				/* relational_expression ::= relational_expression LEFT_ANGLE shift_expression */
				return new BinaryExpression(BinaryOperator.LEFT_ANGLE, untyped n(1), untyped n(3));
			case 60: 
				/* relational_expression ::= relational_expression RIGHT_ANGLE shift_expression */
				return new BinaryExpression(BinaryOperator.RIGHT_ANGLE, untyped n(1), untyped n(3));
			case 61: 
				/* relational_expression ::= relational_expression LE_OP shift_expression */
				return new BinaryExpression(BinaryOperator.LE_OP, untyped n(1), untyped n(3));
			case 62: 
				/* relational_expression ::= relational_expression GE_OP shift_expression */
				return new BinaryExpression(BinaryOperator.GE_OP, untyped n(1), untyped n(3));
			case 64: 
				/* equality_expression ::= equality_expression EQ_OP relational_expression */
				return new BinaryExpression(BinaryOperator.EQ_OP, untyped n(1), untyped n(3));
			case 65: 
				/* equality_expression ::= equality_expression NE_OP relational_expression */
				return new BinaryExpression(BinaryOperator.NE_OP, untyped n(1), untyped n(3));
			case 67: 
				/* and_expression ::= and_expression AMPERSAND equality_expression */
				return new BinaryExpression(BinaryOperator.AMPERSAND, untyped n(1), untyped n(3));
			case 69: 
				/* exclusive_or_expression ::= exclusive_or_expression CARET and_expression */
				return new BinaryExpression(BinaryOperator.CARET, untyped n(1), untyped n(3));
			case 71: 
				/* inclusive_or_expression ::= inclusive_or_expression VERTICAL_BAR exclusive_or_expression */
				return new BinaryExpression(BinaryOperator.VERTICAL_BAR, untyped n(1), untyped n(3));
			case 73: 
				/* logical_and_expression ::= logical_and_expression AND_OP inclusive_or_expression */
				return new BinaryExpression(BinaryOperator.AND_OP, untyped n(1), untyped n(3));
			case 75: 
				/* logical_xor_expression ::= logical_xor_expression XOR_OP logical_and_expression */
				return new BinaryExpression(BinaryOperator.XOR_OP, untyped n(1), untyped n(3));
			case 77: 
				/* logical_or_expression ::= logical_or_expression OR_OP logical_xor_expression */
				return new BinaryExpression(BinaryOperator.OR_OP, untyped n(1), untyped n(3));
			case 79: 
				/* conditional_expression ::= logical_or_expression QUESTION expression COLON assignment_expression */
				return new ConditionalExpression(untyped n(1), untyped n(3), untyped n(5));
			case 81: 
				/* assignment_expression ::= unary_expression assignment_operator assignment_expression */
				return new AssignmentExpression(untyped ev(2), untyped n(1), untyped n(3));
			case 82: 
				/* assignment_operator ::= EQUAL */
				return AssignmentOperator.EQUAL;
			case 83: 
				/* assignment_operator ::= MUL_ASSIGN */
				return AssignmentOperator.MUL_ASSIGN;
			case 84: 
				/* assignment_operator ::= DIV_ASSIGN */
				return AssignmentOperator.DIV_ASSIGN;
			case 85: 
				/* assignment_operator ::= MOD_ASSIGN */
				return AssignmentOperator.MOD_ASSIGN;
			case 86: 
				/* assignment_operator ::= ADD_ASSIGN */
				return AssignmentOperator.ADD_ASSIGN;
			case 87: 
				/* assignment_operator ::= SUB_ASSIGN */
				return AssignmentOperator.SUB_ASSIGN;
			case 88: 
				/* assignment_operator ::= LEFT_ASSIGN */
				return AssignmentOperator.LEFT_ASSIGN;
			case 89: 
				/* assignment_operator ::= RIGHT_ASSIGN */
				return AssignmentOperator.RIGHT_ASSIGN;
			case 90: 
				/* assignment_operator ::= AND_ASSIGN */
				return AssignmentOperator.AND_ASSIGN;
			case 91: 
				/* assignment_operator ::= XOR_ASSIGN */
				return AssignmentOperator.XOR_ASSIGN;
			case 92: 
				/* assignment_operator ::= OR_ASSIGN */
				return AssignmentOperator.OR_ASSIGN;
			case 94: 
				/* expression ::= expression COMMA assignment_expression */
				if(Std.is(e(1), SequenceExpression)){
				    cast(e(1), SequenceExpression).expressions.push(e(3));
				    return s(1);
				}else{
				    return new SequenceExpression([e(1), e(3)]);
				}
			case 96: 
				/* declaration ::= function_prototype SEMICOLON */
				return new FunctionPrototype(untyped s(1));
			case 97: 
				/* declaration ::= init_declarator_list SEMICOLON */
				handleVariableDeclaration(untyped s(1));
				return s(1); 
			case 98: 
				/* declaration ::= PRECISION precision_qualifier type_specifier_no_prec SEMICOLON */
				return new PrecisionDeclaration(untyped ev(2), cast(n(3), TypeSpecifier).dataType);
			case 102: 
				/* function_header_with_parameters ::= function_header parameter_declaration */
				var fh = cast(n(1), FunctionHeader);
				fh.parameters.push(untyped n(2));
				return fh;
			case 103: 
				/* function_header_with_parameters ::= function_header_with_parameters COMMA parameter_declaration */
				var fh = cast(n(1), FunctionHeader);
				fh.parameters.push(untyped n(3));
				return fh; 
			case 104: 
				/* function_header ::= fully_specified_type IDENTIFIER LEFT_PAREN */
				return new FunctionHeader(t(2).data, untyped n(1));
			case 105: 
				/* parameter_declarator ::= type_specifier IDENTIFIER */
				return new ParameterDeclaration(t(2).data, untyped n(1));
			case 106: 
				/* parameter_declarator ::= type_specifier IDENTIFIER LEFT_BRACKET constant_expression RIGHT_BRACKET */
				return new ParameterDeclaration(t(2).data, untyped n(1), null, e(4));
			case 107, 109: 
				/* parameter_declaration ::= type_qualifier parameter_qualifier parameter_declarator */
				/* parameter_declaration ::= type_qualifier parameter_qualifier parameter_type_specifier */
				var pd = cast(n(3), ParameterDeclaration);
				pd.parameterQualifier = untyped ev(2);
				
				if(ev(1).equals(Instructions.SET_INVARIANT_VARYING)){
				    //even though invariant varying isn't allowed, set anyway and catch in the validator
				    pd.typeSpecifier.storage = StorageQualifier.VARYING;
				    pd.typeSpecifier.invariant = true;
				}else{
				    pd.typeSpecifier.storage = untyped ev(1);
				}
				return pd;
			case 108: 
				/* parameter_declaration ::= parameter_qualifier parameter_declarator */
				var pd = cast(n(2), ParameterDeclaration);
				pd.parameterQualifier = untyped ev(1);
				return pd;
			case 110: 
				/* parameter_declaration ::= parameter_qualifier parameter_type_specifier */
				var pd = cast(n(2), ParameterDeclaration); //parameter_declaration ::= parameter_qualifier parameter_type_specifier
				pd.parameterQualifier = untyped ev(1);
				return pd;
			case 111, 202: 
				/* parameter_qualifier ::= */
				/* conditionopt ::= */
				return null;
			case 112: 
				/* parameter_qualifier ::= IN */
				return ParameterQualifier.IN;
			case 113: 
				/* parameter_qualifier ::= OUT */
				return ParameterQualifier.OUT;
			case 114: 
				/* parameter_qualifier ::= INOUT */
				return ParameterQualifier.INOUT;
			case 115: 
				/* parameter_type_specifier ::= type_specifier */
				return new ParameterDeclaration(null, untyped n(1));
			case 116: 
				/* parameter_type_specifier ::= type_specifier LEFT_BRACKET constant_expression RIGHT_BRACKET */
				return new ParameterDeclaration(null, untyped n(1), null, e(3));
			case 118: 
				/* init_declarator_list ::= init_declarator_list COMMA IDENTIFIER */
				var declarator = new Declarator(t(3).data, null, null);
				cast(n(1), VariableDeclaration).declarators.push(declarator);
				return s(1);
			case 119: 
				/* init_declarator_list ::= init_declarator_list COMMA IDENTIFIER LEFT_BRACKET constant_expression RIGHT_BRACKET */
				var declarator = new Declarator(t(3).data, null, e(5));
				cast(n(1), VariableDeclaration).declarators.push(declarator);
				return s(1);
			case 120: 
				/* init_declarator_list ::= init_declarator_list COMMA IDENTIFIER EQUAL initializer */
				var declarator = new Declarator(t(3).data, e(5), null);
				cast(n(1), VariableDeclaration).declarators.push(declarator);
				return s(1);
			case 121: 
				/* single_declaration ::= fully_specified_type */
				return new VariableDeclaration(untyped n(1), []);
			case 122: 
				/* single_declaration ::= fully_specified_type IDENTIFIER */
				var declarator = new Declarator(t(2).data, null, null);
				return new VariableDeclaration(untyped n(1), [declarator]);
			case 123: 
				/* single_declaration ::= fully_specified_type IDENTIFIER LEFT_BRACKET constant_expression RIGHT_BRACKET */
				var declarator = new Declarator(t(2).data, null, e(4));
				return new VariableDeclaration(untyped n(1), [declarator]);
			case 124: 
				/* single_declaration ::= fully_specified_type IDENTIFIER EQUAL initializer */
				var declarator = new Declarator(t(2).data, e(4), null);
				return new VariableDeclaration(untyped n(1), [declarator]);
			case 125: 
				/* single_declaration ::= INVARIANT IDENTIFIER */
				var declarator = new Declarator(t(2).data, null, null);
				return new VariableDeclaration(new TypeSpecifier(null, null, null, true), [declarator]);
			case 127: 
				/* fully_specified_type ::= type_qualifier type_specifier */
				var ts = cast(n(2), TypeSpecifier);
				if(ev(1).equals(Instructions.SET_INVARIANT_VARYING)){
				    ts.storage = StorageQualifier.VARYING;
				    ts.invariant = true;
				}else{
				    ts.storage = untyped ev(1);
				}
				return s(2);
			case 128: 
				/* type_qualifier ::= CONST */
				return StorageQualifier.CONST;
			case 129: 
				/* type_qualifier ::= ATTRIBUTE */
				return StorageQualifier.ATTRIBUTE;
			case 130: 
				/* type_qualifier ::= VARYING */
				return StorageQualifier.VARYING;
			case 131: 
				/* type_qualifier ::= INVARIANT VARYING */
				return Instructions.SET_INVARIANT_VARYING;
			case 132: 
				/* type_qualifier ::= UNIFORM */
				return StorageQualifier.UNIFORM;
			case 134: 
				/* type_specifier ::= precision_qualifier type_specifier_no_prec */
				var ts = cast(n(2), TypeSpecifier);
				ts.precision = untyped ev(1);
				return ts;
			case 135: 
				/* type_specifier_no_prec ::= VOID */
				return new TypeSpecifier(DataType.VOID);
			case 136: 
				/* type_specifier_no_prec ::= FLOAT */
				return new TypeSpecifier(DataType.FLOAT);
			case 137: 
				/* type_specifier_no_prec ::= INT */
				return new TypeSpecifier(DataType.INT);
			case 138: 
				/* type_specifier_no_prec ::= BOOL */
				return new TypeSpecifier(DataType.BOOL);
			case 139: 
				/* type_specifier_no_prec ::= VEC2 */
				return new TypeSpecifier(DataType.VEC2);
			case 140: 
				/* type_specifier_no_prec ::= VEC3 */
				return new TypeSpecifier(DataType.VEC3);
			case 141: 
				/* type_specifier_no_prec ::= VEC4 */
				return new TypeSpecifier(DataType.VEC4);
			case 142: 
				/* type_specifier_no_prec ::= BVEC2 */
				return new TypeSpecifier(DataType.BVEC2);
			case 143: 
				/* type_specifier_no_prec ::= BVEC3 */
				return new TypeSpecifier(DataType.BVEC3);
			case 144: 
				/* type_specifier_no_prec ::= BVEC4 */
				return new TypeSpecifier(DataType.BVEC4);
			case 145: 
				/* type_specifier_no_prec ::= IVEC2 */
				return new TypeSpecifier(DataType.IVEC2);
			case 146: 
				/* type_specifier_no_prec ::= IVEC3 */
				return new TypeSpecifier(DataType.IVEC3);
			case 147: 
				/* type_specifier_no_prec ::= IVEC4 */
				return new TypeSpecifier(DataType.IVEC4);
			case 148: 
				/* type_specifier_no_prec ::= MAT2 */
				return new TypeSpecifier(DataType.MAT2);
			case 149: 
				/* type_specifier_no_prec ::= MAT3 */
				return new TypeSpecifier(DataType.MAT3);
			case 150: 
				/* type_specifier_no_prec ::= MAT4 */
				return new TypeSpecifier(DataType.MAT4);
			case 151: 
				/* type_specifier_no_prec ::= SAMPLER2D */
				return new TypeSpecifier(DataType.SAMPLER2D);
			case 152: 
				/* type_specifier_no_prec ::= SAMPLERCUBE */
				return new TypeSpecifier(DataType.SAMPLERCUBE);
			case 154: 
				/* type_specifier_no_prec ::= TYPE_NAME */
				return new TypeSpecifier(DataType.USER_TYPE(t(1).data));
			case 155: 
				/* precision_qualifier ::= HIGH_PRECISION */
				return PrecisionQualifier.HIGH_PRECISION;
			case 156: 
				/* precision_qualifier ::= MEDIUM_PRECISION */
				return PrecisionQualifier.MEDIUM_PRECISION;
			case 157: 
				/* precision_qualifier ::= LOW_PRECISION */
				return PrecisionQualifier.LOW_PRECISION;
			case 158: 
				/* struct_specifier ::= STRUCT IDENTIFIER LEFT_BRACE struct_declaration_list RIGHT_BRACE */
				var ss = new StructSpecifier(t(2).data, untyped a(4));
				//parse context type definition's are handled at variable declaration
				return ss;
			case 159: 
				/* struct_specifier ::= STRUCT LEFT_BRACE struct_declaration_list RIGHT_BRACE */
				var ss = new StructSpecifier(null, untyped a(3));
				return ss;
			case 160, 163, 187, 210: 
				/* struct_declaration_list ::= struct_declaration */
				/* struct_declarator_list ::= struct_declarator */
				/* statement_list ::= statement_no_new_scope */
				/* translation_unit ::= external_declaration */
				return [n(1)];
			case 161: 
				/* struct_declaration_list ::= struct_declaration_list struct_declaration */
				a(1).push(n(2)); return s(1);
			case 162: 
				/* struct_declaration ::= type_specifier struct_declarator_list SEMICOLON */
				return new StructFieldDeclaration(untyped n(1), untyped a(2));
			case 164: 
				/* struct_declarator_list ::= struct_declarator_list COMMA struct_declarator */
				a(1).push(n(3)); return s(1);
			case 165: 
				/* struct_declarator ::= IDENTIFIER */
				return new StructDeclarator(t(1).data);
			case 166: 
				/* struct_declarator ::= IDENTIFIER LEFT_BRACKET constant_expression RIGHT_BRACKET */
				return new StructDeclarator(t(1).data, e(3));
			case 168: 
				/* declaration_statement ::= declaration */
				return new DeclarationStatement(untyped n(1));
			case 170: 
				/* statement_with_scope ::= scope_push simple_statement scope_pop */
				return s(2);
			case 181, 183, 185: 
				/* compound_statement_with_scope ::= LEFT_BRACE RIGHT_BRACE */
				/* compound_statement_pop_scope ::= LEFT_BRACE scope_pop RIGHT_BRACE */
				/* compound_statement_no_new_scope ::= LEFT_BRACE RIGHT_BRACE */
				return new CompoundStatement([]);
			case 182: 
				/* compound_statement_with_scope ::= LEFT_BRACE scope_push statement_list scope_pop RIGHT_BRACE */
				return new CompoundStatement(untyped a(3));
			case 184, 186: 
				/* compound_statement_pop_scope ::= LEFT_BRACE statement_list scope_pop RIGHT_BRACE */
				/* compound_statement_no_new_scope ::= LEFT_BRACE statement_list RIGHT_BRACE */
				return new CompoundStatement(untyped a(2));
			case 188: 
				/* statement_list ::= statement_list statement_no_new_scope */
				a(1).push(n(2)); 
				return s(1);
			case 189: 
				/* expression_statement ::= SEMICOLON */
				return new ExpressionStatement(null);
			case 190: 
				/* expression_statement ::= expression SEMICOLON */
				return new ExpressionStatement(e(1));
			case 191: 
				/* selection_statement ::= IF LEFT_PAREN expression RIGHT_PAREN selection_rest_statement */
				return new IfStatement(e(3), a(5)[0], a(5)[1]);
			case 192: 
				/* selection_rest_statement ::= statement_with_scope ELSE statement_with_scope */
				return [n(1), n(3)];
			case 193: 
				/* selection_rest_statement ::= statement_with_scope */
				return [n(1), null];
			case 195: 
				/* condition ::= fully_specified_type IDENTIFIER EQUAL initializer */
				var declarator = new Declarator(t(2).data, e(4), null);
				var declaration = new VariableDeclaration(untyped n(1), [declarator]);
				handleVariableDeclaration(declaration);
				return declaration;
			case 196: 
				/* iteration_statement ::= WHILE LEFT_PAREN scope_push condition RIGHT_PAREN statement_pop_scope */
				return new WhileStatement(e(4), untyped n(6));
			case 197: 
				/* iteration_statement ::= DO statement_with_scope WHILE LEFT_PAREN expression RIGHT_PAREN SEMICOLON */
				return new DoWhileStatement(e(5), untyped n(2));
			case 198: 
				/* iteration_statement ::= FOR LEFT_PAREN scope_push for_init_statement for_rest_statement RIGHT_PAREN statement_pop_scope */
				return new ForStatement(untyped n(4), a(5)[0], a(5)[1], untyped n(7));
			case 203: 
				/* for_rest_statement ::= conditionopt SEMICOLON */
				return [e(1), null];
			case 204: 
				/* for_rest_statement ::= conditionopt SEMICOLON expression */
				return [e(1), e(3)];
			case 205: 
				/* jump_statement ::= CONTINUE SEMICOLON */
				return new JumpStatement(JumpMode.CONTINUE);
			case 206: 
				/* jump_statement ::= BREAK SEMICOLON */
				return new JumpStatement(JumpMode.BREAK);
			case 207: 
				/* jump_statement ::= RETURN SEMICOLON */
				return new ReturnStatement(null);
			case 208: 
				/* jump_statement ::= RETURN expression SEMICOLON */
				return new ReturnStatement(untyped n(2));
			case 209: 
				/* jump_statement ::= DISCARD SEMICOLON */
				return new JumpStatement(JumpMode.DISCARD);
			case 211: 
				/* translation_unit ::= translation_unit external_declaration */
				a(1).push(untyped n(2));
				return s(1);
			case 212, 213, 214: 
				/* external_declaration ::= function_definition */
				/* external_declaration ::= declaration */
				/* external_declaration ::= preprocessor_directive */
				cast(n(1), Declaration).external = true;
				return s(1);
			case 215: 
				/* function_definition ::= function_prototype scope_push compound_statement_pop_scope */
				return new FunctionDefinition(untyped n(1), untyped n(3));
			case 216: 
				/* preprocessor_directive ::= PREPROCESSOR_DIRECTIVE */
				return new PreprocessorDirective(t(1).data);
			case 217: 
				/* scope_push ::= */
				parseContext.scopePush();
				return null;
			case 218: 
				/* scope_pop ::= */
				parseContext.scopePop();
				return null; 
		}

		Parser.warn('unhandled reduce rule number $ruleno');
		return null;
		
	}

	static function handleVariableDeclaration(declaration:VariableDeclaration){
		//declare type user type
		switch declaration.typeSpecifier.toEnum() {
			case StructSpecifierNode(n):
				parseContext.declareType(n);
			case null, _:
		}

		//variable declarations
		for(d in declaration.declarators){
			parseContext.declareVariable(d);
		}
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