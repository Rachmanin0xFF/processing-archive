PGraphics pg;
void setup() {
  size(800, 600, P2D);
  pg = createGraphics(5236, 1740, P2D);
  pg.noSmooth();
}
void draw() {
  pg.beginDraw();
  pg.background(255);
  pg.strokeWeight(2);
  
  for(int i = 0; i < 10; i++) {
    PVector dir = new PVector(randomGaussian(), randomGaussian());
    dir.normalize();
    PVector p = new PVector(0, 0);
    PVector pp = new PVector(0, 0);
    PVector p0 = new PVector(random(pg.width), random(pg.height));
    float sqlr = randomGaussian();
    for(int j = 0; j < 100000; j++) {
      p.add(PVector.add(dir, new PVector(randomGaussian()*0.1*sqlr, randomGaussian()*0.1*sqlr)));
      dir.add(new PVector(randomGaussian()*0.1, randomGaussian()*0.1));
      dir.mult(0.998);
      pg.strokeWeight(max(min(6, 3.0 / dir.mag()), 1));
      if((p.x + p0.x > pg.width || p.y + p0.y > pg.height || p.x + p0.x < 0 || p.y + p0.y < 0) && 
      (-p.x + p0.x > pg.width || -p.y + p0.y > pg.height || -p.x + p0.x < 0 || -p.y + p0.y < 0) &&
      (p.y + p0.x > pg.width || p.x + p0.y > pg.height || p.y + p0.x < 0 || p.x + p0.y < 0) &&
      (-p.y + p0.x > pg.width || -p.x + p0.y > pg.height || -p.y + p0.x < 0 || -p.x + p0.y < 0)) break;
      pg.line(p.x + p0.x, p.y + p0.y, pp.x + p0.x, pp.y + p0.y);
      pg.line(-p.x + p0.x, -p.y + p0.y, -pp.x + p0.x, -pp.y + p0.y);
      pg.line(p.y + p0.x, p.x + p0.y, pp.y + p0.x, pp.x + p0.y);
      pg.line(-p.y + p0.x, -p.x + p0.y, -pp.y + p0.x, -pp.x + p0.y);
      
      pp = new PVector(p.x, p.y);
    }
  }
  pg.endDraw();
  image(pg, 0, 0, width, width*17.0/52.0);
  
}
void keyPressed() {
  pg.save("sethcardlines.png");
}
