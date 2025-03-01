int resX = 150;
int resY = 150;
int[][] fm_0 = new int[resX][resY];
int[][] fm_1 = new int[resX][resY];
int[][] fm_2 = new int[resX][resY];
int tick = 0;
float dampening = 0.985f;

void setup() {
  size(1024, 1024, P3D);
}

void draw() {
  background(0);
  //translate(width/2, height/2);
  //rotateX(0.7f);
  println(mouseX + " " + mouseY);
  update_waves();
  if (!keyPressed) {
    background(0);
    display_data_2D_simpleb(fm_0, resX, resY, 0, 0, width, height);
  }
  //if(mousePressed && mouseX > 0 && mouseY > 0 && mouseX < width && mouseY < height)
  //  fm_1[int(float(mouseX)/float(width)*float(resX))][int(float(mouseY)/float(height)*float(resY))] = mouseButton==LEFT?10000000:-2000000;
  if (mousePressed)
    for (int x = 0; x < resX; x++) {
      for (int y = 0; y < resY; y++) {
        float xc = x*(width/(float)resX);
        float yc = y*(height/(float)resY);
        if ((mouseX-xc)*(mouseX-xc) + (mouseY-yc)*(mouseY-yc) < 30*30) {
          fm_1[x][y] = 1000000;
        }
      }
    }
  tick++;
}


void update_waves() {
  for (int x = 1; x < resX-1; x++) {
    for (int y = 1; y < resY-1; y++) {
      int velocity = fm_1[x][y]-fm_2[x][y];
      int smoothed = (fm_1[x+1][y] + fm_1[x][y+1] + fm_1[x-1][y] + fm_1[x][y-1])/4;
      int smoothed2 = int(  fm_1[x-1][y-1]/16.f  + fm_1[x][y-1]/8.f + fm_1[x+1][y-1]/16.f
        + fm_1[x-1][y]/8.f     + fm_1[x][y]/4.f   + fm_1[x+1][y]/8.f
        + fm_1[x-1][y+1]/16.f  + fm_1[x][y+1]/8.f + fm_1[x+1][y+1]/16.f);
      fm_0[x][y] = smoothed2 + round(float(velocity)*dampening);
    }
  }
  for (int x = 0; x < resX; x++) {
    for (int y = 0; y < resY; y++) {
      fm_2[x][y] = fm_1[x][y];
      fm_1[x][y] = fm_0[x][y];
    }
  }
}

void mouseMoved() {
  //pbr_0.add(map(mouseX, 0, width, 0, resX), map(mouseY, 0, height, 0, resY), color(0, 10, 10));
}


//Arguments are as follows:               datawidth dataheight  drawx  drawy   drawwidth drawheight
public void display_data_2D_simplea(int[][] data, int w, int h, float x, float y, float rw, float rh) {
  int tw = int(rw);
  int th = int(rh);
  int tx = int(x);
  int ty = int(y);
  strokeCap(SQUARE);
  //strokeWeight(rw/w);
  strokeWeight(2);
  for (int i = 0; i < w-1; i++) {
    for (int j = 0; j < h-1; j++) {
      float xc = map(float(i), 0, w, float(tx), float(tw));
      float yc = map(float(j), 0, h, float(ty), float(th));
      float dij = data[i][j]/60000.f;
      color p = color(dij + 30, abs(dij) + 30, abs(dij), 255);
      stroke(p);
      //point(xc-width/2, yc-height/2, dij);

      float xc1 = map(float(i+1), 0, w, float(tx), float(tw));
      float yc1 = map(float(j), 0, h, float(ty), float(th));
      float dij1 = data[i+1][j]/60000.f;
      line(xc-width/2, yc-height/2, dij, xc1-width/2, yc1-height/2, dij1);

      float xc2 = map(float(i), 0, w, float(tx), float(tw));
      float yc2 = map(float(j+1), 0, h, float(ty), float(th));
      float dij2 = data[i][j+1]/60000.f;
      line(xc-width/2, yc-height/2, dij, xc2-width/2, yc2-height/2, dij2);
    }
  }
  strokeWeight(1);
  strokeCap(ROUND);
}

//Arguments are as follows:               datawidth dataheight  drawx  drawy   drawwidth drawheight
public void display_data_2D_simpleb(int[][] data, int w, int h, float x, float y, float rw, float rh) {
  int tw = int(rw);
  int th = int(rh);
  int tx = int(x);
  int ty = int(y);
  strokeCap(SQUARE);
  strokeWeight(rw/w);
  for (int i = 0; i < w; i++) {
    for (int j = 0; j < h; j++) {
      float xc = map(float(i), 0, w, float(tx), float(tw));
      float yc = map(float(j), 0, h, float(ty), float(th));
      float f = 60000.f;
      color p = color(-data[i][j]/f, abs(data[i][j]/f*0.6f), data[i][j]/f, 255);
      stroke(p);
      point(xc, yc);
    }
  }
  strokeWeight(1);
  strokeCap(ROUND);
}