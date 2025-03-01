import java.util.Random;
Random rand = new Random();
ArrayList<Star> stars = new ArrayList<Star>();
void setup() {
  size(1600, 900, P2D);
  background(0);
  stroke(255);
  strokeWeight(1);
  strokeCap(SQUARE);
  noSmooth();
  for(int i = 0; i < 3000000; i++) {
    stars.add(new Star());
  }
}
void draw() {
  //filter(BLUR, 4);
  for(Star s : stars) {
    s.display();
  }
}

double lerp(double a, double b, double x) {
  return a*x + (1.0 - x)*b;
}

class Star {
  double x, y, r, g, b, bm;
  public Star() {
    x = random(width);
    y = random(height);
    r = random(1);
    g = random(1);
    b = random(1);
    double bb = (r + g + b)/2.0;
    double ds = Math.pow(rand.nextDouble(), 5.001);
    r = lerp(r, bb, ds);
    g = lerp(g, bb, ds);
    b = lerp(b, bb, ds);
    
    bm = Math.pow(rand.nextDouble(), 590.4) + Math.pow(rand.nextDouble(), 100.0)*0.4;
    //bm = Math.abs(rand.nextGaussian())*0.1;
    
    r *= bm;
    g *= bm;
    b *= bm;
  }
  public void display() {
    set((int)x, (int)y, color((float)r*255.0, (float)g*255.0, (float)b*255.0));
  }
}
