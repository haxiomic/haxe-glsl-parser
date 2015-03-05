import GrammarTokenizer.Token;
import GrammarTokenizer.TokenType;

/* 
	#Notes
	- Rules are tried in reverse order
*/


/*
	Grammar grammar

	root:
		rule
		NEWLINE

	rule:
		RULE_DECL NEWLINE rule_sequence_list

	rule_sequence_list:
		rule_sequence
		rule_sequence rule_sequence_list

	rule_sequence:
		EMPTY NEWLINE
		rule_element_list NEWLINE
	
	rule_element_list:
		rule_element
		rule_element rule_element_list

	rule_element:
		RULE
		TOKEN
*/

class GrammarParser
{
	//state machine data
	static var tokens:Array<Token>;

	static var i:Int;

	static public function parseTokens(tokens:Array<Token>){
		GrammarParser.tokens = tokens;
		i = 0;

		//test 
		root();
		root();
		root();
		root();
		root();
		root();
		root();
		root();
		root();
		root();
		root();

		return {};
	}

	//token and node look ahead - these functions alone are responsible for managing the current index
	static function readToken():Token{//reads and advances
		var token = tokens[i++];
		if(token == null) return null;
		if(token.type == SPACE || token.type == BLOCK_COMMENT || token.type == LINE_COMMENT)
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

	static function tryRule(ruleFunction:Void->RuleResult){
		//responsible for tracking index
		var i_before = i;
		var result = ruleFunction();
		if(result != null) return result;
		i = i_before;
		return null;
	}

	static function trySequence(sequence:Array<Element>):Results{ //array of either Void->RuleResult or tokenType
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

		return results;
	}

	//node functions
	static function root():RuleResult{
		var r = tryRule(rule);
		trace('result:', r);
		if(r != null) return {};

		trace(' --- got to end of root, next token was ${readToken().type}');
		return null;
	}

	static function rule():RuleResult{
		//RULE_DECL NEWLINE rule_sequence_list
		var r;
		if(r = trySequence([Token(RULE_DECL), Token(NEWLINE), Rule(rule_sequence_list)])) return {};
		return null;
	}

	static function rule_sequence_list():RuleResult{
		//rule_sequence || rule_sequence rule_sequence_list
		var r;
		if(r = trySequence([Rule(rule_sequence), Rule(rule_sequence_list)])) return {};
		if(r = trySequence([Rule(rule_sequence)])) return {};
		return null;
	}

	static function rule_sequence():RuleResult{
		//EMPTY NEWLINE || rule_element_list NEWLINE
		var r;
		if(r = trySequence([Rule(rule_element_list), Token(NEWLINE)])) return {};
		if(r = trySequence([Token(EMPTY), Token(NEWLINE)])) return {};
		return null;
	}

	static function rule_element_list():RuleResult{
		//rule_element || rule_element rule_element_list
		var r;
		if(r = trySequence([Rule(rule_element), Rule(rule_element_list)])) return {};
		if(r = trySequence([Rule(rule_element)])) return {};
		return null;
	}

	static function rule_element():RuleResult{
		//RULE or TOKEN
		var r;
		if(r = trySequence([Token(TOKEN)])) return {};
		if(r = trySequence([Token(RULE)])) return {};
		return null;
	}
}

abstract Results(Array<Dynamic>) from Array<Dynamic>{
	public inline function new() this = [];
	@:to function toBool():Bool return this != null;    
}

enum Element{
	Rule(ruleFunction:Void->RuleResult);
	Token(type:TokenType);
}

typedef RuleResult = {};
typedef Node = {};