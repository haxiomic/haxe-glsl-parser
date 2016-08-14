/*
	Actions

	Responsible for constructing the abstract syntax tree by creation
	and concatenation of notes in accordance with the grammar rules of the language
	
	::grammar_name::

	@author George Corney
*/

package glsl.parse;

import glsl.lex.Tokenizer.Token;
import glsl.lex.Tokenizer.TokenType;
import glsl.SyntaxTree;

using glsl.SyntaxTree.NodeTypeHelper;
using glsl.lex.TokenHelper;


typedef MinorType = Dynamic;

@:access(glsl.parse.Parser)
class Actions{

	static var i(get, null):Int;
	static var stack(get, null):Parser.Stack;

	static var ruleno;
	static var parseContext:ParseContext;
	static var lastToken:Token;

	static public function init(){
		ruleno = -1;
		parseContext = new ParseContext();
		lastToken = null;
	}

	static public function processToken(t:Token){
		//check if identifier refers to a user defined type
		//if so, change the token's type to TYPE_NAME
		if(t.type.equals(TokenType.IDENTIFIER)){
			if(!parseContext.declarationContext){
				//ensure it's not directly after a type token
				var afterType = lastToken != null && lastToken.type.isTypeReferenceType();
				var afterStruct = lastToken != null && lastToken.type.equals(TokenType.STRUCT);
				if(!afterType && !afterStruct){
					switch parseContext.searchScope(t.data) {
						case ParseContext.Object.USER_TYPE(_):
							t.type = TokenType.TYPE_NAME;
						case null, _:
					}
				}
			}
		}

		lastToken = t;
		return t;
	}

	static public function reduce(ruleno:Int):MinorType{
		Actions.ruleno = ruleno; //set class ruleno so it can be accessed by other functions

		var __ret:MinorType = null;
		
		switch ruleno{
$$printActionCases(rule_actions,rules,3)
		}

		return __ret;

		Parser.warn('unhandled reduce rule number $ruleno');
		return null;
		
	}

	static function handleVariableDeclaration(declarator:Declarator, ts:TypeSpecifier){
		//declare type user type
		switch ts.safeNodeType(){
			case StructSpecifierNode(n):
				parseContext.declareType(n);
			case null, _:
		}

		//variable declaration
		if(declarator != null){
			parseContext.declareVariable(declarator);
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