PGraphics pg;
void setup() {
  size(512, 512, P2D);
  stroke(255);
  pg = createGraphics(512, 512, P2D);
  background(0);
}
void draw() {
  background(0);
  point(mouseX, mouseY);
  pg.beginDraw();
  pg.loadPixels();
  pg.pixels = pixels;
  pg.updatePixels();
  pg.endDraw();
  image(pg, width/2, height/2);
}
