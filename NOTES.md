- Should the defined operator be only part of the preprocessor?
- Add a parameter to Tokenizer to disable storing line and column and position in the token?


#Paser Notes
- How do we deal with operator precedence?
- How to deal with optionals?
- We could abstract Node to allow comparison with null
- "If a comment resides entirely within a single line, it is treated syntactically as a single space"
- "Newlines are not eliminated by comments" i guess when replacing comments, count the number of newlines within

Resources
http://www.semdesigns.com/Products/DMS/LifeAfterParsing.html?Home=DMSToolkit

- Recursive Decent Parser
	http://stackoverflow.com/questions/2245962/is-there-an-alternative-for-flex-bison-that-is-usable-on-8-bit-embedded-systems/2336769#2336769
	http://stackoverflow.com/questions/25049751/constructing-an-abstract-syntax-tree-with-a-list-of-tokens/25106688#25106688


Outline:
Recursive bottom up pattern	

- We need to eliminate left recursion from our grammar (either direct or indirect)
- Convert an ANTLR glsl grammar (EBNF to BNF) http://lampwww.epfl.ch/teaching/archive/compilation-ssc/2000/part4/parsing/node3.html
- Alternatively, add support for EBNF to the parser core and only convert syntax

'Terminals' are TOKENS
'Non-Terminals' are RULES

/*
#Grammar Recursion Issue
//float aaa, b, c;

// My format:
decl_list:
    single_decl COMMA comma_seperated_list

single_decl:
	FLOAT IDENT

comma_seperated_list:
    IDENT
    IDENT COMMA comma_seperated_list

////// Left recursive format:

decl_list:
    single_decl
    decl_list COMMA IDENT

single_decl
    FLOAT IDENT
*/


/*
#Another Example
struct_declaration:
    TYPE struct_declarator_list SEMICOLON

struct_declarator_list:
    struct_declarator
    struct_declarator_list COMMA struct_declarator

struct_declarator:
    IDENTIFIER
    IDENTIFIER LEFT_BRACKET constant_expression RIGHT_BRACKET
*/