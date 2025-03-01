int res = 128;
PVector[][] E = new PVector[res][res];

// del squared e_pot = -chg_dens / rel_perm
float[][] e_pot = new float[res][res];
float[][] rel_perm = new float[res][res];
float[][] chg_dens = new float[res][res];

void setup() {
  size(1600, 900, P3D);
  noSmooth();
  fillFRandGauss(rel_perm);
  //fillFRandGauss(chg_dens);
  //fillFRandGauss(e_pot);
  
  
  chg_dens = imgToFArr(loadImage("example_strip.png"));
  rel_perm = imgToFArr(loadImage("example_strip_3.png"));
  
  addEpsilon(rel_perm);
}

void draw() {
  background(50);
  for(int i = 0; i < 100; i++)updateV(e_pot);
  plotFArr(chg_dens, 600, 50, 200);
  plotFArr(rel_perm, 50, 600, 200);
  plotFArr(e_pot, 50, 50, 512);
  lights();
  plotFArr3D(e_pot, 1000, 50, 256);
  PVector[][] E = get_grad(e_pot);
  plotVArr(E, 300, 600, 300);
  plotFArr3D(get_mag(E), 1000, 600, 300);
}

void addEpsilon(float[][] V) {
  
  float[][] nrp = new float[rel_perm.length][rel_perm.length];
  for(int x = 1; x < V.length-1; x++) {
    for(int y = 1; y < V.length-1; y++) {
      nrp[x][y] = 0.25*(rel_perm[x][y] + rel_perm[x+1][y] + rel_perm[x][y+1] + rel_perm[x+1][y+1]);
    }
  }
  for(int x = 1; x < V.length-1; x++) {
    for(int y = 1; y < V.length-1; y++) {
      rel_perm[x][y] = nrp[x][y];
    }
  }
  
  for(int x = 0; x < V.length; x++) {
    for(int y = 0; y < V.length; y++) {
      if(rel_perm[x][y] > 0.9) rel_perm[x][y] = 100000.0; else
      if(rel_perm[x][y] > 0.1) rel_perm[x][y] = 3.5; else
      rel_perm[x][y] = 1.0;
      if(chg_dens[x][y] > 0.9) chg_dens[x][y] = 1.0; else {
      if(chg_dens[x][y] < 0.1) chg_dens[x][y] = -1.0;
      else chg_dens[x][y] = 0.0;
      }
    }
  }
}

void updateV(float[][] V) {
  float[][] nv = new float[V.length][V.length];
  
  /*
  for(int x = 0; x < V.length; x++) {
    V[x][0] = 0.0;
    V[x][V.length-1] = 0.1;
    V[0][x] = (float)x/(float)V.length*0.1;
    V[V.length-1][x] = (float)x/(float)V.length*0.1;
  }
  */
  
  
  
  for(int x = 1; x < V.length-1; x++) {
    for(int y = 1; y < V.length-1; y++) {
      
      float a0 = rel_perm[x][y] + rel_perm[x-1][y] + rel_perm[x][y-1] + rel_perm[x-1][y-1];
      float a1 = 0.5*(rel_perm[x][y] + rel_perm[x][y-1]);
      float a2 = 0.5*(rel_perm[x-1][y] + rel_perm[x][y]);
      float a3 = 0.5*(rel_perm[x-1][y-1] + rel_perm[x-1][y]);
      float a4 = 0.5*(rel_perm[x][y-1] + rel_perm[x-1][y-1]);
      
      nv[x][y] = (1.f/a0)*(a1*V[x+1][y] + a2*V[x][y+1] + a3*V[x-1][y] + a4*V[x][y-1] + chg_dens[x][y]);
    }
  }
  for(int x = 1; x < V.length-1; x++) {
    for(int y = 1; y < V.length-1; y++) {
      V[x][y] = nv[x][y];
    }
  }
}

class Mapping {
  float xmin = 100000; float xmax = -100000;
  float ymin = 100000; float ymax = -100000;
  int vx = 10;
  int vy = 10;
  int vw = 900-20;
  int vh = 900-20;
  Mapping(float xmn, float xmx, float ymn, float ymx) {
    xmin = xmn;
    xmax = xmx;
    ymin = ymn;
    ymax = ymx;
    vw = width-20;
    vh = height-20;
  }
  PVector screen_to_coords(float x, float y) {
    return new PVector(map(x, vx, vx+vw, xmin, xmax), map(y, vy, vy + vh, ymin, ymax));
  }
  PVector coords_to_screen(float x, float y) {
    return new PVector(map(x, xmin, xmax, vx, vx+vw), map(y, ymin, ymax, vy, vy + vh));
  }
}
