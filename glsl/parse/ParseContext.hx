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
	public var scopes:Array<Scope>;
	public var scopeDepth(get, null):Int;
	public var localScope(get, null):Scope;

	public function new(){
		scopes = [];
		scopePush(); //create initial scope
	}

	public function scopePush(){
		scopes.push(new Scope());
		trace('scopePush ($scopeDepth)');
	}

	public function scopePop(){
		if(scopes.length <= 1){
			#if debug trace('Parse scope error: trying to pop global scope!'); #end
			return;
		}

		scopes.pop();
		trace('scopePop ($scopeDepth)');
	}

	public function searchScope(name:String):Object{
		var r = null;
		var i = scopes.length;
		while(--i >= 0){
			if((r = scopes[i].get(name)) != null)
				break;
		}
		trace('($scopeDepth) searched for $name found: $r');
		return r;
	}

	public function declareType(specifier:StructSpecifier){
		trace('($scopeDepth) typeDefinition ${specifier.name}');
		localScope.set(specifier.name, USER_TYPE(specifier));
	}

	public function declareVariable(declarator:Declarator){
		trace('($scopeDepth) variableDeclaration ${declarator.name}');
		localScope.set(declarator.name, VARIABLE(declarator));
	}

	inline function get_scopeDepth():Int
		return scopes.length - 1;

	inline function get_localScope():Scope
		return scopes[scopeDepth];
}