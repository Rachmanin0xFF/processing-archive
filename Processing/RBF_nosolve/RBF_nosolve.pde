
import peasy.PeasyCam;


PeasyCam cam;
int gs = 512;

ArrayList<PVector> pts = new ArrayList<PVector>();
void setup() {
  size(1600, 900, P3D);
  strokeCap(SQUARE);
  noSmooth();
  hint(DISABLE_DEPTH_TEST);
  cam = new PeasyCam(this, 400);
}
float zoom = 100;
void draw() {
  background(0);
  stroke(255);
  strokeWeight(5);
  blendMode(ADD);
  for(PVector p : pts) point(p.x*zoom, p.y*zoom, p.z*zoom);
  strokeWeight(1);
  stroke(120, 40, 255);
  for(float x = -(float)gs/zoom/2.f; x < (float)gs/zoom/2.f; x+= 1.f/(float)zoom) {
    for(float y = -(float)gs/zoom/2.f; y < (float)gs/zoom/2.f; y+= 1.f/(float)zoom) {
      point(x*zoom, y*zoom, approx_f(x, y)*zoom);
    }
  }
  blendMode(BLEND);
}

float approx_f(float x, float y) {
  float weight_total = 0;
  float z = 0;
  for(PVector p : pts) {
    float rf = RBF(sqrt((x - p.x)*(x - p.x) + (y - p.y)*(y - p.y)));
    z += rf * p.z;
    weight_total += rf;
  }
  z /= weight_total;
  return z;
}

float RBF(float x) {
  return 1.f/(x*x*x + 0.01);
  //float xs = x*2;
  //if(xs < -1 || xs > 1) return 0;
  //return exp(-1/(1-xs*xs));
}

void keyPressed() {
  float x = random(-2, 2);
  float y = random(-2, 2);
  pts.add(new PVector(x, y, f(x, y)));
}

float f(float x, float y) {
  return cos(x*2) + cos(y*2);
}
