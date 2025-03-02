PImage poop;
plert[] plerts = new plert[0];
color targ = color(255, 255, 255);
void setup() {
  poop = loadImage("A.gif");
  //size(poop.width, poop.height, P2D);
  size(1600, 500);
  loadPixels();
  for(int i = 0; i < poop.pixels.length; i++) {
    set(i%poop.width, i/poop.width, poop.pixels[i]);
  }
  background(0);
  fill(255);
  stroke(255);
  PFont font = loadFont("CourierNewPS-BoldItalicMT-128.vlw");
  textFont(font, 128);
  text("Pongle", 100, 100);
  updatePixels();
  loadPixels();
  for(int x = 0; x < width; x++) {
    for(int y = 0; y < height; y++) {
      if(brightness(get(x, y))<random(-30, 10)||random(100)>99)
        plerts = (plert[])append(plerts, new plert(x, y));
    }
  }
  updatePixels();
}
void draw() {
  fill(0, 0, 0, 10);
  rect(0, 0, width, height);
  for(int i = 0; i < plerts.length; i++) {
    plerts[i].disp();
  }
  glow(3, 2);
}
class plert {
  float x;
  float y;
  float xv;
  float yv;
  plert(float x, float y) {
    this.x = x;
    this.y = y;
  }
  void disp() {
    //set((int)x, (int)y, targ);
    color too = color(xv*7, 255-yv*7, dist(0, 0, xv, yv)*7);
    set((int)x, (int)y, too);
    xv += noise(x/50, y/50)-0.5;
    yv += noise(x/50+2940, y/50+2891)-0.5;
    x += xv/10;
    y += yv/10;
    xv /= 1.05;
    yv /= 1.05;
    if(x>width)
      x = 0;
    if(x<0)
      x = width;
    if(y>height)
      y = 0;
    if(y<0)
      y = height;
  }
}

// GLOWING
 
// Martin Schneider
// October 14th, 2009
// k2g2.org
 
 
// use the glow function to add radiosity to your animation :)
 
// r (blur radius) : 1 (1px)  2 (3px) 3 (7px) 4 (15px) ... 8  (255px)
// b (blur amount) : 1 (100%) 2 (75%) 3 (62.5%)        ... 8  (50%)
   
void glow(int r, int b) {
  loadPixels();
  blur(1); // just adding a little smoothness ...
  int[] px = new int[pixels.length];
  arrayCopy(pixels, px);
  blur(r);
  mix(px, b);
  updatePixels();
}
 
void blur(int dd) {
   int[] px = new int[pixels.length];
   for(int d=1<<--dd; d>0; d>>=1) { 
      for(int x=0;x<width;x++) for(int y=0;y<height;y++) {
        int p = y*width + x;
        int e = x >= width-d ? 0 : d;
        int w = x >= d ? -d : 0;
        int n = y >= d ? -width*d : 0;
        int s = y >= (height-d) ? 0 : width*d;
        int r = ( r(pixels[p+w]) + r(pixels[p+e]) + r(pixels[p+n]) + r(pixels[p+s]) ) >> 2;
        int g = ( g(pixels[p+w]) + g(pixels[p+e]) + g(pixels[p+n]) + g(pixels[p+s]) ) >> 2;
        int b = ( b(pixels[p+w]) + b(pixels[p+e]) + b(pixels[p+n]) + b(pixels[p+s]) ) >> 2;
        px[p] = 0xff000000 + (r<<16) | (g<<8) | b;
      }
      arrayCopy(px,pixels);
   }
}
 
void mix(int[] px, int n) {
  for(int i=0; i< pixels.length; i++) {
    int r = (r(pixels[i]) >> 1)  + (r(px[i]) >> 1) + (r(pixels[i]) >> n)  - (r(px[i]) >> n) ;
    int g = (g(pixels[i]) >> 1)  + (g(px[i]) >> 1) + (g(pixels[i]) >> n)  - (g(px[i]) >> n) ;
    int b = (b(pixels[i]) >> 1)  + (b(px[i]) >> 1) + (b(pixels[i]) >> n)  - (b(px[i]) >> n) ;
    pixels[i] =  0xff000000 | (r<<16) | (g<<8) | b;
  }
}
 
int r(color c) {return (c >> 16) & 255; }
int g(color c) {return (c >> 8) & 255;}
int b(color c) {return c & 255; }
