void setup() {
  size(1600, 900, P2D);
  
}

void draw() {
  background(0);
}

void plot_complex(Function f) {
  
}

//cpl laplace(Function a, cpl s) {
//  
//}

class Function {
  Function(){}
  
  cpl eval(cpl x) {
    return div(new cpl(1, 0), x);
  }
  
  cpl eval_L(cpl s) {
    return null;
  }
}


// simple complex number class
class cpl {
  float re; // cartesian form
  float im;
  
  float r; // polar form
  float t;

  cpl() {}
  cpl(float a, float b) {
    re = a;
    im = b;
  }
  void gen_polar() {
    t = atan2(im, re);
    r = sqrt(re*re+im*im);
  }
  void gen_rect() {
    re = r*cos(t);
    im = r*sin(t);
  }
}

cpl mult(cpl a, cpl b) {
  return new cpl(a.re*b.re - a.im*b.im, a.re*b.im + b.re*a.im);
}

cpl conj(cpl a) {
  return new cpl(a.re, -a.im);
}

cpl dot(cpl a, cpl b) {
  return mult(conj(a), b);
}

cpl div(cpl x1, cpl x2) {
  float a = x1.re;
  float b = x1.im;
  float c = x2.re;
  float d = x2.im;
  
  float br2 = c*c+d*d;
  return new cpl((a*c+b*d)/br2, (b*c-a*d)/br2);
}
