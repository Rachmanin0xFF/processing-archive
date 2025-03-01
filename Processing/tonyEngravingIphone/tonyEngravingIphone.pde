float fh = 2.31f*2400.0f;
float fw = 4.37f*2400.0f;
int w = ceil(fw);
int h = ceil(fh);
float s = 0.6f;
float cmx;
float cmxx;
float cmy;
float cmyy;

int maxIterations = 2048;

void setup() {
  cmx = -fw/(fw+fh)/s;
  cmxx = fw/(fw+fh)/s;
  cmy = -fh/(fw+fh)/s;
  cmyy = fh/(fw+fh)/s;
  
  size(w, h, P2D);
  println(w);
  println(h);
  dispFractal();
  saveFrame("imageOut-" + year() + "-" + month() + "-" + day() + "-" + hour() + "-" + minute() + "-" + second());
  println("Done.");
}

void dispFractal() {
  for(float x = 0; x < w; x++) {
    if(random(10)>9) {
      println("Est time left: " + ((float(millis())/1000.0f)/x)*(fw-x) + "\nPercent Done: " + x/fw*100.0f);
    }
    for(float y = 0; y < h; y++) {
      color c = color(doPt(mapX(x), mapY(y)) * 255.0f);
      set((int)x, (int)y, c);
    }
  }
}

float mapX(float x) {
  return map(x, 0, w, cmx, cmxx);
}

float mapY(float y) {
  return map(y, 0, h, cmy, cmyy);
}

/*
float smoothcolor = exp(-length(v));

  for ( int i = 0 ; i < max_iterations; i++ ) {
    v = c + complex_square( v );
    smoothcolor += exp(-length(v));
    if ( dot( v, v ) > 4.0 ) {
      break;
    
*/
float doPt(float x, float y) {
  Complex c = new Complex(-0.6016374, -0.421682);
  Complex v = new Complex(x, y);
  float smoothColor = exp(-v.getAbs());
  
  float i = 0.0f;
  for(i = 0.0f; i < maxIterations; i++) {
    v.square();
    v.addC(c);
    smoothColor += exp(-v.getAbs());
    if(v.getAbsSquared() > 4.0f)
      break;
  }
  return smoothColor/float(maxIterations)*1.5f;
}


class Complex {
  float real;
  float imag;
  public Complex(float re, float im) {
    real = re;
    imag = im;
  }
  void square() {
    float nreal = real*real - imag*imag;
    float nimag = 2*real*imag;
    real = nreal;
    imag = nimag;
  }
  void addC(Complex c) {
    real += c.real;
    imag += c.imag;
  }
  void addC(float re, float im) {
    real += re;
    imag += im;
  }
  float getAbs() {
    return sqrt(real*real + imag*imag);
  }
  float getAbsSquared() {
    return real*real + imag*imag;
  }
}
