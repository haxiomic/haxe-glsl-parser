/*
	@! Todo
	- Figure out how to use handleDirective on independant tokens

	#Notes
	Preprocessor syntax is handled by regex (is simple enough to allow this)

	------------------------------
		Directives
			#
			#define
			#undef
			#if
			#ifdef
			#ifndef
			#else
			#elif
			#endif
			#error
			#pragma
			#extension
			#version
			#line

		Operators
			defined - used as either:
				defined identifier
				defined ( identifier )

		Predefined Macros
			__LINE__  - will substitute a decimal integer constant that is one more than the number of preceding newlines in the current source string.

			__FILE__ - will substitute a decimal integer constant that says which source string number is currently being processed.

			__VERSION__ - will substitute a decimal integer reflecting the version number of the OpenGL ES shading language. (100 in this case for version 1.00)

			GL_ES - will be defined and set to 1
	------------------------------

	- Some preprocessor directives can only be evaluated on the target platform
	- Preprocessor directives should be stored on root note with position information so that they
		can be printed with the AST
	- Operators and predefined macros should remain as identifier tokens

	- define with a regular variable creates a new const in place? (in contrast to macro function definitions)
		alternatively, just paste the content in place?
	- define is literally just handling arbitrary text rather than expressions
	- macro functions identifiers can be found by tokenizing the function content

	- if's process only a simple subset of expressions and also paste in defines in place
		(tokenize content to find identifiers)

	- Can regular Composite variables be used in preprocessor expressions?
		> in #define, yes, any nonsense can be used - it's just pasting the text string in place
		> in #if, no, only Primitives may be used

	- "Undefined identifiers not consumed by the defined operator do not default to '0'. Use of such
	identifiers causes an error."

	- A separate operator function table _may_ be necessary to handle C-style operations
		(ie, 0 may be interchangeable with false for example)

	- defined operator is treaded as a built in macro (with different function call syntax)
		doesn't seem to exist in os x chrome's preprocessor?
		(handle it anyway)

	------------------------------
	Extra rules:
		__ reserved macros
*/

package glsl.parser;

import glsl.SyntaxTree;
import glsl.parser.Tokenizer;

using Preprocessor.PPTokensHelper;

class Preprocessor{

	static public var warnings:Array<String>;

	//data gathered by the preprocessor
	static public var version:Null<Int>;
	static public var pragmas:Array<String>;
	// static public var extensions:?<?> @! todo, extensions have an associated behavior parameter
	

	static var tokens:Array<Token>;
	static var i:Int;

	static var builtinMacros:Map<String, PPMacro> = [//@! todo
		'defined' => OperatorMacro,
		'__VERSION__' => BuiltinMacro( function(_) return Tokenizer.tokenize(Std.string(version)) ),
		'__LINE__' => BuiltinMacro( function(_) return Tokenizer.tokenize(Std.string(tokens[i].line)) ),
		'GL_ES' => UnresolveableMacro
	];
	static var userDefinedMacros:Map<String, PPMacro>;

	static public function preprocess(tokens:Array<Token>):Array<Token>{
		//make tokens available to other functions within class
		Preprocessor.tokens = tokens;

		//init state machine variables
		i = 0;
		userDefinedMacros = new Map<String, PPMacro>();
		warnings = [];

		version = 100; //default version number
		pragmas = [];

		while(i < Preprocessor.tokens.length){
			var token = Preprocessor.tokens[i];

			switch token.type {
				case PREPROCESSOR_DIRECTIVE:
					try{ processDirective(Preprocessor.tokens, i); }catch(e:String){ warn(e, token); }
				case IDENTIFIER:
					try{ processIdentifier(Preprocessor.tokens, i); }catch(e:String){ warn(e, token); }
				default:
			}

			i++;
		}

		//@! debug trace result
		trace(glsl.printer.Helper.TokenArrayPrinter.print(Preprocessor.tokens));
		return Preprocessor.tokens;
	}

	static function getMacro(id:String):PPMacro{
		var ppMacro:PPMacro;
		if((ppMacro = builtinMacros.get(id)) != null) return ppMacro;
		if((ppMacro = userDefinedMacros.get(id)) != null) return ppMacro;
		return null;
	}

	static function defineMacro(id:String, value:PPMacro){
		var existingMacro = getMacro(id);
		switch existingMacro {
			case BuiltinMacro(_) | UnresolveableMacro: throw 'redefinition of predefined macro';
			case OperatorMacro: throw 'redefinition of operator';
			case UserMacroObject(_), UserMacroFunction(_, _): throw 'macro redefinition';
			case null:
		}
		
		if(~/^__/.match(id)) throw 'macro name is reserved';
		userDefinedMacros.set(id, value);
	}

	static function undefineObject(id:String){
		var existingMacro = getMacro(id);
		switch existingMacro {
			case BuiltinMacro(_) | UnresolveableMacro: throw 'cannot undefine predefined macro';
			case OperatorMacro: throw 'cannot undefine operator';
			case UserMacroObject(_) | UserMacroFunction(_, _): userDefinedMacros.remove(id);
			case null:
		}
	}

	static function processDirective(tokens:Array<Token>, i:Int){
		var token = tokens[i];

		directiveTitleReg.match(token.data);
		var directiveTitle = directiveTitleReg.matched(1);
		var directiveContent = directiveTitleReg.matchedRight();
		directiveContent = StringTools.trim(directiveContent);
		//remove newline indicators '\'
		directiveContent = StringTools.replace(directiveContent, '\\\n', '\n');

		switch directiveTitle {
			case '':
			case 'define':
				//define macro
				try{
					evaluateMacroDefinition(directiveContent);
					tokens.deleteTokens(i);
				}catch(e:String){
					throw e;
				}

			case 'undef':     // @! todo
				throw 'directive #undef is not yet supported';

			case 'if':        // @! todo
				throw 'directive #if is not yet supported';

			case 'ifdef':     // @! todo
				throw 'directive #ifdef is not yet supported';

			case 'ifndef':    // @! todo
				throw 'directive #ifndef is not yet supported';

			case 'else':      // @! todo
				throw 'directive #else is not yet supported';

			case 'elif':      // @! todo
				throw 'directive #elif is not yet supported';

			case 'endif':     // @! todo
				throw 'directive #endif is not yet supported';

			case 'error':     // @! todo
				error('$directiveContent');
				tokens.deleteTokens(i);

			case 'pragma':
				if(~/^\s*STDGL(\s+|$)/.match(directiveContent))
					throw 'pragmas beginning with STDGL are reserved';

				pragmas.push(directiveContent);
				tokens.deleteTokens(i);

			case 'extension': // @! todo
				throw 'directive #extension is not yet supported';

			case 'version':
				//ensure there are no (non-skip) tokens before directive
				if(tokens.nextNonSkipToken(-1, i) == null){
					//extract version number with regex (strictly a string of digits)
					var versionNumRegex = ~/^(\d+)$/;
					var matched = versionNumRegex.match(directiveContent);
					if(matched){
						var numStr = versionNumRegex.matched(1);
						version = Std.parseInt(versionNumRegex.matched(1));
						tokens.deleteTokens(i);
					}else{
						switch directiveContent {
							case '':
								throw 'version number required';
							default:
								throw 'invalid version number \'$directiveContent\'';
						}
					}
				}else{
					throw '#version directive must occur before anything else, except for comments and whitespace';
				}

			case 'line':      // @! todo
				throw 'directive #line is not yet supported';

			default:
				throw 'unknown directive #\'$directiveTitle\'';
		}
	}

	static function processIdentifier(tokens:Array<Token>, i:Int, ?overrideMap:Map<String, PPMacro>){
		var token = tokens[i];
		//could be an operator or a macro
		var ppMacro = overrideMap == null ? getMacro(token.data) : overrideMap.get(token.data);
		if(ppMacro == null) return;

		//we have a PPMacro
		switch ppMacro {
			case UserMacroObject(newTokens):
					//delete identifier token (current token)
					tokens.deleteTokens(i, 1);
					//insert tokenized content
					tokens.insertTokens(i, newTokens);
					//step back one token to allow the first new token to be preprocessed
					i--;

			case UserMacroFunction(newTokens, parameters):
				try{
					var replacementTokens = newTokens.copy();

					//get function arguments
					var functionCall = tokens.readFunctionCall(i);
					//ensure number of arguments match
					if(functionCall.args.length != parameters.length){
						throw 'not enough arguments for macro';
					}

					//map parameter name to function call arguments
					var parameterMap = new Map<String, PPMacro>();
					for(i in 0...parameters.length)
						parameterMap.set(parameters[i], UserMacroObject(functionCall.args[i]));

					//replace IDENTIFIERS with function parameters
					for(j in 0...replacementTokens.length){
						if(replacementTokens[j].type.equals(TokenType.IDENTIFIER)){
							try{ processIdentifier(replacementTokens, j, parameterMap); }catch(e:String){ warn(e, token); }
						}
					}

					//delete function call
					tokens.deleteTokens(i, functionCall.len);
					//insert tokenized content
					tokens.insertTokens(i, replacementTokens);
					//step back one token to allow the first new token to be preprocessed
					i--;
				}catch(e:String){
					return; //identifier isn't a function call
				}
			case BuiltinMacro(func):
				var newTokens = func([]);
				//delete identifier token (current token)
				tokens.deleteTokens(i, 1);
				//insert tokenized content
				tokens.insertTokens(i, newTokens);
				//step back one token to allow the first new token to be preprocessed
				i--;

			case UnresolveableMacro:
				throw 'cannot resolve macro';
			default:
				throw 'unhanded object $ppMacro';
		}
	}


	static function evaluateMacroDefinition(definitionString:String):PPMacro{
		var macroNameReg = ~/^([a-z_]\w*)([^\w]|$)/i;

		if(macroNameReg.match(definitionString)){
			var macroName = macroNameReg.matched(1);
			var macroContent = '';
			var macroParameters = new Array<String>();

			var nextChar = macroNameReg.matched(2);

			var userMacro:PPMacro;

			inline function tokenizeContent(macroContent:String){
				macroContent = StringTools.trim(macroContent); //trim whitespace

				var tokenized = Tokenizer.tokenize(macroContent, function(warning:String){
					throw '$warning';
				}, function(error:String){
					throw '$error';
				});

				return tokenized;
			}

			switch nextChar {
				case '(': //function-like
					//match and extract parameters
					var parametersReg = ~/([^\)]*)\)/; //string between parentheses
					var parameterReg = ~/^\s*(([a-z_]\w*)?)\s*(,|$)/i; //individual parameters
					//(parameter name can be blank)
					var matchedRightParen = parametersReg.match(macroNameReg.matchedRight());
					if(matchedRightParen){
						var parameterString = parametersReg.matched(1);
						macroContent = parametersReg.matchedRight();

						//extract parameters
						var reachedLast = false;
						while(!reachedLast){
							if(parameterReg.match(parameterString)){
								//found parameter
								var parameterName = parameterReg.matched(1);
								var parameterNextChar = parameterReg.matched(3);
								macroParameters.push(parameterName);
								//advance
								parameterString = parameterReg.matchedRight();
								reachedLast = parameterNextChar != ',';
							}else{
								throw 'invalid macro parameter';
							}
						}
					}else{
						throw 'unmatched parentheses';
					}

					//create macro object
					userMacro = UserMacroFunction(tokenizeContent(macroContent), macroParameters);

				default:  //object-like
					macroContent = nextChar + macroNameReg.matchedRight();
					macroContent = StringTools.trim(macroContent); //trim whitespace

					//create macro object
					userMacro = UserMacroObject(tokenizeContent(macroContent));
			}

			defineMacro(macroName, userMacro);
			return userMacro;
		}else{
			throw 'invalid macro definition';
		}

		return null;
	}

	//Utils

	//Custom restricted expression evaluation
	static function evaluateExpr(expr:Expression){//@! todo
		/* Supported expressions
		 * ...
		 */
	}


	//Error Reporting
	static function warn(msg, ?info:Dynamic){
		var str = 'Preprocessor Warning: $msg';

		var line = Reflect.field(info, 'line');
		var col = Reflect.field(info, 'column');
		if(Type.typeof(line).equals(Type.ValueType.TInt)){
			str += ', line $line';
			if(Type.typeof(col).equals(Type.ValueType.TInt)){
				str += ', column $col';
			}
		}

		warnings.push(str);
	}

	static function error(msg, ?info:Dynamic){
		var str = 'Preprocessor Error: $msg';

		var line = Reflect.field(info, 'line');
		var col = Reflect.field(info, 'column');
		if(Type.typeof(line).equals(Type.ValueType.TInt)){
			str += ', line $line';
			if(Type.typeof(col).equals(Type.ValueType.TInt)){
				str += ', column $col';
			}
		}

		throw str;
	}

	//Preprocessor Data
	static var directiveTitleReg = ~/^#\s*([^\s]*)/;

	static var allowedBinaryOperators:Array<BinaryOperator> = [
		STAR,
		SLASH,
		PERCENT,
		PLUS,
		DASH,
		LEFT_OP,
		RIGHT_OP,
		LEFT_ANGLE,
		RIGHT_ANGLE,
		LE_OP,
		GE_OP,
		EQ_OP,
		NE_OP,
		AMPERSAND,
		CARET,
		VERTICAL_BAR,
		AND_OP,
		/* XOR_OP (^^) not allowed */
		OR_OP
	];

	static var allowedUnaryOperators:Array<UnaryOperator> = [
		PLUS,
		DASH,
		BANG,
		TILDE
	];
}

enum PPMacro{//@!
	UserMacroObject(content:Array<Token>);
	UserMacroFunction(content:Array<Token>, parameters:Array<String>);
	BuiltinMacro(func:Array<Array<Token>> -> Array<Token>);//function(args):Array<Token>
	OperatorMacro(); //@! incomplete
	UnresolveableMacro; 
}

class PPTokensHelper{
	static public function readFunctionCall(tokens:Array<Token>, start:Int):{ident:Token, args:Array<Array<Token>>, start:Int, len:Int}{
		//macrofunction (identifier, identifier, ...)
		var j = start;
		var ident = tokens[j];
		if(ident == null || ident.type != TokenType.IDENTIFIER){
			throw 'invalid function call';
		}

		var args:Array<Array<Token>> = [];
		//find matching parenthesis
		//open function
		var t:Token;
		do{
			t = tokens[++j]; //next token
			if(t == null) throw 'invalid function call';
		}while(Tokenizer.skippableTypes.indexOf(t.type) != -1);

		if(t.type.equals(TokenType.LEFT_PAREN)){
			//read args, taking care to match parentheses
			var argBuffer:Array<Token> = [];
			var t:Token;
			var level = 1;
			inline function pushArgs(){
				args.push(argBuffer);
				argBuffer = []; //flush arg buffer
			}
			do{
				t = tokens[++j];//next token
				if(t == null) throw 'expecting \')\'';
				if(Tokenizer.skippableTypes.indexOf(t.type) != -1) continue; //ignore skippable tokens
				switch t.type{
					case TokenType.LEFT_PAREN: level++;
					case TokenType.RIGHT_PAREN: level--;
					case TokenType.COMMA: if(level == 1) pushArgs(); else argBuffer.push(t);
					case null: throw '$t has no token type';
					case _: argBuffer.push(t);
				}
				//close parenthesis reached
				if(level <= 0){
					pushArgs();
					break;
				}
			}while(true);

			return {
				ident: ident,
				args: args,
				start: start,
				len: j - start + 1
			}
		}

		throw 'expecting \'(\'';
		return null;
	}

	static public function readOperatorArguments(){
		// @! todo
		//operator identifier
		//operator (identifier, identifier, ...)
	}

	//returns the token n tokens away from token start. Supports negative n
	static public function nextNonSkipToken(tokens:Array<Token>, n:Int = 1, start:Int):Token{
		var direction = n >= 0 ? 1 : -1;
		var j = start;
		var m = Math.abs(n);
		var t:Token;
		while(m > 0){
			j += direction;//advance token
			t = tokens[j];
			if(t == null) break;
			if(Tokenizer.skippableTypes.indexOf(t.type) != -1)//skip over token
				continue;
			m--;
		}
		return t;
	}

	static public function deleteTokens(tokens:Array<Token>, start:Int, count:Int = 1){
		return tokens.splice(start, count);
	}

	static public function insertTokens(tokens:Array<Token>, start:Int, newTokens:Array<Token>){
		var j = newTokens.length;
		while(--j >= 0) tokens.insert(start, newTokens[j]);
		return tokens;
	}
}

//PP Tokenizer
// typedef PPToken = {
// 	var type:PPTokenType;
// 	var data:String;
// 	@:optional var position:Int;
// 	@:optional var line:Int;
// 	@:optional var column:Int;
// }

// enum PPTokenType{
// 	DIRECTIVE_TITLE;
// 	IDENTIFIER;
// 	LEFT_PAREN;
// 	RIGHT_PAREN;
// 	COMMA;
// 	WHITESPACE;
// 	OTHER;
// }

// class PreprocessorTokenizer{

// 	static public var warnings:Array<String>;
// 	@:noCompletion
// 	static public var verbose:Bool = false;

// 	//state machine data
// 	static var tokens:Array<PPToken>;

// 	static var i:Int;             // scan position
// 	static var last_i:Int;
// 	static var line:Int;          // scan position line & col
// 	static var col:Int;
// 	static var lineStart:Int;     // current token's starting line & col  
// 	static var colStart:Int;
// 	static var mode:ScanMode;
// 	static var buf:String;        // current string buffer

// 	static public function tokenize(source:String):Array<PPToken>{
// 		//init
// 		tokens = [];
// 		i = 0;
// 		line = 1;
// 		col = 1;
// 		warnings = [];

// 		return tokens;
// 	}

// }

// enum ScanMode{}