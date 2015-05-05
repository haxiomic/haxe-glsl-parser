package;

import haxe.io.Path;
import haxe.Template;
import sys.FileSystem;
import sys.io.File;

using Lambda;

class Main {

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
		printActionCases: function(resolve:String->Dynamic, name:String, comments:String = null, indentLevel:String){
			//parameters are initially strings and so must be converted to correct types
			var indentLevel:Int = Std.parseInt(indentLevel);

			var a = resolve(name);
			var commentMap = resolve(comments);

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
				var trimedCode = trimIndentation(trimLines(pa.code));
				var indentedCode = indent(trimedCode, '\t', 1);
				result += 'case '+pa.ruleIds.join(', ')+': ';
				//add comments
				// if(pa.ruleIds.length > 1)
					result += '\n';
				if(commentMap != null){
					var j = 0;
					for(rid in pa.ruleIds){
						var c = Reflect.field(commentMap, Std.string(rid));
						result += (j > 0? '\n' : '') + indent('/* $c */', '\t', 1);
						j++; 
					}
				}
				//add code
				result += '\n'+indentedCode;

				i++;
			}

			return indent(result, '\t', indentLevel);
		}
	};
	
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

	static public function trimIndentation(str:String){
		var result = '';

		var lines = str.split('\n');

		var spaceReg = ~/^([ \t]+)/;
		//determine indentation
		var indentation:String = null;
		for(l in lines){
			if(!spaceReg.match(l))
				continue;//no indentation on this line

			var matchedIndentation = spaceReg.matched(1);
			if(matchedIndentation.length >= l.length)
				continue;//line is just whitespace

			if(indentation == null || matchedIndentation.length < indentation.length)
				indentation = spaceReg.matched(1);
		}

		if(indentation == null)
			return str; //no determinable indentation

		for(i in 0...lines.length){
			var line = lines[i];
           	//remove indentation characters
           	var j = 0;
           	var len = Math.min(indentation.length, line.length);
           	while((line.charAt(j) == indentation.charAt(j)) && (j < len)){
           		j++;
           	}
            line = line.substr(j);
			result += (i > 0 ? '\n' : '') + line;
		}
		return result;
	}

	static public function trimLines(str:String){
		var allSpaceReg = ~/^\s*$/;
		var lines = str.split('\n');
		//remove preceding
		var i = 0;
		while(allSpaceReg.match(lines[i++])){
			lines.shift();
		}
		//remove trailing
		i = lines.length - 1;
		while(allSpaceReg.match(lines[i--])){
			lines.pop();
		}
		return lines.join('\n');
	}


	static function main() return new Main();
}