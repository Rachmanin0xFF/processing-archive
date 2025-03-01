PImage img;
int s;
int w;
void setup() {
  img = loadImage("Above_The_Sea.jpg");
  w = img.width/4;
  s = 1024;
  smooth(8);
  size(s, s, P2D);
  background(0);
  scale(1, -1);
  translate(0, -s);
  //image, screen coordinates(xywh), image coordinates to grab from (x1 y1 x2 y2)
  
  image(img, 0, 0, s, s, w*2, w, w*3, w*2);
  saveFrame("0.bmp");
  
  image(img, 0, 0, s, s, 0, w, w, w*2);
  saveFrame("1.bmp");
  
  image(img, 0, 0, s, s, w, 0, w*2, w);
  saveFrame("2.bmp");
  
  image(img, 0, 0, s, s, w, w*2, w*2, w*3);
  saveFrame("3.bmp");
  
  image(img, 0, 0, s, s, w, w, w*2, w*2);
  saveFrame("4.bmp");
  
  image(img, 0, 0, s, s, w*3, w, w*4, w*2);
  saveFrame("5.bmp");
}
void draw() {
  scale(1, -1);
    translate(mouseX, mouseY);
  image(img, 0, 0, s, s);
}
