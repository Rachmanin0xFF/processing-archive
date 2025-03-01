void setup() {
  size(676, 676, P2D);
  background(0);
}
void draw() {
  colorMode(HSB, 255);
  for(int x = 0; x < width; x++) {
    for(int y = 0; y < height; y++) {
      set(x, y, color(random(255), random(255), 150));
    }
  }
  saveFrame("noise.png");
  noLoop();
}
