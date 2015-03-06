import haxe.io.Path;

class Main{
	static var projectRoot = getProjectRoot();
	static var grammarFile = Path.join([projectRoot, "glsl-grammar.txt"]);

	static var generatedParserPath = Path.join([projectRoot, 'glslparser', 'Parser.hx']);

	static function main() {
		var grammar = sys.io.File.getContent(grammarFile);


		var tokens = GrammarTokenizer.tokenize(grammar);

		//print tokens
		// for(t in tokens) trace(t.type);

		var ast = GrammarParser.parseTokens(tokens);

		var parserCode = ParserGenerator.generate(ast, 'glslparser', 'translation_unit');

		//save parser
		sys.io.File.saveContent(generatedParserPath, parserCode);

		trace('Parser generated as $generatedParserPath');
	}

	static function getProjectRoot(){
		var p = new sys.io.Process("git", ["rev-parse", "--show-toplevel"]);
		if(p.exitCode() != 0) return null;
		var result = p.stdout.readAll().toString();
		p.close();
		return result.substr(0, result.length-1);
	}
}