

int d = 3;
PVector[][] cols = new PVector[d][d];

void setup() {
  size(512, 512, P2D);
  for(int x = 0; x < d; x++) for(int y = 0; y < d; y++) {
    cols[x][y] = new PVector(random(1), random(1), random(1));
    cols[x][y].normalize();
  }
  
  cols[0][0] = new PVector(1, 0, 0);
  cols[1][0] = new PVector(0, 1, 0);
  cols[2][0] = new PVector(0, 0, 1);
  
  cols[0][1] = new PVector(1, 1, 0);
  cols[1][1] = new PVector(0, 1, 1);
  cols[2][1] = new PVector(1, 0, 1);
  
  cols[0][2] = new PVector(1, 1, 1);
  cols[1][2] = new PVector(0.5, 0.5, 0.5);
  cols[2][2] = new PVector(0, 0, 0);
}

void draw() {
  background(0);
  int xi = mouseX * d / width;
  int yi = mouseY * d / height;
  for(int x = 0; x < d; x++) for(int y = 0; y < d; y++) {
    fill(cols[xi][yi].x*cols[x][y].x*230 + cols[x][y].x*25,
         cols[xi][yi].y*cols[x][y].y*230 + cols[x][y].y*25,
         cols[xi][yi].z*cols[x][y].z*230 + cols[x][y].z*25);
    if(xi == x && yi == y) fill(cols[x][y].x*255, cols[x][y].y*255, cols[x][y].z*255);
    rect(x * (float) width / d, y * (float) height / d, width / (float) d, height / (float) d);
  }
}
