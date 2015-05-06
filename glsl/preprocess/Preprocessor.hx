/*
	GLSL Preprocessor
	- in progress

	@author George Corney

	@! Todo
	- create custom expression tokenizer
		- example shader https://www.shadertoy.com/view/Xl2GDm
	- handle #line and #extension

	#Notes
	- in expressions: "Undefined identifiers not consumed by the defined operator do not default to '0'. Use of such
	identifiers causes an error."
*/

package glsl.preprocess;

import glsl.SyntaxTree;

import glsl.lex.Tokenizer;

using glsl.lex.TokenHelper;
using glsl.print.TokenPrinter;

class Preprocessor{

	var tokens:Array<Token>;
	var i:Int;
	var forceResolve:Bool; //force unresolvable macros to be resolved

	var builtinMacros:Map<String, PPMacro>;
	var userDefinedMacros:Map<String, PPMacro>;

	var onMacroDefined:String->PPMacro->Void;
	var onMacroUndefined:String->Void;
	var preserveMacroDefinitions:Bool = false;

	var _warnings:Array<String>;
	var _version:Null<Int>;
	var _pragmas:Array<String>;

	//Preprocessor instances should only be used by the class so the instance constructor is private
	function new(?userDefinedMacros, ?builtinMacros){
		//init state machine variables
		this.i = 0;
		this.userDefinedMacros = userDefinedMacros != null ? userDefinedMacros : new Map<String, PPMacro>();
		this.builtinMacros = builtinMacros != null ? builtinMacros : [
			'__VERSION__' => UnresolveableMacro(BuiltinMacroObject( function() return Std.string(_version) )),
			'__LINE__'    => UnresolveableMacro(BuiltinMacroObject( function() return Std.string(tokens[i].line) )), //line of current token
			'__FILE__'    => UnresolveableMacro(BuiltinMacroObject( function() return '0' )),
			'GL_ES'       => UnresolveableMacro(BuiltinMacroObject( function() return '1' )) //1 for ES platforms
		];

		this._warnings = [];
		this._version = 100; //default version number
		this._pragmas = [];
	}

	function _process(inputTokens:Array<Token>, forceResolve:Bool = false):Array<Token>{
		tokens = inputTokens;
		this.forceResolve = forceResolve;

		//preprocessor loop
		inline function tryProcess(process:Void->Void){
			try process()
			//if no position info is provided, assume error concerns the current token
			catch(e:PPError) switch e{
				case Note(msg, info): note(msg, info != null ? info : tokens[i]);
				case Warn(msg, info): warn(msg, info != null ? info : tokens[i]);
				case Error(msg, info): error(msg, info != null ? info : tokens[i]);
			}
			catch(msg:String) warn(msg, tokens[i]);
		}

		var token:Token;
		while(i < tokens.length){
			switch tokens[i].type {
				case PREPROCESSOR_DIRECTIVE:
					tryProcess(processDirective);
				case _.isIdentifierType() => true:
					tryProcess(processIdentifier);
				default:
			}

			i++;
		}

		return tokens;
	}

	//process functions can alter the state machine directly

	function processDirective(){
		var t = tokens[i];
		var directive = readDirectiveData(t.data);

		switch directive.title {
			case '':
				//empty directive is inconsequential
				tokens.deleteTokens(i);
			case 'define':
				//define macro
				var definition = evaluateMacroDefinition(directive.content);
				defineMacro(definition.id, definition.ppMacro);
				if(!preserveMacroDefinitions) tokens.deleteTokens(i);

			case 'undef':
				var macroName = readMacroName(directive.content);
				undefineMacro(macroName);
				if(!preserveMacroDefinitions) tokens.deleteTokens(i);

			case 'if', 'ifdef', 'ifndef':
				processIfSwitch();

			case 'else', 'elif', 'endif': //unmatched control directive
				throw 'unexpected #${directive.title}';
				// tokens.deleteTokens(i); //a later compiler might make better sense of this; don't remove

			case 'error':
				// tokens.deleteTokens(i); //should not be removed so it can be used by another compiler
				throw Error('${directive.content}', t);

			case 'pragma':
				if(~/^\s*STDGL(\s+|$)/.match(directive.content))
					throw 'pragmas beginning with STDGL are reserved';

				_pragmas.push(directive.content); 
				// tokens.deleteTokens(i); //#pragma should not be removed so it can be used by another compiler

			case 'extension': // @! todo
				throw 'directive #extension is not yet supported';
				// tokens.deleteTokens(i); //should not be removed so it can be used by another compiler

			case 'version':
				//ensure there are no (non-skip) tokens before directive
				if(tokens.nextNonSkipToken(i, -1) == null){
					//extract version number with regex (strictly a string of digits)
					var versionNumRegex = ~/^(\d+)$/;
					var matched = versionNumRegex.match(directive.content);
					if(matched){
						var numStr = versionNumRegex.matched(1);
						_version = Std.parseInt(versionNumRegex.matched(1));

						// tokens.deleteTokens(i); //#version should not be removed so it can be used by another compiler
					}else{
						switch directive.content {
							case '':
								throw 'version number required';
							default:
								throw 'invalid version number \'${directive.content}\'';
						}
					}
				}else{
					throw '#version directive must occur before anything else, except for comments and whitespace';
				}

			case 'line': // @! todo
				//tokens.deleteTokens(i);
				//change all the following line's tokens line numbers to specified line number
				throw 'directive #line is not yet supported';

			default:
				//tokens.deleteTokens(i); //don't know what this is - best pass it on
				throw 'unknown directive #\'${directive.title}\'';
		}
	}

	function processIfSwitch(){
		/*/ @!
		 *  when an #if expression's macros are expanded, the #if should be modified with the fully expanded form
		 *  so that if the if-switch cannot be resolved, the expression only references unresolved macros
		 *  resolved macros will have been removed!
		/*/

		var start = i, end = null;
		var j = i;
		var t:Token;
		var level = 0;//(level = 0 is outside statement)
		var directive:DirectiveData;
		var lastTitle:String;

		var branches:Array<{directiveToken:Token, test:Void->Bool, start:Int, end:Null<Int>}> = [];

		inline function openBlock(test:Void->Bool){
			branches.push({
				directiveToken: t,
				test: test,
				start: j + 1,
				end: null
			});
		}

		inline function closeBlock(){
			branches[branches.length - 1].end = j - 1;
		}

		try{
			//handle opening if
			t = tokens[j];
			//catch so we can pass on with better line info
			try{
				switch directive = readDirectiveData(t.data){
					case {title: 'if', content: content}:  //@!
						level++;
						openBlock(function(){
							throw Note('#if directive is not yet supported', t);
							// return evaluateExpr(expr)
						}); 
					case {title: 'ifdef', content: content}:
						level++;
						var macroName = readMacroName(content);
						openBlock(function() return isMacroDefined(macroName));
					case {title: 'ifndef', content: content}:
						level++;
						var macroName = readMacroName(content);
						openBlock(function() return !isMacroDefined(macroName));
					case directive: throw 'expected if-switch directive, got #${directive.title}';
				}
				lastTitle = directive.title;
				//find and act on other if-switch statements
				while(level > 0){
					j = tokens.nextNonSkipTokenIndex(j, 1, TokenType.PREPROCESSOR_DIRECTIVE);//next preprocessor directive
					t = tokens[j];
					if(t == null) throw 'expecting #endif but reached end of file';

					switch directive = readDirectiveData(t.data){
						case {title: 'if' | 'ifdef' | 'ifndef', content: _}:
							level++;
						case {title: 'else', content: _}:
							if(level == 1){
								if(lastTitle == 'else') throw '#${directive.title} cannot follow #else';
								closeBlock();
								openBlock(function() return true);						
							}
						case {title: 'elif', content: content}: //@!
							if(level == 1){
								if(lastTitle == 'else') throw '#${directive.title} cannot follow #else';
								closeBlock();						
								openBlock(function(){
									throw Note('#elif directive is not yet supported', t);
									// return evaluateExpr(expr)
								});
							}
						case {title: 'endif', content: _}:
							level--;
						case _:
					}

					lastTitle = directive.title;
				}
				//close the last block
				closeBlock();
			}catch(e:Dynamic){
				throw replaceErrorInfo(e, t);
			}

			//if-switch extent = i -> j (inclusive of j)
			end = j;

			var newTokens = new Array<Token>();

			//select branch by first test() returning true
			for(b in branches){
				try{
					if(b.test()){
						//branch selected; grab tokens
						newTokens = tokens.slice(b.start, b.end);
						break;
					}
				}catch(e:Dynamic){
					/* 
						branch's test() could not be resolved, it's now not known which branch should be executed,
						this creates uncertainty on the definition of macros - the following corrects for this,
						setting relevant macros as unresolvable and inserting additional #defines where necessary.
					*/ 

					//clone current user macro map
					var userMacrosBefore = new Map<String, PPMacro>();
					for(k in userDefinedMacros.keys())
						userMacrosBefore.set(k, userDefinedMacros.get(k));

					//these are macros who's definitions have been removed but will still have references in the source
					var requiredMacros = new Map<String, PPMacro>();

					//preprocess branches
					var tokensDelta = 0;//records change in length of if-switch
					for(bi in 0...branches.length){
						//handle branches in reverse order to prevent position conflicts
						var c = branches[branches.length - 1 - bi];
						//if any macros are referenced in the branch directive, they should be marked as required
						//@! this uses glsl.lex to extract identifiers rather than specialized pp tokenizer
						switch readDirectiveData(c.directiveToken.data) {
							case {title: 'if', content: content}, {title: 'elif', content: content}:
								var directiveTokens = Tokenizer.tokenize(content);
								for(dt in directiveTokens){
									if(dt.type.isIdentifierType() && dt.data != 'defined'){ //(ignore defined operator)
										var ppMacro = this.getMacro(dt.data);
										if(ppMacro != null){
											requiredMacros.set(dt.data, ppMacro);
										}
									}
								}
							case null, _:
						}

						var branchTokens = tokens.slice(c.start, c.end);
						//clone user macros for child preprocessor
						var childUserMacros = new Map<String, PPMacro>();
						for(k in userDefinedMacros.keys())
							childUserMacros.set(k, userDefinedMacros.get(k));
						//create child preprocessor
						var pp = new Preprocessor(childUserMacros, builtinMacros);
						pp.preserveMacroDefinitions = true;
						//attach macro definition callbacks
						pp.onMacroDefined = function(id, ppMacro){
							//mark macro as unresolvable
							userDefinedMacros.set(id, UnresolveableMacro(ppMacro));
						}
						pp.onMacroUndefined = function(id){
							var existingMacro = userMacrosBefore.get(id);
							if(existingMacro == null) return;
							//mark macro as unresolvable
							userDefinedMacros.set(id, UnresolveableMacro(existingMacro));
							//references will be left in the source; mark as required macro
							requiredMacros.set(id, existingMacro);
						}
						//preprocess and replace
						try{
							var lenBefore = branchTokens.length;
							var newTokens = pp._process(branchTokens, forceResolve);
							tokensDelta += newTokens.length - lenBefore;
							//replace branch tokens with preprocessed tokens
							tokens.deleteTokens(c.start, c.end - c.start);
							tokens.insertTokens(c.start, newTokens);
						}catch(e:Dynamic){} //suppress any errors from child
					}

					//inject definitions
					//for macros who's definition has been removed but references remain, a #define should be prepended to if-switch
					var prependTokens = new Array<Token>();
					for(id in requiredMacros.keys()){
						var requiredMacro = requiredMacros.get(id);

						var undefineStr = '#undef $id';
						var defineStr = switch requiredMacro {
							case UserMacroObject(content): '#define $id $content';
							case UserMacroFunction(content, params): '#define $id(${params.join(", ")}) $content';
							default: continue;
						}

						var glsl = undefineStr + '\n' + defineStr + '\n';
						//build tokens
						prependTokens = prependTokens.concat(Tokenizer.tokenize(glsl));
					}

					//insert definition tokens above first #if directive
					tokens.insertTokens(start, prependTokens);

					//everything's been shifted - update position trackers
					start += prependTokens.length;
					tokensDelta += prependTokens.length;
					j += tokensDelta;
					end = j;

					//jump preprocessor to end of if-switch
					this.i = end;
					
					//pass error on
					//attach correct token position info to error
					throw replaceErrorInfo(e, b.directiveToken);
				}
			}

			//branch selection success:
			//remove entire if-switch
			tokens.deleteTokens(start, end - start + 1);
			//insert new tokens
			tokens.insertTokens(start, newTokens);
			//step back index since tokens have changed
			this.i = start - 1;

		}catch(e:Dynamic){
			//if-switch could not be handled, probably because of a syntax error
			//leave in place and skip to end of if-switch
			while(level > 0){
				j = tokens.nextNonSkipTokenIndex(j, 1, TokenType.PREPROCESSOR_DIRECTIVE);
				t = tokens[j];
				if(t == null) throw Warn('expecting #endif but reached end of file', tokens[start]);
				switch readDirectiveData(t.data).title{
					case 'if', 'ifdef', 'ifndef': level++;
					case 'endif': level--;
				}
			}
			//set index to end of if-switch
			this.i = j;

			throw e;
		}
	}

	function processIdentifier(){
		var expanded = expandIdentifier(tokens, i);
		if(expanded != null){
			//identifier processed, skip over the new tokens
			this.i += expanded.length;
		}
	}

	//Macro Definition Handling
	function getMacro(id:String):PPMacro{
		var ppMacro:PPMacro;
		if((ppMacro = builtinMacros.get(id)) != null) return ppMacro;
		if((ppMacro = userDefinedMacros.get(id)) != null) return ppMacro;
		return null;
	}

	function defineMacro(id:String, ppMacro:PPMacro){
		var existingMacro = getMacro(id);

		switch existingMacro {
			case isBuiltinMacro(_) => true: throw 'cannot redefine predefined macro \'$id\'';
			case isUserMacro(_) => true: throw 'cannot redefine macro \'$id\'';
			case null, _:
		}

		if(~/^__/.match(id)) throw 'macro names beginning with __ are reserved';
		if(ppMacro == null) throw 'null macro definitions are not allowed';

		userDefinedMacros.set(id, ppMacro);

		if(onMacroDefined != null)
			onMacroDefined(id, ppMacro);
	}

	function undefineMacro(id:String){
		var existingMacro = getMacro(id);

		switch existingMacro {
			case isBuiltinMacro(_) => true: throw 'cannot undefine predefined macro';
			case isUserMacro(_) => true:
				userDefinedMacros.remove(id);

				if(onMacroUndefined != null)
					onMacroUndefined(id);
			case null, _: //undefine of null should not cause error
		}
	}

	function isMacroDefined(id:String):Bool{
		var m = getMacro(id);
		switch m{
			case UnresolveableMacro(fm): 
				if(forceResolve && fm != null) return true;
				else throw Note('cannot resolve macro definition \'$id\'', null);
			case null: return false;
			case _: return true;
		}
	}

	function isUserMacro(ppMacro:PPMacro){
		switch ppMacro{
			case UserMacroObject(_) | UserMacroFunction(_, _): return true;
			case UnresolveableMacro(fm): return isUserMacro(fm);
			case null, _: return false;
		}
	}

	function isBuiltinMacro(ppMacro:PPMacro){
		switch ppMacro{
			case BuiltinMacroObject(_) | BuiltinMacroFunction(_, _): return true;
			case UnresolveableMacro(fm): return isBuiltinMacro(fm);
			case null, _: return false;
		}
	}

	//Preprocessor Language Utils
	function readDirectiveData(data:String):DirectiveData{
		if(!directiveTitleReg.match(data)) throw 'invalid directive title';
		var title = directiveTitleReg.matched(1); 
		var content = StringTools.trim(directiveTitleReg.matchedRight());
		//remove newline overrun character '\'
		content = StringTools.replace(content, '\\\n', '\n');
		return {
			title: title, 
			content: content
		}
	}

	inline function readMacroName(data:String):String{
		if(!macroNameReg.match(data)) throw 'invalid macro name';
		return macroNameReg.matched(1);
	}

	//MACRO_NAME(args)? content?
	function evaluateMacroDefinition(definitionString:String):MacroDefinition{
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

			return {
				id: macroName,
				ppMacro: userMacro
			}
		}else{
			throw 'invalid macro definition';
		}

		return null;
	}

	function expandIdentifiers(tokens:Array<Token>, ?overrideMap:Map<String, PPMacro>, ?ignore:Array<String>):Array<Token>{
		var len = tokens.length;//token length will change
		for(j in 0...len){
			if(tokens[j].type.isIdentifierType()){
				expandIdentifier(tokens, j, overrideMap, ignore);
				len = tokens.length;
			}
		}
		return tokens;
	}

	function expandIdentifier(tokens:Array<Token>, i:Int, ?overrideMap:Map<String, PPMacro>, ?ignore:Array<String>):Array<Token>{
		var token = tokens[i];
		//could be an operator or a macro
		var id = token.data;
		//check ignore tokens
		if(ignore != null && ignore.indexOf(id) != -1) return null;
		//search for macro with id
		var ppMacro = overrideMap == null ? this.getMacro(id) : overrideMap.get(id);
		if(ppMacro == null) return null;

		inline function tokenizeContent(content:String){
			var newTokens = Tokenizer.tokenize(content, function(warning:String){
				throw '$warning';
			}, function(error:String){
				throw '$error';
			});
			//@! line information needs to be corrected, following is approximate:
			for(t in newTokens){
				t.line = token.line;
				t.column = token.column;
			}
			
			return newTokens;
		}

		inline function expand(tokens:Array<Token>){
			//@! expand tokens, pass ignore.push(id);
			if(ignore == null) ignore = [id];
			else ignore.push(id);
			expandIdentifiers(tokens, overrideMap, ignore);
		}

		function resolveMacro(ppMacro:PPMacro){
			switch ppMacro {
				case UserMacroObject(content):
					var newTokens = tokenizeContent(content);
					//expand identifiers @!
					expand(newTokens);
					//delete identifier token (current token)
					tokens.deleteTokens(i, 1);
					//insert tokenized content
					tokens.insertTokens(i, newTokens);

					return newTokens;

				case UserMacroFunction(content, parameters):
					try{
						//get function arguments
						var functionCall = readFunctionCall(tokens, i);
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
						//replace identifier tokens with corresponding function arguments
						//this uses the override identifier map
						expandIdentifiers(newTokens, parameterMap);
						//expand remaining identifiers @!
						expand(newTokens);

						//delete function call
						tokens.deleteTokens(i, functionCall.len);
						//insert tokenized content
						tokens.insertTokens(i, newTokens);

						return newTokens;

					}catch(e:Dynamic){
						//identifier isn't a function call; ignore
					}
					
				case BuiltinMacroObject(func):
					var newTokens = tokenizeContent(func());
					//delete identifier token (current token)
					tokens.deleteTokens(i, 1);
					//insert tokenized content
					tokens.insertTokens(i, newTokens);

					return newTokens;

				case BuiltinMacroFunction(func, requiredParameterCount):
					try{
						//get arguments
						var functionCall = readFunctionCall(tokens, i);
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

						return newTokens;

					}catch(e:Dynamic){
						//identifier isn't a function call; ignore
					}

				case UnresolveableMacro(fm):
					if(forceResolve && fm != null) return resolveMacro(fm);
					else throw Note('cannot resolve macro \'$id\'', token);
				default:
					throw 'unhandled macro object $ppMacro';
			}

			return null;
		}

		return resolveMacro(ppMacro);
	}

	function readFunctionCall(tokens:Array<Token>, start:Int):MacroFunctionCall{
		//macrofunction (identifier, identifier, ...)
		var ident = tokens[start];
		if(ident == null || !ident.type.isIdentifierType()){
			throw 'invalid function call';
		}

		var args:Array<Array<Token>> = [];

		//find matching parenthesis
		//open function
		var j = tokens.nextNonSkipTokenIndex(start);
		if(j == -1) throw 'invalid function call';

		var t:Token = tokens[j];
		if(t.type.equals(TokenType.LEFT_PAREN)){
			//read args, taking care to match parentheses
			var argBuffer:Array<Token> = [];
			var level = 1;
			inline function pushArg(){
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
					case TokenType.COMMA: if(level == 1) pushArg(); else argBuffer.push(t);
					case null: throw '$t has no token type';
					case _: argBuffer.push(t);
				}
				//close parenthesis reached
				if(level <= 0){
					pushArg();
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

	//Custom restricted expression evaluation
	function evaluateExpr(expr:Expression){//@! todo
		/* Supported expressions
		 * ...
		 */
	}

	//Error Reporting
	function note(msg, ?info:Dynamic){
		#if debug
		trace('Preprocessor Note: $msg' + positionString(info));
		#end
	}

	function warn(msg, ?info:Dynamic){
		_warnings.push('Preprocessor Warning: $msg' + positionString(info));
	}

	function error(msg, ?info:Dynamic){
		throw 'Preprocessor Error: $msg' + positionString(info);
	}

	function positionString(?info:Dynamic){
		var str  = '';
		var line = Reflect.field(info, 'line');
		var col = Reflect.field(info, 'column');
		if(Type.typeof(line).equals(Type.ValueType.TInt)){
			str += ', line $line';
			if(Type.typeof(col).equals(Type.ValueType.TInt)){
				str += ', column $col';
			}
		}
		return str;
	}

	function replaceErrorInfo(error:Dynamic, newInfo:Dynamic):Dynamic{
		return switch Type.typeof(error){
			case Type.ValueType.TEnum(PPError):
				switch error{
					case Note(msg, info): Note(msg, newInfo);
					case Warn(msg, info): Warn(msg, newInfo);
					case Error(msg, info): Error(msg, newInfo);
				}
			case null, _: Warn(error, newInfo); //default to Warn
		}
	}

	//Public API
	static public var warnings:Array<String>;

	//data gathered by the preprocessor
	static public var version:Null<Int>;
	static public var pragmas:Array<String>;
	// static public var extensions:?<?> @! todo, extensions have an associated behavior parameter

	static public function process(inputTokens:Array<Token>, forceResolve:Bool = false):Array<Token>{
		var pp = new Preprocessor();
		var tokens = pp._process(inputTokens, forceResolve);
		warnings = pp._warnings;
		version = pp._version;
		pragmas = pp._pragmas;
		return tokens;
	}

	//Preprocessor Data
	static var directiveTitleReg = ~/^#\s*([^\s]*)/;
	static var macroNameReg = ~/^([a-z_]\w*)([^\w]|$)/i;
}

typedef DirectiveData = {
	var title:String;
	var content:String;
}

typedef MacroFunctionCall = {
	var ident:Token;
	var args:Array<Array<Token>>;
	var start:Int;
	var len:Int;
}

typedef MacroDefinition = {
	var id:String;
	var ppMacro:PPMacro;
}

enum PPMacro{
	UserMacroObject(content:String);
	UserMacroFunction(content:String, parameters:Array<String>);
	BuiltinMacroObject(func:Void -> String);//function():Array<Token>
	BuiltinMacroFunction(func:Array<Array<Token>> -> String, parameterCount:Int);//function(args):Array<Token>
	UnresolveableMacro(ppMacro:PPMacro);//macro cannot be handled in anyway (it is not know if this macro is defined or not)
}

enum PPError{
	Note(msg:String, info:Dynamic);
	Warn(msg:String, info:Dynamic);
	Error(msg:String, info:Dynamic);
}