#Todo
------
- Error reporting needs redoing from the top - line numbers and positions should be non-optional for tokens
- Rename ParserReducer to TreeBuilder ? with reduceRule or rule function?
- Rename ParserDebugData?
- Replace GLSLAccessor with GLSLVariable
- Start on preprocessor
- Since array lengths are required CPU size, **we need to evaluate constant expressions**

- A constant expression includes all basic types and user define types! So ```uniform vec2 x[NewThing(3).len];``` is valid as is something awful like. The result should be a basic type


#Notes
````
const struct NewThing{
  int len; 
} a = NewThing(4);

uniform vec2 x[a.len];
````
#Evaluating constant expression
- GLSL is evaluated in a top-down single-pass manner
- As Nodes are stepped through, user-types must be defined
- When a constant expression is reached, it is evaluated with access to the other constant expressions in the state machine
- BinaryExpressions and UnaryExpression are simple enough to handle, SequenceExpression shouldn't be necessary as far as I can tell, AssignmentExpression is tricky because I think it's invalid for consts. FieldSelectionExpression is easyish, ArrayElementSelectionExpression shouldn't be necessary because there can't be any arrays in const. 
----

- Should the 'defined' operator be only part of the preprocessor?
- Add a parameter to Tokenizer to disable storing line and column and position in the token?

- For all rules whos only symbol is another rule, reduce by simply passing on the symbol's node (s(1))

- In GLSL ES: "There is no mechanism for initializing arrays at declaration time from within a shader."
- However, in GLSL (1.2), arrays can be initialized
- We must be clear about language differences and state this is ES only explicitly (along with hints on extending this)