package;

import glslparser.Eval;
import glslparser.Parser;
import glslparser.Tokenizer;
import Editor;
import js.html.Element;

class Main{
	var jsonContainer:Element;
	var messagesElement:Element;
	var warningsElement:Element;
	var successElement:Element;
	var inputChanged:Bool = false;

	function new(){
		jsonContainer =  js.Browser.document.getElementById('json-container');
		messagesElement =  js.Browser.document.getElementById('messages');
		warningsElement =  js.Browser.document.getElementById('warnings');
		successElement =  js.Browser.document.getElementById('success');

		//load input if there is any
		var savedInput = loadInput();
		if(saveInput != null) Editor.setValue(savedInput);

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

			saveInput(input);
			showErrors(Parser.warnings.concat(Tokenizer.warnings));
		}catch(e:Dynamic){
			showErrors([e]);
			
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

	function showErrors(warnings){
		if(warnings.length > 0){
			warningsElement.innerHTML = warnings.join('<br>');
			successElement.innerHTML = '';
			messagesElement.className = 'error';
		}else{
			successElement.innerHTML = 'GLSL parsed without error';
			warningsElement.innerHTML = '';
			messagesElement.className = '';
		}
	}

	function saveInput(input:String){
		js.Browser.getLocalStorage().setItem('glsl-input', input);
	}

	function loadInput(){
		return js.Browser.getLocalStorage().getItem('glsl-input');
	}

	static function main() new Main();
}