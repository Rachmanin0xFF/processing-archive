final float EPSILON = 1;

class Cpl {
  float re;
  float im;
  Cpl() { re = 0; im = 0; }
  Cpl(float x) { re = x; im = 0; }
  Cpl(Cpl c) { re = c.re; im = c.im; }
  Cpl(float x, float y) { re = x; im = y; }
  void add(Cpl c) { re += c.re; im += c.im; }
  void mult(float f) { re *= f; im *= f; }
}

Cpl rand() {
  float r = randomGaussian();
  float theta = random(TWO_PI);
  return new Cpl(r*cos(theta), r*sin(theta));
}

Cpl mult(Cpl x, Cpl y) {
  return new Cpl(x.re*y.re - x.im*y.im, x.re*y.im + x.im*y.re);
}
Cpl add(Cpl x, Cpl y) {
  return new Cpl(x.re + y.re, x.im + y.im);
}
Cpl sub(Cpl x, Cpl y) {
  return new Cpl(x.re - y.re, x.im - y.im);
}
Cpl toC(float x) {
  return new Cpl(x);
}
Cpl toC(float x, float y) {
  return new Cpl(x, y);
}
float mag2(Cpl c) {
  return c.re*c.re + c.im*c.im;
}
Cpl mult(Cpl x, float f) {
  return new Cpl(x.re*f, x.im*f);
}
float mod(Cpl c) {
  return sqrt(mag2(c));
}
float arg(Cpl c) {
  return atan2(c.im, c.re);
}
Cpl clamp(Cpl c) {
  if(c.re < 0) return mult(c, 0.1);
  return c;
  //return mult(c, 1.0 / (mag2(c) + EPSILON));
}
