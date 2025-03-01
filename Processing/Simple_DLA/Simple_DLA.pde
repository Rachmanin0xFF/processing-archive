
float[][] crystal;
void setup() {
  size(512, 512, P2D);
  crystal = new float[width][height];
  crystal[width/2][height/2] = 1.0;
  background(0);
  stroke(255, 255);
}

void draw() {
  blendMode(ADD);
  for(int i = 0; i < 100; i++) {
    int x = 0;
    int y = 0;
    int dir = (int)random(0, 4);
    boolean looping = true;
    stroke(1, 0, 0);
    float load = 1.0;
    while(looping) {
      dir = (int)random(0, 4);
      switch(dir) {
        case 0:
          x++; break;
        case 1:
          x--; break;
        case 2:
          y++; break;
        case 3:
          y--; break;
      }
      x = (x+width)%width;
      y = (y+height)%height;
      float mx = random(1);
      if(crystal[(x+1+width)%width][y] > mx ||
         crystal[(x-1+width)%width][y] > mx ||
         crystal[x][(y+1+height)%height] > mx ||
         crystal[x][(y-1+height)%height] > mx) {
           float deposit = random(0.5);
           deposit *= deposit*deposit;
           crystal[x][y] += deposit;
           load -= deposit;
           if(load <= 0) looping = false;
           set(x, y, color(0, crystal[x][y]*155.0, crystal[x][y]*255.0));
         }
         
      if(crystal[x][y] >= 1.0) set(x, y, color(255, 255));
    }
    stroke(255, 255);
  }
}
