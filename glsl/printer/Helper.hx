package glsl.printer;

import glsl.parser.Tokenizer.Token;

class SyntaxTreePrinter{
	
}

class TokenArrayPrinter{

	static public function print(tokens:Array<Token>){
		var str = "";
		for(t in tokens) str += TokenPrinter.print(t);
		return str;
	}

}

class TokenPrinter{

	static public function print(token:Token){
		return token.data;
	}

}