/*
	LALR parser based on lemon parser generator
	http://www.hwaci.com/sw/lemon/
*/

package glslparser;

import glslparser.Tokenizer.Token;
import glslparser.Tokenizer.TokenType;

class Parser{
	//state machine variables
	static var i:Int; //stack index
	static var stack:Array<StackEntry>;
	static var errorCount:Int;

	static public function parseTokens(tokens:Array<Token>){
		//init
		i = 0;
		errorCount = -1;
		stack = [{
			stateno: 0,
			major: 0,
			minor: null
		}];

		var lastToken = null;
		for(t in tokens){
			if(ParserData.ignoredTokens.indexOf(t.type) != -1) continue;
			parseStep(tokenIdMap.get(t.type), t);
			lastToken = t;
		}

		//eof step
		parseStep(0, lastToken);//using the lastToken for the EOF step allows better error reporting if it fails
		return {};
	}

	//for each token, major = tokenId, minor = Token?
	static function parseStep(major:Int, minor:Token){
		// trace('\n----- parseStep, tokenId $major -> ${minor.type}');
		var act:Int;
		var atEOF:Bool;

		var errorHit:Bool = false;

		atEOF = major == 0;

		do{
			act = findShiftAction(major);
			if(act < nStates){
				assert( !atEOF );
				shift(act, major, minor);
				errorCount--;
				major = illegalSymbolNumber;
			}else if(act < nStates + nRules){
				reduce(act - nStates);
			}else{
				//syntax error
				assert( act == errorAction );
				if(errorsSymbol){
					//#! error recovery code if the error symbol in the grammar is supported
				}else{
					if(errorCount <= 0){
						syntaxError(major, minor);
					}

					errorCount = 3;
					if( atEOF ){
						parseFailed(minor);
					}
					major = illegalSymbolNumber;
				}
			}
		}while( major != illegalSymbolNumber && i >= 0);//would be better as plain while

		return;
	}

	static function popStack(){
		// trace('popStack');
		if(i < 0) return 0;
		var major = stack.pop().major;
		i--;
		return major;
	}


	//Find the appropriate action for a parser given the terminal
	//look-ahead token iLookAhead.
	static function findShiftAction(iLookAhead:Int){
		var stateno = stack[i].stateno;
		var j:Int = shiftOffset[stateno];
		// trace('findShiftAction iLookAhead: $iLookAhead, stateno: $stateno');

		if(stateno > shiftCount || j == shiftUseDefault){
			// trace('findShiftAction exit1');
			return defaultAction[stateno];
		}

		assert(iLookAhead != illegalSymbolNumber);

		j += iLookAhead;

		if(j < 0 || j >= actionCount || lookahead[j] != iLookAhead){
			// trace('findShiftAction exit2');
			return defaultAction[stateno];
		}

		// trace('findShiftAction return action[j]');
		return action[j];
	}

	//Find the appropriate action for a parser given the non-terminal
	//look-ahead token iLookAhead.
	static function findReduceAction(stateno:Int, iLookAhead:Int){
		var j:Int;

		if(errorsSymbol){
			if(stateno > reduceCount) return defaultAction[stateno];
		}else{
			assert( stateno <= reduceCount);
		}

		// trace('findReduceAction stateno: $stateno');
		j = reduceOffset[stateno];

		assert( j != reduceUseDefault );
		assert( iLookAhead != illegalSymbolNumber );
		j += iLookAhead;

		if(errorsSymbol){
			if( j < 0 || j >= actionCount || lookahead[j] != iLookAhead ){
				return defaultAction[stateno];
			}
		}else{
			assert( j >= 0 && j < actionCount );
			assert( lookahead[j] == iLookAhead );
		}

		return action[j];
	}

	static function shift(newState:Int, major:Int, minor:Token){
		// trace('shift newState: $newState, tokenId: $major');

		i++;
		stack[i] = {
			stateno: newState,
			major: major,
			minor: minor
		};
	}

	static function reduce(ruleno:Int){
		var goto:Int;               //next state
		var act:Int;                //next action
		var gotoMinor:Token;        //the LHS of the rule reduced
		var msp:StackEntry;         //top of parser stack
		var size:Int;               //amount to pop the stack

		msp = stack[i];

		gotoMinor = null; //zero gotoMinor?

		switch(ruleno){
			default:
			//#! execute custom reduce functions
		}

		goto = ruleInfo[ruleno].lhs;
		size = ruleInfo[ruleno].nrhs;
		i -= size;

		act = findReduceAction(stack[i].stateno, goto);

		// trace('reduce ruleno: $ruleno, goto: $goto, size: $size, act: $act');

		if(act < nStates){
			shift(act, goto, gotoMinor);
		}else{
			assert( act == nStates + nRules + 1);
			accept();
		}
	}

	static function accept(){
		// trace('accept');
		while(i >= 0) popStack();
	}

	static function syntaxError(major:Int, minor:Token){
		warn('syntax error, $minor');
	}//#! needs improving

	static function parseFailed(minor:Token){
			warn('parse failed, $minor');
	}

	//Utils
	static function assert(cond:Bool, ?pos:haxe.PosInfos)
		if(!cond) warn('assert failed in ${pos.className}::${pos.methodName} line ${pos.lineNumber}');

	//Error Reporting
	static function warn(msg){
		trace('Parser Warning: $msg');
	}

	static function error(msg){
		throw 'Parser Error: $msg';
	}

	//Language Data & Parser Settings
	static inline var errorsSymbol:Bool       = ParserData.errorsSymbol;
	//consts
	static inline var illegalSymbolNumber:Int = ParserData.illegalSymbolNumber;

	static inline var nStates                 = ParserData.nStates;
	static inline var nRules                  = ParserData.nRules;
	static inline var noAction                = nStates + nRules + 2;
	static inline var acceptAction            = nStates + nRules + 1;
	static inline var errorAction             = nStates + nRules;

	//tables
	static var actionCount                    = ParserData.actionCount;
	static var action:Array<Int>              = ParserData.action;
	static var lookahead:Array<Int>           = ParserData.lookahead;

	static inline var shiftUseDefault         = ParserData.shiftUseDefault;
	static inline var shiftCount              = ParserData.shiftCount;
	static inline var shiftOffsetMin          = ParserData.shiftOffsetMin;
	static inline var shiftOffsetMax          = ParserData.shiftOffsetMax;
	static var shiftOffset:Array<Int>         = ParserData.shiftOffset;

	static inline var reduceUseDefault        = ParserData.reduceUseDefault;
	static inline var reduceCount             = ParserData.reduceCount;
	static inline var reduceMin               = ParserData.reduceMin;
	static inline var reduceMax               = ParserData.reduceMax;
	static var reduceOffset:Array<Int>        = ParserData.reduceOffset;

	static var defaultAction:Array<Int>       = ParserData.defaultAction;

	//rule info table
	static var ruleInfo:Array<RuleInfoEntry>  = ParserData.ruleInfo;

	//tokenId
	static var tokenIdMap:Map<TokenType, Int> = ParserData.tokenIdMap;
}

abstract RuleInfoEntry(Array<Int>) from Array<Int> {
	public var lhs(get, set):Int;
	public var nrhs(get, set):Int;
	
	function get_lhs()return this[0];
	function set_lhs(v:Int)return this[0] = v;
	
	function get_nrhs()return this[1];
	function set_nrhs(v:Int)return this[1] = v;
}

typedef StackEntry = {
	var stateno:Int;
	var major:Int;
	var minor:Token;
}