/*
	@! Todo
*/

package glsl.parser;

import glsl.SyntaxTree;

class Preprocessor{

	static public var version:Null<Int>;

	static public function preprocess(tokens:Array<Token>):Array<Tokens>{
		//init state machine
		version = null;
		/*
			@! todo

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
		*/
		return tokens;
	}

}