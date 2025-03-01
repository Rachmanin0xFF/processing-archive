void setup() {
  size(200, 200, P2D);
  background(0);
  stroke(255);
  for(int x = 0; x < width; x++)
    for(int y = 0; y < height; y++) {
      if(x%5 == 0)
        point(x, y);
    }
  saveFrame("stripes.png");
}
