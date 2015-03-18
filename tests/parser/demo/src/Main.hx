package;

import glslparser.Eval;
import glslparser.Parser;
import glslparser.Tokenizer;
import Editor;
import js.Browser;
import js.html.Element;

class Main{
	var jsonContainer:Element;
	var messagesElement:Element;
	var warningsElement:Element;
	var successElement:Element;
	var inputChanged:Bool = false;

	function new(){
		jsonContainer =  Browser.document.getElementById('json-container');
		messagesElement =  Browser.document.getElementById('messages');
		warningsElement =  Browser.document.getElementById('warnings');
		successElement =  Browser.document.getElementById('success');

		//load input if there is any
		var savedInput = loadInput();
		if(savedInput != null) Editor.setValue(savedInput, 1);
		else Editor.setValue('uniform float time;\n\nvoid main( void ){\n\tgl_FragColor = vec4(sin(time), 0.4, 0.8, 1.0);\n}', 1);

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

			Eval.evaluateConstantExpressions(ast);

			displayAST(ast);

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
			.set_show_to_level(3)
			.set_sort_objects(true)
			.set_icons('', '-')
			(ast)
		);
	}

	function showErrors(warnings:Array<String>){
		if(warnings.length > 0){
			var ul = Browser.document.createElement('ul');

			for(w in warnings){
				var li = Browser.document.createElement('li');
				li.innerHTML = w;
				ul.appendChild(li);
			}
			warningsElement.innerHTML = '';
			warningsElement.appendChild(ul);
			warningsElement.style.width = '100%';//chrome dom size fix
			warningsElement.style.display = '';
			successElement.innerHTML = '';
			successElement.style.display = 'none';
			messagesElement.className = 'error';
		}else{
			successElement.innerHTML = 'GLSL parsed without error';
			successElement.style.width = '100%';
			successElement.style.display = '';
			warningsElement.innerHTML = '';
			warningsElement.style.display = 'none';
			messagesElement.className = 'success';
		}

		untyped Browser.window.fitMessageContent();
	}

	function saveInput(input:String){
		Browser.getLocalStorage().setItem('glsl-input', input);
	}

	function loadInput(){
		return Browser.getLocalStorage().getItem('glsl-input');
	}

	static function main() new Main();
}
