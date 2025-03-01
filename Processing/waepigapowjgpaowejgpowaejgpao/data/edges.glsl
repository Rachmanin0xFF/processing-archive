#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

#define PROCESSING_TEXTURE_SHADER

uniform sampler2D texture;
uniform vec2 texOffset;
uniform vec4 tart;
uniform vec2 sineOffset;
uniform float time;
uniform float trippiness;

varying vec4 vertColor;
varying vec4 vertTexCoord;

float rand(vec2 co){
	return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

vec2 spand(vec2 uv, float prod) {
	return (uv - vec2(0.5, 0.5))*(1.0-prod) + vec2(0.5, 0.5);
}

void main(void) {
	vec3 a = texture2D(texture, vertTexCoord.st).xyz;
	vec3 b = texture2D(texture, vertTexCoord.st + vec2((a.x + a.y + a.z)/3.0/6.0, 0.0)).rgb;
  gl_FragColor = vec4(b, 1.0);
  
}
