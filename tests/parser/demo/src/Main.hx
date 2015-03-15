package;

import glslparser.Eval;
import glslparser.Parser;
import glslparser.Tokenizer;
import Editor;
import js.html.Element;

class Main{
	var jsonContainer:Element;
	var warningsElement:Element;
	var inputChanged:Bool = false;

	function new(){
		jsonContainer =  js.Browser.document.getElementById('json-container');
		warningsElement =  js.Browser.document.getElementById('warnings');

		Editor.on("change", function(e:Dynamic){
			inputChanged = true;
		});

		var reparseTimer = new haxe.Timer(500);

		reparseTimer.run = function(){
			if(inputChanged) parseAndEvaluate();
		}

		parseAndEvaluate();
	}

	function parseAndEvaluate(){
		var input = Editor.getValue();

		try{
			var tokens = Tokenizer.tokenize(input);
			var ast = Parser.parseTokens(tokens);

			displayAST(ast);

			Eval.evaluateConstantExpressions(ast);

			showWarnings();
		}catch(e:Dynamic){
			showWarnings();
			warningsElement.innerHTML += '<br>'+e;

			jsonContainer.innerHTML = '';
		}

		inputChanged = false;
	}

	function displayAST(ast:Dynamic){
		// var jsonString = haxe.Json.stringify(ast);
		jsonContainer.innerHTML = '';
		untyped jsonContainer.appendChild(
			renderjson
			.set_show_to_level(5)
			.set_sort_objects(true)
			(ast)
		);
	}

	function showWarnings(){
		warningsElement.innerHTML = Parser.warnings.concat(Tokenizer.warnings).join('<br>');	
	}

	static function main() new Main();
}