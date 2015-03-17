package glslparser;

class Utils{

	static public function glslIntString(i:Int){ //enforce no decimal point
		var str = Std.string(i);
		var rx = ~/(\d+)\./g;
		if(rx.match(str))str = rx.matched(1);
		if(str == "") str = "0";
		return str;
	}

	static public function glslFloatString(f:Float){ //enforce decimal point
		var str = Std.string(f);
		var rx = ~/\./g;
		if(!rx.match(str)) str += '.0';
		return str;
	}

	static public function glslBoolString(b:Bool){
		return Std.string(b);
	}

}