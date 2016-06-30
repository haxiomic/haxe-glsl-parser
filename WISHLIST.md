#Feature Wishlist

- Parser in js worker
- Validator
- Minifier with DCE,
	examples https://code.google.com/p/glsl-unit/wiki/UsingTheCompiler
- Optimizer
	https://www.opengl.org/wiki/GLSL_Optimizations
	http://stackoverflow.com/questions/10880742/glsl-compiler-optimization-of-redundant-assignments-across-functions
	https://github.com/aras-p/glsl-optimizer/tree/master/src/glsl
- Super-set features:
 
    - typing prepass (automatically resolve type mismatches where possible (ie 1.0*3))
    - auto add missing function prototypes
    - default function arguments
    - type inference for function returns and function parameters?
    - functions within functions
    - function reference passing?
    - extra built ins, PI, random() and others
    - function inling: IQ is using #define for speedup of the march function https://www.shadertoy.com/view/XslGRr
    - initialize vectors with just (a,b,c)?
    - var keyword?
    - so var p = (x,y). What about angle brackets?
    - var p = <x,y> compiles to vec2 p = vec2(x, y);
    - struct without trailing ;

   
- Complete Eval (currently just constant expressions)
