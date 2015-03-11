package;

import glslparser.Parser;
import glslparser.Tokenizer;
import Editor;
import js.html.Element;

class Main{
	var outputElement:Element;
	var warningsElement:Element;
	var inputChanged:Bool = false;

	function new(){
		outputElement =  js.Browser.document.getElementById('ast');
		warningsElement =  js.Browser.document.getElementById('warnings');

		Editor.on("change", function(e:Dynamic){
			inputChanged = true;
		});

		var reparseTimer = new haxe.Timer(500);

		reparseTimer.run = function(){
			if(inputChanged) parse();
		}

		parse();
	}

	function parse(){
		var input = Editor.getValue();

		try{
			var tokens = Tokenizer.tokenize(input);
			var ast = Parser.parseTokens(tokens);

			outputElement.innerHTML = haxe.Json.stringify(ast, null, "\t");

			showWarnings();
		}catch(e:Dynamic){
			showWarnings();
			warningsElement.innerHTML += '<br>'+e;

			outputElement.innerHTML = '';
		}

		inputChanged = false;
	}

	function showWarnings(){
		warningsElement.innerHTML = Parser.warnings.concat(Tokenizer.warnings).join('<br>');	
	}

	static function main() new Main();
}