PVector[] quarto = new PVector[40000];
void setup() {
  size(1280, 720, P2D);
  background(0);
  stroke(255, 255, 255, 255);
  strokeWeight(2);
  hint(DISABLE_DEPTH_TEST);
  blendMode(ADD);
  for(int i = 0; i < quarto.length; i++) {
    float x = random(width);
    float y = random(height);
    x += (noise(x/50, y/50)-0.5f)*60.0f;
    y += (noise(y/50+2941, x/50+1279)-0.5f)*60.0f;
    quarto[i] = new PVector(x, y);
  }
}

void draw() {
  fill(0, 0, 0, 40);
  rect(0, 0, width, height);
  
  for(int i = 0; i < quarto.length; i++) {
    if(dist(mouseX, mouseY, quarto[i].x, quarto[i].y)<100 && mousePressed) {
      quarto[i].x += (quarto[i].x-mouseX)/50;
      quarto[i].y += (quarto[i].y-mouseY)/50;
    }
    point(quarto[i].x, quarto[i].y);
  }
}
