import peasy.*;
PeasyCam cam;


void setup() {
  size(1280, 720, P3D);
  cam = new PeasyCam(this, 100);
}

void draw() {
  background(0);
  stroke(255, 255, 100);
  strokeWeight(40);
  float t = millis()/10000.f;
  float w = 10.51;
  float b = 100;
  for(int i = 0; i < 10000; i++) {
    plot(b, w*t, PI/2.0*(1.0 + 0.25*cos(4.0*w*t)));
    strokeWeight(3);
    t += 0.01;
  }
}


PVector pp = new PVector();
void plot(float r, float phi, float theta) {
  point(r*sin(theta)*cos(phi), r*sin(theta)*sin(phi), r*cos(theta));
  PVector p = new PVector(r*sin(theta)*cos(phi), r*sin(theta)*sin(phi), r*cos(theta));
  if(random(1000) > 999) println(PVector.sub(p, pp).mag());
  pp = new PVector(p.x, p.y, p.z);
}
