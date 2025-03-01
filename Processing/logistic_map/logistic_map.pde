
int xres = 1920*4;
int yres = 1080*4;
int[][] dat;
PVector min;
PVector max;

void setup() {
  size(800, 450, P2D);
  noSmooth();
  strokeCap(SQUARE);
  min = new PVector(3, 0);
  max = new PVector(4.01, 1);
  dat = new int[xres][yres];
  surface.setLocation(150,100);
}

void keyPressed() {
  PImage p = createImage(xres, yres, RGB);
  p.loadPixels();
  for(int i = 0; i < xres; i++) {
    for(int j = 0; j < yres; j++) {
      float q = log(dat[i][yres-j-1]);
      color c = color(q, q/10.0, q*2.0, 255);
      p.pixels[i + j*xres] = c;
    }
  }
  p.updatePixels();
  image(p, 0, 0, width, height);
  p.save("bifc.png");
}

void draw() {
  int xc = 0;
  int yc = 0;
  float r = 0;
  float y = 0;
  for(int i = 0; i < 10000; i++) {
    
    r = random(min.x, max.x);
    y = random(1);
    for(int k = 0; k < 1000; k++) {
      y = r*y*(1-y);
      if(k > 500) {
        xc = (int)(map(r, min.x, max.x, 0, xres-1) + 0.5*randomGaussian());
        yc = (int)(map(y, min.y, max.y, 0, yres-1) + 0.5*randomGaussian());
        if(xc >= 0 && xc < xres && yc >= 0 && yc < yres) dat[xc][yc]++;
      }
    }
  }
}
