void setup() {
  size(512, 512);
  smooth(16);
  translate(width/2, height/2);
  background(0);
  rectMode(CENTER);
  noStroke();
  for(int i = 400; i > 50; i--) {
    float q = (float)(i-50)/350;
    fill(lerp(160, 60, q), 255);
    float r = lerp(40, 15, q);
    rect(0, 0, i, i, r, r, 0, 0);
  }
  fill(60);
  rect(0, 0, 400, 400, 50);
  
  noFill();
  
  strokeWeight(40);
  stroke(47, 147, 247);
  rect(0, 0, 400, 400, 40, 40, 40, 40);
  
  fill(0);
  strokeWeight(15);
  stroke(47, 147, 247);
  rect(0, 0, 150, 150, 15, 15, 0, 0);
  
  //strokeCap(ROUND);
  
  for(float i = 0; i <= 1.f; i+=0.01f) {
    strokeWeight(15);
    line(lerp(-76, 76, i), 76, lerp(-180, 180, i), 180);
  }
  
  strokeWeight(2);
  stroke(70);
  PVector[] ponts = new PVector[] { new PVector(0, 0), new PVector(0, 1), new PVector(1, 0), new PVector(1, 1)};
  for(PVector p : ponts) {
    p = mopp(p.x, p.y);
    //point(p.x, p.y);
  }
}

void draw() {}

void keyPressed() {
  saveFrame("output.png");
}

PVector mopp(float x, float y) {
  float ulx = -61; float uly = 84; // upper left
  float urx = 61; float ury = 84; // upper right
  float llx = -165; float lly = 188; // lower left
  float lrx = 165; float lry = 188; // lower right
  return new PVector(lerp(lerp(ulx, urx, x), lerp(llx, lrx, x), y), lerp(uly, lly, y));
}