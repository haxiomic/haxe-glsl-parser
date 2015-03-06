import GrammarTokenizer.Token;
import GrammarTokenizer.TokenType;

/* 
	#Notes
	- Rules are tried in reverse order
	- What is the best way to build the AST?
		- Extend grammar language to include Node generation instructions
		- A second parse over the big array of results
		- A series of buildNodeX(x) functions

	- Make sure *empty* is being handled correctly!

*/
/*	
	//Grammar grammar (A grammar that describes itself!)

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
/* 
	Example AST (generated from the above grammar)

	[
		{
			type: RuleDeclaration,
			name: 'root',
			rules: [
				[{ type: Rule, name: 'rule' }],
				[{ type: Token, name: 'NEWLINE' }]
			]
		},
		{
			type: RuleDeclaration,
			name: 'rule',
			rules: [
						[
							{ type: Token, name: 'RULE_DECL' },
							{ type: Token, name: 'Newline' },
							{ type: Rule, name: 'rule_sequence_list' }
						]
					]
				},
			]
		}
	
	...

	];
*/

//Convenience abstract to allow treating Arrays as Bools for cases where it's helpful to do: if(array) ...
@:forward
abstract SequenceResults(Array<Dynamic>) from Array<Dynamic>{
	public inline function new() this = [];
	@:to function toBool():Bool return this != null;
	@:arrayAccess public inline function get(i:Int) return this[i];
}

enum Element{
	Rule(ruleFunction:Void->Dynamic);
	Token(type:TokenType);
}

typedef Node = {};


class GrammarParser
{
	//state machine data
	static var tokens:Array<Token>;

	static var i:Int;

	static public function parseTokens(tokens:Array<Token>){
		GrammarParser.tokens = tokens;
		i = 0;

		var ast = [];
		while(i < tokens.length){
			var rootNode = root();
			if(rootNode != null)
				ast.push(rootNode);
		}

		return ast;
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

	static function tryRule(ruleFunction:Void->Dynamic){
		//responsible for tracking index
		var i_before = i;
		var result = ruleFunction();
		if(result != null) return result;
		i = i_before;
		return null;
	}

	static function trySequence(sequence:Array<Element>):SequenceResults{ //sequence is an array of either Void->Dynamic or TokenType
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
		trace('Parser Warning: $msg');
	}

	static function error(msg){
		throw 'Parser Error: $msg';
	}

/* ######### Language Specifics ######### */

/* --------- Rule functions --------- */
	static function root():NodeRuleDeclaration{
		var r;
		if(r = trySequence([Rule(rule)])) return cast r[0];
		if(r = trySequence([Token(NEWLINE)])) return null;

		warn(' --- got to end of root, next token was ${readToken()}'); //advances
		return null;
	}

	static function rule():NodeRuleDeclaration{//#! should return RuleDeclaration{name: '...', rules:RuleSequenceList: [...]}
		//RULE_DECL NEWLINE rule_sequence_list
		var r;
		if(r = trySequence([Token(RULE_DECL), Token(NEWLINE), Rule(rule_sequence_list)])) return buildResult_rule(r, 0);
		return null;
	}

	static function rule_sequence_list():Array<Array<NodeRuleElement>>{//#! should return RuleSequenceList::Array<Array<NodeRuleElement>>
		//rule_sequence || rule_sequence rule_sequence_list
		var r;
		if(r = trySequence([Rule(rule_sequence), Rule(rule_sequence_list)])) return buildResult_rule_sequence_list(r, 1);
		if(r = trySequence([Rule(rule_sequence)])) return buildResult_rule_sequence_list(r, 0);
		return null;
	}

	static function rule_sequence():Array<NodeRuleElement>{//#! should return RuleSequence::Array<NodeRuleElement>
		//EMPTY NEWLINE || rule_element_list NEWLINE
		var r;
		if(r = trySequence([Rule(rule_element_list), Token(NEWLINE)])) return buildResult_rule_sequence(r, 1);
		if(r = trySequence([Token(EMPTY), Token(NEWLINE)])) return buildResult_rule_sequence(r, 0);
		return null;
	}

	static function rule_element_list():Array<NodeRuleElement>{//#! should return Array<NodeRuleElement>
		//rule_element || rule_element rule_element_list
		var r;
		if(r = trySequence([Rule(rule_element), Rule(rule_element_list)])) return buildResult_rule_element_list(r, 1);
		if(r = trySequence([Rule(rule_element)])) return buildResult_rule_element_list(r, 0);
		return null;
	}

	static function rule_element():NodeRuleElement{//#! should return NodeRuleElement{type: Rule || Token, name: '...'}
		//RULE or TOKEN
		var r;
		if(r = trySequence([Token(TOKEN)])) return buildResult_rule_element(r, 1);
		if(r = trySequence([Token(RULE)])) return buildResult_rule_element(r, 0);
		return null;
	}

/* --------- Build node functions --------- */
	//for each rule there is a build result function
	//buildResult_* converts raw trySequence result into formatted result for use in AST

	static function buildResult_rule(r:SequenceResults, sequenceIndex:Int):NodeRuleDeclaration{
		var name:String = r[0].data;
		name = name.substr(0, name.length - 1);//remove : character
		return {
			name: name,
			rules: cast r[2]
		};
	}

	static function buildResult_rule_sequence_list(r:SequenceResults, sequenceIndex:Int):Array<Array<NodeRuleElement>>{
		switch (sequenceIndex) {
			case 0: return [cast r[0]];
			case 1: return [cast r[0]].concat( cast r[1]);
		}
		return null;
	}

	static function buildResult_rule_sequence(r:SequenceResults, sequenceIndex:Int):Array<NodeRuleElement>{
		switch (sequenceIndex) {
			case 0: return [{
						type: Empty,
						name: r[0].data
					}];
			case 1: return cast r[0];
		}
		return null;
	}

	static function buildResult_rule_element_list(r:SequenceResults, sequenceIndex:Int):Array<NodeRuleElement>{
		switch (sequenceIndex) {
			case 0: return [cast r[0]];
			case 1: return [cast r[0]].concat(cast r[1]);
		}
		return null;
	}

	static function buildResult_rule_element(r:SequenceResults, sequenceIndex:Int):NodeRuleElement{
		return {type: sequenceIndex == 0 ? Rule : Token, name: r[0].data};
	}

}


typedef NodeRuleDeclaration = {
	> Node,
	var name:String;
	var rules:Array<Array<NodeRuleElement>>;
}

enum NodeRuleElementTypes{
	Rule;
	Token;
	Empty;
}

typedef NodeRuleElement = {
	> Node,
	var type:NodeRuleElementTypes;
	var name:String;
}
