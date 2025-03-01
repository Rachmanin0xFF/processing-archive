
ArrayList<P> pees = new ArrayList<P>();
PImage p;
PGraphics big;
int bsize = 2560;
void setup() {
  size(1000, 1000, P2D);
  big = (PGraphics) createGraphics(bsize, bsize, P2D);
  background(255);
  stroke(0);
  pees.add(new P(0, 0, 1, 0));
  for(int x = 0; x < width; x+=15) {
    for(int y = 0; y < height; y+=15) {
      //pees.add(new P(x, y, 1));
    }
  }
  /*
  p = loadImage("Glxxxy.png");
  big.beginDraw();
  big.image(p, 0, 0);
  big.stroke(255);
  big.strokeWeight(700);
  big.noFill();
  big.rect(0-300, 0-300, 2560+300*2, 2560+300*2);
  big.endDraw();*/
  big.noSmooth();
  big.beginDraw();
  big.background(255);
  big.endDraw();
  frameRate(600);
}
boolean b = true;
void keyPressed() {
  if(key == 'P' || key == 'p') {
    b = !b;
    if(b) loop(); else noLoop();
  }
  if(key == 'q' || key == 'Q') {
    big.save("PIC" + millis() + "2" + second() + ".png");
  }
}
void draw() {
  big.beginDraw();
  big.stroke(0, 255);
  for(int p = pees.size()-1; p >= 0; p--) {
    pees.get(p).update();
    if(pees.get(p).ded) pees.remove(p);
  }
  for(P p : pees) {
    p.display();
  }
  big.endDraw();
 if(random(200) > 199) image(big, 0, 0, 1000, 1000);
 println(pees.size());
}
class P {
  int x;
  int px;
  int y;
  int py;
  float xv;
  float yv;
  float c = 0.f;
  public P(int x, int y, float coeff, int dir) {
    this.x = x;
    this.y = y;
    px = x;
    py = y;
    xv = 0.5;
    yv = 0;
    this.c = coeff;
    this.dir = dir;
  }
  int dir = 0;
  boolean ded = false;
  void update() {
    px = x;
    py = y;
    float p = 100;
    float k = 30.f;
    float d = dist(0, 0, x, y);
    //yv += random(-0.01, 0.01);
    if(random(100) > 99) dir += round(random(-1, 1));
    dir = dir%4;
    if(dir == 0) x++;
    if(dir == 1) y++;
    if(dir == 2) x--;
    if(dir == 3) y--;
    if(r(big.get(x+bsize/2, y+bsize/2)) != 255) {
      ded = true;
      return;
    }
    if(random(100) > 99.5f) ded = true;
    if(random(100) > 99.5f) pees.add(new P(x, y, 0, dir + 1));
    if(random(100) > 99.5f) pees.add(new P(x, y, 0, dir - 1));
    //x += xv*c;
    //y += yv*c;
  }
  void display() {
    big.set(x+bsize/2, y+bsize/2, color(0, 255));
  }
}

int r(color c) {return (c >> 16) & 255; }
int g(color c) {return (c >> 8) & 255;}
int b(color c) {return c & 255; }