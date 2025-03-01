
Camzy camera = new Camzy();
QSpace1D universe;

Slider iter = new Slider(10, 10, 400, 50, "Iterations");
Slider deltort = new Slider(10, 70, 400, 50, "Delta-t");
Theme t = new Theme(color(0, 0), color(255, 255));

void setup() {
  size(1600, 900, P3D);
  frameRate(100);
  noSmooth();
  
  iter.set_theme(t);
  deltort.set_theme(t);
  deltort.set_value(0.1f);
  
  universe = new QSpace1D(12000, 0.001f, 0.d);
}

void draw() {
  background(0);
  pushMatrix();
  camera.update();
  camera.applyRotations();
  
  blendMode(ADD);
  hint(DISABLE_DEPTH_TEST);
  colorMode(HSB);
  
  strokeWeight(1.5f/camera.zoom);
  for(int i = 0; i < max(1, iter.value*20); i++) universe.update();
  universe.display(1.f, 1.f);
  
  hint(ENABLE_DEPTH_TEST);
  blendMode(BLEND);
  colorMode(RGB);
  camera.drawThing();
  popMatrix();
  
  strokeWeight(1);
  iter.update();
  deltort.update();
  iter.display();
  deltort.display();
  universe.dt = 0.00001d*deltort.value;
}

double tau = 6.283185307179586476925286766559d;
double planck = 1.d;
double h_bar = planck/tau;

class QSpace1D {
  Sample[] space;
  int len;
  double sep;
  double dt;
  QSpace1D(int len, float separation, double delta_t) {
    this.len = len;
    sep = separation;
    dt = delta_t;
    space = new Sample[len];
    for(int i = 0; i < len; i++) {
      space[i] = new Sample(index_to_x(i));
    }
    double sum = 0.d;
    for(int i = 0; i < len; i++) {
      sum += abs2(space[i].psi);
    }
    for(int i = 0; i < len; i++) space[i].psi = div(space[i].psi, sum);
    println("Created 1D space with array length of " + len + " and separation of " );
  }
  void display(double xscale, double rscale) {
    noFill();
    for(int i = 0; i < len; i++) {
      if(i == len/2 - 100) strokeWeight(4.5f/camera.zoom);
      float xpos = (float)index_to_x(i);
      translate(xpos, 0, 0);
      rotateY(PI/2.f);
      stroke((float)(ang(space[i].psi)/tau + 0.5)*255.f, 160.f, 255.f, 20.f);
      
      Complex disp = space[i].psi;
      
      float magnitude = (float)(Math.sqrt(abs2(disp))*rscale);
      ellipse(0, 0, magnitude, magnitude);
      rotateY(-PI/2.f);
      line(0, 0, 0, 0, (float)(rscale*disp.Re)/2.f, (float)(rscale*disp.Im)/2.f);
      translate(-xpos, 0, 0);
      if(i == len/2 - 100)  {
        println(Math.sqrt(abs2(disp)));
        strokeWeight(1.5f/camera.zoom);
      }
    }
  }
  double index_to_x(int i) {
    return (double)(sep*(double)(i-len/2));
  }
  void update() {
    for(int i = 1; i < len-1; i++) {
      Complex dx_a = div(sub(space[i].psi, space[i-1].psi), sep);
      Complex dx_b = div(sub(space[i+1].psi, space[i].psi), sep);
      space[i].dx2 = div(sub(dx_b, dx_a), sep);
    }
    double mass_or_whatever = 20.d;
    for(int i = 0; i < len; i++) {
      // Compute V(x)/hbar and hbar/(2m)∂^2psi/∂x^2
      Complex potentialTerm = mul(space[i].psi, V(index_to_x(i))/h_bar);
      Complex differentialTerm = mul(space[i].dx2, h_bar/(mass_or_whatever*2.d));
      
      // Divide sum of previous two terms by i (sqrt(-1)) and multiply by dt
      Complex statement = div(sub(potentialTerm, differentialTerm), new Complex(0, 1.d));
      
      // Integrate using standard explicit euler integration
      space[i].psi = add(space[i].psi, mul(statement, dt));
    }
    double sum = 0.d;
    for(int i = 0; i < len; i++) {
      sum += abs2(space[i].psi);
    }
    sum = Math.sqrt(sep*sum);
    for(int i = 0; i < len; i++) space[i].psi = div(space[i].psi, sum);
  }
  double V(double x) {
    return 0.d;
  }
}

float k = 1.f;

class Sample {
  Complex psi;
  Complex dx2;
  Complex dt;
  public Sample(double xpos) {
    psi = new Complex(0.d, 0.d);
    double p = 0.d;
    double prob = Math.pow(2.71828, -((xpos-p)*(xpos-p)*2.d));
    //psi = new Complex(prob, 0.d);
    double p2 = 0.3d;
    double prob2 = 0.d*Math.pow(2.71828, -((xpos-p2)*(xpos-p2)*2.d));
    psi = new Complex(sin(k)*prob + sin(-k*2.f)*prob2/2.f, cos(k)*prob + cos(-k*2.f)*prob2/2.f);
    k += 0.01f;
    dx2 = new Complex(0.d, 0.d);
    dt = new Complex(0.d, 0.d);
  }
}

public class Complex {
  double Re;
  double Im;
  public Complex() {
    Re = 0.d;
    Im = 0.d;
  }
  public Complex(double Re, double Im) {
    this.Re = Re;
    this.Im = Im;
  }
}

public Complex add(Complex a, Complex b) {
  // (a + bi) + (c + di)
  return new Complex(a.Re + b.Re, a.Im + b.Im);
}

public Complex sub(Complex a, Complex b) {
  // (a + bi) - (c + di)
  return new Complex(a.Re - b.Re, a.Im - b.Im);
}

public Complex mul(Complex a, double x) {
  // x(a + bi)
  return new Complex(a.Re*x, a.Im*x);
}

public Complex div(Complex dividend, double divisor) {
  // (a + bi)/x
  return new Complex(dividend.Re/divisor, dividend.Im/divisor);
}

public Complex mul(Complex a, Complex b) {
  // (a + bi)(c + di)
  return new Complex(a.Re*b.Re - a.Im*b.Im, a.Im*b.Re + a.Re*b.Im);
}

public Complex div(Complex dividend, Complex divisor) {
  // (a + bi)/(c + di)
  double a = dividend.Re;
  double b = dividend.Im;
  double c = divisor.Re;
  double d = divisor.Im;
  return new Complex((a*c + b*d)/(c*c + d*d), (b*c - a*d)/(c*c + d*d));
}

public Complex conj(Complex a) {
  // (a + bi)*
  return new Complex(a.Re, -a.Im);
}

public double abs2(Complex a) {
  // |(a+bi)|^2
  // Alternatively, mul(a, conj(a)) gives the same result...
  // |x|^2 = (x)(x*) for some complex x
  return a.Re*a.Re + a.Im*a.Im;
}

public double ang(Complex a) {
  // Returns atan2(b, a) when given (a + bi)
  return Math.atan2(a.Im, a.Re);
}