
//@author Adam Lastowka

//todo in another pde - color space diagrams

ArrayList<Mesh> m;
Camzy c;

void setup() {
  size(1600, 900, P3D);
  noSmooth();
  m = loadFile("cow.obj");
  //m.get(0).printIndexCheck();
  //m.get(0).removeDoublesHashmap(); //Broken fancy algorithm (finds doubles reaaly fast, then removes them)
  //m.get(0).removeDoubles(0.000001); //Working double removal algorithm, runs in O(n^2)
  for(Mesh ms : m) ms.calculateNormals();
  c = new Camzy();
}

void mousePressed() {
  if(mouseButton==RIGHT) {
    for(int i = 0; i < 100; i++) m.get(0).mergeVerts((int)random(m.get(0).verts.size()-1), (int)random(m.get(0).verts.size()-1));
    //m.get(0).removeVertexDirty(0);
    //m.get(0).printIndexCheck();
  }
}

void draw() {
  background(60);
  lights();
  c.update();
  c.applyRotations();
  
  fill(255);
  noStroke();
  for(Mesh i : m) {
    i.display();
  }
  
  stroke(255, 0, 0);
  strokeWeight(10);
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

import java.util.*;

//When editing a mesh, be sure to update:

//Faces.indices
//Faces.ids
 
//Vertices
//Vertices.connectedFaces
//Vertices.ids

class Mesh {
  ArrayList<Vertex> verts = new ArrayList<Vertex>();
  ArrayList<Face> faces = new ArrayList<Face>();
  Mesh() {}
  
  void addFace(Face f) {
    faces.add(f);
  }
  
  void addFace(int... idx) {
    faces.add(new Face(idx));
    for(int i : idx)
      verts.get(i).addFace(faces.size()-1);
  }
  
  void removeFace(int i) {
    faces.remove(i);
    for(int j = 0; j < verts.size(); j++) {
      for(int k = verts.get(j).connectedFaces.size() - 1; k >= 0; k--) {
        if(verts.get(j).connectedFaces.contains(i)) verts.get(j).connectedFaces.remove(verts.get(j).connectedFaces.indexOf(i));
      }
    }
    for(int j = i; j < faces.size(); j++) faces.get(j).id--;
    for(int j = 0; j < verts.size(); j++) {
      for(int k = 0; k < verts.get(j).connectedFaces.size(); k++) {
        if(verts.get(j).connectedFaces.get(k) >= i)
          verts.get(j).connectedFaces.set(k, verts.get(j).connectedFaces.get(k)-1);
      }
    }
  }
  
  void addVertex(Vertex v) {
    verts.add(v);
  }
  
  //Removes a vertex without deleting the faces it is attached to.
  //WARNING: Using this function may cause faces to reference nonexistent vertices!
  void removeVertexDirty(int i) {
    verts.remove(i);
    for(int j = i; j < verts.size(); j++) {
      verts.get(j).id--;
    }
    for(int j = 0; j < faces.size(); j++) {
      for(int k = 0; k < faces.get(j).indices.size(); k++) {
        if(faces.get(j).get(k) >= i)
          faces.get(j).set(k, faces.get(j).get(k)-1);
      }
    }
  }
  
  //Removes b, splices it into a
  void mergeVerts(int a, int b) {
    //Merge at vertex center
    verts.get(a).pos.add(verts.get(b).pos);
    verts.get(a).pos.mult(0.5);
    verts.get(a).uv.add(verts.get(b).uv);
    verts.get(a).uv.mult(0.5);
    for(int i : verts.get(b).connectedFaces) {
      verts.get(a).addFace(i);
      int index = faces.get(i).indices.indexOf(b);
      if(faces.get(i).contains(a)) {
        faces.get(i).indices.remove(index);
      } else {
        faces.get(i).indices.set(index, a);
      }
    }
    removeVertexDirty(b);
    //remove2VertexFaces();
    genVertConns();
  }
  
  void removeDoubles(double epsilon) {
    double epsilon2 = epsilon*epsilon;
    for(int i = verts.size() - 1; i >= 0; i--) {
      for(int j = i; j >= 0; j--) {
        if(i != j) {
          VecN a = copy_vec(verts.get(i).pos);
          VecN b = copy_vec(verts.get(j).pos);
          if(a.distance_to2(b) < epsilon2) { mergeVerts(j, i); i--; }
        }
      }
    }
    remove2VertexFaces();
    calculateNormals();
  }
  
  void removeDoublesHashmap() {
    println("Mark.");
    //Identifies doubles
    SpatialHashmap sh = new SpatialHashmap();
    sh.affixToVerts(verts, 20);
    for(Vertex v : verts) v.name = "none";
    for(int i = 0; i < verts.size(); i++) {
      ArrayList<Integer> clones = sh.getClones(i, verts);
      for(int j : clones) verts.get(i).mergTargHashmap = j;
    }
    println("Stage 1 completed.");
    
    println("Stage 2 completed.");
    remove2VertexFaces();
  }
  
  void remove2VertexFaces() {
    ArrayList<Face> tmp = new ArrayList<Face>(faces);
    for(int i = tmp.size()-1; i >= 0; i--) {
      Face f = tmp.get(i);
      if(f.indices.size() < 3) {
        removeFace(i);
      }
    }
  }
  
  void calculateNormals() {
    for(Face f : faces) {
      f.calcNorm(verts);
    }
    for(Vertex v : verts) {
      v.calcNorm(faces);
    }
  }
  
  void genVertConns() {
    for(Vertex v : verts) v.connectedFaces.clear();
    for(Face f : faces) for(int i : f.indices) verts.get(i).addFace(f.id);
  }
  
  boolean wireframe = false;
  boolean fillNorms = true;
  boolean fillUVs = false;
  void display() {
    if(wireframe) noFill(); else noStroke();
    for(Face f : faces) {
      beginShape(TRIANGLE_FAN);
      for(int i : f.indices) {
        Vertex v = verts.get(i);
        if(wireframe) {
          if(fillNorms) {
            stroke((float)v.norm.x*255.f + 255.f/2.f, (float)v.norm.y*255.f + 255.f/2.f, (float)v.norm.z*255.f + 255.f/2.f);
          } else if(fillUVs) {
            stroke((float)v.uv.x*255.f, (float)v.uv.y*255.f, 0.f);
          } else stroke(0);
        } else {
          if(fillNorms) {
            fill((float)v.norm.x*255.f + 255.f/2.f, (float)v.norm.y*255.f + 255.f/2.f, (float)v.norm.z*255.f + 255.f/2.f);
          } else if(fillUVs) {
            fill((float)v.uv.x*255.f, (float)v.uv.y*255.f, 0.f);
          } else fill(255/2.f);
        }
        //fill((float)f.norm.x*255.f + 255.f/2.f, (float)f.norm.y*255.f + 255.f/2.f, (float)f.norm.z*255.f + 255.f/2.f);
        //fill((float)v.c.x,(float)v.c.y, (float)v.c.z);
        //fill((float)v.uv.x*255.f, (float)v.uv.y*255.f, 0.f);
        vertex((float)v.pos.x, (float)v.pos.y, (float)v.pos.z);
      }
      endShape(CLOSE);
    }
  }
  
  void printIndexCheck() {
    for(Face f : faces) {
      print("\nF" + f.id);
      for(int i : f.indices) print(" " + i);
    }
    for(Vertex v : verts) {
      print("\nV" + v.id);
      for(int i : v.connectedFaces) print(" " + i);
    }
  }
}

//Spatial hashing for fanciness
class SpatialHashmap {
  int resolution = 0;
  Bucket[][][] items;
  
  double minx = 0.; double maxx = 0.;
  double miny = 0.; double maxy = 0.;
  double minz = 0.; double maxz = 0.;
  
  void affixToVerts(ArrayList<Vertex> verts, int resolution) {
    for(int i = 0; i < verts.size(); i++) {
      VecN v = verts.get(i).pos;
      if(v.x < minx) minx = v.x; else if(v.x > maxx) maxx = v.x;
      if(v.y < miny) miny = v.y; else if(v.y > maxy) maxy = v.y;
      if(v.z < minz) minz = v.z; else if(v.z > maxz) maxz = v.z;
    }
    minx -= 0.01; maxx += 0.01;
    miny -= 0.01; maxy += 0.01;
    minz -= 0.01; maxz += 0.01;
    
    this.resolution = resolution;
    items = new Bucket[resolution][resolution][resolution];
    for(int i = 0; i < verts.size(); i++) {
      VecN v = verts.get(i).pos;
      int[] idx = getBucketIndex(v.x, v.y, v.z);
      if(items[idx[0]][idx[1]][idx[2]] == null) items[idx[0]][idx[1]][idx[2]] = new Bucket();
      items[idx[0]][idx[1]][idx[2]].pointers.add(i);
    }
  }
  
  ArrayList<Integer> getClones(int i, ArrayList<Vertex> verts) {
    VecN v = verts.get(i).pos;
    int[] idx = getBucketIndex(v.x, v.y, v.z);
    return subDoubles(idx[0], idx[1], idx[2], verts, verts.get(i));
  }
  
  ArrayList<Integer> subDoubles(int x, int y, int z, ArrayList<Vertex> verts, Vertex v) {
    ArrayList<Integer> out = new ArrayList<Integer>();
    Bucket b = items[x][y][z];
    for(int j : b.pointers) {
      VecN v2 = verts.get(j).pos;
      if((v.id != verts.get(j).id) && (v.pos.distance_to(v2)) < 0.0000001) out.add(j);
    }
    return out;
  }
  
  int[] getBucketIndex(double a, double b, double c) {
    int x = (int)((a - minx)/(maxx - minx)*resolution);
    int y = (int)((b - miny)/(maxy - miny)*resolution);
    int z = (int)((c - minz)/(maxz - minz)*resolution);
    return new int[]{x, y, z};
  }
  
  class Bucket {
    ArrayList<Integer> pointers = new ArrayList<Integer>();
  }
}

ArrayList<Mesh> loadFile(String fileLocation) {
  ArrayList<Mesh> marr = new ArrayList<Mesh>();
  if(true || fileLocation.endsWith("\\.obj")) {
    println("Importing OBJ file from " + fileLocation + "...");
    
    ArrayList<VecN> vertices = new ArrayList<VecN>();
    ArrayList<VecN> normals = new ArrayList<VecN>();
    ArrayList<VecN> uvs = new ArrayList<VecN>();
    
    int vindex = 0;
    int vioff = 0;
    int vioffcase = 0;
    int normioff = 0;
    int uvioff = 0;
    int currentLine = 0;
    boolean mergeFlag = false;
    Mesh mout = new Mesh();
    
    String[] lines = loadStrings(fileLocation);
    for(int k = 0; k < lines.length + 1; k++) {
      if(k%1000==0) println(mout.faces.size());
      String s = "o ";
      if(k < lines.length) s = lines[k];
      if(vindex != 0 && s.startsWith("o ")) {
        marr.add(mout);
        
        vioff += vertices.size();
        vioffcase += mout.verts.size();
        normioff += normals.size();
        uvioff += uvs.size();
        
        mout = new Mesh();
        vertices = new ArrayList<VecN>();
        normals = new ArrayList<VecN>();
        uvs = new ArrayList<VecN>();
        
        vindex = 0;
      } else if(s.startsWith("v ")) {
        String[] split = s.split(" ");
        vertices.add(new VecN(Float.parseFloat(split[1]), Float.parseFloat(split[2]), Float.parseFloat(split[3])));
      } else if(s.startsWith("vn")) {
        String[] split = s.split(" ");
        normals.add(new VecN(Float.parseFloat(split[1]), Float.parseFloat(split[2]), Float.parseFloat(split[3])));
      } else if(s.startsWith("vt")) {
        String[] split = s.split(" ");
        uvs.add(new VecN(Float.parseFloat(split[1]), Float.parseFloat(split[2])));
      } else if(s.startsWith("f ")) {
        String[] split = s.split(" ");
        Face f = new Face();
        f.id = mout.faces.size();
        if(split[1].contains("/")) {
          mergeFlag = true;
          if(split[1].contains("//")) {
            for(int i = 0; i < split.length-1; i++) {
              String[] subSplit = split[i+1].split("//");
              int idex0 = Integer.parseInt(subSplit[0]) - 1 - vioff;
              int idex1 = Integer.parseInt(subSplit[1]) - 1 - normioff;
              Vertex v = new Vertex(vindex, vertices.get(idex0).x, vertices.get(idex0).y, vertices.get(idex0).z,
                                            normals.get(idex1).x,  normals.get(idex1).y,  normals.get(idex1).z);
              v.addFace(f.id);
              mout.addVertex(v);
              f.add(vindex);
              vindex++;
            }
            
          } else {
            for(int i = 0; i < split.length-1; i++) {
              String[] subSplit = split[i+1].split("/");
              int idex0 = Integer.parseInt(subSplit[0]) - 1 - vioff;
              int idex1 = Integer.parseInt(subSplit[1]) - 1 - uvioff;
              int idex2 = Integer.parseInt(subSplit[2]) - 1 - normioff;
              Vertex v = new Vertex(vindex, vertices.get(idex0).x, vertices.get(idex0).y, vertices.get(idex0).z,
                                            normals.get(idex2).x,  normals.get(idex2).y,  normals.get(idex2).z,
                                            uvs.get(idex1).x,  uvs.get(idex1).y);
              v.addFace(f.id);
              mout.addVertex(v);
              f.add(vindex);
              vindex++;
            }
          }
        } else {
          for(VecN v : vertices) {
            mout.addVertex(new Vertex(mout.verts.size(), v.x, v.y, v.z));
          }
          vertices = new ArrayList<VecN>();
          uvs = new ArrayList<VecN>();
          for(int i = 0; i < split.length-1; i++) {
            int j = Integer.parseInt(split[i+1]) - 1 - vioffcase;
            mout.verts.get(j).addFace(f.id);
            f.add(j);
            vindex++;
          }
        }
        mout.addFace(f);
      }
      currentLine++;
    }
  }
  return marr;
}

class Vertex {
  int id = -1;
  String name = "";
  VecN pos = new VecN(0, 0, 0);
  VecN norm = new VecN(0, 0, 0);
  VecN uv = new VecN(0, 0);
  VecN c = new VecN(random(0,255), random(0,255), random(0,255));

  ArrayList<Integer> connectedFaces = new ArrayList<Integer>();
  Vertex() {}
  Vertex(int id) {
    this.id = id;
  }
  Vertex(int id, double x, double y, double z) {
    this(id);
    pos = new VecN(x, y, z);
  }
  Vertex(int id, double x, double y, double z, double nx, double ny, double nz) {
    this(id, x, y, z);
    norm = new VecN(nx, ny, nz);
  }
  Vertex(int id, double x, double y, double z, double nx, double ny, double nz, double u, double v) {
    this(id, x, y, z, nx, ny, nz);
    uv = new VecN(u, v);
  }
  
  void calcNorm(ArrayList<Face> faces) {
    norm = new VecN(0., 0., 0.);
    for(int i : connectedFaces) {
      norm.add(faces.get(i).norm);
    }
    norm.normalize();
  }
  
  //The following functions will not actually add or remove faces, they will simply (un)designate the vertex as a member of the face at [id].
  void addFace(int id) {
    if(!connectedFaces.contains(id))
      connectedFaces.add(id);
  }
  void removeFace(int id) {
    connectedFaces.remove(connectedFaces.indexOf(id));
  }
  int mergTargHashmap = -1; //for use in hashmap double removal
}

class Face {
  int id = -1;
  String name = "";
  ArrayList<Integer> indices = new ArrayList<Integer>();
  VecN norm = new VecN();
  Face() {}
  Face(int... idx) {
    for(int i : idx) {
      indices.add(i);
    }
    if(idx.length < 3)
      System.err.println("Warning! Faces must reference at least 3 vertices!");
  }
  int get(int i) {
    return indices.get(i);
  }
  boolean contains(int index) {
    return indices.contains(index);
  }
  void remove(int i) {
    indices.remove(i);
  }
  void add(int i) {
    if(!indices.contains(i))
      indices.add(i);
  }
  void set(int index, int value) {
    indices.set(index, value);
  }
  void insert(int index, int value) {
    indices.add(index, value);
  }
  void calcNorm(ArrayList<Vertex> verts) {
    double Nx = 0.;
    double Ny = 0.;
    double Nz = 0.;
    for(int i = 0; i < indices.size(); i++) {
      int i2 = i + 1;
      if(i == indices.size() - 1) i2 = 0;
      VecN v1 = verts.get(indices.get(i)).pos;
      VecN v2 = verts.get(indices.get(i2)).pos;
      
      Nx += (v1.y - v2.y)*(v1.z + v2.z);
      Ny += (v1.z - v2.z)*(v1.x + v2.x);
      Nz += (v1.x - v2.x)*(v1.y + v2.y);
    }
    VecN v = new VecN(Nx, Ny, Nz);
    v.normalize();
    norm = v;
  }
}

//Unused, don't want to get into this yet
class Edge {
  int id = -1;
  int a = -1;
  int b = -1;
  Edge(int a, int b) {
    this.a = a;
    this.b = b;
  }
}



//WARNING EXPERIMENTAL OPENGL STUFF BELOW HERE

/*
import processing.opengl.*;
import javax.media.opengl.*;
import javax.media.opengl.glu.*;
PGraphicsOpenGL pg = null;
PGL pgl = null;  
GL2 gl = null;

pgl = beginPGL();
gl = ((PJOGL)pgl).gl.getGL2();
copyMatrices();

gl.glColor4f(0.7, 0.7, 0.7, 0.8);
gl.glTranslatef(width/2, height/2, 0);
gl.glRotatef(mouseX, 1, 0, 0);
gl.glRotatef(mouseX*2, 0, 1, 0);
gl.glRectf(-200, -200, 200, 200);
gl.glRotatef(90, 1, 0, 0);
gl.glRectf(-200, -200, 200, 200);

endPGL();

// Copies the current projection and modelview matrices from Processing to OpenGL
// It needs to be done explicitly, otherwise GL will use the identity matrices by
// default!
float[] projMatrix = new float[16];
float[] mvMatrix = new float[16];
void copyMatrices() {
  PGraphicsOpenGL pg = (PGraphicsOpenGL)g;
  gl.glMatrixMode(GL2.GL_PROJECTION);
  projMatrix[0] = pg.projection.m00;projMatrix[1] = pg.projection.m10;projMatrix[2] = pg.projection.m20;projMatrix[3] = pg.projection.m30;
  projMatrix[4] = pg.projection.m01;projMatrix[5] = pg.projection.m11;projMatrix[6] = pg.projection.m21;projMatrix[7] = pg.projection.m31;
  projMatrix[8] = pg.projection.m02;projMatrix[9] = pg.projection.m12;projMatrix[10] = pg.projection.m22;projMatrix[11] = pg.projection.m32;
  projMatrix[12] = pg.projection.m03;projMatrix[13] = pg.projection.m13;projMatrix[14] = pg.projection.m23;projMatrix[15] = pg.projection.m33;
  gl.glLoadMatrixf(projMatrix, 0);
  gl.glMatrixMode(GL2.GL_MODELVIEW);
  mvMatrix[0] = pg.modelview.m00;mvMatrix[1] = pg.modelview.m10;mvMatrix[2] = pg.modelview.m20;mvMatrix[3] = pg.modelview.m30;
  mvMatrix[4] = pg.modelview.m01;mvMatrix[5] = pg.modelview.m11;mvMatrix[6] = pg.modelview.m21;mvMatrix[7] = pg.modelview.m31;
  mvMatrix[8] = pg.modelview.m02;mvMatrix[9] = pg.modelview.m12;mvMatrix[10] = pg.modelview.m22;mvMatrix[11] = pg.modelview.m32;
  mvMatrix[12] = pg.modelview.m03;mvMatrix[13] = pg.modelview.m13;mvMatrix[14] = pg.modelview.m23;mvMatrix[15] = pg.modelview.m33;
  gl.glLoadMatrixf(mvMatrix, 0);
}
*/
