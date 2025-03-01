ArrayList<PVector> verts = new ArrayList<PVector>();
ArrayList<PVector> faces = new ArrayList<PVector>();
ArrayList<vec4> posits = new ArrayList<vec4>();
float zoom = 4f;
float kn = 1.4f;
int res = 100;
float sc = 10f;
boolean[][][] fullData = new boolean[res][res][res];
boolean[][][] visited = new boolean[res][res][res];
boolean dbs = true;

void setup() {
  size(900, 600, P3D);
  sphereDetail(4, 2);
  println("Voxel Data Generation Beginning...");
  for(int x = 0; x < res; x++)
    for(int y = 0; y < res; y++)
      for(int z = 0; z < res; z++) {
        fullData[x][y][z] = matFunc(((float)x-res/2)/sc, ((float)y-res/2)/sc, ((float)z-res/2)/sc);
        if(x <=1 || y <=1 || z<=1 || x > res-2 || y > res-2 || z > res-2)
          fullData[x][y][z] = false;
      }
  println("Voxel Data Completed. Beginning floater removal and expandication...");
  expandicate();
  
  int[] v7 = getV();
  visited[v7[0]][v7[1]][v7[2]] = true;
  println(v7[0] + " " + v7[1] + " " + v7[2]);
  
  for(int i = 0; i < 100; i++) floodFill();
  
  println("Floater Removal Completed. Beginning Raymarching...");
  boolean wasBlock = false;
  boolean isBlock = false;
  for(int x = 0; x < res; x++)
    for(int y = 0; y < res; y++)
      for(int z = 0; z < res; z++) {
        isBlock = fullData[x][y][z];
        if(isBlock&&!wasBlock)
          addGeomXY(x, y, z, 1);
        else if((!isBlock&&wasBlock)&&dbs)
          addGeomXY(x, y, z, 1);
        wasBlock = isBlock;
      }
  println("X Plane Complete...");
  for(int z = 0; z < res; z++)
    for(int x = 0; x < res; x++)
      for(int y = 0; y < res; y++) {
        isBlock = fullData[x][y][z];
        if(isBlock&&!wasBlock)
          addGeomXZ(x, y, z, 1);
        else if((!isBlock&&wasBlock)&&dbs)
          addGeomXZ(x, y, z, 1);
          
        wasBlock = isBlock;
      }
  println("Y Plane Complete...");
  for(int y = 0; y < res; y++)
    for(int z = 0; z < res; z++)
      for(int x = 0; x < res; x++) {
        isBlock = fullData[x][y][z];
        if(isBlock&&!wasBlock)
          addGeomYZ(x, y, z, 1);
        else if((!isBlock&&wasBlock)&&dbs)
          addGeomYZ(x, y, z, 1);
        wasBlock = isBlock;
      }
  println("Z Plane Complete...\nWriting to OBJ...");
  saveGeomFull();
  println("Done.");
}

void expandicate() {
  boolean[][][] o = new boolean[res][res][res];
  for(int x = 1; x < res-1; x++)
    for(int y = 1; y < res-1; y++)
      for(int z = 1; z < res-1; z++)
        if(fullData[x][y][z]) {
          o[x][y][z] = true;
          o[x+1][y][z] = true;
          o[x-1][y][z] = true;
          o[x][y+1][z] = true;
          o[x][y-1][z] = true;
          o[x][y][z+1] = true;
          o[x][y][z-1] = true;
        }
  fullData = o;
}

int[] getV() {
  int[] o = {0, 0, 0};
  int m = 4000;
  for(int x = 1; x < res; x++)
    for(int y = 1; y < res; y++)
      for(int z = 1; z < res; z++)
        if(fullData[x][y][z]==true) {
          if(m>0)
            o = new int[]{x, y, z};
          m--;
        }
   return o;
}

void floodFill() {
  for(int x = 1; x < res-1; x++) {
    for(int y = 1; y < res-1; y++) {
      for(int z = 1; z < res-1; z++) {
        if(visited[x][y][z]==true) {
          if(fullData[x+1][y][z]==true) visited[x+1][y][z] = true;
          if(fullData[x-1][y][z]==true) visited[x-1][y][z] = true;
          if(fullData[x][y+1][z]==true) visited[x][y+1][z] = true;
          if(fullData[x][y-1][z]==true) visited[x][y-1][z] = true;
          if(fullData[x][y][z+1]==true) visited[x][y][z+1] = true;
          if(fullData[x][y][z-1]==true) visited[x][y][z-1] = true;
        }
      }
    }
  }
}

boolean matFunc(float x, float y, float z) {
  noiseDetail(1, 1);
  
  if(abs(cos(x*2f)+cos(y*2f)+cos(z*2f))<0.45)
    return true;
  
  if((x*sc==0||y*sc==0||z*sc==0||x*sc==res||y*sc==res||z*sc==res))
    return false;
  return false;
}
boolean matFunc2(float xa, float ya, float za) {
  float n = 3.0f;
  
  float x = xa;
  float y = ya;
  float z = za;
  for(int i = 0; i < 8; i++) {
    float r = sqrt(x*x+y*y+z*z);
    float t = atan2(sqrt(x*x+y*y), z);
    float p = atan2(y, x);
    x = pow(r, n)*sin(n*t)*cos(n*p)+xa;
    y = pow(r, n)*sin(n*t)*sin(n*p)+ya;
    z = pow(r, n)*cos(n*t)+za;
    if(x*x+y*y+z*z>3)
      break;
  }
  if(x*x+y*y+z*z>3)
    return false;
  return true;
}
void ifsFunc1() {
  float x = 0.5f;
  float y = 0.6f;
  float z = 0.7f;
  for(int i = 0; i < 90000000; i++) {
    float g = random(1000);
    if(g<250) {
      x = 0.5*x+0.5;
      y = 0.5*y+0.5;
      z = 0.5*z+0.5;
    } else if(g<500) {
      x = 0.5*x+0.5;
      y = 0.5*y-0.5;
      z = 0.5*z-0.5;
    } else if(g<750) {
      x = 0.5*x-0.5;
      y = 0.5*y+0.5;
      z = 0.5*z-0.5;
    } else {
      x = 0.5*x-0.5;
      y = 0.5*y-0.5;
      z = 0.5*z+0.5;
    }
    int xp = int(x*res);
    int yp = int(y*res);
    int zp = int(z*res);
    int r = 0;
    if(xp<res-r&&yp<res-r&&zp<res-r&&xp>=r&&yp>=r&&zp>=r) {
      fullData[xp+(int)random(-r, r)][yp+(int)random(-r, r)][zp+(int)random(-r, r)] = true;
    }
  }
}
void loadOBJ(String location) {
  int thickness = 2;
  String[] info = loadStrings(location);
  for(String s : info) {
    String[] parts = s.split(" ");
    if(parts[0].equals("v")) {
      int xp = (int)(Float.parseFloat(parts[1])*(float)res/2.0f+res/2.0f);
      int yp = (int)(Float.parseFloat(parts[2])*(float)res/2.0f+res/2.0f);
      int zp = (int)(Float.parseFloat(parts[3])*(float)res/2.0f+res/2.0f);
      if(xp<res-thickness&&xp>=thickness && yp<res-thickness&&yp>=thickness && zp<res-thickness&&zp>=thickness) {
        fullData[xp][yp][zp] = true;
        for(int x = -thickness; x <= thickness; x++)
          for(int y = -thickness; y <= thickness; y++)
            for(int z = -thickness; z <= thickness; z++) {
              fullData[xp+x][yp+y][zp+z] = true;
            }
      }
    }
  }
  for(int x = 0; x < res; x++)
    for(int y = 0; y < res; y++)
      for(int z = 0; z < res; z++)
        if(x <=1 || y <=1 || z<=1 || x > res-2 || y > res-2 || z > res-2)
          fullData[x][y][z] = false;
}
void draw() {
  randomSeed(2);
  lights();
  noStroke();
  background(255);
  camTransforms();
  translate(-res/2, -res/2, -res/2);
  for(vec4 v : posits) {
    if(true) {
      pushMatrix();
      translate(v.x, v.y, v.z);
      box(1, 1, 1);
      popMatrix();
    }
  }
}
void saveGeomOctet(int b) {
  String[] toWrite = new String[verts.size()+faces.size()];
  int k = verts.size()/8*b;
  for(int i = verts.size()/8*b; i < verts.size()/8*(b+1); i++) {
    toWrite[k] = "v " + (verts.get(k).x/float(res)-0.5f) + " " + (verts.get(k).y/float(res)-0.5f) + " " + (verts.get(k).z/float(res)-0.5f);
    k++;
  }
  int ind = faces.size()/8*b;
  for(int i = faces.size()/8*b; i < faces.size()/8*(b+1); i++) {
    toWrite[k] = "f " + (int)faces.get(ind).x + " " + (int)faces.get(ind).y + " " + (int)faces.get(ind).z;
    k++;
    ind++;
  }
  saveStrings("fractalPart" + b + ".obj", toWrite);
}
void saveGeomFull() {
  String[] toWrite = new String[verts.size()+faces.size()];
  int k = 0;
  for(int i = 0; i < verts.size(); i++) {
    toWrite[k] = "v " + (verts.get(k).x/float(res)-0.5f)*2.0f + " " + (verts.get(k).y/float(res)-0.5f)*2.0f + " " + (verts.get(k).z/float(res)-0.5f)*2.0f;
    k++;
  }
  int ind = 0;
  for(int i = 0; i < faces.size(); i++) {
    toWrite[k] = "f " + (int)faces.get(ind).x + " " + (int)faces.get(ind).y + " " + (int)faces.get(ind).z;
    k++;
    ind++;
  }
  saveStrings("voxelMesh.obj", toWrite);
}
void addGeomXY(float x, float y, float z, float w) {
  posits.add(new vec4(x, y, z, w));
  
  verts.add(new PVector(x, y, z));
  verts.add(new PVector(x, y+w, z));
  verts.add(new PVector(x+w, y+w, z));
  verts.add(new PVector(x+w, y, z));
  
  int n = verts.size()-4;
  
  faces.add(new PVector(1+n, 2+n, 3+n));
  faces.add(new PVector(1+n, 3+n, 4+n));
}
void addGeomYZ(float x, float y, float z, float w) {
  posits.add(new vec4(x, y, z, w));
  
  verts.add(new PVector(x, y, z));
  verts.add(new PVector(x, y+w, z));
  verts.add(new PVector(x, y+w, z+w));
  verts.add(new PVector(x, y, z+w));
  
  int n = verts.size()-4;
  
  faces.add(new PVector(1+n, 2+n, 3+n));
  faces.add(new PVector(1+n, 3+n, 4+n));
}
void addGeomXZ(float x, float y, float z, float w) {
  posits.add(new vec4(x, y, z, w));
  
  verts.add(new PVector(x, y, z));
  verts.add(new PVector(x+w, y, z));
  verts.add(new PVector(x+w, y, z+w));
  verts.add(new PVector(x, y, z+w));
  
  int n = verts.size()-4;
  
  faces.add(new PVector(1+n, 2+n, 3+n));
  faces.add(new PVector(1+n, 3+n, 4+n));
}
class vec4 {
  float x, y, z, w;
  public vec4(float x, float y, float z, float w) {
    this.x = x;
    this.y = y;
    this.z = z;
    this.w = w;
  }
}
void camTransforms() {
  scale(zoom);
  translate(width/2/zoom, height/2/zoom);
  rotateY(map(mouseX*4,0,width,-PI,PI));
  rotateX(map(mouseY*4,0,height,-PI,PI));
}
PVector rotVec(PVector v, float amount) {
  PVector nv = new PVector(v.x + random(-amount, amount), v.y + random(-amount, amount), v.z + random(-amount, amount));
  nv.normalize();
  if(nv.y<0.2)
    return rotVec(v, amount);
  return nv;
}
float deltaFunc(float in) {
  return in/10+1;
}
float sizeFunc(float in) {
  return in*7;
}

void addGeomXYM(float x, float y, float z, float w) {
  posits.add(new vec4(x, y, z, w));
  
  verts.add(new PVector(x, y, z+w));
  verts.add(new PVector(x, y+w, z+w));
  verts.add(new PVector(x+w, y+w, z+w));
  verts.add(new PVector(x+w, y, z+w));
  
  int n = verts.size()-4;
  
  faces.add(new PVector(1+n, 2+n, 3+n));
  faces.add(new PVector(1+n, 3+n, 4+n));
}
void addGeomYZM(float x, float y, float z, float w) {
  posits.add(new vec4(x, y, z, w));
  
  verts.add(new PVector(x+w, y, z));
  verts.add(new PVector(x+w, y+w, z));
  verts.add(new PVector(x+w, y+w, z+w));
  verts.add(new PVector(x+w, y, z+w));
  
  int n = verts.size()-4;
  
  faces.add(new PVector(1+n, 2+n, 3+n));
  faces.add(new PVector(1+n, 3+n, 4+n));
}
void addGeomXZM(float x, float y, float z, float w) {
  posits.add(new vec4(x, y, z, w));
  
  verts.add(new PVector(x, y+w, z));
  verts.add(new PVector(x+w, y+w, z));
  verts.add(new PVector(x+w, y+w, z+w));
  verts.add(new PVector(x, y+w, z+w));
  
  int n = verts.size()-4;
  
  faces.add(new PVector(1+n, 2+n, 3+n));
  faces.add(new PVector(1+n, 3+n, 4+n));
}
