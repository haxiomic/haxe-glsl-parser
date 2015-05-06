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
####Rebuilding the parser after grammar changes
A fork of [lemon](http://www.hwaci.com/sw/lemon/) is used to generate the haxe parser. The parser generator automatically copies the output into the core code - all you need to do is navigate to **tools/parser-generator/** and execute run.sh