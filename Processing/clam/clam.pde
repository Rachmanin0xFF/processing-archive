
PFont standardFont;
PShader blurShader;

void setup() {
  size(1900, 1000, P2D);
  standardFont = loadFont("CordiaUPC-64.vlw");
  blurShader = loadShader("blur.glsl");
  surface.setResizable(true);
  textFont(standardFont);
  smooth(8);
  noStroke();
}

void draw() {
  background(255);
  
  colorMode(HSB);
  fill(frameCount/10, 20, 100);
  translate(width/2, height/2);
  scale((float)mouseX/100.f);
  
  drawShapes(true);
  blur(10.f);
  //drawShapes(false);
}

void drawShapes(boolean lines) {
  pushMatrix();
  rotate(TWO_PI*50.f/360.f);
  //rect(-5000, 0, 10000, 10000);
  int k = 800;
  
  float mX = 0;
  float mY = 0;
  float mZ = 0;
  mX = noise(0, (float)frameCount/1000.f)*255.f;
  mY = noise(124.0512, (float)frameCount/1000.f)*255.f;
  mZ = noise(152.251, (float)frameCount/1000.f)*255.f;
  translate(0, height/3*2);
  beginShape();
  fill(mY, 100, 180);
  vertex(-k, 0);
  fill(mY + 40, 100, 80);
  vertex(-k + k*2, 0);
  fill(mY + 40, 100, 80);
  vertex(-k + k*2, -k*2);
  fill(mY, 100, 180);
  vertex(-k, -k*2);
  endShape(CLOSE);
  popMatrix();
  rotate(TWO_PI*10.f/360.f);
  
  beginShape();
  fill(mX, 100, 180);
  vertex(-k, 0);
  fill(mX + 40, 100, 80);
  vertex(-k + k*2, 0);
  fill(mX + 40, 100, 80);
  vertex(-k + k*2, k*2);
  fill(mX, 100, 180);
  vertex(-k, k*2);
  endShape(CLOSE);
  
  if(lines) {
  fill(0, 0, 255);
  rect(-1000, -25, 2000, 25);
  ellipse(0, 0, 250, 250);
  }
  fill(mZ, 200*0, 50*0);
  ellipse(0, 0, 200, 200);
}

void blur(float sigma) {
  blurShader.set("blurSize", 50);
  blurShader.set("sigma2", max(0.001f, sigma));
  blurShader.set("horizontalPass", 1);
  filter(blurShader);
  blurShader.set("horizontalPass", 0);
  filter(blurShader);
}