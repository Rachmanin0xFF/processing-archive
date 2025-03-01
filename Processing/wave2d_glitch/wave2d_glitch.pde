int resX = 400;
int resY = 400;
int[][] pbr_0 = new int[resX][resY];
int[][] pbr_1 = new int[resX][resY];
int tick = 0;
float dampening = 1.f;

void setup() {
  size(1024, 1024, P2D);
}

void draw() {
  update_waves();
  if(!keyPressed) {
    if(tick%2==0)
      display_data_2D_simple(pbr_0, resX, resY, 0, 0, width, height);
    else
      display_data_2D_simple(pbr_1, resX, resY, 0, 0, width, height);
  }
  if(mousePressed)
    pbr_0[int(float(mouseX)/float(width)*float(resX))][int(float(mouseY)/float(height)*float(resY))] = 100;
  tick++;
}


void update_waves() {
  for(int x = 1; x < resX-1; x++) {
    for(int y = 1; y < resY-1; y++) {
      pbr_1[x][y] = (pbr_0[x-1][y] + pbr_0[x+1][y] + pbr_0[x][y-1] + pbr_0[x][y+1])>>1 - pbr_1[x][y];// + (pbr_0[x+1][y+1] + pbr_0[x-1][y+1] + pbr_0[x-1][y-1] + pbr_0[x+1][y-1])/4.f*0.70710678118 
      pbr_1[x][y] = round(float(pbr_1[x][y])*dampening);
    }
  }
  for(int x = 0; x < resX; x++) {
    for(int y = 0; y < resY; y++) {
      int a = pbr_0[x][y];
      pbr_0[x][y] = pbr_1[x][y];
      pbr_1[x][y] = a;
    }
  }
}

void mouseMoved() {
  //pbr_0.add(map(mouseX, 0, width, 0, resX), map(mouseY, 0, height, 0, resY), color(0, 10, 10));
}