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

	var currentScope(get, null):Scope;

	public function new(){
		scopes = [];
		scopePush(); //create initial scope
	}

	public function scopePush(){
		scopes.push(new Scope());
		trace('scopePush');
	}

	public function scopePop(){
		if(scopes.length <= 1){
			#if debug trace('Parse scope error: trying to pop global scope!'); #end
			return;
		}
		scopes.pop();
	}

	public function typeDefinition(specifier:StructSpecifier){
		trace('typeDefinition ${specifier.name}');
		currentScope.set(specifier.name, USER_TYPE(specifier));
	}

	public function variableDeclaration(declarator:Declarator){
		trace('variableDeclaration ${declarator.name}');
		currentScope.set(declarator.name, VARIABLE(declarator));
	}

	public function searchScope(name:String):Object{
		var r = null;
		var i = scopes.length;
		while(--i >= 0){
			if((r = scopes[i].get(name)) != null)
				break;
		}
		return r;
	}

	inline function get_currentScope():Scope{
		return scopes[scopes.length - 1];
	}
}