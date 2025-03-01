ArrayList<Bal> bals = new ArrayList<Bal>();
int passedF = 0;
int dnSize = 140;
int[][] dnsa;
void setup() {
  size(400, 800, P2D);
  stroke(255, 255, 255, 40);
  strokeWeight(1f);
  addSphr(200, 200);
  dnsa = new int[dnSize][dnSize];
}
void addSphr(int x, int y) {
  for(float i = 0; i < 20000; i++)
    bals.add(new Bal(x+random(-100, 100), y+random(-100, 100)));
}
void draw() {
  fill(0, 0, 0, 150);
  rect(0, 0, width, height);
  background(0);
  stroke(255, 255, 255, 40);
  for(Bal b:bals) b.updateP();
  //scale(0.5f);
  for(Bal b:bals) {
    for(int i = 0; i < bals.size(); i++)
      b.attract(bals.get(i).p);
    b.drawBal();
  }
  //scale(2f);
  //blur(3);
  //filter(BLUR, 2);
  //blur(1);
  //filter(BLUR, 1);
  drawDNS();
  saveFrame("frame" + passedF + ".jpg");
  passedF++;
  println(passedF);
}
void drawDNS() {
  translate(0, height/2);
  noStroke();
  for(int x = 0; x < dnSize; x++) {
    for(int y = 0; y < dnSize; y++) {
      fill(dnsa[x][y]*2);
      rect(x*width/dnSize, y*height/dnSize/2, 10, 10);
    }
  }
  dnsa = new int[dnSize][dnSize];
}
class Bal {
  PVector p;
  PVector np;
  PVector v;
  PVector a;
  color c;
  public Bal(float x, float y) {
    np = new PVector(0, 0);
    p = new PVector(x, y);
    v = new PVector(0, 0);
    a = new PVector(0, 0);
    float rgbx = (x/(float)width);
    float rgby = (y/(float)height/2);
    color ul = color(255);
    color ur = color(255, 0, 0);
    color ll = color(150, 100, 255);
    color lr = color(255, 100, 0);
    //c = mix(mix(ul, ur, rgbx), mix(ll, lr, rgbx), rgby);
  }
  public void attract(PVector posit) {
    float d = max(dist(p.x, p.y, posit.x, posit.y), 0.0)+1;
    a.x = posit.x-p.x;
    a.y = posit.y-p.y;
    a.normalize();
    float kq = 10f;
    float q = (-d/kq+1);
    float sprongF = q*q*q-2*(-d/kq+1); if(d/kq>2.3) sprongF = 0.05f;
    a.x = a.x*sprongF/8000000f;
    a.y = a.y*sprongF/8000000f;
    v.add(a);
    np.add(v);
  }
  public void updateP() {
    p.add(np);
    np = new PVector(0, 0);
  }
  public void drawBal() {
    //stroke(c);
    point(p.x, p.y);
    if(p.x<width-10&&p.y<width-10&&p.x>10&&p.y>10)
      dnsa[int(p.x/(float)width*(float)dnSize)][int(p.y/(float)width*(float)dnSize)]++;
  }
}

color mix(color a, color b, float x) {
  return color(r(a)*x+r(b)*(1.0-x), g(a)*x+g(b)*(1.0-x), b(a)*x+b(b)*(1.0-x));
}

int r(color c) {return (c >> 16) & 255; }
int g(color c) {return (c >> 8) & 255;}
int b(color c) {return c & 255; }
