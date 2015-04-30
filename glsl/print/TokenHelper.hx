/*

	Token Printer

	@author George Corney

*/

package glsl.print;

typedef PrintableToken = {data:String};

class TokenArrayPrinter{
	static public function print(tokens:Array<PrintableToken>):String{
		var str = "";
		for(t in tokens) str += TokenPrinter.print(t);
		return str;
	}
}
class TokenPrinter{
	static public function print(token:PrintableToken):String{
		return token.data;
	}
}