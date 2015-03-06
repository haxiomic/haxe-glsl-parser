import glslparser.Tokenizer;

class Main{

	static function main(){
		var input = '';

		input = 'int A = 1;';

		trace('"$input"');
		var tokens = Tokenizer.tokenize(input);
		var ast = glslparser.Parser.parseTokens(tokens);
	}

}