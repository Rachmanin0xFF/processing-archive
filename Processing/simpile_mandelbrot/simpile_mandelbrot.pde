void setup() {
  size(512, 512, P2D);
  background(0);
}
void draw() {
  background(0);
  for(int x = 0; x < width; x++) {
    for(int y = 0; y < height; y++) {
      float re = (x/(float)width * 2.0 - 1.0)*1.5;
      float im = (y / (float) height * 2.0 - 1.0)*1.5;
      float re_c = re;
      float im_c = im;
      int i = 0;
      for(i = 0; i < 255; i++) {
        float tre = re*re - im*im + re_c;
        float tim = 2*re*im + im_c;
        re = tre;
        im = tim;
        if(re * re + im*im > 4.0) {
          break;
          
        }
      }
      colorMode(HSB);
      color c;
      if(i != 255) {
        c = color(i, 255, 255);
      } else {
        c = color(255, 0, 0);
      }
      set(x, y, c);
    }
  }
}
