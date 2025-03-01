PGraphics g;
PImage p;
void setup() {
  size(512, 512);
  g = createGraphics(512, 512);
  p = loadImage("PixGlow.png");
}
void draw() {
  background(0);
  ellipse(mouseX, mouseY, 100, 100);
  blur(4);
}
void blur(int dd) {
  loadPixels();
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
        int rgb = (r+g+b);
        r-=rgb;
        g-=rgb;
        b-=rgb;
        px[p] = 0xff000000 + (r<<16) | (g<<8) | b;
      }
      arrayCopy(px,pixels);
   }
   updatePixels();
}
int r(color c) {return (c >> 16) & 255; }
int g(color c) {return (c >> 8) & 255;}
int b(color c) {return c & 255; }
