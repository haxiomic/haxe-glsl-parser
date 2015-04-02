/*
	@! Todo
	
	#Notes

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

	- define with a regular variable creates a new const in place? (in contrast to macro function definitions)
		alternatively, just paste the content in place?
	- define is literally just handling arbitrary text rather than expressions
	- macro functions identifiers can be found by tokenizing the function content

	- if's process only a simple subset of expressions and also paste in defines in place
		(tokenize content to find identifiers)

	- Can regular Composite variables be used in preprocessor expressions?
		> in #define, yes, any nonsense can be used - it's just pasting the text string in place
		> in #if, no, only Primitives may be used

	- do pragmas have special syntax?

	- "Undefined identifiers not consumed by the defined operator do not default to '0'. Use of such
	identifiers causes an error."

	- A separate operator function table _may_ be necessary to handle C-style operations
		(ie, 0 may be interchangeable with false for example)
*/

package glsl.parser;

import glsl.SyntaxTree;
import glsl.parser.Tokenizer;

class Preprocessor{

	static public var warnings:Array<String>;

	//data gathered by the preprocessor
	static public var version:Null<Int>;
	// static public var pragmas:Array<String> @! todo
	// static public var extensions:?<?> @! todo, extensions have an associated behavior parameter
	

	static var tokens:Array<Token>;
	static var i:Int;
	static var tokenBuffer:Array<Token>;

	// static var operators:? @! todo
	// static var builtInMacros:? @! todo
	// static var userDefinedMacros:? @! todo

	static public function preprocess(tokens:Array<Token>):Array<Token>{
		//init state machine
		version = null;
		i = 0;
		tokenBuffer = [];
		warnings = [];
		//make tokens available to other functions within class
		Preprocessor.tokens = tokens;

		while(i < tokens.length){
			var token = tokens[i];

			switch token.type {
				case PREPROCESSOR_DIRECTIVE:
					handleDirective(token);
				case IDENTIFIER:
					handleIdentifier(token);
				default:
					tokenBuffer.push(token);
			}

			i--;
		}

		return tokens;
	}

	static function handleDirective(token:Token){
		directiveReg.match(token.data);
		var directiveTitle = directiveReg.matched(1);
		var directiveContent = directiveReg.matchedRight();

		switch directiveTitle {
			case '':
			case 'define':    // @! todo
				warn('directive define is not yet supported');

			case 'undef':     // @! todo
				warn('directive undef is not yet supported');

			case 'if':        // @! todo
				warn('directive if is not yet supported');

			case 'ifdef':     // @! todo
				warn('directive ifdef is not yet supported');

			case 'ifndef':    // @! todo
				warn('directive ifndef is not yet supported');

			case 'else':      // @! todo
				warn('directive else is not yet supported');

			case 'elif':      // @! todo
				warn('directive elif is not yet supported');

			case 'endif':     // @! todo
				warn('directive endif is not yet supported');

			case 'error':     // @! todo
				warn('directive error is not yet supported');

			case 'pragma':    // @! todo
				warn('directive pragma is not yet supported');

			case 'extension': // @! todo
				warn('directive extension is not yet supported');

			case 'version':   // @! todo
				warn('directive version is not yet supported');

			case 'line':      // @! todo
				warn('directive line is not yet supported');

			default:
				warn('unknown directive \'$directiveTitle\'', token);
		}
	}

	static function handleIdentifier(token:Token){ //@!
		//could be an operator or a macro
		
	}

	static function readOperatorParameters(?expectedParameterCount:Int):Array<Token>{
		// @! todo
		//operator identifier
		//operator (identifier, identifier, ...)
		return null;
	}

	//Custom restricted expression evaluation
	static function evaluateExpr(expr:Expression){//@! todo
		/* Supported expressions
		 * ...
		 */
	}

	//Utils
	// @! needs testing
	static function nextToken(n:Int = 1, ignoreSkippable:Bool){
		var j = i + 1;
		var m = n;
		var t:Token;
		while(m > 0){
			t = tokens[j++];
			if(ignoreSkippable && Tokenizer.skippableTypes.indexOf(t.type) != -1)//skip over token
				continue;
			m--;
		}
		return t;
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
	static var directiveReg = ~/^#\s*([\w\d]*)/;

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