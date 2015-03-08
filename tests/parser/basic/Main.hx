import glslparser.Tokenizer;

class Main{

	static function main(){
		var input = '';

		input = '
		/**
		 * @name czm_depthRangeStruct
		 * @glslStruct
		 */
		struct czm_depthRangeStruct
		{
		    float near;
		    float far;
		}x;
		';

		// trace('"$input"');
		var tokens = Tokenizer.tokenize(input);
		trace('tokens generated');

		//trace debug c token array
		var ids:Array<Int> = [];
		for(t in tokens){
			var id = glslparser.ParserData.tokenIdMap.get(t.type);
			if(id != null) ids.push(id);
		}

		trace('{'+ids.join(',')+'}');

		var ast = glslparser.Parser.parseTokens(tokens);
		trace('parsed');
	}

}