import GrammarParser.NodeRuleDeclaration;
import GrammarParser.NodeRuleElement;

/*
	#Notes
	- Make sure EMPTY is handled properly
*/

class ParserGenerator{

	static public function generate(ast:Array<NodeRuleDeclaration>):String{
		//generate rule functions
		//generate buildResult stubs
		//generate typedefs for each result
		var haxeCode = '';

		haxeCode += '/* --------- Rule functions --------- */\n';
		for(ruleDecl in ast){
			haxeCode += generateRuleFunction(ruleDecl);
			haxeCode += '\n';
			haxeCode += '\n';
		}

		haxeCode += '/* --------- Build result functions --------- */\n';
		for(ruleDecl in ast){
			haxeCode += generateBuildResultStub(ruleDecl);
			haxeCode += '\n';
			haxeCode += '\n';
		}

		return haxeCode;
	}


	static function generateRuleFunction(ruleDecl:NodeRuleDeclaration):String{
		var fnName = 'rule_' + ruleDecl.name;//remove : character

		var fnHeader = 'static function $fnName(){\n';
		var contentStart = '\tvar r;\n';
		var contentRules = '';

		var i = ruleDecl.rules.length;
		while(--i >= 0){
			var rule = ruleDecl.rules[i];
			contentRules += '\tif(r = trySequence([';
			contentRules += rule.map(function (e:NodeRuleElement){
				switch (e.type) {
					case Rule: return 'Rule(${e.name})';
					case Token: return 'Token(${e.name})';
					case Empty: warn('NodeRuleElement Empty is not yet handled'); //#!
				}
				return null;
			}).join(',');
			contentRules += '])) return buildResult_${ruleDecl.name}(r, $i);\n';
		}

		var contentEnd = '\treturn null;\n}';

		return fnHeader + contentStart + contentRules + contentEnd;
	}

	static function generateBuildResultStub(ruleDecl:NodeRuleDeclaration):String{
		var fnName = 'buildResult_' + ruleDecl.name;//remove : character
		var fnHeader = 'static function $fnName(r:RawResults, sequenceIndex:Int){\n';
		var contentBody = '\treturn {};\n';
		var conentEnd = '}';

		return fnHeader + contentBody + conentEnd;
	}

	//Error Reporting
	static function warn(msg){
		trace('Generator Warning: $msg');
	}

	static function error(msg){
		throw 'Generator Error: $msg';
	}
}