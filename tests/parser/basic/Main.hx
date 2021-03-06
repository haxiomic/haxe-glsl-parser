import glsl.lex.Tokenizer;

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

		var ast = glsl.parse.Parser.parseTokens(tokens);
		trace('\n\n\n');
		trace(haxe.Json.stringify(ast));
	}

	//trace array of tokenIds for use in the C debug build
	static function traceCTokenArray(tokens:Array<Token>){
		var ids:Array<Int> = [];
		for(t in tokens){
			var id = glsl.parse.Tables.tokenIdMap.get(t.type);
			if(id != null) ids.push(id);
		}

		trace('{'+ids.join(',')+'}');
	}

}