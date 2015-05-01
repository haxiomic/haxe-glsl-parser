import haxe.io.Path;

class Main{
	static var projectRoot = getProjectRoot();
	static var grammarFile = Path.join([projectRoot, 'grammars', 'GLES-100_pp_scope.txt']);

	static function main() {
		var grammar = sys.io.File.getContent(grammarFile);

		var tokens = GrammarTokenizer.tokenize(grammar);

		// /*print tokens */ for(t in tokens) trace(t.type);

		var ast = GrammarParser.parseTokens(tokens);

		//generate lemon grammar file
		var lemonGrammar = LemonGrammarGenerator.generate(ast, 'translation_unit');
		
		var grammarFilename = Path.withoutExtension(Path.withoutDirectory(grammarFile));
		var grammarDirectory = Path.directory(grammarFile);

		var savePath = Path.join([grammarDirectory, '$grammarFilename.lemon']);
		sys.io.File.saveContent(savePath, lemonGrammar);
		trace('Lemon grammar generated as $savePath');
	}

	static function getProjectRoot(){
		var p = new sys.io.Process("git", ["rev-parse", "--show-toplevel"]);
		if(p.exitCode() != 0) return null;
		var result = p.stdout.readAll().toString();
		p.close();
		return result.substr(0, result.length-1);
	}
}