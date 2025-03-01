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
uniform float rotX;

const float epsilon = 0.001;
vec3 lightDir = vec3(0.0, -0.2, 1.0);
vec3 skyColor = vec3(0.4, 0.3, 1.0);

float rand(vec2 co){
  return fract(sin(dot(co.xy, vec2(12.9898, 78.233)))*43758.5453);
}

///////////////////////Stolen from online.../////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
mat4 rotationMatrix(vec3 axis, float angle)
{
axis = normalize(axis);
float s = sin(angle);
float c = cos(angle);
float oc = 1.0 - c;
return mat4(oc * axis.x * axis.x + c, oc * axis.x * axis.y - axis.z * s, oc * axis.z * axis.x + axis.y * s, 0.0,
oc * axis.x * axis.y + axis.z * s, oc * axis.y * axis.y + c, oc * axis.y * axis.z - axis.x * s, 0.0,
oc * axis.z * axis.x - axis.y * s, oc * axis.y * axis.z + axis.x * s, oc * axis.z * axis.z + c, 0.0,
0.0, 0.0, 0.0, 1.0);
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

float heightFunc(vec2 v) {
	return sin(v.x) + sin(v.y) + ((sin(v.x*2.0) + sin(v.y*2.0)))/2.0 + ((sin(v.x*8.0) + sin(v.y*8.0)))/8.0 + ((sin(v.x*4.0) + sin(v.y*4.0)))/4.0;
}
vec3 color(vec2 v) {
	return vec3(abs(sin(v.x*10.)), abs(sin(v.y*10.)), 1.0);
}

vec3 getNormal(vec3 p) {
	float eps = 0.0001;
    const vec3 n = vec3(heightFunc(vec2(p.x - eps, p.z)) - heightFunc(vec2(p.x+eps, p.z)), 2.0f*eps, heightFunc(vec2(p.x, p.z - eps)) - heightFunc(vec2(p.x, p.z + eps)));
    return normalize(n);
}

float shadow( in vec3 ro, in vec3 rd, float mint, float maxt )
{
    for( float t=mint; t < maxt; t += 0.1)
    {
        float h = heightFunc((ro + rd*t).xz);
        if( h>(ro + rd*t).y )
            return 0.0;
        t += h;
    }
    return 1.0;
}

vec4 march(vec3 ro, vec3 rd) {
	float mint = 0.1;
	float maxt = 20.;
	float dt = 0.01;
	float lh = 0.;
	float ly = 0.;
	for(float t = mint; t < maxt; t += dt) {
		const vec3 p = ro + rd*t;
		const float h = heightFunc(p.xz);
		if(p.y < h) {
			float resT = t - dt + dt*(lh - ly)/(p.y - ly - h + lh);
			return vec4(p.x, resT, p.z, 1.0);
		}
		dt = 0.005*t;
		lh = h;
		ly = p.y;
	}
	return vec4(0.0, 0.0, 0.0, 0.0);
}
void main(void) {
	lightDir = normalize(lightDir);
	mat4 view_rot = rotationMatrix(vec3(0., 1., 0.), rotX);
	vec3 vrd = (view_rot*vec4(vec3(vertTexCoord.rg - vec2(0.5, 0.5), 2.), 0.5)).xyz;
	vrd = normalize(vrd);
	vec4 m_v = march(userPosition, vrd);
	
	if(m_v.w > 0.0) {
		vec3 v = m_v.xyz;
		vec3 n = getNormal(v);
		vec3 eye_to_v = normalize(userPosition - v);
		float lambertian = dot(n, -lightDir);
		float specular = pow(max(0.0, dot(reflect(-lightDir, n), eye_to_v)), 64.0);
		vec3 light = color(vec2(v.x, v.z))*lambertian + specular;
		
		vec4 shadowed = march(v - lightDir, -lightDir);
		if(shadowed.w > 0.5)
			light *= 0.3;
		
		//gl_FragColor = vec4(color(shadowed.xz), 1.0);
		gl_FragColor = vec4(light, 1.0);
	} else
		gl_FragColor = vec4(skyColor, 1.0);
}