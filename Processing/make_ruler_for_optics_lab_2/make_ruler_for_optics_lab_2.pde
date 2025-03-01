void setup() {
  size(512, 512, P2D);
  background(0);
  stroke(255);
  translate(100, 100);
  textAlign(CENTER, TOP);
  textSize(24);
  for(int x = 0; x <= 300; x += 10) {
    line(x, 0, x, -10);
    if(x%50==0) {
      line(x, 0, x, -20);
      
    }
    if(x%100==0) {
      line(x, 0, x, -40);
      text(x/100 + "cm", x, +2);
    }
  }
}
