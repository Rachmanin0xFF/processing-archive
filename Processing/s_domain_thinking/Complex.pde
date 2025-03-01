class Cpl {
  float re;
  float im;
  Cpl(float a, float b) {
    re = a;
    im = b;
  }
}
float mod(Cpl z) {
  return sqrt(z.re*z.re+z.im*z.im);
}
float abs(Cpl z) {
  return mod(z);
}
float arg(Cpl z) {
  return atan2(z.im, z.re);
}
Cpl mult(Cpl z, float a) {
  return new Cpl(z.re*a, z.im*a);
}
Cpl div(Cpl z, float a) {
    return new Cpl(z.re/a, z.im/a);
}
Cpl mult(Cpl a, Cpl b) {
  return new Cpl(a.re*b.re - a.im*b.im, a.re*b.im + a.im*b.re);
}
Cpl div(Cpl a, Cpl b) {
  float r2 = 1.0/(b.re*b.re + b.im*b.im);
  return new Cpl(r2*(a.re*b.re+a.im*b.im), r2*(a.im*b.re - a.re*b.im));
}
Cpl add(Cpl a, Cpl b) {
  return new Cpl(a.re + b.re, a.im + b.im);
}
Cpl sub(Cpl a, Cpl b) {
  return new Cpl(a.re - b.re, a.im - b.im);
}
Cpl exp(Cpl z) {
  float r = exp(z.re);
  return new Cpl(r*cos(z.im), r*sin(z.im));
}
Cpl conj(Cpl z) {
  return new Cpl(z.re, -z.im);
}
Cpl pow(Cpl z, int n) {
  float r = pow(mod(z), n);
  float phi = arg(z);
  return new Cpl(r*cos(n*phi), r*sin(n*phi));
}
