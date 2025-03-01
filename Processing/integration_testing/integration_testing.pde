

System sys;

void setup() {
  size(1600, 900, P2D);
  background(0);
  stroke(255);
  smooth(16);
}

void draw() {
  background(0);
  
  stroke(50, 140, 255);
  strokeWeight(4);
  for(int i = 0; i < 1000; i++) {
    point(i*10, height*exp(-0.3*(i/10.0)));
  }
  stroke(255, 255, 255);
  strokeWeight(1);
  
  beginShape();
  noFill();
  sys = new System(new d3List(new dVec3[]{new dVec3(0, height, 0)}));
  for(int i = 0; i < 1000; i++) {
    vertex((float)sys.s.r.r[0].x, (float)sys.s.r.r[0].y);
    if(mousePressed) {
      sys.adams_bashforth();
    } else sys.explicit_euler();
  }
  endShape();
  
}

d3List drdt(State s) {
  d3List o = new d3List(s.r);
  for(int i = 0; i < o.r.length; i++) {
    o.r[i].mult(-0.3);
    o.r[i].x = 100;
  }
  return o;
}

class ButcherTableau {
  double[][] c;
  double[] a;
  double[] b;
  ButcherTableau(double[] aa, double[][] cc) {
    a = aa;
    c = cc;
  }
}


class System {
  State s;
  ArrayList<d3List> H = new ArrayList<d3List>();
  double dt0;
  public System(d3List r) {
    s = new State(r);
    dt0 = 0.5;
  }
  void explicit_euler() {
    d3List drdt0 = drdt(s);
    s.r.add(mult(drdt0, dt0));
  }
  void adams_bashforth() {
    d3List drdt0 = drdt(s);
    double dt = H.size() == 4 ? dt0 : dt0*0.1;
    switch(H.size()) {
      case 0:
        s.r.add(mult(drdt0, dt));
        break;
      case 1:
        s.r.add(add(mult(drdt0, 1.5*dt), mult(H.get(0), -0.5*dt)));
        break;
      case 2:
        s.r.add(add(mult(drdt0, dt*23.0/12.0), add(mult(H.get(1), -dt*4.0/3.0), mult(H.get(0), dt*5.0/12.0))));
        break;
      case 3:
        s.r.add(add(add(mult(drdt0, dt*55.0/24.0), mult(H.get(2), -dt*59.0/24.0)), add(mult(H.get(1), dt*37.0/24.0), mult(H.get(0), -dt*9.0/24.0))));
        break;
      case 4:
        s.r.add(add(mult(drdt0, dt*1901.0/720.0), add(add(mult(H.get(3), -dt*2774.0/720.0), mult(H.get(2), dt*2616.0/720.0)), add(mult(H.get(1), -dt*1274.0/720.0), mult(H.get(0), dt*251.0/720.0)))));
        H.remove(0);
        break;
    }
    H.add(drdt0);
  }
}

class State {
  d3List r;
  State(){}
  State(d3List rr){
    r = rr;
  }
  State(State s) {
    r = new d3List(s.r);
  }
}



class d3List {
  dVec3[] r;
  d3List(dVec3[] v) {
    r = v;
  }
  d3List(d3List s) {
    r = new dVec3[s.r.length];
    for(int i = 0; i < r.length; i++) r[i] = s.r[i].copy();
  }
  void add(d3List a) {
    for(int i = 0; i < a.r.length; i++) r[i].add(a.r[i]);
  }
}
d3List add(d3List a, d3List b) {
  d3List o = new d3List(a);
  for(int i = 0; i < a.r.length; i++) o.r[i].add(b.r[i]);
  return o;
}
d3List sub(d3List a, d3List b) {
  d3List o = new d3List(a);
  for(int i = 0; i < a.r.length; i++) o.r[i].sub(b.r[i]);
  return o;
}
d3List mult(d3List a, double b) {
  d3List o = new d3List(a);
  for(int i = 0; i < a.r.length; i++) o.r[i].mult(b);
  return o;
}
