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
  float randA = rand(vec2(gl_FragCoord.x, gl_FragCoord.y));
  float randB = 0*rand(vec2(gl_FragCoord.y, gl_FragCoord.x + 102.511510));
  float randC = 0*rand(vec2(gl_FragCoord.x/2.4021 - 1000.6, gl_FragCoord.y/8.4444));
  float randD = 0*rand(vec2(gl_FragCoord.x*12.44, gl_FragCoord.y-13.33));
  
  float randTemporalA = 0*rand(vec2(gl_FragCoord.x + time +5.819, gl_FragCoord.y*44.43 - time));
  float randTemporalB = 0*rand(vec2(time, time));

  vec2 q = vertTexCoord.st + vec2(trippiness*sin((gl_FragCoord.x+sineOffset.x)/80.0), trippiness*sin((gl_FragCoord.y+sineOffset.y)/80.0))/40.0;
  vec4 col0 = texture2D(texture, q); col0 -= vec4(0.5, 0.5, 0.5, 0.0);
  q += -0.05*randA*(vertTexCoord.st - vec2(0.5, 0.5));
  vec4 col1 = vec4(texture2D(texture, spand(q, randB*0.05)).r, texture2D(texture, spand(q, randC*0.1)).g, texture2D(texture, spand(q, randD*0.15)).b, 1.0);
  
  vec4 pdd = texture2D(texture, fract(q*100.0)/100.0);
  if(randTemporalA > 0.5 && false) {
  	pdd = vec4(0.0);
  }
  gl_FragColor = col1 + pdd;
  
}
