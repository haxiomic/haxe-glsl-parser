- Should the 'defined' operator be only part of the preprocessor?
- Add a parameter to Tokenizer to disable storing line and column and position in the token?

- For all rules whos only symbol is another rule, reduce by simply passing on the symbol's node (s(1))


int a = 12 + 16;

{
	translation_unit{
		external_declation{ //ie global declaration
			declaration{
				init_declarator_list{

				}
			}
		}
	}
}