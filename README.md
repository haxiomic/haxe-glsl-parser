Cross Platform GLSL ES 1.0 Parser
------

Parses [GLSL version 1.00](https://www.khronos.org/files/opengles_shading_language.pdf) (the version used in webgl) using the reference language grammar.

Parser based on LALR parser from [The Lemon Parser Generator](http://www.hwaci.com/sw/lemon/)

Supports all platforms available to the [haxe](haxe.org) compiler (notably JavaScript, Java, C++ and Python)

###[Demo](http://haxiomic.github.io/haxe-glsl-parser/)

##Project Status
###Complete
- Parser
- Printer: pretty and compact
- Preprocessor

###In progress
- Evaluator
- Validator
- Optimizer
- Minifier

Feel free to contact me at haxiomic@gmail.com if you have any questions


------
####Extending the parser to handle other versions of glsl
First generate new parser tables with [lemon](http://www.hwaci.com/sw/lemon/), then update the node-building code (in *parser/TreeBuilder.hx*) to handle the new rules

To generate new tables you need a BNR language grammar (khronos provides this in the specification pdf). It can be converted to the lemon grammar format using */tools/grammar-converter/*. With the grammar, lemon will generate a C based parser, from which the parsing tables can be copied into *parser/Tables.hx*