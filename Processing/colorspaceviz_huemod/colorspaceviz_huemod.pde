import processing.opengl.*;


ArrayList<ColVert> cv;
Camzy cam = new Camzy();

void setup() {
  size(1280, 720, P3D);
  background(255);
  noSmooth();
  strokeCap(SQUARE);
  cv = loadImg("chiaroscuro.jpg");
}

void draw() {
  background(255/2);
  //blendMode(ADD);
  //hint(DISABLE_DEPTH_TEST);
  cam.update();
  cam.applyRotations();
  noFill();
  stroke(255);
  box(255, 255, 255);
  strokeWeight(1.f);
  noStroke();
  for(ColVert bec : cv) {
    float focal_dist = modelZ(bec.vert.x, bec.vert.y, bec.vert.z);
    float k1 = abs(focal_dist);
    //fill(bec.col, k1/3.f);
    fill(bec.col, 255);
    //stroke(bec.col, k1/3.f);
    //strokeWeight(max(2.f, 100.f/(k1*k1)));
    translate(bec.vert.x, bec.vert.y, bec.vert.z);
    //point(0, 0, 0);
    box(1);
    translate(-bec.vert.x, -bec.vert.y, -bec.vert.z);
    //point(bec.vert.x, bec.vert.y, bec.vert.z);
  }
}
int r(color c) {return (c >> 16) & 255; }
int g(color c) {return (c >> 8) & 255;}
int b(color c) {return c & 255; }
class ColVert {
  color col;
  PVector vert;
  public ColVert(color c, PVector p) {
    vert = p;
    col = c;
  }
}

ArrayList<ColVert> loadImg(String s) {
  ArrayList<ColVert> c = new ArrayList<ColVert>();
  PImage p = loadImage(s);
  for(color g : p.pixels) {
    c.add(new ColVert(g, new PVector(hue(g)-255/2 + random(-0.5, 0.5), saturation(g)-255/2 + random(-0.5, 0.5), brightness(g)-255/2 + random(-0.5, 0.5))));
  }
  return c;
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
    vh /= 1.0f;
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