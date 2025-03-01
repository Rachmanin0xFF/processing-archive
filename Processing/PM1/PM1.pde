int k = 50;
float eas = 0.001f;
Bucket[][] mesh = new Bucket[k][k];

void setup() {
  size(512, 512, P2D);
  for(int x = 0; x < k; x++) {
    for(int y = 0; y < k; y++) {
      mesh[x][y] = new Bucket(x, y, random(255));
    }
  }
  grav();
}

void draw() {
  background(0);
  noStroke();
  dispMesh();
}

void dispMesh() {
  for(int x = 0; x < k; x++) {
    for(int y = 0; y < k; y++) {
      fill(mesh[x][y].xv);
      rect((float)x*(float)width/(float)k, (float)y*(float)height/(float)k, (float)width/(float)k, (float)height/(float)k);
    }
  }
}

void grav() {
  for(int x = 0; x < k; x++) {
    for(int y = 0; y < k; y++) {
      
      for(int x2 = 0; x2 < k; x2++) {
        for(int y2 = 0; y2 < k; y2++) {
          if(x2 != x && y2 != y)
            mesh[x][y].attract(x2, y2, mesh[x2][y2].density);
        }
      }
      
    }
  }
}

class Bucket {
  float x;
  float y;
  float xv;
  float yv;
  float density;
  public Bucket(float x, float y, float d) {
    this.x = x;
    this.y = y;
    xv = 0;
    yv = 0;
    this.density = d;
  }
  void attract(float x0, float y0, float ds) {
    float d = dist(x, y, x0, y0);
    PVector q = new PVector(x0-x, y0-y);
    q.normalize();
    xv += q.x/(d*d/100)*eas*ds;
    yv += q.y/(d*d/100)*eas*ds;
  }
  void cls() {
    xv = 0;
    yv = 0;
  }
}
