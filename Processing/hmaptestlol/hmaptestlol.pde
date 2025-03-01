int s = 512;
float[][] arr = new float[s][s];
float zoom = 3f;
void setup() {
  size(1920, 1080-70, P3D);
  noiseDetail(1, 0.5f);
  background(0);
  stroke(255);
  noFill();
  drawMap();
  fillArr(0);
}
void draw() {
  scale(zoom);
  translate(width/2/zoom, height/2/zoom);
  rotateY(map(mouseX*4,0,width,-PI,PI));
  rotateX(map(mouseY*4,0,height,-PI,PI));
  
  background(0);
  drawTerrain();
}

void keyPressed() {
  fillArr(millis());
}

//RIDGED MULTIFRACTAL RIGT HERE BABBI WOOHOO//
float getHeight(float xc, float yc) {
  float sum = 0.0f;
  for(float i = 2.0f; i > 0.05f; i *= 0.5f) {
    float sx = xc/i + i*-37501;
    float sy = yc/i + i*37501;
    PVector sampC = new PVector(sx, sy);
    sampC.rotate(i * 401.7291);
    float q = noise(sampC.x, sampC.y);
    if(q > 0.25f)
      q = 0.5f - q;
    sum += q * i;
  }
  return sum;
}
//////////////////////////////////////////////

void drawTerrain() {
  for(int x = 0; x < s - 1; x++)
    for(int y = 0; y < s - 1; y++) {
      stroke(arr[x][y] * 255.0f * 0.5f);
      line(x - (float)s/2, y - (float)s/2, arr[x][y] * 50.0f, x + 1 - (float)s/2, y + 1 - (float)s/2, arr[x + 1][y + 1] * 50.0f);
      //line(x - (float)s/2, y - (float)s/2, arr[x][y] * 50.0f, x - (float)s/2, y + 1 - (float)s/2, arr[x][y + 1] * 50.0f);
    }
}
void drawMap() {
  for(float x = 0; x < s; x++)
    for(float y = 0; y < s; y++) {
      stroke(getHeight(x/50.0f, y/50.0f) * 255.0f);
      point(x, y);
    }
}
void fillArr(float time) {
  for(float x = 0; x < s; x++)
    for(float y = 0; y < s; y++) {
      float h = getHeight((x + time)/50.0f, y/50.0f);
      if(h < 0.5f)
        h = 0.5f;
      arr[int(x)][int(y)] = h * 2.0f;
    }
}
