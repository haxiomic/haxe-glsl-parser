#Todo
-----
- TYPE_NAME scoping:
	-> fix function parameter scope issue
		Define types at variable definition
		Create new dummy rule to handle function definition
		Pass parameters to context
	-> define parameters in parseContext
	-> tokens are processed in the wrong order?
		-> type putting scope_push and pop outside of braces
	-> TYPE_NAME is being replaced in the wrong places, for example, int a, S;
- TreeBuilder to ParserActions?
- warn on redefinitions in parseContext?
- TreeBuilder should be Parser and Parser should be ParserCore. processToken() shouldn't need to track lastToken
- Support for complex types in Eval + Improved operator selection in Eval
- Parser core separation
- Preprocessor expression parser and eval
- Validator

- Handle setting the default precision with parseContext

- isolate core parser for resuse by preprocessor

- We probably need a preprocessor expression parser that includes the defined operator
- Preprocessor_directive tokens need to be part of the SyntaxTree to make passing on PP tokens possible
- Error reporting needs redoing from the top - if token has pos info, this should be integrated into to nodes

- A constant expression includes all basic types and user define types! So ```uniform vec2 x[NewThing(3).len];``` is valid as is something awful like. The result should be a basic type


#Notes

##TYPE_NAME scope test
```
struct A{
    int a;
};

void main(in A, out A[5]){
    	struct S {
			int x, y;
		};
		{
			S S = S(0,0); // 'S' is only visible as a struct and constructor
			S; // 'S' is now visible only as a variable
		}

		if(true){
		    struct Q{
		        float f;
		    };
		}
		
	    Q q = Q(4.4);
}
```

###TYPE_NAME parameter scope leak
```
void main(struct X{int j;}){
}

X test = X(10);
```










Preprocessor ifs
```
#ifdef A
1
#elif B == 12
2
#elif B == 3
3
#else
4
#endif
```
{isDefined(A), [1]} , {eval(B == 12), [2]} , {eval(B == 3), [3]} , {!eval(B == 3), [3]}





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

- For all rules whose only symbol is another rule, reduce by simply passing on the symbol's node (s(1))

- In GLSL ES: "There is no mechanism for initializing arrays at declaration time from within a shader."
- However, in GLSL (1.2), arrays can be initialized
- We must be clear about language differences and state this is ES only explicitly (along with hints on extending this)
-