
int r(color c) {return (c >> 16) & 255; }
int g(color c) {return (c >> 8) & 255;}
int b(color c) {return c & 255; }

color HSBC2rgb(float[] hsb) {
  float s = sqrt(hsb[0]*hsb[0] + hsb[1]*hsb[1])*2.f;
  float h = ((atan2(hsb[1], hsb[0]) + TWO_PI)%TWO_PI)/TWO_PI*255.f;
  float b = hsb[2] + 127.5;
  s = s/(b/255.f);
  colorMode(HSB);
  color c = color(h, s, b);
  colorMode(RGB);
  return c;
}

color HSB2rgb(float[] hsb) {
  colorMode(HSB);
  color c = color(hsb[0]+127.5, hsb[1]+127.5, hsb[2]+127.5);
  colorMode(RGB);
  return c;
}

color lab2rgb(float[] lab){
  float y = ((lab[0] + 100)/2 + 16) / 116;
  float x = lab[1] / 500 + y;
  float z = y - lab[2] / 200;
  float r = 0;
  float g = 0;
  float b = 0;

  x = pivotxyz_inv(x);
  y = pivotxyz_inv(y);
  z = pivotxyz_inv(z);

  r = x *  3.2406 + y * -1.5372 + z * -0.4986;
  g = x * -0.9689 + y *  1.8758 + z *  0.0415;
  b = x *  0.0557 + y * -0.2040 + z *  1.0570;

  r = pivotrgb_inv(r);
  g = pivotrgb_inv(g);
  b = pivotrgb_inv(b);

  return color(max(0, min(1, r)) * 255, max(0, min(1, g)) * 255, max(0, min(1, b)) * 255, 255);
}

//actually takes srgb
float[] rgb2lab(color rgb){
  float r = pivotrgb((float)r(rgb) / 255.f);
  float g = pivotrgb((float)g(rgb) / 255.f);
  float b = pivotrgb((float)b(rgb) / 255.f);
  float x = 0;
  float y = 0;
  float z = 0;

  //d65
  x = (r * 0.4124 + g * 0.3576 + b * 0.1805);
  y = (r * 0.2126 + g * 0.7152 + b * 0.0722);
  z = (r * 0.0193 + g * 0.1192 + b * 0.9505);

  x = pivotxyz(x);// / 95.047);
  y = pivotxyz(y);// / 100.000);
  z = pivotxyz(z);// / 108.883);

  return new float[]{((116 * y) - 16)*2 - 100, 500 * (x - y), 200 * (y - z)};
}

float[] rgb2hsb(color rgb) {
  return new float[]{hue(rgb), saturation(rgb), brightness(rgb)};
}

float[] rgb2hsbc(color rgb) {
  float h = hue(rgb);
  float s = saturation(rgb);
  float b = brightness(rgb);
  return new float[]{cos(h/255.f*TWO_PI)*s*0.5*b/255.f, sin(h/255.f*TWO_PI)*s*0.5*b/255.f, b - 127.5};
}

// pivot for xyz->lab
float pivotxyz(float x) {
  return x > 0.008856 ? pow(x, 0.333333333) : 7.787*x + 0.137931;
}

// pivot for srgb->rgb
float pivotrgb(float n) {
  return (n > 0.04045 ? pow((n + 0.055) / 1.055, 2.4) : n / 12.92);
}

float pivotxyz_inv(float x) {
  if(x > 0.206897) return x*x*x;
  return 0.12841854934*(x-0.137931034);
}

float pivotrgb_inv(float v) {
  if(v <= 0.0031308) return 12.92*v;
  else return (1.055*pow(v, 1.0/2.4) - 0.055);
}

PVector[] rgb2lab(PVector[] rgb){
  PVector[] p = new PVector[rgb.length];
  for(int i = 0; i < p.length; i++) {
    float[] vs = rgb2lab(color(rgb[i].x+127.5, rgb[i].y+127.5, rgb[i].z+127.5));
    p[i] = new PVector(vs[0], vs[1], vs[2]);
  }
  return p;
}

PVector[] rgb2HSB(PVector[] rgb){
  PVector[] p = new PVector[rgb.length];
  for(int i = 0; i < p.length; i++) {
    float[] vs = rgb2hsb(color(rgb[i].x+127.5, rgb[i].y+127.5, rgb[i].z+127.5));
    p[i] = new PVector(vs[0]-127.5, vs[1]-127.5, vs[2]-127.5);
  }
  return p;
}

PVector[] rgb2HSBC(PVector[] rgb){
  PVector[] p = new PVector[rgb.length];
  for(int i = 0; i < p.length; i++) {
    float[] vs = rgb2hsbc(color(rgb[i].x+127.5, rgb[i].y+127.5, rgb[i].z+127.5));
    p[i] = new PVector(vs[0], vs[1], vs[2]);
  }
  return p;
}

//CIE94 delta E from some guy online (i forget)
float deltaE(float[] labA, float[] labB){
  float deltaL = labA[0] - labB[0];
  float deltaA = labA[1] - labB[1];
  float deltaB = labA[2] - labB[2];
  float c1 = sqrt(labA[1] * labA[1] + labA[2] * labA[2]);
  float c2 = sqrt(labB[1] * labB[1] + labB[2] * labB[2]);
  float deltaC = c1 - c2;
  float deltaH = deltaA * deltaA + deltaB * deltaB - deltaC * deltaC;
  deltaH = deltaH < 0 ? 0 : sqrt(deltaH);
  float sc = 1.0 + 0.045 * c1;
  float sh = 1.0 + 0.015 * c1;
  float deltaLKlsl = deltaL / (1.0);
  float deltaCkcsc = deltaC / (sc);
  float deltaHkhsh = deltaH / (sh);
  float i = deltaLKlsl * deltaLKlsl + deltaCkcsc * deltaCkcsc + deltaHkhsh * deltaHkhsh;
  return i < 0 ? 0 : sqrt(i);
}

float deltaE(int rgb0, int rgb1) {
  return deltaE(rgb2lab(rgb0), rgb2lab(rgb1));
}
