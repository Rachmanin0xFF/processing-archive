
void setup() {
  size(900, 900);
}
   
void draw() {
  fill(255, 255, 255, 100);
  rect(0, 0, width-1, height-1);
  fill(255, 255, 0, 10);
  
  int k = 0;
  int g = 0;
  while(k < width) {
    g = 0;
    while(g < height) {
    rect(k, g, mouseX, mouseY);
    g += 100;
    }
    k += 100;
  }
}
