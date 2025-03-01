
void setup() {
  size(512, 512, P3D);
  ortho();
  background(0);
  stroke(100, 255, 100);
}


//@author Adam Lastowka
final float D_T = 0.01f;

void draw() {
  background(0);
  
}

class Rocket {
  PVector r;
  PVector v;
  PVector a;
  float mass = 0.f;
  float 
  public Rocket(float x, float y, float z) {
    r = new PVector(x, y, z);
  }
  void update() {
    v.add(PVector.mult(a, D_T));
    r.add(PVector.mult(v, D_T));
  }
} 
