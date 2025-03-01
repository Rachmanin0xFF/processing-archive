PGraphics pg;
int K = 2;
void setup() {
  //size(1024, 1024, P2D);
  fullScreen(P2D, 2);
  pg = createGraphics(width/K, height/K, P2D);
  noSmooth();
}
void draw() {
  int r = 40;
  
  float t = frameCount / 10.0;
  int mx = (int)(cos(t)*pg.width/4 + pg.width/2);
  int my = (int)(sin(t)*pg.width/4 + pg.height/2);
  pg.beginDraw();
  for(int x = 0; x < pg.width; x++) {
    for(int y = 0; y < pg.height; y++) {
      int dx = mx - x;
      int dy = my - y;
      
      if(dx*dx + dy*dy < r*r || frameCount < 10) {
        float rr = pow(random(1), 95);
        float gg = pow(random(1), 60);
        float bb = pow(random(1), 50);
        pg.set(x, y, color(255*rr, 255*gg, 255*bb));
      }
    }
  }
  pg.endDraw();
  
  
  // COMMENT THESE FILTERS OUT FOR THE REAL PROGRAM
  if(random(100) > 30)
  pg.filter(DILATE);
  else
  pg.filter(ERODE);
  
  pg.filter(INVERT);
  image(pg, 0, 0, width, height);
  
  for(int x = 0; x < width; x++) {
    for(int y = 0; y < height; y++) {
      int dx = mx*K - x;
      int dy = my*K - y;
      if(dx*dx + dy*dy < r*r*4 || frameCount < 10) {
        set(x, y, color(0));
      }
    }
  }
}
