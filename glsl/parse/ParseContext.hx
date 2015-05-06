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

	public var declarationContext:Bool;

	public var defaultPrecision:Map<DataType, PrecisionQualifier>;

	public function new(){
		scopes = [];
		scopePush(); //create initial scope

		declarationContext = false;

		defaultPrecision = new Map<DataType, PrecisionQualifier>();//@! need correct initial defaults
	}

	public function scopePush(){
		scopes.push(new Scope());
	}

	public function scopePop(){
		if(scopes.length <= 1){
			#if debug trace('Parse scope error: trying to pop global scope!'); #end
			return;
		}

		scopes.pop();
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

	public function enterDeclarationContext(){
		declarationContext = true;
	}

	public function exitDeclarationContext(){
		declarationContext = false;
	}

	public function declareType(specifier:StructSpecifier){
		localScope.set(specifier.name, USER_TYPE(specifier));
	}

	public function declareVariable(declarator:Declarator){
		localScope.set(declarator.name, VARIABLE(declarator));
	}

	public function declarePrecision(declaration:PrecisionDeclaration){
		defaultPrecision.set(declaration.dataType, declaration.precision);
	}

	inline function get_scopeDepth():Int
		return scopes.length - 1;

	inline function get_localScope():Scope
		return scopes[scopeDepth];
}