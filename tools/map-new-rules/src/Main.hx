import haxe.io.Path;

/*
	Rough tool to help transitioning to a new rule set

	expects switch statement in input to be ordered
*/

typedef RuleMap = Map<String, Int>;
enum ChangeType{
	NewRule(idx:Int, rule:String);
	UpdateIdx(oldIdx:Int, newIdx:Int, rule:String);
}

class Main{
	static function main(){

		//start
		var c = getChanges(rulemaps.GLES_100_PP_scope_v2.map, rulemaps.GLES_100_PP_scope_v1.map);

		var filename = 'TreeBuilder.hx';
		var treeBuilderPath = Path.join([getProjectRoot(), 'glsl', 'parse', filename]);
		var input = sys.io.File.getContent(treeBuilderPath);
		var processed = applyChanges(c, input);

		sys.io.File.saveContent(Path.join(['output', filename]), processed);
	}

	static function getChanges(newMap:RuleMap, oldMap:RuleMap){
		var changes:Array<ChangeType> = [];

		for(rule in newMap.keys()){
			var newRuleIdx = newMap.get(rule);
			var oldRuleIdx = oldMap.get(rule);

			if(oldRuleIdx == null){
				changes.push(NewRule(newRuleIdx, rule));
				continue;
			}

			if(newRuleIdx != oldRuleIdx){
				changes.push(UpdateIdx(oldRuleIdx, newRuleIdx, rule));
			}
		}

		return changes;
	}

	static function applyChanges(changes:Array<ChangeType>, input:String):String{
		sortChanges(changes, true);
		var result:String = input;

		var incomplete:Array<ChangeType> = [];
		for(c in changes){
			switch c{
				case UpdateIdx(oldIdx, newIdx, _):
					//searches for case \d+: and updates rule number
					var r = new EReg('(\\bcase\\s+'+oldIdx+'\\s*\\:)', '');
					result = r.replace(result, 'case '+newIdx+':');
					reportChange(c);
				case ct: 
					incomplete.push(ct);
			}
		}

		if(incomplete.length>0){
			trace('--------------------------');
			trace('--- INCOMPLETE CHANGES ---');
			report(incomplete);
		}

		return result;
	}

	static function sortChanges(changes:Array<ChangeType>, reverse:Bool = false){
		changes.sort(function(a, b){
			inline function getI(ct) return switch ct {
				case NewRule(i, _): i;
				case UpdateIdx(i, _, _): i;
			}
			var agtb = getI(a) > getI(b);
			if(reverse) agtb = !agtb;
			return agtb ? 1 : -1;
		});
		return changes;
	}

	static function report(changes:Array<ChangeType>){
		sortChanges(changes);
		for(c in changes) reportChange(c);
	}

	static function reportChange(c:ChangeType){
		switch c{
			case NewRule(idx, rule):
				trace('New:     $idx\t\t($rule)');
			case UpdateIdx(oldIdx, newIdx, rule):
				trace('Updated: $oldIdx -> $newIdx\t\t($rule)');
		}
	}

	static function getProjectRoot(){
		var p = new sys.io.Process("git", ["rev-parse", "--show-toplevel"]);
		if(p.exitCode() != 0) return null;
		var result = p.stdout.readAll().toString();
		p.close();
		return result.substr(0, result.length-1);
	}
}
