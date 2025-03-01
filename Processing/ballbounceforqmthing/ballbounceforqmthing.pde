
PImage dwn;

Box biga;
Box bigb;
Box bigc;
Box bigd;

PFont font;

Box[] bxs = new Box[3];
void setup() {
  size(1600, 1000, P2D);
  for(int i = 0; i < bxs.length; i++) {
    bxs[i] = new Box(100, i*200+100, 400, 150);
  }
  biga = new Box(400, 50, 600, 400);
  biga.vy = 0;
  biga.py = 100;
  bigb = new Box(400, 500, 600, 400);
  bigb.vy = 0;
  bigb.py = 300;
  
  bigc = new Box(800, 50, 600, 400);
  bigc.vy = 1;
  bigc.py = 200;
  font = loadFont("Consolas-48.vlw");
  textFont(font);
  smooth(16);
  dwn = loadImage("down.png");
}
void draw() {
  background(0);
  float ty= biga.y;
  if(kq <= 0) {
    biga.y = (biga.y + bigb.y)/2.0;
  }
  for(int i = 0; i < 7; i++){
  //for(Box b : bxs) b.ud();
  biga.ud(i==0, false);
  if(kq > 0) { bigb.ud(i==0, kq==4); } else bigb.update(kq==4);
  //bigc.ud();
  }
  stroke(230, 50, 20);
  biga.y = ty;
  if(kq > 2) line(biga.x+biga.px, 0, biga.x+biga.px, height);
}
int kq = -3;
void keyPressed() {
  kq++;
  if(kq < 0) biga.py = random(biga.br, biga.h-biga.br);
  if(kq == 0) biga.py = 100;
  if(kq == 2) bigb.vy = 1.0;
}
float sgn(float x) {
  return x < 0 ? -1 : 1;
}

class Box {
  float x;
  float y;
  float w;
  float h;
  float px;
  float py;
  float vx;
  float vy;
  float br = 40;
  boolean z = false;
  Box(float x, float y, float w, float h) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.vx = 1.0;
    this.vy = 0.5*random(-this.vx, this.vx);
    this.px = w/2;
    this.py = random(br, h-br);
  }
  void display(boolean z) {
    stroke(255);
    strokeWeight(3);
    noFill();
    if(z){rect(x, y, w, h);
    textSize(30);
    fill(20, 230, 80, 100);
    text("v=(" + this.vx + ","+nf(this.vy, 0, 2)+")", x+w+20, y+20);
    noFill();
    }
    strokeWeight(2);
    stroke(255, 100);
    ellipse(x+px, y+py, br*2.0, br*2.0);
    stroke(20, 230, 80, 50);
    fill(20, 230, 80, 50);
    draw_arrow(x+px, y+py, x+vx*100.0+px, y+vy*100.0+py);
  }
  void ud(boolean z, boolean j) {
    update(j);
    display(z);
    tint(255, 255, 255, 40);
    if(j && z) 
    for(float i = 0; i < 3; i++) {
      for(float jj = 0; jj < 3; jj++) {
            image(dwn, x+i*200+50, y+7+jj*100+50, 90, 90);
      }
    }
  }
  void update(boolean j) {
    px += vx;
    py += vy;
    if(j) {vy += 0.01; vy *= 0.99995;}
    if(px > (w-br)) {
      px = 2.0*(w-br) - px;
      vx = -vx;
    }
    if(px < br) {
      px = 2.0*br-px;
      vx = -vx;
    }
    if(py > h-br) {
      py = 2.0*(h-br) - py;
      vy = -vy;
    }
    if(py < br) {
      py = 2.0*br-py;
      vy = -vy;
    }
  }
}

float rd = 14.0;
void draw_arrow(float x1, float y1, float x2, float y2) {
  PVector d = new PVector(x2-x1, y2-y1);
  float l = d.mag();
  float dir = atan2(d.y, d.x);
  d.normalize();
  pushMatrix();
  translate(x1, y1);
  rotate(dir);
  line(0, 0, l, 0);
  beginShape();
  vertex(l, 0);
  vertex(l-rd, rd*0.8);
  vertex(l-rd, -rd*0.8);
  endShape(CLOSE);
  popMatrix();
}
