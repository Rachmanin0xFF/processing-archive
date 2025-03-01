String datapath = "embedding.csv";
ArrayList<LerpyLine> net = new ArrayList<LerpyLine>();

PVector bmin = new PVector();
PVector bmax = new PVector();

class LerpyLine {
  Line l1;
  Line l2;
  public LerpyLine(Line a, Line b) {
    l1 = a;
    l2 = b;
  }
  void draw2D(float a) {
    PVector p1 = PVector.lerp(l1.v1, l2.v1, constrain(a, 0.0, 1.0));
    PVector p2 = PVector.lerp(l1.v2, l2.v2, constrain(a, 0.0, 1.0));
    
    line(p1.x, p1.y, p2.x, p2.y);
  }
  void draw3D(float a) {
    PVector p1 = PVector.lerp(l1.v1, l2.v1, constrain(a, 0.0, 1.0));
    PVector p2 = PVector.lerp(l1.v2, l2.v2, constrain(a, 0.0, 1.0));
    
    line(p1.x, p1.y, p1.z, p2.x, p2.y, p2.z);
  }
}

void update_minmax(PVector v) {
  if(v.x < bmin.x) bmin.x = v.x;
  if(v.y < bmin.y) bmin.y = v.y;
  if(v.z < bmin.z) bmin.z = v.z;
  if(v.x > bmax.x) bmax.x = v.x;
  if(v.y > bmax.y) bmax.y = v.y;
  if(v.z > bmax.z) bmax.z = v.z;
}

class Line {
  PVector v1;
  PVector v2;
  public Line(PVector a, PVector b) {
    v1 = a;
    v2 = b;
  }
  public Line(float x0, float y0, float z0, float x1, float y1, float z1) {
    v1 = new PVector(x0, y0, z0);
    v2 = new PVector(x1, y1, z1);
    update_minmax(v1);
    update_minmax(v2);
  }
}

void setup() {
  size(650, 550, P2D);
  smooth(16);
  background(255);
  stroke(25);
  strokeWeight(3);
  String[] table;
  table = loadStrings(datapath);
  for(int i = 1; i < table.length; i += 3) {
    String[] parts1 = table[i].split(",");
    String[] parts2 = table[i+1].split(",");
    
    float xA = -float(parts1[0]);
    float yA = -float(parts1[1]);
    float zA = float(parts1[2]);
    
    float xA0 = float(parts1[3]);
    float yA0 = float(parts1[4]);
    float zA0 = float(parts1[5]);
    
    float xB = -float(parts2[0]);
    float yB = -float(parts2[1]);
    float zB = float(parts2[2]);
    
    float xB0 = float(parts2[3]);
    float yB0 = float(parts2[4]);
    float zB0 = float(parts2[5]);
    
    Line end = new Line(xA, yA, zA, xB, yB, zB);
    Line start = new Line(xA0, yA0, zA0, xB0, yB0, zB0);
    
    LerpyLine ll = new LerpyLine(start, end);
    net.add(ll);
  }
}

float sms(float x) {
  if(x <= 0) return 0;
  if(x >= 1) return 1;
  return x * x * x * (x * (6.0f * x - 15.0f) + 10.0f);
}

boolean up = true;
final float dt = 0.05;
final float r = 0.2;
float a = -r;
void draw() {
  background(255);
  float radius = PVector.sub(bmin, bmax).mag();
  translate(width/2, height/2);
  //rotateX(-0.5);
  //rotateY(frameCount/200.0);
  strokeWeight(7);
  
  scale(1.0*(float)width/radius);
  int maxf = 100;
  
  
  if(up) {
    a += dt;
    if(a > r+1.0) up = false;
  } else {
    a -= dt;
    if(a < -r) {
      up = true;
      noLoop();
    }
  }
  for(LerpyLine ll : net) {
    ll.draw2D(sms(a));
  }
  saveFrame("output/frame_" + frameCount + ".png");
}
