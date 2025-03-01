
class Solver {
  ArrayList<Body> bodies;
  dVec3[] body_r;
  
  Solver() {
    bodies = new ArrayList<Body>();
  }
  
  double dt = 0.00002;
  double G = 10.0;
  dVec3 a(Body b) {
    dVec3 ac = new dVec3(0, 0, 0);
    for(int i = 0; i < body_r.length; i++) {
      if(i != b.id) {
         dVec3 dir = sub(body_r[i], b.r);
         double r3 = Math.pow(dir.mag2(), 1.5);
         dir.mult(G*bodies.get(i).mass/r3);
         ac.add(dir);
      }
    }
    return ac;
  }
  void add_body(double x, double y, double z, double xv, double yv, double zv, double mass) {
    dVec3 r = new dVec3(x, y, z);
    dVec3 v = new dVec3(xv, yv, zv);
    Body b = new Body(this, r, v, mass, bodies.size());
    bodies.add(b);
  }
  void update(int count) {
    for(int i = 0; i < count; i++) {
      regrab_U();
      for(Body b : bodies) {
        b.updateEuler(dt);
      }
    }
  }
  void display() {
    blendMode(ADD);
    hint(DISABLE_DEPTH_TEST);
    for(Body b : bodies) {
      b.displayTrails();
    }
    hint(ENABLE_DEPTH_TEST);
    blendMode(BLEND);
    for(Body b : bodies) {
      b.display();
    }
  }
  void regrab_U() {
    body_r = new dVec3[bodies.size()];
    for(int i = 0; i < body_r.length; i++) {
      body_r[i] = bodies.get(i).r.copy();
    }
  }
}

class Body {
  dVec3 r;
  dVec3 v;
  Solver parent;
  double mass;
  int id;
  int mycol;
  Trail mytrail;
  int it = 0;
  Body(Solver parent, dVec3 r, dVec3 v, double mass, int id) {
    this.r = r;
    this.v = v;
    this.id = id;
    this.mass = mass;
    this.parent = parent;
    mytrail = new Trail(50000);
    mytrail.add_pt(r);
    mycol = color(random(100, 255), random(100, 255), random(100, 255));
  }
  void updateEuler(double dt) {
    v.add(mult(parent.a(this), dt));
    r.add(mult(v, dt));
    it++; if(it%2000==0) mytrail.add_pt(r);
  }
  void displayTrails() {
    noFill();
    //mytrail.add_pt(r);
    mytrail.display(mycol);
  }
  void display() {
    pushMatrix();
    translate((float)r.x, (float)r.y, (float)r.z);
    fill(mycol);
    noStroke();
    sphere((float)Math.pow(mass, 1.0/3.0));
    popMatrix();
  }
}
