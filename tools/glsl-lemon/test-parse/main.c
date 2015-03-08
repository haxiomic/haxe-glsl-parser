#include <stdio.h>
#include <stdlib.h>

#include "../glsl.c"
#include "../glsl.h"

int GetNextToken(int *id, void* token);

int main(){
	printf("Hello World\n");

	void *pParser;
	pParser = ParseAlloc( malloc );

	int hTokenId;

	while( GetNextToken(&hTokenId, NULL) ){
	    Parse(pParser, hTokenId, NULL);
	}

    Parse(pParser, 0, NULL);
    ParseFree(pParser, free );

	return 0;
}

int i = 0;
int GetNextToken(int *id, void* token){
	int tokenArray[] = {80,1,81,15,1,65,15,1,65,82,1,65};
	int len = sizeof(tokenArray) / sizeof(int);

	if(i < len){
		*id = tokenArray[i++];
		return 1;
	}
	return 0;
}