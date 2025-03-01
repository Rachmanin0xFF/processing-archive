void setup() {
  //size(1800, 970, P2D);
  
  fullScreen(P2D);
  frameRate(500);
  noSmooth();
}
void draw() {
  background(0);
  int iw = 50;
  noStroke();
  for(int i = 0; i < width; i+=iw) {
    
    color geen = geet(i*0.002f*5.0 + millis()/3000.f);
    float b = sin(i*0.002f + millis()/100.f);
    fill(geen);
    //if(b < 0.9) fill(0);
    rect(i, 0, iw+1, height);
  }
  float nn = noise(millis()/100.f)*2.f;
  color c = color(nn*255.f, nn*100.f, nn*30.f);
  //background(c);
}

color geet(float theta) {
  float rr = 50.f;
  
  float x = cos(theta)*rr;
  float y = sin(theta)*rr;
  
  color c3 = lab2rgb(new float[]{40, x, y});
  return c3;
}
