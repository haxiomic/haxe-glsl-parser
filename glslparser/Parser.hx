import glslparser.Tokenizer.Token;

/*
	Notes
	- How do we deal with operator precedence?
	- How to deal with optionals?
	- We could abstract Node to allow comparison with null
	- "If a comment resides entirely within a single line, it is treated syntactically as a single space"
	- "Newlines are not eliminated by comments" i guess when replacing comments, count the number of newlines within
	
	Resources
	http://www.semdesigns.com/Products/DMS/LifeAfterParsing.html?Home=DMSToolkit

	- Recursive Decent Parser
		http://stackoverflow.com/questions/2245962/is-there-an-alternative-for-flex-bison-that-is-usable-on-8-bit-embedded-systems/2336769#2336769
		http://stackoverflow.com/questions/25049751/constructing-an-abstract-syntax-tree-with-a-list-of-tokens/25106688#25106688


	Outline:
	Recursive bottom up pattern		

*/

class Parser{

	//state machine data
	static var tokens:Array<Tokens>;

	static var i:Int;

	static public function parseTokens(tokens:Array<Token>){
		Parser.tokens = tokens;
		i = 0;
	}


	//Error Reporting
	static function warn(msg){
		trace('Parser Warning: $msg');
	}

	static function error(msg){
		throw 'Parser Error: $msg';
	}
}

typedef Node = {
}