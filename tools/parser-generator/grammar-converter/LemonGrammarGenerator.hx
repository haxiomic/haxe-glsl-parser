import GrammarParser;

class LemonGrammarGenerator{

	static public function generate(ast:Array<Node>):String{
		var result = '';

		//@! need to split up inline code into dummy rules

		for(n in ast){
			switch n.toEnum(){
				case DirectiveNode(n):
					var elements:String = n.content.map(function (e) return e.data).join(' ');

					result += '%${n.name} $elements\n';
				case RuleDeclarationNode(n):
					for(els in n.rules){
						var elements:String = els.map( function (e:RuleElement) return e.name ).join(' ');
						result += '${n.name} ::= $elements.';
						//add code
						var lastE = els[els.length - 1];
						if(lastE.code != null)
							result += ' {${lastE.code}}';
						result += '\n';
					}
				case null, _:
			}
		}
		return result;
	}

}