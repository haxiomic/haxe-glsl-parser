import glslparser.Tokenizer;

class Main{

	static function main(){
		var input = '';

		input = '
		
		';

		input = '
		void main(){
			a = 1 + 3, b += 2++;
		}
		';

		trace('"$input"');
		var tokens = Tokenizer.tokenize(input);
		trace('tokens generated');

		//traceCTokenArray();

		var ast = glslparser.Parser.parseTokens(tokens);
		trace('\n\n\n');
		trace(ast);
	}

	static function traceCTokenArray(tokens:Array<Token>){
		//trace array of tokenIds for use in the C debug build
		var ids:Array<Int> = [];
		for(t in tokens){
			var id = glslparser.ParserData.tokenIdMap.get(t.type);
			if(id != null) ids.push(id);
		}

		trace('{'+ids.join(',')+'}');
	}

}