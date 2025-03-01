#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

#define PROCESSING_TEXTURE_SHADER

uniform sampler2D texture;
uniform float amount;
uniform vec2 RES;

float rand(vec2 co){
	return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

float PI = 3.14159265359;

float incr = PI/32.0;

void main(void) {
  float aspect = RES.y/RES.x;
  float w = 0.0;
  vec2 uv = gl_FragCoord.xy/RES.xy;
  float theta0 = rand(gl_FragCoord.xy);
  for(float i = 0.0; i < PI*2.0; i+=incr) {
  	float r = sqrt(rand(uv + vec2(i*72.4 + gl_FragCoord.y, 0)));
  	float theta = theta0 + i;
  	vec2 offset = r*vec2(cos(theta)*aspect, sin(theta));
  	vec4 col = texture2D(texture, uv + offset*amount);
  	float w2 = col.r + col.g + col.b;
  	gl_FragColor += col*w2;
  	w += w2;
  }
  gl_FragColor /= w;
}
