void setup() {
  size(1000, 500, P2D);
  frameRate(1000);
  background(0);
}
void draw() {
  background(0);
  stroke(255,150);
  strokeWeight(4);
  for(float i = 0.f; i < 20.f; i++) {
    for(float j = 0.f; j < i; j++) {
      point(i/j*width/20.f, 200);
    }
  }
  for(float i = 0.f; i < 20.f; i++) {
    for(float j = 0.f; j < i; j++) {
      point(i/j*width/20.f, i*10.f);
    }
  }
  stroke(0, 255, 0, 255);
  strokeWeight(4);
  point(1.f/map(mouseX, 0, width, 0.f, 1.f)*width/20.f, 201);
}