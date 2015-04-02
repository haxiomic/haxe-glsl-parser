/*
	@! Todo
	
	#Notes
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
			__LINE__  - will substitute a decimal integer constant that is one more than the number of preceding newlines
	in the current source string.

			__FILE__ - will substitute a decimal integer constant that says which source string number is currently
				being processed.

			__VERSION__ - will substitute a decimal integer reflecting the version number of the OpenGL ES shading
	language. (100 in this case for version 1.00)

			GL_ES - will be defined and set to 1

	------------------------------

	- Some preprocessor directives can only be evaluated on the target platform
	- Preprocessor directives should be stored on root note with position information so that they
		can be printed with the AST
	- Operators and predefined macros should remain as identifier tokens
*/

package glsl.parser;

import glsl.SyntaxTree;
import glsl.parser.Tokenizer;

class Preprocessor{
	static public var version:Null<Int>;
	
	static public var warnings:Array<String>;

	static var tokens:Array<Token>;

	static public function preprocess(tokens:Array<Token>):Array<Token>{
		//init state machine
		version = null;
		warnings = [];
		//make tokens available to other functions within class
		Preprocessor.tokens = tokens;

		for(token in tokens){
			switch token.type {
				case PREPROCESSOR_DIRECTIVE:
					handleDirective(token);
				case IDENTIFIER:
					handleIdentifier(token);
				default:
			}
		}

		return tokens;
	}

	static function handleDirective(token:Token){
		trace(token);
		directiveReg.match(token.data);
		var directiveTitle = directiveReg.matched(1);
		var directiveContent = directiveReg.matchedRight();

		warn(directiveContent, token);

		switch directiveTitle {
			case '':
			case 'define':    // @! todo
			case 'undef':     // @! todo
			case 'if':        // @! todo
			case 'ifdef':     // @! todo
			case 'ifndef':    // @! todo
			case 'else':      // @! todo
			case 'elif':      // @! todo
			case 'endif':     // @! todo
			case 'error':     // @! todo
			case 'pragma':    // @! todo
			case 'extension': // @! todo
			case 'version':   // @! todo
			case 'line':      // @! todo
			default:
				warn('unknown preprocessor directive \'$directiveTitle\'', token);
		}
	}

	static function handleIdentifier(token:Token){ //@!
		//could be an operator or a macro
		switch token.data {
			//Operators
			case 'defined':
			
			//Macros
			default:
			//search built in and user defined
		}
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

	static var directiveReg = ~/^#\s*([\w\d]*)/;
}