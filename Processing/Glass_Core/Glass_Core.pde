OBJ b;
void setup() {
  size(512, 512, P2D);
  strokeWeight(2);
  b = new OBJ(0, height/2);
  background(255);
  frameRate(1000000);
  line(0, height/2.f, width, height/2.f);
}
int passed_frames = 0;
void draw() {
  b.update();
  point(b.status.p.x, b.status.p.y);
  t += delta_t;
  passed_frames++;
}

float t = 0.f;
float delta_t = 0.06f;
public class OBJ {
  State status;
  public OBJ() {
    status = new State();
  }
  public OBJ(State s) {
    status = cp(s);
  }
  public OBJ(float x, float y) {
    status = new State(x, y, 0, 0);
  }
  void update() {
    RK4_Integrate(status, t, delta_t);
    //explicit_Euler_Integrate(status, t, delta_t);
    //implicit_Euler_Integrate(status, t, delta_t);
    //improved_Euler_Integrate(status, t, delta_t);
  }
  public void explicit_Euler_Integrate(State s, float t, float dt) {
     s.v.add(PVector.mult(acceleration(s, t + dt), dt));
     s.p.add(PVector.mult(s.v, dt));
  }
  public void implicit_Euler_Integrate(State s, float t, float dt) {
     s.p.add(PVector.mult(s.v, dt));
     s.v.add(PVector.mult(acceleration(s, t + dt), dt));
  }
  public void improved_Euler_Integrate(State s, float t, float dt) {
    Derivative a = Evaluate(s, t, 0.f, new Derivative());
    Derivative b = Evaluate(s, t, dt*0.5f, new Derivative());
    PVector dpdt2 = PVector.add(a.dp, b.dp);
    PVector dvdt2 = PVector.add(a.dv, b.dv);
    s.p.add(PVector.mult(b.dp, dt));
    s.v.add(PVector.mult(b.dv, dt));
  }
  public void RK4_Integrate(State s, float t, float dt) {
    Derivative a = Evaluate(s, t, 0.f, new Derivative());
    Derivative b = Evaluate(s, t, dt*0.5f, a);
    Derivative c = Evaluate(s, t, dt*0.5f, b);
    Derivative d = Evaluate(s, t, dt, c);
    PVector dpdt6 = PVector.add(PVector.add(a.dp, PVector.mult(PVector.add(b.dp, c.dp), 2.f)), d.dp);
    PVector dvdt6 = PVector.add(PVector.add(a.dv, PVector.mult(PVector.add(b.dv, c.dv), 2.f)), d.dv);
    s.p.add(PVector.mult(dpdt6, dt/6.f));
    s.v.add(PVector.mult(dvdt6, dt/6.f));
  }
  public Derivative Evaluate(State initial, float t, float dt, Derivative d) {
    State s = new State();
    s.p = PVector.add(cp(initial.p), PVector.mult(cp(d.dp), dt));
    s.v = PVector.add(cp(initial.v), PVector.mult(cp(d.dv), dt));
    Derivative o = new Derivative();
    o.dp = s.v;
    o.dv = acceleration(s, t + dt);
    return o;
  }
  public PVector acceleration(State s, float t) {
    return new PVector(sin(t)*10.f, cos(t)*10.f);
  }
}

public State cp(State s) {
  return new State(cp(s.p), cp(s.v));
}

public Derivative cp(Derivative s) {
  return new Derivative(cp(s.dp), cp(s.dv));
}

public PVector cp(PVector p) {
  return new PVector(p.x, p.y, p.z);
}

class State {
  PVector p;
  PVector v;
  public State() {
    p = new PVector();
    v = new PVector();
  }
  public State(PVector p, PVector v) {
    this.p = cp(p);
    this.v = cp(v);
  }
  public State(float x0, float y0, float z0, float x1, float y1, float z1) {
    this.p = new PVector(x0, y0, z0);
    this.v = new PVector(x1, y1, z1);
  }
  public State(float x0, float y0, float x1, float y1) {
    this.p = new PVector(x0, y0);
    this.v = new PVector(x1, y1);
  }
}

class Derivative {
  public PVector dp;
  public PVector dv;
  public Derivative() {
    dp = new PVector();
    dv = new PVector();
  }
  public Derivative(PVector dx, PVector dv) {
    this.dp = cp(dp);
    this.dv = cp(dv);
  }
  public Derivative(float x0, float y0, float z0, float x1, float y1, float z1) {
    this.dp = new PVector(x0, y0, z0);
    this.dv = new PVector(x1, y1, z1);
  }
  public Derivative(float x0, float y0, float x1, float y1) {
    this.dp = new PVector(x0, y0);
    this.dv = new PVector(x1, y1);
  }
}
