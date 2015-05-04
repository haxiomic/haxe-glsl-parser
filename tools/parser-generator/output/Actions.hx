/*
	TreeBuilder is responsible for constructing the abstract syntax tree by creation
	and concatenation of notes in accordance with the grammar rules of the language
	
	Using ruleset GLSL_ES_100_PP_scope v2: GLES 1.00 modified to accept preprocessor tokens as translation_units and statements

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
				return new Root(untyped a(1));
			case 1: 
				return new Identifier(t(1).data);
			case 2, 7, 9, 13, 14, 15, 16, 17, 18, 21, 40, 48, 52, 55, 58, 63, 66, 68, 70, 72, 74, 76, 78, 80, 93, 95, 99, 100, 101, 117, 126, 133, 153, 167, 170, 171, 172, 175, 176, 177, 178, 179, 180, 190, 195, 196, 197: 
				return s(1);
			case 3: 
				
				        var l = new Primitive<Int>(Std.parseInt(t(1).data), DataType.INT); 
				        l.raw = t(1).data;
				        return l;
				    
			case 4: 
				
				        var l = new Primitive<Float>(Std.parseFloat(t(1).data), DataType.FLOAT);
				        l.raw = t(1).data;
				        return l;
				    
			case 5: 
				
				        var l = new Primitive<Bool>(t(1).data == 'true', DataType.BOOL);
				        l.raw = t(1).data;
				        return l;
				    
			case 6: 
				
				        e(2).enclosed = true;
				        return s(2);
				    
			case 8: 
				return new ArrayElementSelectionExpression(e(1), e(3));
			case 10: 
				return new FieldSelectionExpression(e(1), new Identifier(t(3).data));
			case 11: 
				return new UnaryExpression(UnaryOperator.INC_OP, e(1), false);
			case 12: 
				return new  UnaryExpression(UnaryOperator.DEC_OP, e(1), false);
			case 19: 
				
				        cast(n(1), ExpressionParameters).parameters.push(untyped n(2));
				        return s(1);
				    
			case 20: 
				
				        cast(n(1), ExpressionParameters).parameters.push(untyped n(3));
				        return s(1);
				    
			case 22: 
				return new Constructor(untyped ev(1));
			case 23: 
				return new FunctionCall(t(1).data);
			case 24: 
				return DataType.FLOAT;
			case 25: 
				return DataType.INT;
			case 26: 
				return DataType.BOOL;
			case 27: 
				return DataType.VEC2;
			case 28: 
				return DataType.VEC3;
			case 29: 
				return DataType.VEC4;
			case 30: 
				return DataType.BVEC2;
			case 31: 
				return DataType.BVEC3;
			case 32: 
				return DataType.BVEC4;
			case 33: 
				return DataType.IVEC2;
			case 34: 
				return DataType.IVEC3;
			case 35: 
				return DataType.IVEC4;
			case 36: 
				return DataType.MAT2;
			case 37: 
				return DataType.MAT3;
			case 38: 
				return DataType.MAT4;
			case 39: 
				return DataType.USER_TYPE(t(1).data);
			case 41: 
				return new UnaryExpression(UnaryOperator.INC_OP, e(2), true);
			case 42: 
				return new UnaryExpression(UnaryOperator.DEC_OP, e(2), true);
			case 43: 
				return new UnaryExpression(untyped ev(1), e(2), true);
			case 44: 
				return UnaryOperator.PLUS;
			case 45: 
				return UnaryOperator.DASH;
			case 46: 
				return UnaryOperator.BANG;
			case 47: 
				return UnaryOperator.TILDE;
			case 49: 
				return new BinaryExpression(BinaryOperator.STAR, e(1), e(3));
			case 50: 
				return new BinaryExpression(BinaryOperator.SLASH, e(1), e(3));
			case 51: 
				return new BinaryExpression(BinaryOperator.PERCENT, e(1), e(3));
			case 53: 
				return new BinaryExpression(BinaryOperator.PLUS, e(1), e(3));
			case 54: 
				return new BinaryExpression(BinaryOperator.DASH, e(1), e(3));
			case 56: 
				return new BinaryExpression(BinaryOperator.LEFT_OP, untyped n(1), untyped n(3));
			case 57: 
				return new BinaryExpression(BinaryOperator.RIGHT_OP, untyped n(1), untyped n(3));
			case 59: 
				return new BinaryExpression(BinaryOperator.LEFT_ANGLE, untyped n(1), untyped n(3));
			case 60: 
				return new BinaryExpression(BinaryOperator.RIGHT_ANGLE, untyped n(1), untyped n(3));
			case 61: 
				return new BinaryExpression(BinaryOperator.LE_OP, untyped n(1), untyped n(3));
			case 62: 
				return new BinaryExpression(BinaryOperator.GE_OP, untyped n(1), untyped n(3));
			case 64: 
				return new BinaryExpression(BinaryOperator.EQ_OP, untyped n(1), untyped n(3));
			case 65: 
				return new BinaryExpression(BinaryOperator.NE_OP, untyped n(1), untyped n(3));
			case 67: 
				return new BinaryExpression(BinaryOperator.AMPERSAND, untyped n(1), untyped n(3));
			case 69: 
				return new BinaryExpression(BinaryOperator.CARET, untyped n(1), untyped n(3));
			case 71: 
				return new BinaryExpression(BinaryOperator.VERTICAL_BAR, untyped n(1), untyped n(3));
			case 73: 
				return new BinaryExpression(BinaryOperator.AND_OP, untyped n(1), untyped n(3));
			case 75: 
				return new BinaryExpression(BinaryOperator.XOR_OP, untyped n(1), untyped n(3));
			case 77: 
				return new BinaryExpression(BinaryOperator.OR_OP, untyped n(1), untyped n(3));
			case 79: 
				return new ConditionalExpression(untyped n(1), untyped n(3), untyped n(5));
			case 81: 
				return new AssignmentExpression(untyped ev(2), untyped n(1), untyped n(3));
			case 82: 
				return AssignmentOperator.EQUAL;
			case 83: 
				return AssignmentOperator.MUL_ASSIGN;
			case 84: 
				return AssignmentOperator.DIV_ASSIGN;
			case 85: 
				return AssignmentOperator.MOD_ASSIGN;
			case 86: 
				return AssignmentOperator.ADD_ASSIGN;
			case 87: 
				return AssignmentOperator.SUB_ASSIGN;
			case 88: 
				return AssignmentOperator.LEFT_ASSIGN;
			case 89: 
				return AssignmentOperator.RIGHT_ASSIGN;
			case 90: 
				return AssignmentOperator.AND_ASSIGN;
			case 91: 
				return AssignmentOperator.XOR_ASSIGN;
			case 92: 
				return AssignmentOperator.OR_ASSIGN;
			case 94: 
				
				        if(Std.is(e(1), SequenceExpression)){
				            cast(e(1), SequenceExpression).expressions.push(e(3));
				            return s(1);
				        }else{
				            return new SequenceExpression([e(1), e(3)]);
				        }
				    
			case 96: 
				return new FunctionPrototype(untyped s(1));
			case 97: 
				
				        handleVariableDeclaration(untyped s(1));
				        return s(1); 
				    
			case 98: 
				return new PrecisionDeclaration(untyped ev(2), cast(n(3), TypeSpecifier).dataType);
			case 102: 
				
				        var fh = cast(n(1), FunctionHeader);
				        fh.parameters.push(untyped n(2));
				        return fh;
				    
			case 103: 
				
				        var fh = cast(n(1), FunctionHeader);
				        fh.parameters.push(untyped n(3));
				        return fh; 
				    
			case 104: 
				return new FunctionHeader(t(2).data, untyped n(1));
			case 105: 
				return new ParameterDeclaration(t(2).data, untyped n(1));
			case 106: 
				return new ParameterDeclaration(t(2).data, untyped n(1), null, e(4));
			case 107, 109: 
				
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
				
				        var pd = cast(n(2), ParameterDeclaration);
				        pd.parameterQualifier = untyped ev(1);
				        return pd;
				    
			case 110: 
				
				        var pd = cast(n(2), ParameterDeclaration); //parameter_declaration ::= parameter_qualifier parameter_type_specifier
				        pd.parameterQualifier = untyped ev(1);
				        return pd;
				    
			case 111, 198: 
				return null;
			case 112: 
				return ParameterQualifier.IN;
			case 113: 
				return ParameterQualifier.OUT;
			case 114: 
				return ParameterQualifier.INOUT;
			case 115: 
				return new ParameterDeclaration(null, untyped n(1));
			case 116: 
				return new ParameterDeclaration(null, untyped n(1), null, e(3));
			case 118: 
				
				        var declarator = new Declarator(t(3).data, null, null);
				        cast(n(1), VariableDeclaration).declarators.push(declarator);
				        return s(1);
				    
			case 119: 
				
				        var declarator = new Declarator(t(3).data, null, e(5));
				        cast(n(1), VariableDeclaration).declarators.push(declarator);
				        return s(1);
				    
			case 120: 
				
				        var declarator = new Declarator(t(3).data, e(5), null);
				        cast(n(1), VariableDeclaration).declarators.push(declarator);
				        return s(1);
				    
			case 121: 
				return new VariableDeclaration(untyped n(1), []);
			case 122: 
				
				        var declarator = new Declarator(t(2).data, null, null);
				        return new VariableDeclaration(untyped n(1), [declarator]);
				    
			case 123: 
				
				        var declarator = new Declarator(t(2).data, null, e(4));
				        return new VariableDeclaration(untyped n(1), [declarator]);
				    
			case 124: 
				
				        var declarator = new Declarator(t(2).data, e(4), null);
				        return new VariableDeclaration(untyped n(1), [declarator]);
				    
			case 125: 
				
				        var declarator = new Declarator(t(2).data, null, null);
				        return new VariableDeclaration(new TypeSpecifier(null, null, null, true), [declarator]);
				    
			case 127: 
				
				        var ts = cast(n(2), TypeSpecifier);
				        if(ev(1).equals(Instructions.SET_INVARIANT_VARYING)){
				            ts.storage = StorageQualifier.VARYING;
				            ts.invariant = true;
				        }else{
				            ts.storage = untyped ev(1);
				        }
				        return s(2);
				    
			case 128: 
				return StorageQualifier.CONST;
			case 129: 
				return StorageQualifier.ATTRIBUTE;
			case 130: 
				return StorageQualifier.VARYING;
			case 131: 
				return Instructions.SET_INVARIANT_VARYING;
			case 132: 
				return StorageQualifier.UNIFORM;
			case 134: 
				
				        var ts = cast(n(2), TypeSpecifier);
				        ts.precision = untyped ev(1);
				        return ts;
				    
			case 135: 
				return new TypeSpecifier(DataType.VOID);
			case 136: 
				return new TypeSpecifier(DataType.FLOAT);
			case 137: 
				return new TypeSpecifier(DataType.INT);
			case 138: 
				return new TypeSpecifier(DataType.BOOL);
			case 139: 
				return new TypeSpecifier(DataType.VEC2);
			case 140: 
				return new TypeSpecifier(DataType.VEC3);
			case 141: 
				return new TypeSpecifier(DataType.VEC4);
			case 142: 
				return new TypeSpecifier(DataType.BVEC2);
			case 143: 
				return new TypeSpecifier(DataType.BVEC3);
			case 144: 
				return new TypeSpecifier(DataType.BVEC4);
			case 145: 
				return new TypeSpecifier(DataType.IVEC2);
			case 146: 
				return new TypeSpecifier(DataType.IVEC3);
			case 147: 
				return new TypeSpecifier(DataType.IVEC4);
			case 148: 
				return new TypeSpecifier(DataType.MAT2);
			case 149: 
				return new TypeSpecifier(DataType.MAT3);
			case 150: 
				return new TypeSpecifier(DataType.MAT4);
			case 151: 
				return new TypeSpecifier(DataType.SAMPLER2D);
			case 152: 
				return new TypeSpecifier(DataType.SAMPLERCUBE);
			case 154: 
				return new TypeSpecifier(DataType.USER_TYPE(t(1).data));
			case 155: 
				return PrecisionQualifier.HIGH_PRECISION;
			case 156: 
				return PrecisionQualifier.MEDIUM_PRECISION;
			case 157: 
				return PrecisionQualifier.LOW_PRECISION;
			case 158: 
				
				        var ss = new StructSpecifier(t(2).data, untyped a(4));
				        //parse context type definition's are handled at variable declaration
				        return ss;
				    
			case 159: 
				
				        var ss = new StructSpecifier(null, untyped a(3));
				        return ss;
				    
			case 160, 163, 183, 206: 
				return [n(1)];
			case 161: 
				a(1).push(n(2)); return s(1);
			case 162: 
				return new StructFieldDeclaration(untyped n(1), untyped a(2));
			case 164: 
				a(1).push(n(3)); return s(1);
			case 165: 
				return new StructDeclarator(t(1).data);
			case 166: 
				return new StructDeclarator(t(1).data, e(3));
			case 168: 
				return new DeclarationStatement(untyped n(1));
			case 169, 173, 174: 
				return s(2);
			case 181: 
				return new CompoundStatement([]);
			case 182: 
				return new CompoundStatement(untyped a(2));
			case 184: 
				
				        a(1).push(n(2)); 
				        return s(1);
				    
			case 185: 
				return new ExpressionStatement(null);
			case 186: 
				return new ExpressionStatement(e(1));
			case 187: 
				return new IfStatement(e(3), a(5)[0], a(5)[1]);
			case 188: 
				return [n(1), n(3)];
			case 189: 
				return [n(1), null];
			case 191: 
				
				        var declarator = new Declarator(t(2).data, e(4), null);
				        var declaration = new VariableDeclaration(untyped n(1), [declarator]);
				        handleVariableDeclaration(declaration);
				        return declaration;
				    
			case 192: 
				return new WhileStatement(e(4), untyped n(6));
			case 193: 
				return new DoWhileStatement(e(5), untyped n(2));
			case 194: 
				return new ForStatement(untyped n(4), a(5)[0], a(5)[1], untyped n(7));
			case 199: 
				return [e(1), null];
			case 200: 
				return [e(1), e(3)];
			case 201: 
				return new JumpStatement(JumpMode.CONTINUE);
			case 202: 
				return new JumpStatement(JumpMode.BREAK);
			case 203: 
				return new ReturnStatement(null);
			case 204: 
				return new ReturnStatement(untyped n(2));
			case 205: 
				return new JumpStatement(JumpMode.DISCARD);
			case 207: 
				
				        a(1).push(untyped n(2));
				        return s(1);
				    
			case 208, 209, 210: 
				
				        cast(n(1), Declaration).external = true;
				        return s(1);
				    
			case 211: 
				return new FunctionDefinition(untyped n(1), untyped n(3));
			case 212: 
				return new PreprocessorDirective(t(1).data);
			case 213: 
				
				        parseContext.scopePush();
				        return null;
				    
			case 214: 
				
				        parseContext.scopePop();
				        return null; 
				    ;
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