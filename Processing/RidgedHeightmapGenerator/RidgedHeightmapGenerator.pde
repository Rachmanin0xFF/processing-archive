
int resX = 600;
int resY = 600;

float[][] data = new float[resX][resY];
float[][] ao = new float[resX][resY];

Camzy c = new Camzy();

void setup() {
  size(resX, resY, P3D);
  background(0);
  for(int x = 0; x < width; x++) {
    for(int y = 0; y < height; y++) {
      float h = getHeight1(new PVector((float)x/500.f, (float)y/500.f, 10.f), 2) - 0.5f;
      color c = color(h*255.f, 255);
      data[x][y] = h*255.f;
      ao[x][y] = 255.f;
      set(x, y, c);
    }
  }
  /*
  int r = 100;
  for(int x = 0; x < resX; x++) {
    for(int y = 0; y < resY; y++) {
      float shadiness = 0.f;
      for(int x2 = -r; x2 < r; x2++) {
        for(int y2 = -r; y2 < r; y2++) {
          if(data[x][y] < gett(x + x2, y + y2)) shadiness++;
        }
      }
      ao[x][y] = 255.f - shadiness/170.f;
    }
    println(int(100.f*(float)x/(float)resX));
  }*/
  fill(0, 0, 0);
  rect(10, 10, 50, 50);
  fill(255/2, 255/2, 255/2);
  rect(70, 10, 50, 50);
  fill(255, 255, 255);
  rect(130, 10, 50, 50);
  strokeCap(SQUARE);
  noSmooth();
  saveFrame("MAP.png");
}

void draw() {
  background(0);
  lights();
  c.update();
  c.applyRotations();
  scale(0.1f);
  //blendMode(ADD);
  //hint(DISABLE_DEPTH_TEST);
  stroke(255, 50);
  strokeWeight(1);
  noStroke();
  fill(150, 255);
  for(int x = 1; x < width; x++) {
    for(int y = 1; y < height; y++) {
      //float h = data[x][y];
      //point(x - width/2, h*2.f, y - height/2);
      beginShape(TRIANGLE_FAN);
      fill(ao[x-1][y], 255);
      vertex(x - width/2 - 1, data[x-1][y]*2.f, y - height/2);
      fill(ao[x-1][y-1], 255);
      vertex(x - width/2 - 1, data[x-1][y-1]*2.f, y - height/2 - 1);
      fill(ao[x][y], 255);
      vertex(x - width/2, data[x][y-1]*2.f, y - height/2 - 1);
      fill(ao[x][y], 255);
      vertex(x - width/2, data[x][y]*2.f, y - height/2);
      endShape(CLOSE);
    }
  }
}
float gett(int x, int y) {
  if(x >= resX || x < 0) return 10000.f;
  if(y >= resY || y < 0) return 10000.f;
  return data[x][y];
}

class Camzy {
  float rotHorizontial = PI*0.25f;
  float rotVertical = PI*0.75f;
  float zoom = 1.f;
  float vv = 0.f;
  float vh = 0.f;
  float vz = 0.f;
  boolean pmousePressed = false;
  void applyRotations() {
    translate(width/2, height/2);
    scale(zoom);
    rotateX(rotVertical);
    rotateY(rotHorizontial);
    strokeWeight(1.f/zoom);
    stroke(255, 0, 0);
    line(0, 0, 0, 10, 0, 0);
    stroke(0, 255, 0);
    line(0, 0, 0, 0, 10, 0);
    stroke(0, 0, 255);
    line(0, 0, 0, 0, 0, 10);
  }
  void update() {
    zoom = CAMZY_GLOBALZOOM;
    if(keyPressed) if(key == '+') CAMZY_GLOBALZOOM *= 1.05f; else if(key == '-') CAMZY_GLOBALZOOM /= 1.05f;
    if(mousePressed && pmousePressed) {
      vh = float(pmouseX - mouseX)/300.f;
      vv = float(pmouseY - mouseY)/300.f;
    }
    rotHorizontial += vh;
    rotVertical += vv;
    vh /= 1.1f;
    vv /= 1.1f;
    pmousePressed = mousePressed;
  }
}
float CAMZY_GLOBALZOOM = 10.f;
void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  if(e < 0.f) CAMZY_GLOBALZOOM *= 1.05f;
  else CAMZY_GLOBALZOOM /= 1.05f;
}

float getHeight1(PVector p, int iter) {
  noiseDetail(1, 1.f);
  p.add(new PVector(94.38f, 11.82f, -57.55f));
  float sum = 0.f;
  for(int i = 0; i < iter; i++) {
    float k = pow(2, i);
    PVector q = new PVector(p.x*k, p.y*k, p.z*k);
    q = rotateA(q, new PVector(1, 0, 0), i*48.5964);
    q = rotateA(q, new PVector(0, 1, 0), i*94.6866);
    q = rotateA(q, new PVector(0, 0, 1), i*24.7906);
    p.add(new PVector(94.38f, 11.82f, -57.55f));
    sum += (float)ridged_noise(q.x, q.y, q.z)/k/2.f;
  }
  return sum;
}
PVector rotateA(PVector v, PVector _axis, float ang) {
  PVector na = new PVector(_axis.x, _axis.y, _axis.z); na.normalize();
  PVector nv = new PVector(v.x, v.y, v.z); nv.normalize();
  PVector axis=new PVector(na.x, na.y, na.z);
  PVector vnorm=new PVector(nv.x, nv.y, nv.z);
  float _parallel=PVector.dot(axis,v);
  PVector parallel=PVector.mult(axis,_parallel);
  PVector perp=PVector.sub(parallel, v);
  PVector Cross = v.cross(axis);
  PVector result=PVector.add(parallel,PVector.add(PVector.mult(Cross,sin(-ang)),PVector.mult(perp,cos(-ang))));
  return result;
}

// JAVA REFERENCE IMPLEMENTATION OF IMPROVED NOISE - COPYRIGHT 2002 KEN PERLIN.

public class ImprovedNoise {
   public double noise(double x, double y, double z) {
      int X = (int)Math.floor(x) & 255,                  // FIND UNIT CUBE THAT
          Y = (int)Math.floor(y) & 255,                  // CONTAINS POINT.
          Z = (int)Math.floor(z) & 255;
      x -= Math.floor(x);                                // FIND RELATIVE X,Y,Z
      y -= Math.floor(y);                                // OF POINT IN CUBE.
      z -= Math.floor(z);
      double u = fade(x),                                // COMPUTE FADE CURVES
             v = fade(y),                                // FOR EACH OF X,Y,Z.
             w = fade(z);
      int A = p[X  ]+Y, AA = p[A]+Z, AB = p[A+1]+Z,      // HASH COORDINATES OF
          B = p[X+1]+Y, BA = p[B]+Z, BB = p[B+1]+Z;      // THE 8 CUBE CORNERS,

      return lerp(w, lerp(v, lerp(u, grad(p[AA  ], x  , y  , z   ),  // AND ADD
                                     grad(p[BA  ], x-1, y  , z   )), // BLENDED
                             lerp(u, grad(p[AB  ], x  , y-1, z   ),  // RESULTS
                                     grad(p[BB  ], x-1, y-1, z   ))),// FROM  8
                     lerp(v, lerp(u, grad(p[AA+1], x  , y  , z-1 ),  // CORNERS
                                     grad(p[BA+1], x-1, y  , z-1 )), // OF CUBE
                             lerp(u, grad(p[AB+1], x  , y-1, z-1 ),
                                     grad(p[BB+1], x-1, y-1, z-1 ))));
   }
   double fade(double t) { return t * t * t * (t * (t * 6 - 15) + 10); }
   double lerp(double t, double a, double b) { return a + t * (b - a); }
   double grad(int hash, double x, double y, double z) {
      int h = hash & 15;                      // CONVERT LO 4 BITS OF HASH CODE
      double u = h<8 ? x : y,                 // INTO 12 GRADIENT DIRECTIONS.
             v = h<4 ? y : h==12||h==14 ? x : z;
      return ((h&1) == 0 ? u : -u) + ((h&2) == 0 ? v : -v);
   }
   final int p[] = new int[512], permutation[] = { 151,160,137,91,90,15,
   131,13,201,95,96,53,194,233,7,225,140,36,103,30,69,142,8,99,37,240,21,10,23,
   190, 6,148,247,120,234,75,0,26,197,62,94,252,219,203,117,35,11,32,57,177,33,
   88,237,149,56,87,174,20,125,136,171,168, 68,175,74,165,71,134,139,48,27,166,
   77,146,158,231,83,111,229,122,60,211,133,230,220,105,92,41,55,46,245,40,244,
   102,143,54, 65,25,63,161, 1,216,80,73,209,76,132,187,208, 89,18,169,200,196,
   135,130,116,188,159,86,164,100,109,198,173,186, 3,64,52,217,226,250,124,123,
   5,202,38,147,118,126,255,82,85,212,207,206,59,227,47,16,58,17,182,189,28,42,
   223,183,170,213,119,248,152, 2,44,154,163, 70,221,153,101,155,167, 43,172,9,
   129,22,39,253, 19,98,108,110,79,113,224,232,178,185, 112,104,218,246,97,228,
   251,34,242,193,238,210,144,12,191,179,162,241, 81,51,145,235,249,14,239,107,
   49,192,214, 31,181,199,106,157,184, 84,204,176,115,121,50,45,127, 4,150,254,
   138,236,205,93,222,114,67,29,24,72,243,141,128,195,78,66,215,61,156,180
   };
   { for (int i=0; i < 256 ; i++) p[256+i] = p[i] = permutation[i]; }
}

public double ridged_noise(double x, double y, double z) {
  double r = (new ImprovedNoise()).noise(x, y, z)*.5f + .5f;
  return r > 0.5 ? (1.f - r)*2.f : r*2.f;
}
public float ridged_noise2(float x, float y, float z) {
  float r = noise(x, y, z)*2.f;
  return r > 0.5 ? (1.f - r)*2.f : r*2.f;
}

float min = 0.f;
float max = 1.f;
public void minmaxCheck(int iter) {
  float min2 = 10000000.f;
  float max2 = -10000000.f;
  for(int i = 0; i < iter; i++) {
    float r = ridged_noise2(random(-100.f, 100.f), random(-100.f, 100.f), random(-100.f, 100.f));
    if(r < min2) min2 = r;
    if(r > max2) max2 = r;
  }
  min = min2;
  max = max2;
  println("MIN: " + min + " MAX: " + max);
}

/*
 q = rotateA(q, new PVector(1, 0, 0), i*1324.722f);
  q = rotateA(q, new PVector(0, 1, 0), i*1501.2155f);
  q = rotateA(q, new PVector(0, 0, 1), i*4421.89f);
  q.add(new PVector(1247, 111, -571));
*/
