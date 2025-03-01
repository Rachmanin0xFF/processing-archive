#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

#define PROCESSING_TEXTURE_SHADER

uniform sampler2D texture;
uniform vec2 texOffset;

varying vec4 vertColor;
varying vec4 vertTexCoord;

uniform vec3 userPosition;
const float epsilon = 0.001;
uniform vec2 mouseInput;


///////////////////////////////////////////////////
float sdTorus( vec3 p, vec2 t )
{
  vec2 q = vec2(length(p.xz)-t.x,p.y);
  return length(q)-t.y;
}
float opRep( vec3 p, vec3 c )
{
    vec3 q = mod(p,c)-0.5*c;
    return sdTorus( q, vec2(0.1, 0.1) );
}
float dF(vec3 p) {
	return opRep(p, vec3(3.0, 3.0, 3.0));
}
///////////////////////////////////////////////////

vec3 march(vec3 ro, vec3 rd) {
	float t = 0.;
	float d = 0.;
	const int maxSteps = 64;
	vec3 p;
	for(int i = 0; i < maxSteps; i++) {
		p = ro + rd*t;
		d = dF(p);
		if(d < epsilon) {
			return vec3(p);
		}
		t += d;
	}
	return vec3(p);
}
void main(void) {
	vec3 vrd = vec3(vertTexCoord.rg - vec2(0.5, 0.5), 2.);
	vrd = normalize(vrd);
	vec3 v = march(userPosition, vrd);
	
	gl_FragColor = vec4(vec3(abs(sin(v.x)), abs(sin(v.y)), abs(sin(v.z))) * vertColor - vec3(length(userPosition-v)/50.0), 1.0);
}