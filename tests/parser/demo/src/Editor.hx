package;

extern class Editor{
	static public function getValue():String;
	static public function setValue(v:String):String;
	static public function on(event:String, callback:Dynamic->Void):Void;
}