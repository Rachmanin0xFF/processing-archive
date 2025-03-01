// TODO:
// Port to JS
// Better force-directed layout algorithm
// Classify and sort elements by cycle count


import peasy.*;
PeasyCam cam;
ButtonList controls;

Particle[] vertices;
int[][] indices;
boolean[] is_index_active;

Toggler freeze;

void setup() {
  size(1600, 900, P3D);
  
  String[] tbl = loadStrings("symmetric/A_5.txt");
  if(tbl.length != tbl[0].split(" ").length) {
    println("ERROR: Non-square table / wrong delimiter.\nPlsease use \" \" to delimit characters.");
  }
  /*
  tbl = new String[]{"0 1 2 3 4 5",
                     "1 0 4 5 2 3",
                     "2 3 0 1 5 4",
                     "3 2 5 4 0 1",
                     "4 5 1 0 3 2",
                     "5 4 3 2 1 0"};
  */
  indices = new int[tbl.length][tbl.length];
  vertices = new Particle[tbl.length];
  is_index_active = new boolean[tbl.length];
  for(int i = 0; i < tbl.length; i++) {
    String[] spl = tbl[i].split(" ");
    for(int j = 0; j < spl.length; j++) {
      indices[i][j] = int(spl[j]);
    }
    vertices[i] = new Particle();
  }
  
  cam = new PeasyCam(this, 100);
  cam.setMinimumDistance(1);
  cam.setMaximumDistance(5000);
  controls = new ButtonList(tbl.length);
  //controls.toggles[7].state = true;
  //controls.toggles[8].state = true;
  freeze = new Toggler(width - 30, 10, 20, 20);
}

void draw() {
  background(0);
  stroke(255);
  noFill();
  //box(100);
  is_index_active = controls.get_array();
  
  for(int i = 0; i < vertices.length; i++) {
    vertices[i].update();
    vertices[i].display();
  }
  for(int i = 0; i < indices.length; i++) {
    randomSeed(i);
    stroke(random(50, 255), random(50, 255), random(50, 255), 255);
    if(is_index_active[i])
      for(int j = 0; j < indices[0].length; j++) {
        int id1 = j;
        int id2 = indices[i][j];
        PVector p1 = vertices[id1].r;
        if(id1 != id2) {
          PVector p2 = vertices[id2].r;
          line(p1.x, p1.y, p1.z, p2.x, p2.y, p2.z);
          if(!freeze.state) {
            vertices[id1].add_F(spring(p1, p2));
            vertices[id2].add_F(spring(p2, p1));
          }
        }
      }
    if(!freeze.state)
    for(int j = 0; j < indices[0].length; j++) {
      int id1 = j;
      int id2 = indices[i][j];
      if(id1 != id2) {
        PVector p1 = vertices[id1].r;
        PVector p2 = vertices[id2].r;
        vertices[id1].add_F(repulse(p1, p2));
        vertices[id2].add_F(repulse(p2, p1));
      }
    }
  }
  cam.beginHUD();
  controls.update();
  freeze.update();
  freeze.display();
  cam.endHUD();
}

PVector spring(PVector p1, PVector p2) {
  PVector a = PVector.sub(p2, p1);
  float d = a.mag();
  a.normalize();
  a.mult((d - 50)*0.1);
  return a;
}

PVector repulse(PVector p1, PVector p2) {
  PVector a = PVector.sub(p2, p1);
  float d = a.mag();
  a.normalize();
  a.mult(-1/d);
  return a;
}

class Particle {
  PVector v;
  PVector r;
  PVector F;
  Particle() {
    r = PVector.random3D();
    r.mult(100);
    F = new PVector(0, 0, 0);
    v = new PVector(0, 0, 0);
  }
  void add_F(PVector q) {
    F.add(q);
  }
  void update() {
    v.add(F);
    F = new PVector();
    r.add(v);
    v.mult(0.94);
  }
  void display() {
    strokeWeight(16);
    point(r.x, r.y, r.z);
    strokeWeight(1);
  }
}
