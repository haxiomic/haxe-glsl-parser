package;

import glsl.parser.Preprocessor;
import glsl.parser.Parser;
import glsl.parser.Tokenizer;
import glsl.SyntaxTree.Node;
import js.Browser;
import js.html.DOMElement;

using glsl.printer.SyntaxTreeHelper;

class Main{
	var jsonContainer:DOMElement;
	var messagesElement:DOMElement;
	var warningsElement:DOMElement;
	var successElement:DOMElement;
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

		//listen for changes and parse when required
		Editor.on("change", function(e:Dynamic){
			inputChanged = true;
		});

		var reparseTimer = new haxe.Timer(500);
		reparseTimer.run = function(){
			if(inputChanged) parseAndEvaluate();
		}
		parseAndEvaluate();
	}

	var warnings = [];
	function parseAndEvaluate(){
		var input = Editor.getValue();

		try{
			warnings = [];
			
			var ast = parse(input);
			displayAST(ast);
			

			// displayAST(ast);
			// var globals = Extract.extractGlobalVariables(ast);
			// warnings = warnings.concat(globals.warnings);
			// trace('Extracted globals:\n$globals');
			// //print variable values
			// for(v in globals.variables){
			// 	trace('${v.name} = ${v.value}');
			// }

			var pretty = ast.print('\t');
			var plain = ast.print(null);
			// trace('#\n\n\n');

			trace('-- Pretty --');
			trace(pretty);
			trace('-- Plain --');
			trace(plain);

			// trace('-- Trying Second Parse -- ');
			// var pretty2 = parse(pretty).print('\t');
			// var plain2 = parse(pretty).print(null);
			// var prettyMatch = pretty == pretty2;
			// var plainMatch = plain == plain2;
			// trace('pretty match: '+prettyMatch);
			// trace('plain match: '+plainMatch);
			// if(!plainMatch){
			// 	trace('-- Pretty2 --');
			// 	trace(pretty2);
			// }
			// if(!prettyMatch){
			// 	trace('-- Plain2 --');
			// 	trace(plain2);
			// }

		}catch(e:Dynamic){
			warnings = warnings.concat([e]);
			jsonContainer.innerHTML = '';
		}	

		saveInput(input);

		showErrors(warnings);

		inputChanged = false;
	}

	function parse(input:String):Node{
		var tokens = glsl.parser.Tokenizer.tokenize(input);
		warnings = warnings.concat(Tokenizer.warnings);
		
		tokens = glsl.parser.Preprocessor.process(tokens);
		warnings = warnings.concat(Preprocessor.warnings);

		var ast = Parser.parseTokens(tokens);
		warnings = warnings.concat(Parser.warnings);
		return ast;
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
