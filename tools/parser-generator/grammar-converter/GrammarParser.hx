import GrammarTokenizer.Token;
import GrammarTokenizer.TokenType;

/* 
	#Notes
	- Rules are tried in reverse order
	- What is the best way to build the SyntaxTree?
		- Extend grammar language to include Node generation instructions
		- A second parse over the big array of results
		- A series of buildNodeX(x) functions

	- Make sure *empty* is being handled correctly!

*/
/*	
	//Grammar grammar (A grammar that describes itself!)

	root:
		NEWLINE
		directive
		rule

	directive:
		DIRECTIVE directive_content_list NEWLINE

	directive_content_list:
		directive_element
		directive_element directive_content_list

	directive_element:
		RULE
		TOKEN
		WORD
		NUMBER
		CODE_BLOCK

	rule:
		RULE_DECL NEWLINE rule_sequence_list

	rule_sequence_list:
		rule_sequence
		rule_sequence rule_sequence_list

	rule_sequence:
		EMPTY NEWLINE
		EMPTY CODE_BLOCK NEWLINE
		rule_element_list NEWLINE
	
	rule_element_list:
		rule_element
		rule_element rule_element_list

	rule_element:
		RULE
		TOKEN
		RULE CODE_BLOCK
		TOKEN CODE_BLOCK
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

class GrammarParser
{
	//state machine data
	static var tokens:Array<Token>;

	static var i:Int;

	static var ignoredTokens:Array<TokenType> = [
		SPACE,
		BLOCK_COMMENT,
		LINE_COMMENT
	];

	static public function parseTokens(tokens:Array<Token>){
		GrammarParser.tokens = tokens;
		i = 0;

		var ast:Array<Node> = [];
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
		if(ignoredTokens.indexOf(token.type) != -1)
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
	static function root():Node{
		var r;
		if(r = trySequence([Rule(rule)])) return r[0];
		if(r = trySequence([Rule(directive)])) return r[0];
		if(r = trySequence([Token(NEWLINE)])) return null;

		warn(' --- got to end of root, next token was ${readToken()}'); //advances
		return null;
	}

	static function directive():Directive{
		//DIRECTIVE directive_content_list NEWLINE
		var r;
		if(r = trySequence([Token(DIRECTIVE), Rule(directive_content_list), Token(NEWLINE)])) return buildResult_directive(r, 0);
		return null;
	}

	static function directive_content_list():Array<DirectiveElement>{
		//directive_element || directive_element directive_content_list
		var r;
		if(r = trySequence([Rule(directive_element), Rule(directive_content_list)])) return buildResult_directive_content_list(r, 1);
		if(r = trySequence([Rule(directive_element)])) return buildResult_directive_content_list(r, 0);
		return null;
	}

	static function directive_element():DirectiveElement{
		//RULE || TOKEN || WORD || NUMBER || CODE_BLOCK
		var r;
		if(r = trySequence([Token(CODE_BLOCK)])) return buildResult_directive_element(r, 4);
		if(r = trySequence([Token(NUMBER)])) return buildResult_directive_element(r, 3);
		if(r = trySequence([Token(WORD)])) return buildResult_directive_element(r, 2);
		if(r = trySequence([Token(TOKEN)])) return buildResult_directive_element(r, 1);
		if(r = trySequence([Token(RULE)])) return buildResult_directive_element(r, 0);
		return null;
	}

	static function rule():RuleDeclaration{
		//RULE_DECL NEWLINE rule_sequence_list
		var r;
		if(r = trySequence([Token(RULE_DECL), Token(NEWLINE), Rule(rule_sequence_list)])) return buildResult_rule(r, 0);
		return null;
	}

	static function rule_sequence_list():Array<Array<RuleElement>>{
		//rule_sequence || rule_sequence rule_sequence_list
		var r;
		if(r = trySequence([Rule(rule_sequence), Rule(rule_sequence_list)])) return buildResult_rule_sequence_list(r, 1);
		if(r = trySequence([Rule(rule_sequence)])) return buildResult_rule_sequence_list(r, 0);
		return null;
	}

	static function rule_sequence():Array<RuleElement>{//@! should return RuleSequence::Array<NodeRuleElement>
		//EMPTY NEWLINE || EMPTY CODE_BLOCK NEWLINE || rule_element_list NEWLINE
		var r;
		if(r = trySequence([Rule(rule_element_list), Token(NEWLINE)])) return buildResult_rule_sequence(r, 2);
		if(r = trySequence([Token(EMPTY), Token(CODE_BLOCK), Token(NEWLINE)])) return buildResult_rule_sequence(r, 1);
		if(r = trySequence([Token(EMPTY), Token(NEWLINE)])) return buildResult_rule_sequence(r, 0);
		return null;
	}

	static function rule_element_list():Array<RuleElement>{//@! should return Array<NodeRuleElement>
		//rule_element || rule_element rule_element_list
		var r;
		if(r = trySequence([Rule(rule_element), Rule(rule_element_list)])) return buildResult_rule_element_list(r, 1);
		if(r = trySequence([Rule(rule_element)])) return buildResult_rule_element_list(r, 0);
		return null;
	}

	static function rule_element():RuleElement{//@! should return NodeRuleElement{type: Rule || Token, name: '...'}
		//RULE || TOKEN || RULE CODE_BLOCK || TOKEN CODE_BLOCK
		var r;
		if(r = trySequence([Token(TOKEN), Token(CODE_BLOCK)])) return buildResult_rule_element(r, 3);
		if(r = trySequence([Token(RULE), Token(CODE_BLOCK)])) return buildResult_rule_element(r, 2);
		if(r = trySequence([Token(TOKEN)])) return buildResult_rule_element(r, 1);
		if(r = trySequence([Token(RULE)])) return buildResult_rule_element(r, 0);
		return null;
	}

/* --------- Build node functions --------- */
	//for each rule there is a build result function
	//buildResult_* converts raw trySequence result into formatted result for use in SyntaxTree

	static function buildResult_directive(r:SequenceResults, si:Int):Directive{
		var name:String = cast(r[0].data, String).substr(1);
		return new Directive(name, cast r[1]);
	}

	static function buildResult_directive_content_list(r:SequenceResults, si:Int):Array<DirectiveElement>{
		switch (si) {
			case 0: return [cast r[0]];
			case 1: return [cast r[0]].concat( cast r[1]);
		}
		return null;
	}

	static function buildResult_directive_element(r:SequenceResults, si:Int):DirectiveElement{
		return new DirectiveElement(r[0].type, r[0].data);
	}

	static function buildResult_rule(r:SequenceResults, si:Int):RuleDeclaration{
		var name:String = r[0].data;
		name = name.substr(0, name.length - 1);//remove ':' character
		return new RuleDeclaration(name, r[2]);
	}

	static function buildResult_rule_sequence_list(r:SequenceResults, si:Int):Array<Array<RuleElement>>{
		switch (si) {
			case 0: return [cast r[0]];
			case 1: return [cast r[0]].concat( cast r[1]);
		}
		return null;
	}

	static function buildResult_rule_sequence(r:SequenceResults, si:Int):Array<RuleElement>{
		switch (si) {
			case 0: return [new RuleElement('', r[0].type)]; //empty
			case 1: 
				var code:String = r[1].data;
				//remove outer {}
				code = code.substr(1, code.length - 2);
				return [new RuleElement('', r[0].type, code)]; //empty {code}
			case 2: return cast r[0];
		}
		return null;
	}

	static function buildResult_rule_element_list(r:SequenceResults, si:Int):Array<RuleElement>{
		switch (si) {
			case 0: return [cast r[0]];
			case 1: return [cast r[0]].concat(cast r[1]);
		}
		return null;
	}

	static function buildResult_rule_element(r:SequenceResults, si:Int):RuleElement{
		switch si {
			case 0, 1: return new RuleElement(r[0].data, r[0].type);
			case 2, 3: 
				var code:String = r[1].data;
				//remove outer {}
				code = code.substr(1, code.length - 2);
				return new RuleElement(r[0].data, r[0].type, code);
		}
		return null;
	}

}

interface Node{
	public function toEnum():NodeEnum;
}

class Directive implements Node{
	public var name:String;
	public var content:Array<DirectiveElement>;
	public function new(name:String, content:Array<DirectiveElement>){
		this.name = name;
		this.content = content;
	}
	public function toEnum():NodeEnum
		return DirectiveNode(this);
}

class DirectiveElement implements Node{
	public var type:TokenType;
	public var data:String;
	public function new(type:TokenType, data:String){
		this.type = type;
		this.data = data;
	}
	public function toEnum():NodeEnum
		return DirectiveElementNode(this);
}

class RuleDeclaration implements Node{
	public var name:String;
	public var rules:Array<Array<RuleElement>>;
	public function new(name:String, rules:Array<Array<RuleElement>>){
		this.name = name;
		this.rules = rules;
	}
	public function toEnum():NodeEnum
		return RuleDeclarationNode(this);
}

class RuleElement implements Node{
	public var name:String;
	public var type:TokenType;
	public var code:String;
	public function new(name:String, type:TokenType, code:String = null){
		this.name = name;
		this.type = type;
		this.code = code;
	}
	public function toEnum():NodeEnum
		return RuleElementNode(this);
}

enum NodeEnum{
	DirectiveNode(n:Directive);
	DirectiveElementNode(n:DirectiveElement);
	RuleDeclarationNode(n:RuleDeclaration);
	RuleElementNode(n:RuleElement);
}