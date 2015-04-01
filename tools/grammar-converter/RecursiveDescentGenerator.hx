/*	
	@! Unfinished
	Generates rule functions correctly but buildResults / (node construction) functions are left incomplete
*/

import GrammarParser.NodeRuleDeclaration;
import GrammarParser.NodeRuleElement;

class ParserGenerator{

	static var packageName:String;
	static var coreRule:String;

	static public function generate(ast:Array<NodeRuleDeclaration>, packageName:String, coreRule:String):String{
		ParserGenerator.packageName = packageName;
		ParserGenerator.coreRule = coreRule;

		//generate rule functions
		//generate buildResult stubs
		//generate typedefs for each result
		var haxeCode = '';

		haxeCode += generateClassStart();

		haxeCode += '/* --------- Rule functions --------- */\n';
		haxeCode += '\tstatic var r;//convenience variable\n';
		for(ruleDecl in ast){
			haxeCode += indent(generateRuleFunction(ruleDecl), 1);
			haxeCode += '\n';
			haxeCode += '\n';
		}


		haxeCode += '/* --------- Build result functions --------- */\n';
		for(ruleDecl in ast){
			haxeCode += indent(generateBuildResultStub(ruleDecl), 1);
			haxeCode += '\n';
			haxeCode += '\n';
		}

		haxeCode += generateClassEnd();

		return haxeCode;
	}

	static function generateRuleFunction(ruleDecl:NodeRuleDeclaration):String{
		var fnHeader = 'static function rule_${ruleDecl.name}(){\n';
		
		var contentRules = '\ttrace("trying rule: ${ruleDecl.name}");\n';//@! debug

		var includesRuleEmptyType = false;
		var i = ruleDecl.rules.length;
		while(--i >= 0){ //descending
		// for(i in 0...ruleDecl.rules.length){ //ascending
			var rule = ruleDecl.rules[i];

			var ruleTryStatement = '';
			if(rule[0].type == Empty){
				ruleTryStatement += '\t';
				includesRuleEmptyType = true;
			}else{
				ruleTryStatement += '\tif(r = trySequence([';
				ruleTryStatement += rule.map(function (e:NodeRuleElement){
					switch (e.type) {
						case Rule: return 'Rule(rule_${e.name})';
						case Token: return 'Token(${e.name})';
						default:
					}
					return null;
				}).join(',');
				ruleTryStatement += '])) ';
			}

			ruleTryStatement += 'return buildResult_${ruleDecl.name}(r, $i);\n';
			contentRules += ruleTryStatement;
		}

		contentRules += '\ttrace("failed ${ruleDecl.name}");\n';//@! debug


		var fnEnd = includesRuleEmptyType ? '}' : '\treturn null;\n}';

		return fnHeader + contentRules + fnEnd;
	}

	static function generateBuildResultStub(ruleDecl:NodeRuleDeclaration):String{
		//@! ? default node could be type: SomeType, data: r.data
		//(where each node keeps track of the data which is the concatenated string of the results)

		var fnHeader = 'static function buildResult_${ruleDecl.name}(r:SequenceResults, sequenceIndex:Int){\n';

		var contentStart = '\ttrace("building result for ${ruleDecl.name}");\n';//@! debug

		//default switch
		var switchStart = '\tswitch (sequenceIndex) {\n';

		var switchCases = '';
		for(i in 0...ruleDecl.rules.length){
			var rule = ruleDecl.rules[i];
			var caseComment = '// '+rule.map(function(e:NodeRuleElement) return e.name).join(' ');
			switchCases += '\t\tcase $i: ' + caseComment + '\n';
		}

		var switchEnd = '\t}\n';

		var contentSwitch = switchStart + switchCases + switchEnd;

		var fnEnd = '\treturn {};\n}';

		return fnHeader + contentStart + contentSwitch + fnEnd;
	}

	static function generateClassStart():String{
		return 'package $packageName;
import $packageName.Tokenizer.Token;
import $packageName.Tokenizer.TokenType;


//Convenience abstract to allow treating Arrays as Bools for cases where it\'s helpful to do: if(array) ...
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
			var coreNode = rule_$coreRule();
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
		trace(\'Parser Warning: \'+msg);
	}

	static function error(msg){
		throw \'Parser Error: \'+msg;
	}\n\n';
	}

	static function generateClassEnd():String{
		return "}";
	}



	//Utils
	static function indent(str:String, n:Int = 1){
		var lines = str.split('\n');
		var tabStr = [for(i in 0...n) '\t'].join('');
		for(i in 0...lines.length){
			var l = lines[i];
			if(l.length > 0) lines[i] = tabStr+l;
		}
		return lines.join('\n');
	}

	//Error Reporting
	static function warn(msg){
		trace('Generator Warning: $msg');
	}

	static function error(msg){
		throw 'Generator Error: $msg';
	}
}