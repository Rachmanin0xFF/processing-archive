void setup() {
  size(512, 512, P2D);
  frameRate(10000);
  smooth(8);
}

void draw() {
  if(frameCount < 2) {
    background(random(255), random(255), random(255));
  }
}

void mousePressed() {
  noStroke();
  fill(random(255), random(255), random(255), 255);
  drawRect(random(width)-50, random(height)-50, 100, 100);
}

void shadeLine(float x, float y, float x2, float y2) {
  float theta = atan2(y - y2, x - x2) + PI/2.f;
  float cx = cos(theta);
  float cy = sin(theta);
  for(float i = 0.f; i < shadeWidth; i++) {
    stroke(0, map(i, 0, shadeWidth, shadeRange.x, shadeRange.y));
    line(x + cx*i, y + cy*i, x2 + cx*i, y2 + cy*i);
  }
}

float shadeWidth = 40.f;
PVector shadeRange = new PVector(70.f, 255.f);
void drawRect(float x, float y, float w, float h) {
  rect(x, y, w, h);
  blendMode(SUBTRACT);
  image(shadeRect(x, y, w, h), 0, 0);
  blendMode(BLEND);
}

PImage shadeRect(float x, float y, float w, float h) {
  PGraphics pg = createGraphics(width, height, P2D);
  pg.beginDraw();
  pg.background(255);
  pg.beginShape(LINES);
  for(float i = 0.f; i < w; i++) {
    pg.stroke(shadeRange.x, 255);
    pg.vertex(x + i , y);
    pg.stroke(shadeRange.y, 255);
    pg.vertex(x + i, y - shadeWidth);
  }
  for(float i = 0.f; i < w; i++) {
    pg.stroke(shadeRange.x, 255);
    pg.vertex(x + i , y + h);
    pg.stroke(shadeRange.y, 255);
    pg.vertex(x + i, y + h + shadeWidth);
  }
  for(float i = 0.f; i < h; i++) {
    pg.stroke(shadeRange.x, 255);
    pg.vertex(x , y + i);
    pg.stroke(shadeRange.y, 255);
    pg.vertex(x - shadeWidth, y + i);
  }
  for(float i = 0.f; i < h; i++) {
    pg.stroke(shadeRange.x, 255);
    pg.vertex(x + w, y + i);
    pg.stroke(shadeRange.y, 255);
    pg.vertex(x + w + shadeWidth, y + i);
  }
  for(float i = -PI; i < -PI/2.f; i+=0.01f) {
    float xc = cos(i);
    float yc = sin(i);
    pg.stroke(shadeRange.x, 255);
    pg.vertex(x, y);
    pg.stroke(shadeRange.y, 255);
    pg.vertex(x + xc*shadeWidth, y + yc*shadeWidth);
  }
  for(float i = -PI/2.f; i < 0.f; i+=0.01f) {
    float xc = cos(i);
    float yc = sin(i);
    pg.stroke(shadeRange.x, 255);
    pg.vertex(x + w, y);
    pg.stroke(shadeRange.y, 255);
    pg.vertex(x + w + xc*shadeWidth, y + yc*shadeWidth);
  }
  for(float i = 0.f; i < PI/2.f; i+=0.01f) {
    float xc = cos(i);
    float yc = sin(i);
    pg.stroke(shadeRange.x, 255);
    pg.vertex(x + w, y + h);
    pg.stroke(shadeRange.y, 255);
    pg.vertex(x + w + xc*shadeWidth, y + h + yc*shadeWidth);
  }
  for(float i = PI/2.f; i < PI; i+=0.01f) {
    float xc = cos(i);
    float yc = sin(i);
    pg.stroke(shadeRange.x, 255);
    pg.vertex(x, y + h);
    pg.stroke(shadeRange.y, 255);
    pg.vertex(x + xc*shadeWidth, y + h + yc*shadeWidth);
  }
  pg.endShape(CLOSE);
  pg.endDraw();
  //pg.loadPixels();
  //pg.updatePixels();
  return pg;
}
