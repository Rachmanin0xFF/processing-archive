void setup() {
  size(1280, 1000);
  smooth(16);
}
void draw() {
  background(0);
  stroke(255);
  float px = 0;
  float py = 0;
  float py_dec = 0;
  float py_noise = 0;
  float py_noise_dec = 0;
  translate(0, 150);
  for(int i = 0; i < width; i++) {
    float x = i;
    float y = sin(x/100.f)*100;
    float y_dec = round(y/40)*40;
    float y_noise = y + random(-30, 30);
    float y_noise_dec = round(y_noise/40)*40;
    pushMatrix();
    if(i > 0) {
      line(px, py, x, y);
      translate(0, 200);
      line(px, py_dec, x, y_dec);
      translate(0, 200);
      line(px, py_noise, x, y_noise);
      translate(0, 200);
      line(px, py_noise_dec, x, y_noise_dec);
    }
    popMatrix();
    px = x;
    py = y;
    py_dec = y_dec;
    py_noise = y_noise;
    py_noise_dec = y_noise_dec;
  }
}
