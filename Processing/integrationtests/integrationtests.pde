boolean advancedEuler = true;

PVector pos = new PVector();
PVector vel = new PVector();
void setup() {
  size(512, 512, P2D);
  background(255);
  smooth(8);
  frameRate(1000);
  //strokeWeight(2);
  //pos = new PVector(width/2.f, height/2.f);
  pos = new PVector(300, 300);
  vel = new PVector(3.f, 0.f);
}
float t = 0.f;
float dt = 0.04f;
float px = 0.f;
float py = 0.f;
void draw() {
  float a = 200;
  float b = 200;
  PVector toTarg = new PVector(a-pos.x, b-pos.y);
  toTarg.normalize();
  PVector acc = new PVector((a-pos.x)*10.f, (b-pos.y)*10.f);
  //acc = new PVector(sin(t)*10.f, cos(t)*10.f);
  acc = new PVector(toTarg.x*10000.f/pow(dist(a, b, pos.x, pos.y), 2.f), toTarg.y*10000.f/pow(dist(a, b, pos.x, pos.y), 2.f));
  PVector np = PVector.add(pos, PVector.mult(vel, dt));
  PVector nv = PVector.add(vel, PVector.mult(acc, dt));
  toTarg = new PVector(a-np.x, b-np.y);
  toTarg.normalize();
  PVector acc2 = new PVector((a-np.x)*10.f, (b-np.y)*10.f);
  //acc2 = new PVector(sin(t+dt)*10.f, cos(t+dt)*10.f);
  acc2 = new PVector(toTarg.x*10000.f/pow(dist(a, b, np.x, np.y), 2.f), toTarg.y*10000.f/pow(dist(a, b, np.x, np.y), 2.f));
  if(advancedEuler) {
    pos.add(PVector.mult(PVector.add(vel, nv), 0.5f*dt));
    vel.add(PVector.mult(PVector.add(acc, acc2), 0.5f*dt));
  } else {
    vel.add(PVector.mult(acc, dt));
    pos.add(PVector.mult(vel, dt));
  }
  t += dt;
  //point(pos.x, pos.y);
  if(t > dt) line(pos.x, pos.y, px, py);
  px = pos.x;
  py = pos.y;
}
