void setup() {
  size(512, 512);
  loadPixels();
  for(int i = 0; i < pixels.length; i++)
    pixels[i] = color(random(255), random(255), random(255));
  updatePixels();
}
void draw() {}
void keyPressed() {
  saveFrame("random.png");
}
