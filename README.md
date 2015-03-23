Cross Platform GLSL ES 1.0 Parser
------

Parses [GLSL version 1.00](https://www.khronos.org/files/opengles_shading_language.pdf) (the version used in webgl) using the reference language grammar.

Parser based on LALR parser from [The Lemon Parser Generator](http://www.hwaci.com/sw/lemon/)

Supports all platforms available to the [haxe](haxe.org) compiler (notably JavaScript, Java, C++ and Python)

**Status:** parser is complete, preprocessor, validator in development. Although the project can be used for AST generation, it is still under heavy development.

Feel free to contact me at haxiomic@gmail.com if you have any questions

###[Demo](http://haxiomic.github.io/haxe-glsl-parser/)

------
##FAQ

####Can the parser be extended to handle other versions of glsl?
Yes, you only need to generate new parser tables with [lemon](http://www.hwaci.com/sw/lemon/) and update the node-building code to handle the new rules.

To generate new tables first obtain the BNR grammar (khronos provides this in the specification pdf), then convert it to the lemon grammar format using */tools/grammar-converter/* and run lemon on the new grammar. Lemon will generate a C based parser from which the parsing tables can be copied (it's fairly straight forward) into ParserData.hx. Once this is complete, ParserReducer.hx must be updated to generate nodes corresponding to the new language rules.
