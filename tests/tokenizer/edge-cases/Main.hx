import glsl.parser.Tokenizer;

class Main{
	static var input:String;
	static function main(){

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
		try{
			Tokenizer.tokenize(input);
		}catch(e:Dynamic){
			trace('Fatal Error: $e');
		}
		trace('--------');
	}

}