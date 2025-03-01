void setup() {
  size(512, 512, P2D);
  background(255);
  stroke(0, 255);
  frameRate(600000);
  smooth(8);
}
float px;
float py;
void draw() {
  background(255);
  float x = mouseX - 100;
  float y = mouseY - 100;
  strokeWeight(20);
  float d = dist(x, y, px, py);
  //stroke(255.f - 255.f/(1.f + d/20.f));
  stroke(0);
  line(x, y, (px+x*1.f)/2.f, (py+y*1.f)/2.f);
  if(d == 0.f)
    point(x, y);
  px = x;
  py = y;
  noStroke();
}
void keyPressed() {
  noLoop();
}
