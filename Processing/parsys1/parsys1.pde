
//MODIFIABLE//
int gridRes = 70;
int screenRes = 600;
int numParticles = 80000;
float initsep = 80.0f;
float gridAlpha = 1.0f;
float linAlpha = 10.6f;
float spreadFactor = 0.0015f;
boolean useLines = true;

//BAD TO MODIFY//
ArrayList<Particle> system = new ArrayList<Particle>();
PVector[][] grid = new PVector[gridRes][gridRes];
PVector[][] velo = new PVector[gridRes][gridRes];
PVector[][] ngrid = new PVector[gridRes][gridRes];
PVector[][] nvelo = new PVector[gridRes][gridRes];
float[][] density = new float[gridRes][gridRes];
float pf = 0.0f;
boolean useGrid = true;
boolean quantizedReaction = true;
boolean wrapParticles = false;

void setup() {
  size(screenRes, screenRes, P2D);
  frameRate(100000);
  fill(0, 0, 0, 60);
  strokeWeight(1);
  gridAlpha /= 255.0f;
  for(int x = 0; x < gridRes; x++)
    for(int y = 0; y < gridRes; y++) {
      grid[x][y] = new PVector();
      velo[x][y] = new PVector();
      ngrid[x][y] = new PVector();
      nvelo[x][y] = new PVector();
    }
  for(int i = 0; i < numParticles; i++) {
    float r = random(1);
    r = sqrt(r);
    r *= initsep;
    float theta = random(TWO_PI);
    system.add(new Particle(width/2+r*cos(theta), height/2+r*sin(theta), (float(i)/float(numParticles))));
  }
}

void draw() {
  fill(0, 0, 0, 110);
  rect(0, 0, width, height);
  for(Particle p : system) p.update(mouseX, mouseY);
    //p.update((noise(float(millis())/1000.0f)-0.5f)*width/4.0f+width/2, (noise(float(millis())/1000.0f+100.0f)-0.5f)*height/4.0f+height/2);
  if(quantizedReaction && useGrid) {
      calcVelo();
      diffusionVelo();
  }
  if(useGrid) {
    if(!useLines) dispGrid();
    diffusion();
  }
  if(quantizedReaction && useGrid)
    clearDensity();
  if(useLines) {
    blendMode(ADD);
    hint(DISABLE_DEPTH_TEST);
    dispLines();
  }
  pf++;
}

void dispLines() {
  for(Particle i : system)
    i.dispLine();
}

void clearDensity() {
  for(int x = 0; x < gridRes; x++)
    for(int y = 0; y < gridRes; y++)
      density[x][y] = 0.0f;
}

void dispVelo() {
  for(int x = 0; x < gridRes; x++)
    for(int y = 0; y < gridRes; y++) {
      fill(velo[x][y].x, velo[x][y].y, velo[x][y].z);
      stroke(velo[x][y].x, velo[x][y].y, velo[x][y].z);
      rect(x*float(width)/float(gridRes), y*float(height)/float(gridRes), float(width)/float(gridRes), float(height)/float(gridRes));
      velo[x][y].mult(0.5f);
    }
}

void dispDensity() {
  for(int x = 0; x < gridRes; x++)
    for(int y = 0; y < gridRes; y++) {
      fill(density[x][y]);
      stroke(density[x][y]);
      rect(x*float(width)/float(gridRes), y*float(height)/float(gridRes), float(width)/float(gridRes), float(height)/float(gridRes));
    }
}

void dispGrid() {
  for(int x = 0; x < gridRes; x++)
    for(int y = 0; y < gridRes; y++) {
      fill(grid[x][y].x, grid[x][y].y, grid[x][y].z);
      stroke(grid[x][y].x, grid[x][y].y, grid[x][y].z);
      rect(x*float(width)/float(gridRes), y*float(height)/float(gridRes), float(width)/float(gridRes), float(height)/float(gridRes));
      grid[x][y].mult(0.5f);
    }
}

void calcVelo() {
  for(int x = 1; x < gridRes-1; x++) {
    for(int y = 1; y < gridRes-1; y++) {
      velo[x][y] = new PVector();
      velo[x][y] = calcIndivVelo(x, y);
    }
  }
}

PVector calcIndivVelo(int cx, int cy) {
  PVector sum = new PVector();
  for(int x = -1; x <= 1; x++)
    for(int y = -1; y <= 1; y++) {
      if(!(x == 0 && y == 0)) {
        float veltMul = 1.0f/dist(0, 0, float(x), float(y));
        float deltaDensity = density[cx][cy] - density[cx+x][cy+y];
        PVector s = new PVector(x, y);
        s.mult(deltaDensity);
        s.mult(veltMul);
        sum.add(s);
      }
    }
  return sum;
}

class Particle {
  float x;
  float y;
  float xv;
  float yv;
  float px;
  float py;
  float z;
  color c;
  boolean swope = false;
  public Particle(float x, float y, float ma) {
    this.x = x;
    this.y = y;
    c = color(mix(ma, 90f, 255f), mix(ma, 90f, 120f), mix(ma, 255f, 20f), linAlpha);
    z = ma+1.0f;
  }
  public void update(float tx, float ty) {
    if(mousePressed) {
      xv += (tx-x)*0.0000075f*dist(tx, ty, x, y)*z;
      yv += (ty-y)*0.0000075f*dist(tx, ty, x, y)*z;
    }
    int gx = round(x/float(width)*float(gridRes));
    int gy = round(y/float(height)*float(gridRes));
    if(quantizedReaction) {
      PVector q = getBilinear(x, y);
      xv += q.x * spreadFactor;
      yv += q.y * spreadFactor;
    }
    x += xv;
    y += yv;
    xv /= 1.0015f;
    yv /= 1.0015f;
    if(keyPressed) {
      xv /= 1.2f;
      yv /= 1.2f;
    }
    if(wrapParticles) {
      if(x < 0 || y < 0 || x > width || y > width)
        swope = true;
      else
        swope = false;
      if(x < 0) x = width;
      if(y < 0) y = height;
      if(x > width) x = 0;
      if(y > height) y = 0;
    }
    if(quantizedReaction && gx < gridRes && gx >= 0 && gy < gridRes && gy >= 0)
      density[gx][gy]++;
    if(useGrid) {
      if(gx < gridRes && gx >= 0 && gy < gridRes && gy >= 0) {
        grid[gx][gy].add(new PVector(float(r(c))*gridAlpha, float(g(c))*gridAlpha, float(b(c))*gridAlpha));
      }
    }
  }
  void dispLine() {
    if(!swope) {
      stroke(c);
      line(px, py, x, y);
    }
    px = x;
    py = y;
  }
}

PVector getBilinear(float x, float y) {
  float mX = x/float(width)*float(gridRes);
  float mY = y/float(height)*float(gridRes);
  int lowX = floor(mX); int lowY = floor(mY);
  int highX = ceil(mX); int highY = ceil(mY);
  if(lowX < 0 || lowY < 0 || highX >= gridRes || highY >= gridRes) 
    return new PVector();
  PVector samp_00 = copyVec(velo[lowX][lowY]);
  PVector samp_01 = copyVec(velo[lowX][highY]);
  PVector samp_10 = copyVec(velo[highX][lowY]);
  PVector samp_11 = copyVec(velo[highX][highY]);
  float mul_00 = (float(highX)-mX)*(float(highY)-mY);
  float mul_01 = (float(highX)-mX)*(mY-float(lowY));
  float mul_10 = (mX-float(lowX))*(float(highY)-mY);
  float mul_11 = (mX-float(lowX))*(mY-float(lowY));
  samp_00.mult(mul_00);
  samp_01.mult(mul_01);
  samp_10.mult(mul_10);
  samp_11.mult(mul_11);
  PVector sum = new PVector();
  sum.add(samp_00);
  sum.add(samp_01);
  sum.add(samp_10);
  sum.add(samp_11);
  return sum;
}

void diffusion() {
  for(int x = 1; x < gridRes-1; x++)
    for(int y = 1; y < gridRes-1; y++) {
      ngrid[x][y] = new PVector();
      ngrid[x][y].x = (grid[x+1][y].x + grid[x-1][y].x + grid[x][y+1].x + grid[x][y-1].x)/4.0f;
      ngrid[x][y].y = (grid[x+1][y].y + grid[x-1][y].y + grid[x][y+1].y + grid[x][y-1].y)/4.0f;
      ngrid[x][y].z = (grid[x+1][y].z + grid[x-1][y].z + grid[x][y+1].z + grid[x][y-1].z)/4.0f;
    }
  grid = ngrid;
}

void diffusionVelo() {
  for(int x = 1; x < gridRes-1; x++)
    for(int y = 1; y < gridRes-1; y++) {
      nvelo[x][y].x = (velo[x+1][y].x + velo[x-1][y].x + velo[x][y+1].x + velo[x][y-1].x)/4.0f;
      nvelo[x][y].y = (velo[x+1][y].y + velo[x-1][y].y + velo[x][y+1].y + velo[x][y-1].y)/4.0f;
    }
  for(int x = 0; x < gridRes; x++)
    for(int y = 0; y < gridRes; y++)
      velo[x][y] = new PVector(nvelo[x][y].x, nvelo[x][y].y, nvelo[x][y].z);
}

PVector copyVec(PVector p) {
  return new PVector(p.x, p.y, p.z);
}

float mix(float x, float a, float b) {
  return a*(1.0f-x)+b*x;
}

float getNoise(float x, float y, float z) {
  return noise(x/(float)width*5.0f, y/(float)width*5.0f, z/(float)width*5.0f)-0.5f;
}

float getNoise(float x, float y) {
  return noise(x/(float)width*5.0f, y/(float)width*5.0f)-0.5f;
}

int a(color Ce) {
  return (Ce>>24)&0xFF;
}
 
int r(color Ce) {
  return (Ce>>16)&0xFF;
}
 
int g(color Ce) {
  return (Ce>>8)&0xFF;
}
 
int b(color Ce) {
  return Ce&0xFF;
}
