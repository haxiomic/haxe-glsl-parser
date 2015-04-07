precision highp float;

uniform lowp vec2 resolution;
varying vec3 fNormal;
uniform sampler2D Tex0;

void someFunction(int param1[5], inout float param2);

invariant varying struct TypeA {
    int i,j;
};

struct TypeB {
    int k,l;
    mat3 mat;
} tb = TypeB(3,4), tb2 = TypeB(5,6);

const int doge = 12;

void someFunction(int param1[5], inout float param2){
    //fracttext.frag
    
    int a = true ? 1 : 2;
    float f = (a++, a*3);
    
    gl_FragColor = vec4(tb.k, tb2.mat[1], 1.0, 1.0);
    gl_FragColor = vec4(fNormal, 1.0);
    (5*2 + (3/2 - 100));
    
    if(fract(newPosTex.s)>0.5) colorB = texture2D(Tex0, vec2(gl_TexCoord[0].s*(-1.0),gl_TexCoord[0].t));
    else if(true == false){/* there is no god */}
    else if(2^3 == 1){
        a = 4 % 1;
    }else{
        while(i > 19){{
            i++;
        }}
    }
    
    while(1 > 2) i++;
    
    do{
      for (int i=0; i<4; ++i) {
		for (int j=0; j<4; ++j) {
			col = texture2D(buffer, p+offset);
			sum += col.r + (col.g + col.b/mag)/mag;
			offset.y += ip;
		}
		offset.x += ip;
		offset.y = 0.0;
		if(offset.x > 1) return 100;
		else return;
	    }  
    }while(true);
    
    do i++;
    while(false);
	
	return;
}