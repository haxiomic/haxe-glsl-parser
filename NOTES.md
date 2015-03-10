- Should the 'defined' operator be only part of the preprocessor?
- Add a parameter to Tokenizer to disable storing line and column and position in the token?

- For all rules whos only symbol is another rule, reduce by simply passing on the symbol's node (s(1))

- In GLSL ES: "There is no mechanism for initializing arrays at declaration time from within a shader."
- However, in GLSL (1.2), arrays can be initialized
- We must be clear about language differences and state this is ES only explicitly (along with hints on extending this)


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