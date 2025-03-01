ArrayList<PVector> verts = new ArrayList<PVector>();
ArrayList<PVector> faces = new ArrayList<PVector>();
ArrayList<vec4> posits = new ArrayList<vec4>();
float zoom = 0.008;
float kn = 1.4;

void recur(float x, float y, float z, float i, PVector dir, float branchSize) {
  addGeom(x, y, z, branchSize);
  PVector ndir = rotVec(dir, 0.15);
  float ni = deltaFunc(branchSize);
  if(i>1.0||branchSize>20) {
    if(random(100)>97) {
      recur(x+dir.x*ni*kn, y+dir.y*ni*kn, z+dir.z*ni*kn, i-1, ndir, branchSize/1.3);
      recur(x+dir.x*ni*kn, y+dir.y*ni*kn, z+dir.z*ni*kn, i-1, rotVec(ndir, 1.0), branchSize/1.3);
    } else
      recur(x+dir.x*ni*kn, y+dir.y*ni*kn, z+dir.z*ni*kn, i-1, ndir, branchSize-1);
  }
}

void setup() {
  size(900, 600, P3D);
  sphereDetail(4, 2);
  recur(0, 0, 0, 240, new PVector(0, 1, 0), 2040);
  saveGeom();
}
void draw() {
  lights();
  noStroke();
  background(255);
  camTransforms();
  for(vec4 v : posits) {
    pushMatrix();
    translate(v.x, v.y, v.z);
    sphere(v.w);
    popMatrix();
  }
}
void saveGeom() {
  String[] toWrite = new String[verts.size()+faces.size()];
  int k = 0;
  for(PVector v : verts) {
    toWrite[k] = "v " + verts.get(k).x + " " + verts.get(k).y + " " + verts.get(k).z;
    k++;
  }
  int ind = 0;
  for(PVector v : faces) {
    toWrite[k] = "f " + (int)faces.get(ind).x + " " + (int)faces.get(ind).y + " " + (int)faces.get(ind).z;
    k++;
    ind++;
  }
  saveStrings("fractal.obj", toWrite);
}
void addGeom(float x, float y, float z, float w) {
  posits.add(new vec4(x, y, z, w));
  
  verts.add(new PVector(x+1*w, y, z));
  verts.add(new PVector(x-1*w, y, z));
  
  verts.add(new PVector(x, y+1*w, z));
  verts.add(new PVector(x, y-1*w, z));
  
  verts.add(new PVector(x, y, z+1*w));
  verts.add(new PVector(x, y, z-1*w));
  
  int n = verts.size()-6;
  
  faces.add(new PVector(1+n, 3+n, 6+n));
  faces.add(new PVector(3+n, 2+n, 6+n));
  faces.add(new PVector(2+n, 4+n, 6+n));
  faces.add(new PVector(4+n, 1+n, 6+n));
  
  faces.add(new PVector(1+n, 3+n, 5+n));
  faces.add(new PVector(3+n, 2+n, 5+n));
  faces.add(new PVector(2+n, 4+n, 5+n));
  faces.add(new PVector(4+n, 1+n, 5+n));
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
