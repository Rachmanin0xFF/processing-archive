PGraphics pg;
PShader flt;
PImage p2;

void setup() {
  size(1600, 900, P3D);
  pg = createGraphics(1600/2, 900/2, P3D);
  pg.noSmooth();
  flt = loadShader("filt.glsl");
}

void draw() {
  PImage poo = pg.get();
  //poo.filter(DILATE);
  //poo.filter(ERODE);
  pg.beginDraw();
  pg.background(0);
  pg.translate(pg.width/2, pg.height/2, 0);
  pg.pushMatrix();
  pg.translate(0, 0, -372-17);
  //pg.translate(0, 0, -372-16);
  //pg.translate(0, 0, -372-7);
  pg.rotate(0.005);
  pg.tint(253, 253, 254);
  pg.image(poo, -pg.width, -pg.height, pg.width*2, pg.height*2);
  pg.popMatrix();
  //pg.translate(0, 0, 372+7);
  //pg.rotateY((millis()/3000.0 + PI/2.0)%PI - PI/2.0);
  pg.rotateY(sin(millis()/500.f)*0.5f);
  pg.rotateX(cos(millis()/500.f)*0.5f);
  pg.textSize(170);
  pg.textAlign(CENTER, CENTER);
  pg.noStroke();
  for(int i = -20; i < 20; i++) {
    pg.pushMatrix();
    pg.translate(0, 0, i*2);
    
    
    float c1 = millis()/500.f;
    lab2rgb(new float[]{100, cos(c1), sin(c1)});
    float a_range = 70.f;
    float b_range = 20.f;
    float lightness_range = 40.f;
    pg.fill(lab2rgb(new float[]{lightness_range*(sin(c1*PI - i/10.f)+1.0), cos(c1*1.6180339887 - i/10.f)*a_range, sin(c1 - i/72.f)*b_range}));
    String boobies = "life...";
    pg.text(boobies, 0, -20);
    pg.translate(random(-2000, 2000), random(-2000, 2000), random(-100, 100) - 200);
    //pg.sphere(30);
    pg.popMatrix();
  }
  pg.endDraw();
  background(0);
  image(pg, 0, 0, width, height);
  //pg.filter(flt);
}
