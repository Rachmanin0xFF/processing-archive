void setup() {
  size(510, 510, P2D);
  background(0);
  colorMode(HSB);
  for(int x = 0; x < width; x++)
  for(int y = 0; y < height; y++) {
    float d = dist(width/2, height/2, x, y);
    float theta = atan2(y - height/2, x - width/2);
    stroke((theta+PI)/TWO_PI*255.f, 255 - max(0, 500 -(d-100)*(d-100)/5 -  255), 300 -(d-100)*(d-100)/7);
    point(x, y);
  }
}
void draw() {
}