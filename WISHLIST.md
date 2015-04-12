#Feature Wishlist

- Validator
- Minifier with DCE
	Examples https://code.google.com/p/glsl-unit/wiki/UsingTheCompiler
- Optimizer
	https://www.opengl.org/wiki/GLSL_Optimizations
	http://stackoverflow.com/questions/10880742/glsl-compiler-optimization-of-redundant-assignments-across-functions
	https://github.com/aras-p/glsl-optimizer/tree/master/src/glsl
- LazyGLSL: 
	- typing prepass (automatically resolve type mismatches where possible (ie 1.0*3))
	- add missing function prototypes
    - default function arguments
    - type inference for function returns and function parameters?
- Complete Eval (currently just constant expressions)
