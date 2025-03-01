void setup() {
  size(512, 512, P2D);
  noSmooth(); strokeCap(SQUARE); strokeWeight(2);
  for(int x = 0; x < width; x++) for(int y = 0; y < height; y++) {
    stroke(x ^ y, 255);
    point(x*2+1, y*2+1);
  }
  saveFrame("xor.png");
}
