import glslparser.Tokenizer;

class Main{

	static function main(){
		var input = '';

		input = '
		precision mediump float;

		int i = 42;
		bool;

		void main(){
			return 5;
		}
		';

		input = '
			int noParams();
			
			int magicFunction(float a, vec2 v, inout int c);
			int magicFunction(float a, vec2 v, inout int c){
				return 0;
			}
		';

		trace('"$input"');
		var tokens = Tokenizer.tokenize(input);
		trace('tokens generated');

		//traceCTokenArray();

		var ast = glslparser.Parser.parseTokens(tokens);
		trace('parsed');
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