typedef Token = {
	var type:TokenType;
	var data:String;
	@:optional var position:Int;
	@:optional var line:Int;
	@:optional var column:Int;
}

enum TokenType {
	DIRECTIVE;
	CODE_BLOCK;
	RULE_DECL;
	RULE;
	TOKEN;
	WORD;
	NUMBER;
	EMPTY;
	PERIOD;
	LINE_COMMENT;
	BLOCK_COMMENT;
	SPACE;
	NEWLINE;
}

class GrammarTokenizer{

	static var i:Int = 0;
	static var line:Int;
	static var col:Int;
	static var source:String;

	static var tokens:Array<Token>;

	static public function tokenize(source:String):Array<Token>{
		GrammarTokenizer.source = source;
		i = 0;
		line = 1;
		col = 1;
		tokens = [];

		while(i < source.length)
			root();

		//append newline to end if not already (simplifies the grammar so we don't have to introduce an EOF token)
		if(tokens[tokens.length - 1].type != NEWLINE)
			buildToken(NEWLINE, '\n');

		return tokens;
	}

	static function nextString(length:Int){
		return source.substr(i, length);
	}

	static function advance(n:Int = 1){
		var last_i = i;
		var buf = "";
		while(n-- > 0 && i < source.length){
			buf += source.charAt(i);
			i++;
		}

		//track new lines between last_i and i
		var splitByLines = ~/\n/gm.split(source.substring(last_i, i));
		var nl = splitByLines.length - 1;
		if(nl > 0){
			line += nl;
			col = splitByLines[nl].length + 1;
		}else{
			col+= i - last_i;
		}

		return buf;
	}

	static function tryToken(tokenFunction:Void->Bool){
		var i_save = i, line_save = line, col_save = col;
		if(tokenFunction()) return true;
		i = i_save; line = line_save; col = col_save;
		return false;
	}

	//token functions
	static function root(){
		if(tryToken(space)) return;
		if(tryToken(newline)) return;
		if(tryToken(block_comment)) return;
		if(tryToken(line_comment)) return;
		if(tryToken(number)) return;
		if(tryToken(code_block)) return;
		if(tryToken(directive)) return;
		if(tryToken(rule_decl)) return;
		if(tryToken(rule)) return;
		if(tryToken(token)) return;
		if(tryToken(word)) return;
		if(tryToken(empty)) return;
		if(tryToken(period)) return;

		warn("unhandled token " + source.charAt(i));
		advance(1);
	}

	static function space(){
		var s = "";
		while(spaceRegex.match(nextString(1))) s += advance(1);

		if(s.length > 0){
			buildToken(SPACE, s);
			return true;
		}

		return false;
	}

	static function newline(){
		var s = "";
		while(nextString(1) == "\n") s += advance(1);
		if(s.length > 0){
			buildToken(NEWLINE, s);
			return true;
		}
		return false;
	}

	static function block_comment(){
		if(nextString(2) == "/*"){
			var s = "";
			while(nextString(2) != "*/") s += advance(1);
			s += advance(2);

			buildToken(BLOCK_COMMENT, s);
			return true;
		}
		return false;
	}

	static function line_comment(){
		if(nextString(2) == "//"){
			var s = "";
			while(nextString(1) != "\n") s += advance(1);
			buildToken(LINE_COMMENT, s);
			return true;
		}
		return false;
	}

	static function number(){
		var s = "", c = "";
		var digits = 0;
		var dots = 0;
		while(true){
			c = nextString(1);

			if(~/\d/.match(c)){
				digits++;
			}else if(c == '.'){
				dots++;
				if(dots > 1) break;
			}else{
				break;
			}

			s += advance(1);
		}
		if(digits > 0){
			buildToken(NUMBER, s);
			return true;
		}
		return false;
	}

	static function code_block(){
		if(nextString(1) == "{"){
			var lastOpen = line;
			var s = advance(1);
			var level = 1;
			while(level > 0){
				var c = advance(1);
				switch c{
					case '{': level++; lastOpen = line;
					case '}': level--;
					case null, '':	//reached eof without exiting code block
						//temporarily change line info for better reporting
						var lineOld = line;
						line = lastOpen;
						warn('unmatched parentheses');
						line = lineOld;
						return false;
				}
				s += c;
			}
			buildToken(CODE_BLOCK, s);
			return true;
		}
		return false;
	}

	static function directive(){
		var s = "";
		if((s = advance(1)) == "%"){
			//read name
			while(directiveNameRegex.match(nextString(1))) s += advance(1);
			buildToken(DIRECTIVE, s);
			return true;
		}
		return false;
	}

	static function rule_decl(){
		var s = "";
		var previousCharacter = source.charAt(i-1);
		while(ruleRegex.match(nextString(1))) s += advance(1);
		if(s.length > 0){
			s += advance(1);
			if(s.charAt(s.length-1) != ':') return false;

			if(previousCharacter != '\n' && previousCharacter != '')
				warn('rule declarations must begin on a new line');
			buildToken(RULE_DECL, s);
			return true;
		}
		return false;
	}

	static function rule(){
		var s = "";
		while(ruleRegex.match(nextString(1))) s += advance(1);
		if(s.length > 0){
			if(~/\w/i.match(nextString(1))) return false; //next character cannot be another word character
			buildToken(RULE, s);
			return true;
		}
		return false;
	}

	static function token(){
		var s = "";
		while(tokenRegex.match(nextString(1))) s += advance(1);
		if(s.length > 0){
			if(~/\w/i.match(nextString(1))) return false; //next character cannot be another word character
			buildToken(TOKEN, s);
			return true;
		}
		return false;
	}

	static function word(){
		var s = "";
		while(~/\w/i.match(nextString(1))) s += advance(1);
		if(s.length > 0){
			buildToken(WORD, s);
			return true;
		}
		return false;
	}

	static function empty(){
		var emptyStr = '*empty*';
		var s = "";
		if((s = advance(emptyStr.length)) == emptyStr){
			buildToken(EMPTY, s);
			return true;
		}
		return false;
	}

	static function period(){
		if(nextString(1) == '.'){
			buildToken(PERIOD, advance(1));
			return true;
		}
		return false;
	}

	static function buildToken(type:TokenType, data:String){
		if(type == null) error('cannot have null token type');
		if(data == '') error('cannot have empty token data');
		var token:Token = {
			type: type,
			data: data,
			line: line,
			column: col,
			position: i - data.length
		}
		tokens.push(token);
	}

	//Error Reporting
	static function warn(msg){
		trace('Tokenizer Warning: $msg, line $line');
	}

	static function error(msg){
		throw 'Tokenizer Error: $msg, line $line';
	}

	static var spaceRegex = ~/[ \t]/;
	// static var whitespaceRegex = ~/\s/;
	static var ruleRegex = ~/[a-z0-9_]/;
	static var directiveNameRegex = ~/[a-z0-9_]/;
	static var tokenRegex = ~/[A-Z0-9_]/;
}