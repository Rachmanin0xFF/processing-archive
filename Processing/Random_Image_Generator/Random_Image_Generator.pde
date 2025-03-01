void setup() {
  size(1024, 1024, P2D);
  for(int x = 0; x < width; x++)
    for(int y = 0; y < height; y++) {
      color c = color(random(255), random(255), random(255), 255);
      set(x, y, c);
    }
}
void draw() {
  saveFrame("random.bmp");
}
