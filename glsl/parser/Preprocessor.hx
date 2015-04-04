/*
	@! Todo
	- Unresolveable macros should result in tokens being left unchanged
	- Use of Tokenizer should be replaced with PPTokenizer

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

	- defined operator is only available in macro expressions!

	------------------------------
	Extra rules:
		__ reserved macros
*/

package glsl.parser;

import glsl.SyntaxTree;

using Preprocessor.PPTokensHelper;
using glsl.printer.Helper;

class Preprocessor{

	static public var warnings:Array<String>;

	//data gathered by the preprocessor
	static public var version:Null<Int>;
	static public var pragmas:Array<String>;
	// static public var extensions:?<?> @! todo, extensions have an associated behavior parameter

	static var tokens:Array<PPToken>;
	static var i:Int;

	static var builtinMacros:Map<String, PPMacro> = [
		'__VERSION__' => BuiltinMacroObject( function() return Std.string(version) ),
		'__LINE__' => BuiltinMacroObject( function() return Std.string(tokens[i].line) ), //line of current token
		'__FILE__' => UnresolveableMacro, //@! this should be left to the real compiler (however, it's not a critical issue)
		'GL_ES' => UnresolveableMacro
	];
	static var userDefinedMacros:Map<String, PPMacro>;

	static public function preprocess(input:String):String{
		//make tokens available to other functions within class
		tokens = PPTokenizer.tokenize(input);

		//init state machine variables
		i = 0;
		userDefinedMacros = new Map<String, PPMacro>();
		warnings = [];

		version = 100; //default version number
		pragmas = [];

		while(i < tokens.length){
			var token = tokens[i];

			switch token.type {
				case PREPROCESSOR_DIRECTIVE:
					try{ processDirective(tokens, i); }catch(e:String){ warn(e, token); }
				case IDENTIFIER:
					try{ 
						if(processIdentifier(tokens, i) != null){ //identifier processed
							//step back one token to allow the first new token to be preprocessed
							i--;
						}
					}catch(e:String){ warn(e, token); }
				default:
			}

			i++;
		}

		//@! debug trace result
		trace(tokens.print());
		return tokens.print();
	}

	static function getMacro(id:String):PPMacro{
		var ppMacro:PPMacro;
		if((ppMacro = builtinMacros.get(id)) != null) return ppMacro;
		if((ppMacro = userDefinedMacros.get(id)) != null) return ppMacro;
		return null;
	}

	static function defineMacro(id:String, ppMacro:PPMacro){
		var existingMacro = getMacro(id);
		switch existingMacro {
			case BuiltinMacroObject(_) | BuiltinMacroFunction(_, _) | UnresolveableMacro: throw 'redefinition of predefined macro';
			case UserMacroObject(_), UserMacroFunction(_, _): throw 'macro redefinition';
			case null:
		}

		if(~/^__/.match(id)) throw 'macro name is reserved';
		if(ppMacro == null) throw 'null macro definitions are not allowed';

		userDefinedMacros.set(id, ppMacro);

		//check for recursion and undefine macro if discovered
		switch ppMacro{
			case UserMacroObject(content), UserMacroFunction(content, _):
				var macroTokens = PPTokenizer.tokenize(content);
				var j = 0;
				//expand macros and search for ppMacro
				while(j < macroTokens.length){
					if(macroTokens[j].type.equals(PPTokenType.IDENTIFIER)){
						var processedPPMacro = processIdentifier(macroTokens, j);
						if(processedPPMacro != null) j--;//macro expanded, step back once to process new tokens
						if(ppMacro.equals(processedPPMacro)){
							//macro contains itself - remove and throw
							undefineObject(id);
							throw 'macro contains recursion';
						}
					}
					j++;
				}

			default:
		}
	}

	static function undefineObject(id:String){
		var existingMacro = getMacro(id);
		switch existingMacro {
			case BuiltinMacroObject(_) | BuiltinMacroFunction(_, _) | UnresolveableMacro: throw 'cannot undefine predefined macro';
			case UserMacroObject(_) | UserMacroFunction(_, _): userDefinedMacros.remove(id);
			case null:
		}
	}

	static function isMacroDefined(id:String):Bool{
		return getMacro(id) != null;
	}

	static function processDirective(tokens:Array<PPToken>, i:Int){
		var token = tokens[i];

		inline function getDirectiveTitle(t:PPToken){
			directiveTitleReg.match(t.data);
			return directiveTitleReg.matched(1);
		}

		var directiveTitle = getDirectiveTitle(token);
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

			case 'undef':
				if(macroNameReg.match(directiveContent)){
					var macroName = macroNameReg.matched(1);
					undefineObject(macroName);
					tokens.deleteTokens(i);
				}else{
					throw 'invalid #undef syntax';
				}

			case 'if':        // @! todo
				//@! parse with glsl parser and evaluate with PP evaluator
				throw 'directive #if is not yet supported';

			case 'ifdef':     // @! todo
				//all regions of an if sequence are mutually exclusive
				//all ifs must eventually reach an endif

				//first identify regions
				//identify regions and their associated tests
				throw 'directive #ifdef is not yet supported';

				if(macroNameReg.match(directiveContent)){
					var macroName = macroNameReg.matched(1);

					var testResult = isMacroDefined(macroName);
				}else{
					throw 'invalid #ifdef syntax';
				}

			case 'ifndef':    // @! todo
				throw 'directive #ifndef is not yet supported';

			case 'else', 'elif', 'endif':      // @! todo
				throw 'unexpected #$directiveTitle';

			case 'error':
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
				if(tokens.nextNonSkipToken(i, -1) == null){
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

	static function processIdentifier(tokens:Array<PPToken>, i:Int, ?overrideMap:Map<String, PPMacro>):PPMacro{
		var token = tokens[i];
		//could be an operator or a macro
		var ppMacro = overrideMap == null ? getMacro(token.data) : overrideMap.get(token.data);
		if(ppMacro == null) return null;

		inline function tokenizeContent(content:String){
			var newTokens = PPTokenizer.tokenize(content, function(warning:String){
				throw '$warning';
			}, function(error:String){
				throw '$error';
			});
			//@! correct line information, approximate (everything following is now incorrect)
			for(t in newTokens){
				t.line = token.line;
				t.column = token.column;
			}
			return newTokens;
		}

		//we have a PPMacro
		switch ppMacro {
			case UserMacroObject(content):
				var newTokens = tokenizeContent(content);
				//delete identifier token (current token)
				tokens.deleteTokens(i, 1);
				//insert tokenized content
				tokens.insertTokens(i, newTokens);

				return ppMacro;

			case UserMacroFunction(content, parameters):
				try{
					//get function arguments
					var functionCall = tokens.readFunctionCall(i);
					//ensure number of arguments match
					if(functionCall.args.length != parameters.length){
						switch functionCall.args.length > parameters.length{
							case true: throw 'too many arguments for macro';
							case false: throw 'not enough arguments for macro';
						}
					}

					var newTokens = tokenizeContent(content);

					//map parameter name to function call arguments
					var parameterMap = new Map<String, PPMacro>();
					for(i in 0...parameters.length){
						if(!parameterMap.exists(parameters[i]))
							parameterMap.set(parameters[i], UserMacroObject(functionCall.args[i].print()));
					}

					//replace IDENTIFIERS with function parameters
					for(j in 0...newTokens.length){
						if(newTokens[j].type.equals(PPTokenType.IDENTIFIER)){
							processIdentifier(newTokens, j, parameterMap);
						}
					}

					//delete function call
					tokens.deleteTokens(i, functionCall.len);
					//insert tokenized content
					tokens.insertTokens(i, newTokens);

					return ppMacro;

				}catch(e:String){
					//identifier isn't a function call; ignore
				}
			case BuiltinMacroObject(func):
				var newTokens = tokenizeContent(func());
				//delete identifier token (current token)
				tokens.deleteTokens(i, 1);
				//insert tokenized content
				tokens.insertTokens(i, newTokens);

				return ppMacro;

			case BuiltinMacroFunction(func, requiredParameterCount):
				try{
					//get arguments
					var functionCall = tokens.readFunctionCall(i);
					//ensure number of arguments match
					if(functionCall.args.length != requiredParameterCount){
						switch functionCall.args.length > requiredParameterCount{
							case true: throw 'too many arguments for macro';
							case false: throw 'not enough arguments for macro';
						}
					}

					var newTokens = tokenizeContent(func(functionCall.args));

					//delete operator call
					tokens.deleteTokens(i, functionCall.len);
					//insert tokenized content
					tokens.insertTokens(i, newTokens);

					return ppMacro;

				}catch(e:String){
					//identifier isn't a function call; ignore
				}

			case UnresolveableMacro:
				throw 'cannot resolve macro';

			default:
				throw 'unhandled macro object $ppMacro';
		}

		return null;
	}


	static function evaluateMacroDefinition(definitionString:String):PPMacro{
		if(macroNameReg.match(definitionString)){
			var macroName = macroNameReg.matched(1);
			var macroContent = '';
			var macroParameters = new Array<String>();

			var nextChar = macroNameReg.matched(2);

			var userMacro:PPMacro;

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
					userMacro = UserMacroFunction(StringTools.trim(macroContent), macroParameters);

				default:  //object-like
					macroContent = nextChar + macroNameReg.matchedRight();
					macroContent = StringTools.trim(macroContent); //trim whitespace

					//create macro object
					userMacro = UserMacroObject(StringTools.trim(macroContent));
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
	static var macroNameReg = ~/^([a-z_]\w*)([^\w]|$)/i;
}

typedef MacroFunctionCall = {
	var ident:PPToken;
	var args:Array<Array<PPToken>>;
	var start:Int;
	var len:Int;
}

enum PPMacro{//@!
	UserMacroObject(content:String);
	UserMacroFunction(content:String, parameters:Array<String>);
	BuiltinMacroObject(func:Void -> String);//function():Array<PPToken>
	BuiltinMacroFunction(func:Array<Array<PPToken>> -> String, parameterCount:Int);//function(args):Array<PPToken>
	UnresolveableMacro; 
}

class PPTokensHelper{
	static public function readFunctionCall(tokens:Array<PPToken>, start:Int):MacroFunctionCall{
		//macrofunction (identifier, identifier, ...)
		var ident = tokens[start];
		if(ident == null || ident.type != PPTokenType.IDENTIFIER){
			throw 'invalid function call';
		}

		var args:Array<Array<PPToken>> = [];

		//find matching parenthesis
		//open function
		var j = tokens.nextNonSkipTokenIndex(start);
		if(j == -1) throw 'invalid function call';

		var t:PPToken = tokens[j];
		if(t.type.equals(PPTokenType.LEFT_PAREN)){
			//read args, taking care to match parentheses
			var argBuffer:Array<PPToken> = [];
			var level = 1;
			inline function pushArgs(){
				args.push(argBuffer);
				argBuffer = []; //flush arg buffer
			}
			do{
				t = tokens[++j];//next token
				if(t == null) throw 'expecting \')\'';
				if(PPTokenizer.skippableTypes.indexOf(t.type) != -1) continue; //ignore skippable tokens
				switch t.type{
					case PPTokenType.LEFT_PAREN: level++;
					case PPTokenType.RIGHT_PAREN: level--;
					case PPTokenType.COMMA: if(level == 1) pushArgs(); else argBuffer.push(t);
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

	//returns the token n tokens away from token start, ignoring skippables. Supports negative n
	static public function nextNonSkipToken(tokens:Array<PPToken>, start:Int, n:Int = 1, ?requiredType:PPTokenType):PPToken{
		var direction = n >= 0 ? 1 : -1;
		var j = start;
		var m = Math.abs(n);
		var t:PPToken;
		while(m > 0){
			j += direction;//advance token
			t = tokens[j];
			if(t == null) break;
			//continue for skip over
			if(PPTokenizer.skippableTypes.indexOf(t.type) != -1) continue;
			if(requiredType != null && !t.type.equals(requiredType)) continue;
			m--;
		}
		return t;
	}

	static public function nextNonSkipTokenIndex(tokens:Array<PPToken>, start:Int, n:Int = 1, ?requiredType:PPTokenType):Int{
		var direction = n >= 0 ? 1 : -1;
		var j = start;
		var m = Math.abs(n);
		var t:PPToken;
		while(m > 0){
			j += direction;//advance token
			t = tokens[j];
			if(t == null) return -1;
			//continue for skip over
			if(PPTokenizer.skippableTypes.indexOf(t.type) != -1) continue;
			if(requiredType != null && !t.type.equals(requiredType)) continue;
			m--;
		}
		return j;
	}

	static public function deleteTokens(tokens:Array<PPToken>, start:Int, count:Int = 1){
		return tokens.splice(start, count);
	}

	static public function insertTokens(tokens:Array<PPToken>, start:Int, newTokens:Array<PPToken>){
		var j = newTokens.length;
		while(--j >= 0) tokens.insert(start, newTokens[j]);
		return tokens;
	}
}

/*
	Preprocessor Tokenizer
	
	for simplicity it uses glsl tokenizer but remaps special tokens
*/
typedef PPToken = {
	var type:PPTokenType;
	var data:String;
	@:optional var position:Int;
	@:optional var line:Int;
	@:optional var column:Int;
}
typedef PPTokenType = glsl.parser.Tokenizer.TokenType;

@:access(glsl.parser.Tokenizer)
class PPTokenizer{
	static public function tokenize(input:String, ?onWarn:String->Void, ?onError:String->Void):Array<PPToken>{
		//temporarily clear keywords map on Tokenizer
		var tmpKeywords = glsl.parser.Tokenizer.literalKeywordMap;
		glsl.parser.Tokenizer.literalKeywordMap = new Map<String, glsl.parser.Tokenizer.TokenType>();

		var tokens = glsl.parser.Tokenizer.tokenize(input, onWarn, onError);

		glsl.parser.Tokenizer.literalKeywordMap = tmpKeywords;

		return remap(tokens);
	}

	static function remap(tokens:Array<glsl.parser.Tokenizer.Token>){
		for(t in tokens){
			t.type = switch t.type {
				//remap special keywords to identifier
				case TYPE_NAME:
					//remap to
					IDENTIFIER;
				default: t.type;
			}
		}
		return tokens;
	}

	static public var skippableTypes = glsl.parser.Tokenizer.skippableTypes;
}