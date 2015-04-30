import glsl.tokens.Tokenizer;

class Main{

	static function main(){
		var input = "";

		//fuzz
		var chars = ['e', 'E', '+', '-', '.', '_', '=', '^', '/' ,' ', ' ', ' ', '0x', '00', '\\', ' asm', ' if ', ' while ', ' struct ', '{', '}', '\n'];
		for (i in 0...10) chars.push(Std.string(i));

		for(n in 0...1000){
			var i = Math.floor(Math.random()*chars.length);
			input += chars[i];
		}

		trace('"$input"');
		var tokens = Tokenizer.tokenize(input);
	}

}