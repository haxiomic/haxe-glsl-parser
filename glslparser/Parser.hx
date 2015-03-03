/*
	Notes
	- "If a comment resides entirely within a single line, it is treated syntactically as a single space"
	- "Newlines are not eliminated by comments" i guess when replacing comments, count the number of newlines within

	- Do we need a validation pass where we enforce rules like
		"Identifiers starting with “gl_” are reserved for use by OpenGL ES. No user-defined identifiers may begin
with “gl_”."
		"All identifiers containing two consecutive underscores (__) are reserved as possible future
keywords."

	- Shunting Yard Algorithm for expressions http://stackoverflow.com/questions/28256/equation-expression-parser-with-precedence
*/