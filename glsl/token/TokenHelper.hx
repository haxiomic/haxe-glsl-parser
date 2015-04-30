package glsl.token;

import glsl.token.Tokenizer;

class TokenHelper{

	//returns the token n tokens away from token start, ignoring skippables. Supports negative n
	static public function nextNonSkipToken(tokens:Array<Token>, start:Int, n:Int = 1, ?requiredType:TokenType):Token{
		var j = nextNonSkipTokenIndex(tokens, start, n, requiredType);
		return j != -1 ? tokens[j] : null;
	}

	static public function nextNonSkipTokenIndex(tokens:Array<Token>, start:Int, n:Int = 1, ?requiredType:TokenType):Int{
		var direction = n >= 0 ? 1 : -1;
		var j = start;
		var m = Math.abs(n);
		var t:Token;
		while(m > 0){
			j += direction;//advance token
			t = tokens[j];
			if(t == null) return -1;
			//continue for skip over
			if(requiredType != null && !t.type.equals(requiredType)) continue;
			if(Tokenizer.skippableTypes.indexOf(t.type) != -1) continue;
			m--;
		}
		return j;
	}

	static public function deleteTokens(tokens:Array<Token>, start:Int, count:Int = 1){
		return tokens.splice(start, count);
	}

	static public function insertTokens(tokens:Array<Token>, start:Int, newTokens:Array<Token>){
		var j = newTokens.length;
		while(--j >= 0) tokens.insert(start, newTokens[j]);
		return tokens;
	}

	static public inline function isIdentifierType(type:TokenType){
		return identifierTokens.indexOf(type) >= 0;
	}

	static var identifierTokens:Array<TokenType> = [
		IDENTIFIER,
		ATTRIBUTE,
		UNIFORM,
		VARYING,
		CONST,
		VOID,
		INT,
		FLOAT,
		BOOL,
		VEC2,
		VEC3,
		VEC4,
		BVEC2,
		BVEC3,
		BVEC4,
		IVEC2,
		IVEC3,
		IVEC4,
		MAT2,
		MAT3,
		MAT4,
		SAMPLER2D,
		SAMPLERCUBE,
		BREAK,
		CONTINUE,
		WHILE,
		DO,
		FOR,
		IF,
		ELSE,
		RETURN,
		DISCARD,
		STRUCT,
		IN,
		OUT,
		INOUT,
		INVARIANT,
		PRECISION,
		HIGH_PRECISION,
		MEDIUM_PRECISION,
		LOW_PRECISION,
		BOOLCONSTANT,
		RESERVED_KEYWORD,
		TYPE_NAME,
		FIELD_SELECTION
	];
}