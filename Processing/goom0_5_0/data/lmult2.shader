#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

#define PROCESSING_TEXTURE_SHADER

uniform sampler2D texture;
uniform vec2 texOffset;
uniform vec4 tart;
uniform float time;
uniform float ASPECT;

varying vec4 vertColor;
varying vec4 vertTexCoord;

float rand(vec2 co){
	return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

void main(void) {
  vec2 q = vertTexCoord.st;
  vec4 col1 = texture2D(texture, vertTexCoord.xy);
	
  q.y /= ASPECT;
  vec2 c = floor(q*50.0)/50.0;
  vec4 pdd2 = vec4(texture2D(texture, c + vec2(0.0, -0.01)).r, texture2D(texture, c).g, texture2D(texture, c + vec2(0.0, 0.01)).b, 1.0);
  float randSquare = rand(vec2(c.x, c.y + time/100000000.0));
  if(randSquare > 0.02) {
  	pdd2 = vec4(0.0);
  }
  gl_FragColor = col1+pdd2;
  
}
