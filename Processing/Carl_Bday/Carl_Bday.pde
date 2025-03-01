PImage src;
PGraphics g;
ArrayList<Circ> circs = new ArrayList<Circ>();
void setup() {
  size(1280, 720, P2D);
  src = loadImage("source.png");
  src.loadPixels();
  g = createGraphics(1920, 1080, P2D);
  g.beginDraw();
  g.background(0, 0, 0);
  //g.image(src, 0, 0);
  g.noStroke();
  
  for(int j = 0; j < 10000; j++) {
    PVector p = get_white();
    float rad = 10;
    for(int i = 0; i < circs.size(); i++) {
      rad = min(rad, circs.get(i).biggest_at2(p.x, p.y));
    }
    println(rad);
    if(rad > 2) {
      circs.add(new Circ(p.x, p.y, rad));
    }
  }
  
  g.endDraw();
}

PVector get_white() {
  while(true) {
    PVector p = new PVector(random(src.width), random(src.height));
    if(src.get((int)p.x, (int)p.y) != color(0, 255)) return p;
  }
}

void draw() {
  g.beginDraw();
  g.background(0);
  for(int i = 0; i < circs.size(); i++) {
    if(frameCount > 10) circs.get(i).update1(i);
  }
  for(int i = 0; i < circs.size(); i++) {
    if(frameCount > 10) circs.get(i).update2();
   circs.get(i).update_col();
    g.ellipse(circs.get(i).r.x, circs.get(i).r.y, circs.get(i).rad*2, 2*circs.get(i).rad);
  }
  g.endDraw();
  image(g, 0, 0, width, height);
  println("ok");
  if(frameCount%5==0) saveFrame(frameCount + ".png");
}

class Circ {
  float rad;
  PVector r;
  PVector v;
  PVector a;
  int col;
  float m;
  Circ(float x, float y, float rad) {
    r = new PVector(x, y);
    col = src.get((int)x, (int)y);
    v = new PVector(random(-4, 4), random(-4, 4));
    a = new PVector(0, 0);
    this.rad = rad;
    this.m = rad*rad;
  }
  float biggest_at2(float x, float y) {
    return sqrt((r.x-x)*(r.x-x) + (r.y-y)*(r.y-y)) - rad;
  }
  void update1(int this_id) {
    for(int i = 0; i < circs.size(); i++) {
      if(i != this_id) {
        Circ c = circs.get(i);
        if(sqrt((r.x-c.r.x)*(r.x-c.r.x) + (r.y-c.r.y)*(r.y-c.r.y)) < rad + c.rad - 0.1) {
          this.a.add(PVector.mult(PVector.sub(r, c.r), 2.0));
        }
      }
    }
  }
  void update2() {
    if(this.r.y + this.rad > g.height) {
      this.v.y = -this.v.y;
      this.r.y += g.height - (this.r.y + this.rad);
    }
    this.v.add(PVector.mult(a, 0.1));
    this.v.add(new PVector(noise(this.r.x*0.01+5, this.r.y*0.01+3)-0.5, noise(this.r.x*0.01, this.r.y*0.01)-0.5));
    this.r.add(PVector.mult(v, 0.1));
    this.v.mult(0.99);
    this.a = new PVector(0, 0);
    g.fill(col);
  }
  void update_col() {
    g.fill(col);
  }
}
