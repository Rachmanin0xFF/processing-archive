
//@author Adam Lastowka

float dt = 0.01f;
float p_x = 0.f;

void setup() {
  size(512, 512, P2D);
  background(255);
  stroke(0, 255, 0, 100);
  line(c.r, 0, c.r, height);
}

ArrayList<Float> data = new ArrayList<Float>();
ArrayList<Boolean> qq = new ArrayList<Boolean>();
void draw() {
  background(255);
  
  update_phys();
  data.add(c.x);
  qq.add(c.dir);
  if(data.size() > width) {
    data.remove(0);
    qq.remove(0);
  }
  plotData(0, 0, width, height, data, qq);
  stroke(0, 100);
}

class CubicThing {
  float c = 1.f;
  float a = 0.f;
  float v = 0.1f;
  float x = 0.0f;
  float r = 0.5f;
  boolean dir = false;
  void update_phys3() {
    float t = sqrt(abs(2*v/c));
    float q = 0.f;
    if(v > 0.f)
      q = x - c*t*t*t/6.f;
    else
      q = x + c*t*t*t/6.f;
    float m = (q + r)/2.f;
    if(x < m) {
      dir = true;
      a = c*t;
    } else {
      dir = false;
      a = -c*t;
    }
  }
  void update_phys2() {
    float t = v/c;
    float q = 0.f;
    if(v > 0.f)
      q = x - v*v/2*c;
    if(v < 0.f)
      q = x + v*v/2*c;
    float m = (q + r)/2.f;
    if(x < m) {
      dir = true;
      a = c;
    } else {
      dir = false;
      a = -c;
    }
    if(abs(r - x) + v < 0.1) {
      a /= 3.f;
    }
  }
}

float v = 0.1f;
float x = 0.f;
CubicThing c = new CubicThing();
void update_phys() {
  c.v = v;
  c.x = x;
  c.update_phys2();
  v += c.a*dt;
  x += v*dt;
}

void plotData(float x, float y, float w, float h, ArrayList<Float> data, ArrayList<Boolean> qq) {
  stroke(0, 100);
  line(0, c.r*float(height), width, c.r*float(height));
  noFill();
  stroke(0, 255);
  rect(x, y, w, h);
  color[] dataColors = new color[]{color(200, 200, 0), color(0, 200, 200), color(200, 0, 200), color(200, 0, 0), color(0, 200, 0), color(0, 0, 200)};
  int k = 0;
  for(int i = 0; i < data.size() - 1; i++) {
    if(qq.get(i))
      stroke(255, 0, 0, 255);
    else
      stroke(0, 255, 0, 255);
    line(i, data.get(i)*float(width), i+1, data.get(i+1)*float(width));
  }
}

int clamp(int a, int x, int y) {
  if(x > y) return -1;
  if(a < x) return x;
  if(a > y) return y;
  return a;
}

float clamp(float a, float x, float y) {
  if(x > y) return -1.f;
  if(a < x) return x;
  if(a > y) return y;
  return a;
}
