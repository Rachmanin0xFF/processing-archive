
float molt = 1f;

int res = (int)(100*molt);

boolean holo = false;

boolean[][][] data = new boolean[res][res][res];
float[][][] data3 = new float[res][res][res];
color[][][] data2 = new color[res][res][res];
boolean lookupData(int x, int y, int z) {
  if(x >= data.length || x < 0) return false;
  if(y >= data.length || y < 0) return false;
  if(z >= data.length || z < 0) return false;
  else return data[x][y][z];
}
int printcount = 0;
void keyPressed() {
  saveFrame("p" + printcount + ".png");
  printcount++;
}

float noiseF(float x, float y, float z) {
  return noise(x, y, z);
}

void setup() {
  size(1024, 1024, P3D);
  noiseDetail(10);
  for(int x = 0; x < data.length; x++)
    for(int y = 0; y < data.length; y++)
      for(int z = 0; z < data.length; z++) {
        float p = (x-res/2)*(x-res/2) + (y-res/2)*(y-res/2) + (z-res/2)*(z-res/2);
        float n = noise((float)x/20f/molt, (float)y/20f/molt, (float)z/20f/molt);
        //noiseDetail(1); n *= 4.f; if(n > 1.f) n = 2.f - n; n /= 1.5f;
        data[x][y][z] = n*10f-5.8f > 0.f;
        if(p > res*res/4) data[x][y][z] = false;
      }
  int r = 5;
  for(int x = 0; x < data.length; x++)
    for(int y = 0; y < data.length; y++)
      for(int z = 0; z < data.length; z++) {
        float total = 0.f;
        for(int x2 = -r; x2 <= r; x2++)
          for(int y2 = -r; y2 <= r; y2++)
            for(int z2 = -r; z2 <= r; z2++) {
              if(lookupData(x+x2,y+y2,z+z2)) total++;
            }
        data3[x][y][z] = (float)total/(r*r*r*8);
        data3[x][y][z] = min(1.f, 2.f*(1.f-data3[x][y][z]));
      }
  r = 8;
  for(int x = 0; x < data.length; x++)
    for(int y = 0; y < data.length; y++)
      for(int z = 0; z < data.length; z++) {
        float total = 0.f;
        for(int x2 = -r; x2 <= r; x2++)
          for(int y2 = -r; y2 <= r; y2++)
            for(int z2 = -r; z2 <= r; z2++) {
              if(lookupData(x+x2,y+y2,z+z2)) total++;
            }
        data3[x][y][z] *= min(1.f, 2.f*(1.f-(float)total/(r*r*r*8)));
        data3[x][y][z] = (float)total/(r*r*r*8) + 0.25f;
        if(holo) data3[x][y][z]/=20.f;
      }
  r = 1;
  boolean[][][] tdata = new boolean[res][res][res];
  for(int x = 0; x < data.length; x++)
    for(int y = 0; y < data.length; y++)
      for(int z = 0; z < data.length; z++) tdata[x][y][z] = data[x][y][z];
  for(int x = 0; x < data.length; x++)
    for(int y = 0; y < data.length; y++)
      for(int z = 0; z < data.length; z++) {
        int total = 0;
        for(int x2 = -r; x2 <= r; x2++)
          for(int y2 = -r; y2 <= r; y2++)
            for(int z2 = -r; z2 <= r; z2++) {
              if(lookupData(x+x2,y+y2,z+z2)) total++;
            }
        if(total == (r*2+1)*(r*2+1)*(r*2+1)) tdata[x][y][z] = false;
      }
  for(int x = 0; x < data.length; x++)
    for(int y = 0; y < data.length; y++)
      for(int z = 0; z < data.length; z++) data[x][y][z] = tdata[x][y][z];
  noiseDetail(2);
  for(int x = 0; x < data.length; x++)
    for(int y = 0; y < data.length; y++)
      for(int z = 0; z < data.length; z++) {
        float f = squig((noise((float)x/20f/molt-29204, (float)y/20f/molt-281, (float)z/20f/molt-2891)*255.f*10.f), 255.f);
        float f2 = squig((noise((float)x/20f/molt-204, (float)y/20f/molt-7681, (float)z/20f/molt-829)*255.f*10.f), 255.f);
        float f3 = squig((noise((float)x/20f/molt-1204, (float)y/20f/molt-81, (float)z/20f/molt-1245)*255.f*10.f), 255.f);
        //colorMode(HSB);
        float p = 0.5f/((f + f2 + f3)/255.f/3.f);
        p = 1.f;
        data2[x][y][z] = color(f*data3[x][y][z]*p, f2*data3[x][y][z]*p, f3*data3[x][y][z]*p);
        //data2[x][y][z] = color(data3[x][y][z]*255.f);
      }
      
  ArrayList<PVector> tposs = new ArrayList<PVector>();
  ArrayList<Integer> tcols = new ArrayList<Integer>();
  for(int x = 0; x < data.length; x++)
    for(int y = 0; y < data.length; y++)
      for(int z = 0; z < data.length; z++)
        if(data[x][y][z]) {
          float b = (float)data.length/2;
          tposs.add(new PVector(x-b, y-b, z-b));
          tcols.add(data2[x][y][z]);
        }
  poss = new PVector[tposs.size()];
  cols = new color[tcols.size()];
  for(int i = 0; i < poss.length; i++) {
    poss[i] = tposs.get(i);
    cols[i] = color(tcols.get(i));
  }
  
  noSmooth();
  strokeCap(SQUARE);
}

PVector[] poss;
color[] cols;

float squig(float x, float mod) {
  float g = x%(mod*2.f);
  if(g > mod) g = mod*2.f - g;
  return g;
}
void draw() {
  background(0);
  translate(width/2, height/2, width/2); 
  rotateY(float(mouseX)/200f + ((float)frameCount)/200.f);
  rotateX(float(mouseY)/200f);
  scale(3.6f/molt);
  
  if(holo) {
    blendMode(ADD);
    hint(DISABLE_DEPTH_TEST);
  }
  for(int i = 0; i < poss.length; i++) {
    strokeWeight(280.f/(-modelZ(poss[i].x, poss[i].y, poss[i].z)/3.5f+255.f));
    stroke(cols[i]);
    point(poss[i].x, poss[i].y, poss[i].z);
  }
  //dispVolume(data);
  //println(millis());
}
void dispVolume(boolean[][][] a) {
  float b = (float)a.length/2;
  for(int x = 0; x < a.length; x++)
    for(int y = 0; y < a.length; y++)
      for(int z = 0; z < a.length; z++) {
        if(a[x][y][z]) {
          strokeWeight(280.f/(-modelZ(x-b, y-b, z-b)/3.5f+255.f));
          stroke(data2[x][y][z]);
          //stroke(-modelZ(x-b, y-b, z-b)/3.5f+255.f);
          point(x-b, y-b, z-b);
        }
      }
}