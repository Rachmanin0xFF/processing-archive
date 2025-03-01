ArrayList<PVector> positions = new ArrayList<PVector>();
void setup() {
  size(1024, 1024, P2D);
  background(255);
  noFill();
  stroke(0);
  frameRate(100000);
  PImage img = loadImage("input.png");
  //image(img, 0, 0);
  fill(0);
  colorMode(HSB);
  stroke(0);
  noSmooth();
  colorMode(RGB);
}
void draw() {
  //PVector b = rangeCheckSquared();
  PVector b = choosePos2();
  //PVector b = randomSize();
  float targetx = b.x;
  float targety = b.y;
  float rad = min(350, rangeCheck2(targetx, targety));
  noStroke();
  stroke(0);
  colorMode(HSB);
  fill(log(abs(rad))*40, 255, 255);
  positions.add(new PVector(targetx, targety, rad/2));
  //strokeWeight(max(1, rad/20));
  ellipse(targetx, targety, rad, rad);
}
PVector choosePos() {
  PVector o = new PVector(0, 0);
  int times = 0;
  while(!isWhite(round(o.x), round(o.y)) && times<1000) {
    o = new PVector(random(width), random(height));
  }
  if(times==1000)
    return new PVector(0, 0);
  return o;
}
PVector choosePos2() {
  PVector o = new PVector(-1000, -1000);
  float maxDist = 0.f;
  for(int x = 0; x < width; x++) {
    for(int y = 0; y < height; y++) {
      float dfc2 = (x-width/2)*(x-width/2) + (y - width/2)*(y - width/2);
      if(isWhite(x, y) && dfc2 < width*width/4) {
        float r = rangeCheck2(x, y);
        if(r > maxDist && distanceLessThan(x, y, width/2, width/2, width/2 - r)) {
          maxDist = r;
          o = new PVector(x, y);
        }
      }
    }
  }
  return o;
}
boolean distanceLessThan(float x, float y, float x2, float y2, float r) {
  return (x2 - x)*(x2 - x) + (y2 - y)*(y2 - y) < r*r;
}
boolean isWhite(int x, int y) {
  return r(get(x, y)) == 255&&g(get(x, y)) == 255&&b(get(x, y)) == 255;
}
PVector randomSize() {
  return new PVector(random(width), random(height));
}
float rangeCheck2(float tx, float ty) {
  float aDist = 10000;
  for(PVector p : positions) {
    float tDist = dist(tx, ty, p.x, p.y)-p.z;
    if(tDist < aDist)
      aDist = tDist;
  }
  return aDist*2;
}
float rangeCheck(float tx, float ty) {
  float fDist = 10000;
  float nX = 0;
  float nY = 0;
  for(int x = 0; x < width; x++) {
    for(int y = 0; y < height; y++) {
      if(r(get(x, y)) != 255) {
        float tDist = dist(x, y, tx, ty);
        if(tDist<fDist) {
          fDist = tDist;
          nX = x;
          nY = y;
        }
      }
    }
  }
  return fDist*2;
}
PVector rangeCheckSquared() {
  PVector best = new PVector(0, 0);
  float hiDst = 0;
  for(int x = 0; x < width; x++) {
    for(int y = 0; y < height; y++) {
      float nowDst = rangeCheck2(x, y);
      if(nowDst>hiDst) {
        hiDst = nowDst;
        best.x = x;
        best.y = y;
      }
    }
  }
  return best;
}
void mousePressed() {
  saveFrame("Output.png");
}
void keyPressed() {
  positions = new ArrayList<PVector>();
  background(255);
}
int r(color c){return (c>>16)&255;}
int g(color c){return (c>>8)&255;}
int b(color c){return c&255;}
