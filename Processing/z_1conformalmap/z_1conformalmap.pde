void setup() {
  size(1024, 1024, P2D);
}
PVector cmap(float x, float y) {
  return new PVector(1000.0*x/(x*x+y*y), 1000.0*-y/(x*x+y*y));
}
void draw() {
  blendMode(BLEND);
  background(0);
  blendMode(ADD);
  stroke(255, 0, 0);
  translate(width/2, height/2);
  for(float y = -500; y < 500; y++) {
    for(float x = -500; x < 500; x+=0.1) {
      line(cmap(x, y).x, cmap(x, y).y,cmap(x+0.1, y).x, cmap(x+0.1, y).y);
    }
  }
  stroke(0, 0, 255);
  for(float y = -500; y < 500; y++) {
    for(float x = -500; x < 500; x+=0.1) {
      line(cmap(y, x).x, cmap(y, x).y,cmap(y, x+0.1).x, cmap(y, x+0.1).y);
    }
  }
}
