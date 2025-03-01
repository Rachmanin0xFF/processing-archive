
float t;

void setup() {
  size(512, 512, P2D);
  smooth();
}

void draw() {
  translate(width/2, height/2);
  rotate(float(mouseX)/20);
  translate(-width/2, -height/2);
  fill(255);
  rect(0, 0, width, height);
  
  strokeWeight(4);
  
  float x = 0;
  float y = 0;
  
  while(x < width) {
    y = 0;
    while(y < height) {
      float a = 5*noise(x/50, y/50, float(millis())/2000);
      strokeWeight(a);
      point(x, y);
      y += 4;
    }
    x += 4;
  }
  
  t+=0.009f;
  
} 
