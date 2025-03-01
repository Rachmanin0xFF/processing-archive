float x = 0;
float y = 0;
float x1 = 70;
float y1 = 400;
float x2 = 600;
float y2 = 100;
float x3 = 800;
float y3 = 600;
void setup() {
  size(900, 720);
  strokeWeight(1);
  smooth(16);
  background(0);
  x = x1;
  y = y1;
  randomSeed(3);
}
void draw() {
  //background(0);
  for(int i = 0; i < 100000; i++) {
  
  stroke(50, 237, 150);
  point(x, y);
  int j = (int)random(3);
  if(j == 0) {
    x = (x + x1)/2.0;
    y = (y + y1)/2.0;
  } else if (j == 1) {
    x = (x + x2) / 2.0;
    y  = (y + y2)/2.0;
  } else if (j == 2) {
    x = (x + x3) / 2.0;
    y = (y + y3) / 2.0;
  }
  stroke(255);
  if(frameCount <= 1) {
  point(x1, y1);
  point(x2, y2);
  point(x3, y3);
  }
}
  saveFrame("dots" + frameCount + ".png");
}
