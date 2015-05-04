/*
	ParseContext tracks declarations and scope

	@author George Corney
*/

package glsl.parse;

import glsl.SyntaxTree;

typedef Scope = Map<String, Object>;

enum Object{
	USER_TYPE(specifier:StructSpecifier);
	VARIABLE(declarator:Declarator);
	// FUNCTION;
}

class ParseContext{
	var scopes:Array<Scope>;

	var depth(get, null):Int;
	var localScope(get, null):Scope;

	public function new(){
		scopes = [];
		scopePush(); //create initial scope
	}

	public function scopePush(){
		scopes.push(new Scope());
		trace('scopePush ($depth)');
	}

	public function scopePop(){
		if(scopes.length <= 1){
			#if debug trace('Parse scope error: trying to pop global scope!'); #end
			return;
		}

		scopes.pop();
		trace('scopePop ($depth)');
	}

	public function declareType(specifier:StructSpecifier){
		trace('($depth) typeDefinition ${specifier.name}');
		localScope.set(specifier.name, USER_TYPE(specifier));
	}

	public function declareVariable(declarator:Declarator){
		trace('($depth) variableDeclaration ${declarator.name}');
		localScope.set(declarator.name, VARIABLE(declarator));
	}

	public function searchScope(name:String):Object{
		var r = null;
		var i = scopes.length;
		while(--i >= 0){
			if((r = scopes[i].get(name)) != null)
				break;
		}
		trace('($depth) search for $name found: $r');
		return r;
	}

	inline function get_depth():Int
		return scopes.length - 1;

	inline function get_localScope():Scope
		return scopes[depth];
}