import glsl.parser.Tokenizer;

class Main{
	static var input:String;
	static function main(){


		//preprocessor
		input = "#define x\\\n100\nint i; #pragma invalid\n     #pragma valid\n 		#\n";
		tryTokenize();

		input = "!struct\n/* who does this?\n */ typename {...!}";
		tryTokenize();

		input = "!struct //line comment\\ \n/* who does this?\n */ typename {...!}";
		tryTokenize();

		input = "0x4.4 01 0xe3 0e0 1.e+=2";
		tryTokenize();

		input = "=-+!@£$%^&*(){}";
		tryTokenize();

		//input = sys.io.File.getContent('test.glsl');
	}

	static function tryTokenize(){
		trace('"$input"');
		var tokens:Array<Token> = null;
		try{
			tokens = Tokenizer.tokenize(input);
		}catch(e:Dynamic){
			trace('Fatal Error: $e');
		}
		trace('--------');
		return tokens;
	}

	static function printTokens(tokens:Array<Token>){
		for(t in tokens){
			trace(t.type, t.data);
		}
	}

}