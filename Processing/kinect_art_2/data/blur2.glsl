#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

#define PROCESSING_TEXTURE_SHADER

uniform sampler2D texture;

varying vec4 vertColor;
varying vec4 vertTexCoord;

uniform float r;

float rand(vec2 co){
    return fract(sin(dot(co.xy, vec2(12.9898, 78.233)))*43758.5453);
}

void main(void) {
  gl_FragColor += texture2D(texture, vertTexCoord.st + vec2(0.0, 5.0)*r)*0.2;
  gl_FragColor += texture2D(texture, vertTexCoord.st + vec2(0.0, 4.0)*r)*0.4;
  gl_FragColor += texture2D(texture, vertTexCoord.st + vec2(0.0, 3.0)*r)*0.6;
  gl_FragColor += texture2D(texture, vertTexCoord.st + vec2(0.0, 2.0)*r)*0.8;
  gl_FragColor += texture2D(texture, vertTexCoord.st + vec2(0.0, 1.0)*r);
  
  gl_FragColor += texture2D(texture, vertTexCoord.st + vec2(0.0, -1.0)*r);
  gl_FragColor += texture2D(texture, vertTexCoord.st + vec2(0.0, -2.0)*r)*0.8;
  gl_FragColor += texture2D(texture, vertTexCoord.st + vec2(0.0, -3.0)*r)*0.6;
  gl_FragColor += texture2D(texture, vertTexCoord.st + vec2(0.0, -4.0)*r)*0.4;
  gl_FragColor += texture2D(texture, vertTexCoord.st + vec2(0.0, -5.0)*r)*0.2;
  
  gl_FragColor = vec4(gl_FragColor.rgb/6.0, 1.0);
}
