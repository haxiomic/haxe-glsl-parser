package;

import haxe.io.Path;
import haxe.Template;
import sys.FileSystem;
import sys.io.File;

using Lambda;

class Main {
	
	var macros = {
		defaultTo: function(resolve:String->Dynamic, name:String, defaultValue:String){
			var tt = resolve(name);
			return (tt == null || tt == "") ? defaultValue : tt;
		},
		printEnumMap: function(resolve:String->Dynamic, name:String){
			var a = resolve(name);
			var result = '';
			result += '[';
			var i = 0;
			for(k in Reflect.fields(a)){
				if(i > 0) result += ',';
				var v = Reflect.field(a, k);
				result += '$k=>$v';
				i++;
			}
			result += ']';
			return result;
		},
		printActionCases: function(resolve:String->Dynamic, name:String){
			var a = resolve(name);
			var result = '';

			var processedActions = new Array<{ruleIds:Array<Int>, code:String}>();

			for(k in Reflect.fields(a)){
				var code = processRuleCode(Reflect.field(a, k));
				var rid = Std.parseInt(k);

				//check if same code already exists
				var matched = false;
				for(pa in processedActions){
					if(pa.code == code){
						pa.ruleIds.push(rid);
						matched = true;
						break;
					}
				}

				if(matched) continue;

				processedActions.push({
					ruleIds: [rid],
					code: code
				});
			}

			var i = 0;
			for(pa in processedActions){
				if(i > 0) result += '\n';
				var indentedCode = indent(pa.code, '\t', 4);
				result += '\t\t\tcase '+pa.ruleIds.join(', ')+': \n'+indentedCode;
				i++;
			}

			return result;
		}
	};

	function new() {
		var jsonPath = null;

		//search for json file
		var localFiles = FileSystem.readDirectory('.');
		for(f in localFiles){
			if(Path.extension(f).toLowerCase() == 'json'){
				jsonPath = f;
				break;
			}
		}

		if(jsonPath == null){
			throw 'couldn\'t find any json files';
		}

		var json = haxe.Json.parse(File.getContent(jsonPath));

		//generate for each template templates
		var templatesDir = Path.normalize('./templates');
		var templateFiles = FileSystem.readDirectory(templatesDir);
		for(f in templateFiles){
			if(!~/\w/.match(f.charAt(0))) continue; //probably system file
			generateFile(json, Path.join([templatesDir, f]));
		}

	}

	function generateFile(json:Dynamic, path:String){
		var tablesTemplate = File.getContent(path);
		var filename = Path.withoutDirectory(path);

		//create output directory
		if(!FileSystem.exists('output')){
			FileSystem.createDirectory('output');
		}

		var t = new Template(tablesTemplate);

		var result = t.execute(json, macros);

		var path = Path.join(['output', filename]);
		trace('generated $path');
		File.saveContent(path, result);
	}

	static function processRuleCode(code:String):String{
		var result = '';
		var reg = ~/\$\$\s*=\s*/ig;
		var matched = reg.match(code);
		if(matched){
			result = reg.replace(code, 'return ');
		}else{
			result = 'return $code';
		}

		return result;
	}

	static public function indent(str:String, chars:String, level:Int = 1){
		if(chars == null || level == 0) return str;
		var result = '';
		var identStr = [for(i in 0...level) chars].join('');
		var lines = str.split('\n');
		for(i in 0...lines.length){
			var line = lines[i];
			result += identStr + line + (i < lines.length - 1 ? '\n' : '');
		}
		return result;
	}

	// static public function trimIndentation(str:String, chars:String){
	// 	var result = '';
	// 	var lines = str.split('\n');

	// 	var indentReg = new EReg('^((\t)+)', '');
	// 	//find smallest indentation string
	// 	var smallestIdent = null;
	// 	for(i in 0...lines.length){
	// 		var line = lines[i];
	// 		var m = indentReg.match(line);
	// 		trace(m, line);
	// 		if(!m) break;
	// 		var indent = indentReg.matched(2);
	// 		if(smallestIdent == null || indent.length < smallestIdent.length)
	// 			smallestIdent = indent;
	// 	}

	// 	trace('smallestIdent "$smallestIdent"');
	// 	if(smallestIdent == null) smallestIdent = '';

	// 	var smallestIdentReg = new EReg('^'+smallestIdent, '');
	// 	for(i in 0...lines.length){
	// 		var line = lines[i];
	// 		result += smallestIdentReg.replace(line, '') + (i < lines.length - 1 ? '\n' : '');
	// 	}

	// 	return result;
	// }

	static function main() return new Main();
}