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
$$printActionCases(rule_actions);
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