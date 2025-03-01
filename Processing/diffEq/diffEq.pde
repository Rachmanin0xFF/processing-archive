float centerX;
float centerY;
float zoom = 0.5;
float tmx;
float tmy;
float linespace = 10;
int f = 1;
void setup() {
  size(400, 400);
  background(255);
  stroke(255);
  colorMode(HSB);
}
void draw() {
  background(0);
  drawColors(1);
  //drawVectors();
  if(keyPressed) {
    if(key=='w')
      centerY--;
    if(key=='s')
      centerY++;
    if(key=='a')
      centerX--;
    if(key=='d')
      centerX++;
    if(key=='q')
      zoom/=1.1;
    if(key=='e')
      zoom*=1.1;
  }
  f++;
}
void drawVectors() {
  for(float x = -width/2-20; x < width/2+20; x+=linespace) {
    for(float y = -height/2-20; y < height/2+20; y+=linespace) {
      float mx = map(x, -width/2, width/2, (centerX-10)/zoom, (centerX+10)/zoom);
      float my = map(y, -height/2, height/2, (centerY-10)/zoom, (centerY+10)/zoom);
      float dy = deltaY(mx, my);
      float dx = deltaX(mx, my);
      line(x+width/2, y+height/2, x+width/2 + dx*4, y+height/2 + dy*4);
    }
  }
}
void drawColors(int p) {
  for(int x = 0; x < width; x+=p) {
    for(int y = 0; y < height; y+=p) {
      float mx = map(x, 0, width, (centerX-10)/zoom, (centerX+10)/zoom);
      float my = map(y, 0, height, (centerY-10)/zoom, (centerY+10)/zoom);
      float dy = deltaY(mx, my);
      float dx = deltaX(mx, my);
      set(x, y, color((sin(dx)+1)*255/2, 255, (sin(dy)+1)*255/2));
    }
  }
}
float deltaY(float x, float y) {
  return 2.4*y*(1-y);
}
float deltaX(float x, float y) {
  return y*y + x;
}
