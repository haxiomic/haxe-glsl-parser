import GrammarParser.NodeRuleDeclaration;
import GrammarParser.NodeRuleElement;

class LemonGrammarGenerator{

	static public function generate(ast:Array<NodeRuleDeclaration>, startRule:String):String{
		var lemonGrammar = '';
		lemonGrammar += '%start_symbol root\n';
		lemonGrammar += '\n';
		lemonGrammar += 'root ::= $startRule.\n';
		lemonGrammar += '\n';

		for(r in ast){
			for(e in r.rules){
				var elements = e.map(function (e:NodeRuleElement) return e.name).join(' ');
				lemonGrammar += '${r.name} ::= $elements.\n';
			}
		}
		return lemonGrammar;
	}

}