/*
	Based on GLSL ES 1.0 Spec
	https://www.khronos.org/files/opengles_shading_language.pdf

	@author George Corney
	
	* Scan and read ahead technique
*/

package glsl.parser;

typedef Token = {
	var type:TokenType;
	var data:String;
	@:optional var position:Int;
	@:optional var line:Int;
	@:optional var column:Int;
}

enum TokenType{
	//keywords
	ATTRIBUTE; CONST; BOOL; FLOAT; INT;
	BREAK; CONTINUE; DO; ELSE; FOR; IF; DISCARD; RETURN;
	BVEC2; BVEC3; BVEC4; IVEC2; IVEC3; IVEC4; VEC2; VEC3; VEC4;
	MAT2; MAT3; MAT4; IN; OUT; INOUT; UNIFORM; VARYING; SAMPLER2D; SAMPLERCUBE;
	STRUCT; VOID; WHILE;

	INVARIANT;
	HIGH_PRECISION; MEDIUM_PRECISION; LOW_PRECISION; PRECISION;

	BOOLCONSTANT;

	//operators
	LEFT_OP; RIGHT_OP; INC_OP; DEC_OP; 
	LE_OP; GE_OP; EQ_OP; NE_OP; AND_OP; OR_OP; XOR_OP; 
	MUL_ASSIGN; DIV_ASSIGN; ADD_ASSIGN; MOD_ASSIGN; SUB_ASSIGN; 
	LEFT_ASSIGN; RIGHT_ASSIGN; AND_ASSIGN; XOR_ASSIGN; OR_ASSIGN; 
	LEFT_PAREN; RIGHT_PAREN; LEFT_BRACKET; RIGHT_BRACKET; LEFT_BRACE; RIGHT_BRACE; 
	DOT; COMMA; COLON; EQUAL; SEMICOLON; BANG; DASH; TILDE; PLUS; STAR; SLASH; PERCENT; 
	LEFT_ANGLE; RIGHT_ANGLE; VERTICAL_BAR; CARET; AMPERSAND; QUESTION;

	//identifier
	IDENTIFIER; TYPE_NAME; FIELD_SELECTION;

	//integer-constant
	INTCONSTANT;
	
	//floating-constant
	FLOATCONSTANT; 

	//other
	WHITESPACE;             // (non-spec)
	BLOCK_COMMENT;          // (non-spec)
	LINE_COMMENT;           // (non-spec)
	PREPROCESSOR_DIRECTIVE; // (non-spec)
	RESERVED_KEYWORD;       // (non-spec)
}


class Tokenizer{

	static public var warnings:Array<String>;
	@:noCompletion
	static public var verbose:Bool = false;

	static var onWarn:String->Void;
	static var onError:String->Void;

	//state machine data
	static var tokens:Array<Token>;

	static var i:Int;             // scan position
	static var last_i:Int;
	static var line:Int;          // scan position line & col
	static var col:Int;
	static var lineStart:Int;     // current token's starting line & col  
	static var colStart:Int;
	static var mode:ScanMode;
	static var buf:String;        // current string buffer

	static var userDefinedTypes:Array<String>;

	static var source:String;

	static public function tokenize(source:String, ?onWarn:String->Void, ?onError:String->Void):Array<Token>{
		Tokenizer.source = source;
		Tokenizer.onWarn = onWarn;
		Tokenizer.onError = onError;

		//init
		tokens = [];
		i = 0;
		line = 1;
		col = 1;
		userDefinedTypes = [];
		warnings = [];

		mode = UNDETERMINED;

		var lastMode:ScanMode;
		while(i < source.length || mode != UNDETERMINED){
			lastMode = mode;

			//handle mode
			switch (mode) {
				case UNDETERMINED: determineMode();
				case PREPROCESSOR_DIRECTIVE: preprocessorMode();
				case BLOCK_COMMENT: blockCommentMode();
				case LINE_COMMENT: lineCommentMode();
				case WHITESPACE: whitespaceMode();
				case OPERATOR: operatorMode();
				case LITERAL: literalMode();

				case FLOATING_CONSTANT: floatingConstantMode();
				case FRACTIONAL_CONSTANT: fractionalConstantMode();
				case EXPONENT_PART: exponentPartMode();

				case HEX_CONSTANT,
					 OCTAL_CONSTANT,
					 DECIMAL_CONSTANT: integerConstantMode();
				default:
					error('unhandled mode ' + Std.string(mode));
			}

			if(mode == lastMode && i == last_i){//entered infinite loop
				error('unclosed mode $mode');
				break;
			}
		}

		//identify type references
		//this is somewhat of a hack but the spec requires type references to be identified before grammar parsing
		for(j in 0...tokens.length){
			var t = tokens[j];

			if(t.type != IDENTIFIER) continue;
			//record a new type if it's a type definition 
			var previousTokenType = null;
			var k = j - 1;
			while(k >= 0 && previousTokenType == null){
				var tt = tokens[k--].type;
				if(skippableTypes.indexOf(tt) == -1) previousTokenType = tt;
			}

			if(previousTokenType == STRUCT){
				userDefinedTypes.push(t.data);
				continue;
			}

			if(userDefinedTypes.indexOf(t.data) != -1){
				//check if next token is identifier or left paren
				var nextTokenType = null;
				var k = j+1;
				while(k < tokens.length && nextTokenType == null){
					var tt = tokens[k++].type;
					if(skippableTypes.indexOf(tt) == -1) nextTokenType = tt;
				}

				if(nextTokenType == IDENTIFIER || nextTokenType == LEFT_PAREN || nextTokenType == LEFT_BRACKET)
					t.type = TYPE_NAME;
			}
		}

		return tokens;
	}

	static inline function startLen(m:ScanMode):Null<Int> return startConditionsMap.get(m)();
	static inline function isStart(m:ScanMode):Bool return startLen(m) != null;
	static inline function isEnd(m:ScanMode):Bool return endConditionsMap.get(m)();

	static function tryMode(m:ScanMode):Bool{
		var n = startLen(m); 
		if(n != null){
			mode = m;
			advance(n);
			return true;
		}
		return false;
	}

	static function advance(n:Int = 1){
		last_i = i;

		while(n-- > 0 && i < source.length){
			buf += c(i);
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
	}

	//Mode Functions
	static function determineMode(){
		buf = '';//flush buffer
		lineStart = line;
		colStart = col;

		if(tryMode(BLOCK_COMMENT)) return;
		if(tryMode(LINE_COMMENT)) return;
		if(tryMode(PREPROCESSOR_DIRECTIVE)) return;
		if(tryMode(WHITESPACE)) return;
		if(tryMode(LITERAL)) return;

		//FRACTIONAL_CONSTANT
		if(tryMode(FLOATING_CONSTANT)) return;

		if(tryMode(OPERATOR)) return;

		//INTEGER_CONSTANT
		if(tryMode(HEX_CONSTANT)) return;
		if(tryMode(OCTAL_CONSTANT)) return;
		if(tryMode(DECIMAL_CONSTANT)) return;


		warn('unrecognized token '+c(i));
		mode = UNDETERMINED;
		advance();
		return;
	}

	static function preprocessorMode(){
		if(isEnd(mode)){
			buildToken(TokenType.PREPROCESSOR_DIRECTIVE);
			mode = UNDETERMINED;
			return;
		}
		advance();
	}

	static function blockCommentMode(){
		if(isEnd(mode)){
			buildToken(TokenType.BLOCK_COMMENT);
			mode = UNDETERMINED;
			return;
		}
		advance();
	}

	static function lineCommentMode(){
		if(isEnd(mode)){
			buildToken(TokenType.LINE_COMMENT);
			mode = UNDETERMINED;
			return;
		}
		advance();
	}

	static function whitespaceMode(){
		if(isEnd(mode)){
			buildToken(TokenType.WHITESPACE);
			mode = UNDETERMINED;
			return;
		}
		advance();
	}

	static function operatorMode(){
		if(isEnd(mode)){
			buildToken(operatorMap.get(buf));
			mode = UNDETERMINED;
			return;
		}
		advance();
	}

	static function literalMode(){
		if(isEnd(mode)){
			var tt:TokenType = null;
			//in order of priority
			//check if it's a keyword
			tt = literalKeywordMap.get(buf);
			//check if it's a field selection
			if(tt == null && previousTokenType() == DOT) tt = FIELD_SELECTION;
			//otherwise it must be an identifier
			if(tt == null) tt = IDENTIFIER;

			buildToken(tt);
			mode = UNDETERMINED;
			return;
		}
		advance();
	}

	static var floatMode = 0;//0 (unset), 1 (mode 1), 2 (mode 2), 3 (complete)
	static function floatingConstantMode(){		
		switch (floatMode) {
			case 0:
				if(tryMode(FRACTIONAL_CONSTANT)){
					floatMode = 1;
					return;
				}
				//collect leading digits
				var j = i;
				while(~/[0-9]/.match(c(i))) advance();
				if(i > j){
					floatMode = 2;
					return;
				}
				error('error parsing float, could not determine floatMode');
			case 1:
				floatMode = 3;
				if(tryMode(EXPONENT_PART)) return;
			case 2:
				if(tryMode(EXPONENT_PART)){
					floatMode = 3;
					return;
				}
				else error('float in floatMode 2 must have exponent part - none found');
		}

		if(isEnd(mode)){
			buildToken(TokenType.FLOATCONSTANT);
			mode = UNDETERMINED;
			floatMode = 0;
			return;
		}

		error('error parsing float');
	}

	static function fractionalConstantMode(){
		if(isEnd(mode)){
			mode = FLOATING_CONSTANT;
			return;
		}
		advance();
	}

	static function exponentPartMode(){
		if(isEnd(mode)){
			mode = FLOATING_CONSTANT;
			return;
		}
		advance();
	}

	static function integerConstantMode(){
		if(isEnd(mode)){
			buildToken(TokenType.INTCONSTANT);
			mode = UNDETERMINED;
			return;
		}
		advance();
	}

	//end mode functions

	static function buildToken(type:TokenType){
		if(type == null) error('cannot have null token type');
		if(buf == '') error('cannot have empty token data');
		var token:Token = {
			type: type,
			data: buf,
			line: lineStart,
			column: colStart,
			position: i - buf.length
		}
		if(verbose) trace('building token $type ($buf)');
		tokens.push(token);
		if(type == RESERVED_KEYWORD) warn('using reserved keyword $buf');
	}

	//Utils
	static inline function c(j:Int){
		return source.charAt(j);
	}

	static function previousToken(n:Int = 0, ignoreSkippable:Bool = false){
		if(!ignoreSkippable) return tokens[-n + tokens.length - 1];
		else{
			var t:Token = null, i = 0;
			while(n >= 0 && i < tokens.length){
				t = tokens[-i + tokens.length - 1];
				if(skippableTypes.indexOf(t.type) == -1) n--;
				i++;
			}
			return t;
		}
	}

	static function previousTokenType(n:Int = 0, ?ignoreSkippable:Bool):TokenType{
		var pt = previousToken(n, ignoreSkippable);
		return pt != null ? pt.type : null;
	}

	//Error Reporting
	static function warn(msg){
		if(onWarn != null) onWarn(msg);
		else warnings.push('Tokenizer Warning: $msg, line $line, column $col');
	}

	static function error(msg){
		if(onError != null) onError(msg);
		else throw 'Tokenizer Error: $msg, line $line, column $col';
	}


/*  -------- Tokenizer Data -------- */
/*
--- Mode Conditions ---
format: MODE_NAME open_conditions, ...		close_conditions, ...
the order of modes is important
-----------------------

BLOCK_COMMENT; /*   *\/
LINE_COMMENT;  //   [^\\]\n,

PREPROCESSOR_DIRECTIVE;  #    [^\\]\n
WHITESPACE;    \s   ^\s

OPERATOR;      operatorRegex && anyOperator search
LITERAL;       \w               ^[\w\d]

INTEGER_CONSTANT: OCTAL_CONSTANT | DECIMAL_CONSTANT | HEX_CONSTANT
    OCTAL_CONSTANT;     0octalRegex     ^octalRegex
    DECIMAL_CONSTANT;   [0-9]           ^\d
    HEX_CONSTANT;       0[xX]hexRegex   ^hexRegex   
    
FLOATING_CONSTANT: FRACTIONAL_CONSTANT EXPONENT_PART? | \d+ EXPONENT_PART
    FRACTIONAL_CONSTANT; \d+\.              ^\d 
                         \.\d               ^\d
    EXPONENT_PART;       [eE][+-]?\d        ^\d
*/
	//single character patterns
	static var operatorRegex = ~/[&<=>|*?!+%(){}.~:,;\/\-\^\[\]]/;

	//mode conditions
	//returns either the length of the matched start string (starting from i) or null for invalid starting point
	static var startConditionsMap:Map<ScanMode, Void->Null<Int>> = [
		BLOCK_COMMENT          => function() return source.substring(i, i+2) == '/*'               ? 2 : null,
		LINE_COMMENT           => function() return source.substring(i, i+2) == '//'               ? 2 : null,
		PREPROCESSOR_DIRECTIVE => function(){
			// return c(i) == '#' ? 1 : null;
			//a preprocessor directives # can only be proceeded with whitespace within its line
			if(c(i) == '#'){
				var j = i - 1;
				while(c(j) != '\n' && c(j) != ''){
					if(!~/\s/.match(c(j))) return null;//non-whitespace character found between # and line start
					j--;
				}
				return 1;
			}
			
			return null;
		},
		WHITESPACE             => function() return ~/\s/.match(c(i))                              ? 1 : null,
		OPERATOR               => function() return operatorRegex.match(c(i))                      ? 1 : null,
		LITERAL                => function() return ~/[a-z_]/i.match(c(i))                         ? 1 : null,

		HEX_CONSTANT           => function() return ~/0x[a-f0-9]/i.match(source.substring(i, i+3)) ? 3 : null,
		OCTAL_CONSTANT         => function() return ~/0[0-7]/.match(source.substring(i, i+2))      ? 2 : null,
		DECIMAL_CONSTANT       => function() return ~/[0-9]/.match(c(i))                           ? 1 : null,

		FLOATING_CONSTANT      => function(){
			//first mode: FRACTIONAL_CONSTANT EXPONENT_PART?
			if(isStart(FRACTIONAL_CONSTANT)) return 0;//return fl;
			//second mode: \d+ EXPONENT_PART
			var j = i;
			while(~/[0-9]/.match(c(j))) j++;//match sequence of digits
			var _i = i;i = j;//temporary move i to j to test start
			var exponentFollows = isStart(EXPONENT_PART);
			i = _i;//return i to original place
			if(j > i && exponentFollows) return 0;//return ++j - i; 
			return null;
		},
		FRACTIONAL_CONSTANT    => function() {
			var j = i;
			while(~/[0-9]/.match(c(j))) j++;
			if(j > i && c(j) == '.') return ++j - i; //\d+\.
			return ~/\.\d/.match(source.substring(i, i+2)) ? 2 : null; //\.\d
		},
		EXPONENT_PART          => function(){
			var r = ~/^[e][+-]?\d/i;
			return r.match(source.substring(i, i+3)) ? r.matched(0).length : null;
		}
	];
	static var endConditionsMap:Map<ScanMode, Void->Bool> = [
		BLOCK_COMMENT          => function() return source.substring(i-2,i) == '*/',
		LINE_COMMENT           => function() return c(i) == '\n' || c(i) == '',
		PREPROCESSOR_DIRECTIVE => function() return (c(i) == '\n' && c(i-1) != '\\') || c(i) == '',
		WHITESPACE             => function() return !~/\s/.match(c(i)),
		OPERATOR               => function() return !operatorMap.exists(buf+c(i)) || c(i) == '',
		LITERAL                => function() return !~/[a-z0-9_]/i.match(c(i)),

		HEX_CONSTANT           => function() return !~/[a-f0-9]/i.match(c(i)),
		OCTAL_CONSTANT         => function() return !~/[0-7]/.match(c(i)),
		DECIMAL_CONSTANT       => function() return !~/[0-9]/.match(c(i)),

		FLOATING_CONSTANT 	   => function() return !~/[0-9]/.match(c(i)),
		FRACTIONAL_CONSTANT    => function() return !~/[0-9]/.match(c(i)),
		EXPONENT_PART          => function() return !~/[0-9]/.match(c(i))
	];

	static var operatorMap:Map<String, TokenType> = [
		'<<' => LEFT_OP, '>>' => RIGHT_OP, '++' => INC_OP, '--' => DEC_OP, 
		'<=' => LE_OP, '>=' => GE_OP, '==' => EQ_OP, '!=' => NE_OP, '&&' => AND_OP, '||' => OR_OP, '^^' => XOR_OP, 
		'*=' => MUL_ASSIGN, '/=' => DIV_ASSIGN, '+=' => ADD_ASSIGN, '%=' => MOD_ASSIGN, '-=' => SUB_ASSIGN,
		'<<=' => LEFT_ASSIGN, '>>=' => RIGHT_ASSIGN, '&=' => AND_ASSIGN, '^=' => XOR_ASSIGN, '|=' => OR_ASSIGN,

		'(' => LEFT_PAREN, ')' => RIGHT_PAREN, '[' => LEFT_BRACKET, ']' => RIGHT_BRACKET, '{' => LEFT_BRACE, '}' => RIGHT_BRACE,
		'.' => DOT, ',' => COMMA, ':' => COLON, '=' => EQUAL, ';' => SEMICOLON, '!' => BANG, '-' => DASH, '~' => TILDE, '+' => PLUS, '*' => STAR, '/' => SLASH, '%' => PERCENT,
		'<' => LEFT_ANGLE, '>' => RIGHT_ANGLE, '|' => VERTICAL_BAR, '^' => CARET, '&' => AMPERSAND, '?' => QUESTION
	];

	static var literalKeywordMap:Map<String, TokenType> = [
		'attribute'           => ATTRIBUTE,
		'uniform'             => UNIFORM,
		'varying'             => VARYING,
		'const'               => CONST,

		'void'                => VOID,
		
		'int'                 => INT,
		'float'               => FLOAT,
		'bool'                => BOOL,
		'vec2'                => VEC2,
		'vec3'                => VEC3,
		'vec4'                => VEC4,
		'bvec2'               => BVEC2,
		'bvec3'               => BVEC3,
		'bvec4'               => BVEC4,
		'ivec2'               => IVEC2,
		'ivec3'               => IVEC3,
		'ivec4'               => IVEC4,
		'mat2'                => MAT2,
		'mat3'                => MAT3,
		'mat4'                => MAT4,
		'sampler2D'           => SAMPLER2D,
		'samplerCube'         => SAMPLERCUBE,

		'break'               => BREAK,
		'continue'            => CONTINUE,
		'while'               => WHILE,
		'do'                  => DO,
		'for'                 => FOR,
		'if'                  => IF,
		'else'                => ELSE,
		'return'              => RETURN,
		'discard'             => DISCARD,
		'struct'              => STRUCT,

		'in'                  => IN,
		'out'                 => OUT,
		'inout'               => INOUT,

		'invariant'           => INVARIANT,
		'precision'           => PRECISION,
		'highp'               => HIGH_PRECISION,
		'mediump'             => MEDIUM_PRECISION,
		'lowp'                => LOW_PRECISION,

		'true'                => BOOLCONSTANT,
		'false'               => BOOLCONSTANT,

		//future
		'asm'                 => RESERVED_KEYWORD,
		'class'               => RESERVED_KEYWORD,
		'union'               => RESERVED_KEYWORD,
		'enum'                => RESERVED_KEYWORD,
		'typedef'             => RESERVED_KEYWORD,
		'template'            => RESERVED_KEYWORD,
		'this'                => RESERVED_KEYWORD,
		'packed'              => RESERVED_KEYWORD,
		'goto'                => RESERVED_KEYWORD,
		'switch'              => RESERVED_KEYWORD,
		'default'             => RESERVED_KEYWORD,
		'inline'              => RESERVED_KEYWORD,
		'noinline'            => RESERVED_KEYWORD,
		'volatile'            => RESERVED_KEYWORD,
		'public'              => RESERVED_KEYWORD,
		'static'              => RESERVED_KEYWORD,
		'extern'              => RESERVED_KEYWORD,
		'external'            => RESERVED_KEYWORD,
		'interface'           => RESERVED_KEYWORD,
		'long'                => RESERVED_KEYWORD,
		'short'               => RESERVED_KEYWORD,
		'double'              => RESERVED_KEYWORD,
		'half'                => RESERVED_KEYWORD,
		'fixed'               => RESERVED_KEYWORD,
		'unsigned'            => RESERVED_KEYWORD,
		'input'               => RESERVED_KEYWORD,
		'output'              => RESERVED_KEYWORD,
		'hvec2'               => RESERVED_KEYWORD,
		'hvec3'               => RESERVED_KEYWORD,
		'hvec4'               => RESERVED_KEYWORD,
		'dvec2'               => RESERVED_KEYWORD,
		'dvec3'               => RESERVED_KEYWORD,
		'dvec4'               => RESERVED_KEYWORD,
		'fvec2'               => RESERVED_KEYWORD,
		'fvec3'               => RESERVED_KEYWORD,
		'fvec4'               => RESERVED_KEYWORD,
		'sampler1DShadow'     => RESERVED_KEYWORD,
		'sampler2DShadow'     => RESERVED_KEYWORD,
		'sampler2DRect'       => RESERVED_KEYWORD,
		'sampler3DRect'       => RESERVED_KEYWORD,
		'sampler2DRectShadow' => RESERVED_KEYWORD,
		'sizeof'              => RESERVED_KEYWORD,
		'cast'                => RESERVED_KEYWORD,
		'namespace'           => RESERVED_KEYWORD,
		'using'               => RESERVED_KEYWORD
	];

	static public var skippableTypes(default, null):Array<TokenType> = [WHITESPACE, BLOCK_COMMENT, LINE_COMMENT];
}

private enum ScanMode{
	UNDETERMINED;

	//non-spec
	BLOCK_COMMENT;
	LINE_COMMENT;
	PREPROCESSOR_DIRECTIVE;
	WHITESPACE;

	//token classes
	OPERATOR;
	LITERAL;
	INTEGER_CONSTANT;
		DECIMAL_CONSTANT;
		HEX_CONSTANT;
		OCTAL_CONSTANT;
	FLOATING_CONSTANT;
		FRACTIONAL_CONSTANT;
		EXPONENT_PART;
}