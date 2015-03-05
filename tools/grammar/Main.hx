class Main{
	static var projectRoot = getProjectRoot();
	static var grammarFile = haxe.io.Path.join([projectRoot, "glsl-grammar.txt"]);

	static function main() {
		var grammar = sys.io.File.getContent(grammarFile);


		var tokens = GrammarTokenizer.tokenize(grammar);

		//print tokens
		// for(t in tokens) trace(t.type);

		var ast = GrammarParser.parseTokens(tokens);

		var parserCode = ParserGenerator.generate(ast);
		trace(parserCode);
	}

	static function getProjectRoot(){
		var p = new sys.io.Process("git", ["rev-parse", "--show-toplevel"]);
		if(p.exitCode() != 0) return null;
		var result = p.stdout.readAll().toString();
		p.close();
		return result.substr(0, result.length-1);
	}
}