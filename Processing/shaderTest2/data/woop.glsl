#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

#define PROCESSING_TEXTURE_SHADER

uniform vec2 resXY;

uniform sampler2D texture;

varying vec4 vertColor;
varying vec4 vertTexCoord;

const vec4 lumcoeff = vec4(0.299, 0.587, 0.114, 0);

void main() {
	gl_FragColor = vec4(0, 0, 0, 1);
	
	float isFocus = mod(gl_FragCoord.x, 6);
	if(int(isFocus)==0) {
		vec3 s0 = texture2D(texture, gl_TexCoord[0].st).rgb;
		vec3 s1 = texture2D(texture, gl_TexCoord[0].st+vec2(1.0/resXY.x)).rgb;
		vec3 s2 = texture2D(texture, gl_TexCoord[0].st+vec2(2.0/resXY.x)).rgb;
		vec3 s3 = texture2D(texture, gl_TexCoord[0].st+vec2(3.0/resXY.x)).rgb;
		vec3 s4 = texture2D(texture, gl_TexCoord[0].st+vec2(4.0/resXY.x)).rgb;
		vec3 s5 = texture2D(texture, gl_TexCoord[0].st+vec2(5.0/resXY.x)).rgb;
		gl_FragColor = vec4((s0+s1+s2+s3+s4+s5), 1.0);
	}
}