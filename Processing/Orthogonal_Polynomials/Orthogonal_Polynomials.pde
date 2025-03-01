
final int ORDER = 24;


void setup() {
  size(500, 900, P2D);
  Polynomial p = new Polynomial();
  p.c[4] = 3;
  p.c[2] = 1;
  p.c[0] = 51;
  p.print_();
  derivative(p).print_();
  Legendre(4).print_();
}

void draw() {
  background(0);
  stroke(255);
  strokeWeight(2);
  println("");
  for(int j = mouseY/30; j < 2+mouseY/30; j++) {
    float sum = 0.0;
    for(int i = 0; i < width; i++) {
      float x = map(i, 0, width, 0, 20.0);
      float y = eval_P_dirty(j, max(0, mouseY/30), x);
      y = eval_L(generalized_Laguerre(mouseX/30, mouseY/30), mouseX/30, mouseY/30, x);
      sum += y*(1.0/(float)width)*2.0;
      point(i, map(y, -1, 1, height, 0));
    }
  }
  fill(255);
  text("k:" + max(0, mouseX/30) + " a:" + max(0, mouseY/30), 20, 20);
  //Legendre(mouseX/30).print_();
  generalized_Laguerre(mouseX/30, mouseY/30).print_();
}



Polynomial derivative(Polynomial p) {
  Polynomial o = new Polynomial(p);
  for(int i = 1; i < ORDER; i++) {
    o.c[i-1] = i*o.c[i];
  }
  return o;
}
Polynomial multx(Polynomial p) {
  Polynomial o = new Polynomial();
  for(int i = ORDER-1; i > 0; i--) {
    o.c[i] = p.c[i-1];
  }
  return o;
}
Polynomial mult(Polynomial p, float a) {
  Polynomial o = new Polynomial();
  for(int i = ORDER-1; i >= 0; i--) {
    o.c[i] = p.c[i]*a;
  }
  return o;
}
Polynomial add(Polynomial p, Polynomial q) {
  Polynomial o = new Polynomial();
  for(int i = ORDER-1; i >= 0; i--) {
    o.c[i] = p.c[i] + q.c[i];
  }
  return o;
}
Polynomial sub(Polynomial p, Polynomial q) {
  Polynomial o = new Polynomial();
  for(int i = ORDER-1; i >= 0; i--) {
    o.c[i] = p.c[i] - q.c[i];
  }
  return o;
}

float fctr(int n) {
  float x = 1;
  for(int i = 1; i <= n; i++) x *= i;
  return x;
}


// Many thanks for Justin Willmert for his writeup:
// https://justinwillmert.com/articles/2020/pre-normalizing-legendre-polynomials/

Polynomial associated_Legendre(int l, int m) {
  if(m > l) return new Polynomial();
  Polynomial o = new Polynomial();
  //o.c[0] = 1; // STANDARD NORM
  o.c[0] = 0.28209479177; // SH NORM = sqrt(1/(4PI))
  int ll = 0;
  int mm = 0;
  
  // (m++,l++)
  for(; mm < m; mm++) {
    ll++;
    //float u_l = 2.0*ll-1.0; // STANDARD NORM
    float u_l = sqrt(1.0+1.0/(2.0*ll)); // SH NORM
    o = mult(o, -u_l);
  }
  if(l==m) return o;
  
  // l++ (first step)
  Polynomial m1 = new Polynomial(o); // save state for recurrence later
  ll++;
  //float v_l = 2.0*ll-1.0; // STANDARD NORM
  float v_l = sqrt(1.0+2.0*ll); // SH NORM
  o = mult(multx(o), v_l);
  if(l==ll) return o;
  
  // l++
  Polynomial m0 = new Polynomial(o);
  for(; ll < l;) {
    ll++;
    //float a = (2.0*ll-1.0)/(ll-mm); // STANDARD NORM
    //float b = (ll+mm-1.0)/(ll-mm); // STANDARD NORM
    
    float c = (2.0*ll+1.0)/((2.0*ll-3.0)*(ll*ll-mm*mm));
    float a = sqrt(c*(4.0*(ll-1.0)*(ll-1.0)-1.0)); // SH NORM
    float b = sqrt(c*((ll-1.0)*(ll-1.0)-mm*mm)); // SH NORM
    
    o = add(mult(multx(m0), a), mult(m1, -b));
    m1 = new Polynomial(m0);
    m0 = new Polynomial(o);
  }
  return o;
}


float eval_P_dirty(int l, int m, float x) {
  //return Pgn(l, m, x);
  return pow(1-x*x, (float)m/2.0)*eval(associated_Legendre(l, m), x);
}
float eval(Polynomial p, float x) {
  float y = 0;
  float xx = 1;
  for(int i = 0; i < ORDER; i++) {
    y += p.c[i]*xx;
    xx *= x;
  }
  return y;
}

float eval_L(Polynomial p, int n, int l, float x) {
  float y = eval(p, 2.0*x/(float)n);
  y *= sqrt(8.0/(n*n*n)*fctr(n-l-1)/(2*n*pow(fctr(n+l), 3)));
  y *= exp(-x/(float)n);
  y *= pow(2.0*x/n, l);
  return y;
}

Polynomial generalized_Laguerre(int n, int l) {
    int kmax = n-l-1;
    Polynomial o = new Polynomial();
    o.c[0] = 1.0;
    if(kmax<=0) return o;
    
    Polynomial m1 = new Polynomial(o);
    float a = 2*l+1;
    o.c[0] = 1.0+a; o.c[1] = -1.0;
    if(kmax==1) return o;
    
    Polynomial m0 = new Polynomial(o);
    for(int kk = 1; kk<kmax; kk++) {
        o = mult(sub(sub(mult(m0,2*kk+1+a), multx(m0)), mult(m1, kk+a)), 1.0/(kk+1.0));
        m1 = new Polynomial(m0);
        m0 = new Polynomial(o);
    }
    return o;
}

Polynomial Legendre(int i) {
  Polynomial c = new Polynomial();
  Polynomial cm1 = new Polynomial();
  Polynomial cm2 = new Polynomial();
  
  cm1.c[1] = 1;
  cm2.c[0] = 1;
  if(i < 2) {
    return i == 0 ? cm2 : cm1;
  }
  
  float n = 2.0;
  for(int j = 0; j < i-1; j++) {
    c = mult(add(mult(multx(cm1), 2*n-1), mult(cm2, 1-n)), 1.0/n);
    n++;
    cm2 = new Polynomial(cm1);
    cm1 = new Polynomial(c);
  }
  return c;
}

class Polynomial {
  float[] c;
  Polynomial() {
    c = new float[ORDER];
  }
  Polynomial(Polynomial p) {
    c = new float[ORDER];
    for(int i = 0; i < ORDER; i++) c[i] = p.c[i];
  }
  
  void print_() {
    println();
    for(int n = 0; n < ORDER; n++) {
      if(c[n] != 0)
      print(c[n] + (n!=0?"x^":"") + n + " + ");
    }
    println();
  }
}
