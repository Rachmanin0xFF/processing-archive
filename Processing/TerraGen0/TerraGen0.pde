Map testMap = new Map(750*2, 375*2);

void setup() {
  size(1500, 750, P2D);
  background(209, 151, 100);
  smooth(4);
  background(255);
  println("Making...");
  testMap.loadGradient("gradient.png");
  println("Saving...");
  testMap.saveOBJ("world_out", 2);
  println("Drawing...");
  testMap.display2();
  println("Done!");
}

void draw() {}

void keyPressed() {
  saveFrame("world_out"+ "/" + "world_out" + ".png");
}

import java.io.File;
class Map {
  int w;
  int h;
  PVector[][] pos3;
  float[][] heights;
  float[][] lights;
  float low = 0.9f;
  float high = 1.1f;
  float sealine = 1.06;//= 1.02f;
  PImage gradient;
  boolean gradientOn = false;
  String[] mtl = {"newmtl m_0", "Ka 0.000 0.000 0.000", "Kd 1.000 1.000 1.000", "Ks 0.200 0.200 0.200", "d 1.0", "illum 2", "map_Kd tex_out.png"};
  ArrayList<I2> water = new ArrayList<I2>();
  public Map(int w, int h) {
    this.w = w;
    this.h = h;
    genMap();
  }
  void loadGradient(String location) {
    gradient = loadImage(location);
    gradientOn = true;
  }
  color getGradient(float h) {
    if(gradientOn) {
      int f = (int)map(h, low, high, 0.f, gradient.width);
      return gradient.pixels[min(gradient.width-1, max(0, f))];
    } else
      return color(map(h, low, high, 0.f, 255.f));
  }
  float minH = 10000000.f;
  float maxH = -10000000.f;
  void genMap() {
    pos3 = new PVector[w][h];
    heights = new float[w][h];
    lights = new float[w][h];
    for(int x = 0; x < w; x++)
      for(int y = 0; y < h; y++) {
        float theta = float(y)/float(h)*PI; //Latitude
        float phi = float(x)/float(w)*TWO_PI; //Longitude
        pos3[x][y] = new PVector(sin(theta)*cos(phi), sin(theta)*sin(phi), cos(theta));
        pos3[x][y].normalize();
      }
    for(int x = 0; x < w; x++)
      for(int y = 0; y < h; y++)
        heights[x][y] = getHeight1(pos3[x][y]);
    
    for(int x = 0; x < w; x++)
      for(int y = 0; y < h; y++) {
        if(heights[x][y] < minH) minH = heights[x][y];
        if(heights[x][y] > maxH) maxH = heights[x][y];
      }
    for(int x = 0; x < w; x++)
      for(int y = 0; y < h; y++) {
        heights[x][y] = map(heights[x][y], minH, maxH, low, high);
        pos3[x][y].mult(heights[x][y]);
      }
    
  }
  public void display() {
    blendMode(BLEND);
    for(int x = 0; x < w; x++)
      for(int y = 0; y < h; y++) {
          stroke(getGradient(heights[x][y]));
          point(x, y);
      }
    blendMode(MULTIPLY);
    for(int x = 1; x < w-2; x++)
      for(int y = 1; y < h; y++) {
        float deltaX = (-heights[x][y]*2.f + heights[x+1][y] + heights[x+2][y])/2.f;
        stroke(deltaX*10000.f+100.f);
        if(heights[x][y] < sealine) stroke(100.f);
        point(x, y);
      }
    displayOutline();
  }
  public void display2() {
    background(255);
    //displayHatching();
    //filter(BLUR, 20);
    displayOutline();
    displayHatching();
    for(I2 j : water) point(j.x, j.y);
  }
  void displayHatching() {
    stroke(0);
    strokeWeight(1);
    for(int x = 0; x < w; x++)
      for(int y = 0; y < h; y++) {
        if(heights[x][y] - (sealine-random(0.005f)-0.01f) > 0 && heights[x][y] < sealine && y%3==0) {
          set(x, y, color(0));
        }
        if(heights[x][y] - (sealine-0.0075f) > 0 && heights[x][y] < sealine && x%3==0) {
          set(x, y, color(0));
        }
      }
  }
  void displayOutline() {
    strokeWeight(2);
    for(int x = 0; x < w-1; x++)
      for(int y = 0; y < h-1; y++) {
        if((heights[x][y] >= sealine || heights[x+1][y] >= sealine || heights[x][y+1] >= sealine || heights[x+1][y+1] >= sealine) &&
           (heights[x][y] < sealine || heights[x+1][y] < sealine || heights[x][y+1] < sealine || heights[x+1][y+1] < sealine) &&
           (heights[x][y] >= sealine || heights[x+1][y] >= sealine || heights[x][y+1] >= sealine || heights[x+1][y+1] >= sealine )) {
          stroke(0);
          point(x, y);
        }
      }
    strokeWeight(1);
  }
  boolean isLand(int x, int y) {
    return heights[x][y] > sealine;
  }
  int oW = 0;
  int oH = 0;
  public void saveOBJ(String location, int scale) {
    oW = w/scale;
    oH = h/scale;
    ArrayList<String> stout = new ArrayList<String>();
    stout.add("mtllib " + location + ".mtl");
    stout.add("usemtl m_0");
    PVector[][] dataOut = new PVector[oW][oH];
    for(int x = 0; x < oW; x++)
      for(int y = 0; y < oH; y++) {
        dataOut[x][y] = copyVec(pos3[x*scale][y*scale]);
        dataOut[x][y].normalize();
        float fh = pos3[x*scale][y*scale].mag();
        if(fh < sealine)
          fh = sealine;
        dataOut[x][y].mult(fh);
      }
    for(int x = 0; x < oW; x++)
      for(int y = 0; y < oH; y++)
        stout.add("v " + dataOut[x][y].x + " " + dataOut[x][y].y + " " + dataOut[x][y].z);
    for(int x = 0; x < oW; x++)
      for(int y = 0; y < oH; y++)
        stout.add("vt " + (float(x)/float(oW)) + " " + (1.f-float(y)/float(oH)));
    for(int x = 0; x < oW; x++)
      for(int y = 0; y < oH; y++) {
        stout.add("f " + oIndex(x+1, y+1) + "/" + oIndex(x+1, y+1) + " " + oIndex(x, y+1) + "/" + oIndex(x, y+1) + " " + oIndex(x, y) + "/" + oIndex(x, y) + " " + oIndex(x+1, y) + "/" + oIndex(x+1, y));
      }
    String[] arrout = new String[stout.size()];
    for(int i = 0; i < arrout.length; i++) arrout[i] = stout.get(i);
    new File(location).mkdir();
    saveStrings(location + "/" + location + ".obj", arrout);
    mtl[6] = "map_Kd " + location + ".png";
    saveStrings(location + "/" + location + ".mtl", mtl);
    PImage img = createImage(w, h, RGB);
    for(int x = 0; x < w; x++)
      for(int y = 0; y < h; y++)
        img.set(x, y, getGradient(heights[x][y]));
    img.save(location + "/" + location + ".png");
  }
  int oIndex(int x, int y) {
    if(x == oW) x = 0;
    if(y == oH) y = 0;
    return x*oH+y+1;
  }
  PVector copyVec(PVector p) {
    return new PVector(p.x, p.y, p.z);
  }
  float getHeight0(PVector p) {
    PVector q = copyVec(p);
    return noise(q.x+129, q.y+157, q.z-1125);
  }
  float getHeight1(PVector p) {
    noiseDetail(1, 1.f);
    float sum = 0.f;
    for(float i = 1.f; i < pow(2, 7); i *= 2.f) {
      PVector q = copyVec(p);
      q = rotateA(q, new PVector(1, 0, 0), i*1324.722f);
      q = rotateA(q, new PVector(0, 1, 0), i*1501.2155f);
      q = rotateA(q, new PVector(0, 0, 1), i*4421.89f);
      q.mult(1.f);
      q.add(new PVector(1247, 111, -571));
      q.mult(i);
      
      float n = noise(q.x+129+i, q.y+157-i, q.z-1125+i)*4.f;
      if(n > 1.f) n = 2.f-n;
      sum += n*0.4f/i;
    }
    return sum;
  }
  PVector rotateA(PVector v, PVector _axis, float ang) {
    PVector na = copyVec(_axis); na.normalize();
    PVector nv = copyVec(v); nv.normalize();
    PVector axis=new PVector(na.x, na.y, na.z);
    PVector vnorm=new PVector(nv.x, nv.y, nv.z);
    float _parallel=PVector.dot(axis,v);
    PVector parallel=PVector.mult(axis,_parallel);
    PVector perp=PVector.sub(parallel, v);
    PVector Cross = v.cross(axis);
    PVector result=PVector.add(parallel,PVector.add(PVector.mult(Cross,sin(-ang)),PVector.mult(perp,cos(-ang))));
    return result;
  } 
}

class I2 {
  int x;
  int y;
  I2(int x, int y) {
    this.x = x;
    this.y = y;
  }
}
