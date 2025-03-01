void setup() {
  size(400, 400);
  noiseDetail(1);
  for(int x = 0; x < width; x++) {
    for(int y = 0; y < height; y++) {
      float n = noise((float)x/100, (float)y/100)*4.f;
      if(n > 1.f) n = 2.f - n;
      stroke(n*255.f);
      point(x, y);
    }
  }
}