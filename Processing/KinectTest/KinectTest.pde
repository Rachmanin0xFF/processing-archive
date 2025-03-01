import SimpleOpenNI.*;

SimpleOpenNI kinect;

PVector[] coords = new PVector[640*480];
PVector[][] coords2D = new PVector[640][480];

int min1 = 10000000;
int min2 = 10000000;

void setup() {
  size(1280, 720, P3D);
  kinect = new SimpleOpenNI(this);
  if(kinect.isInit() == false) {
     println("Can't initialize SimpleOpenNI, maybe the camera is not connected?"); 
     exit();
     return;  
  }
  kinect.setMirror(false);
  kinect.enableDepth();
  kinect.enableRGB();
  for(int x = 0; x < 640; x++) for(int y = 0; y < 480; y++) coords2D[x][y] = new PVector();
}

void kinectUpdate() {
  kinect.update();
  coords = kinect.depthMapRealWorld();
  copyTo2D();
  findMinimums();
}

void draw() {
  kinectUpdate();
  
  pushMatrix();
  hint(DISABLE_DEPTH_TEST);
  blendMode(ADD);
  background(0);
  stroke(255);
  translate(width/2, height/2);
  rotateX((float)mouseY/100.0f);
  rotateY((float)mouseX/100.0f);
  translate(0,0,-1000);
  
  int step = 2;
  beginShape(POINTS);
  for(int x = 0; x < 640; x += step)
    for(int y = 0; y < 480; y += step)
      vertex(coords2D[x][y].x, -coords2D[x][y].y, coords2D[x][y].z);
  endShape();
  stroke(255, 0, 0);
  strokeWeight(5);
  point(coords[min1].x, coords[min1].y, coords[min1].z);
  strokeWeight(1);
  
  popMatrix();
  
  for(int x = 0; x < 640; x++)
    for(int y = 0; y < 480; y++) {
      stroke(coords2D[x][y].z/10.0f);
      point(x, y);
    }
}

void copyTo2D() {
  for(int i = 0; i < coords.length; i++) {
    coords2D[i%640][min(i/480, 479)] = new PVector(coords[i].x, coords[i].y, coords[i].z);
  }
}

void findMinimums() {
  min1 = 10000000;
  min2 = 10000000;
  for(int i = 0; i < coords.length; i++) {
    if(coords[i].z < min1 && coords[i].z > 600) {
      min2 = min1;
      min1 = i;
    }
  }
}
