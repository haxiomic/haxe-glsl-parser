package glsl.print;

class Utils{

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

	static public function intString(i:Int){ //enforce no decimal point
		var str = Std.string(i);
		var rx = ~/(\d+)\./g;
		if(rx.match(str))str = rx.matched(1);
		return str == '' ? '0' : str;
	}

	static public function floatString(f:Float){ //enforce decimal point
		var str = Std.string(f);
		var rx = ~/\./g;
		if(!rx.match(str)) str += '.0';
		return str;
	}

	static public function boolString(b:Bool){
		return Std.string(b);
	}

}