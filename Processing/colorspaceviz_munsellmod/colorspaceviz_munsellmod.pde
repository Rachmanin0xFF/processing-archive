import processing.opengl.*;


ArrayList<ColVert> cv;
Camzy cam = new Camzy();

void setup() {
  size(1280, 720, P3D);
  background(255);
  noSmooth();
  strokeCap(SQUARE);
  cv = loadImg("seth.jpg");
}

void draw() {
  background(255/4);
  //blendMode(ADD);
  //hint(DISABLE_DEPTH_TEST);
  cam.update();
  cam.applyRotations();
  noFill();
  stroke(255);
  //box(255, 255, 255);
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
  strokeWeight(1f);
  noFill();
  stroke(255, 40);
  rotateX(PI/2);
  drawCylinder(16, 255.f/2.f, 255.f/2.f, 255.f);
  drawCylinder(16, 255.f/2.f, 255.f/2.f, 255.f/3.f);
  drawCylinder(1, 0.1, 0.1, 255.f);
  rotateX(-PI/2);
  line(255/2.f, 255/2.f, 0, -255/2.f, 255/2.f, 0);
  line(0, 255/2.f, 255/2.f, 0, 255/2.f, -255/2.f);
  
  line(255/2.f, -255/2.f, 0, -255/2.f, -255/2.f, 0);
  line(0, -255/2.f, 255/2.f, 0, -255/2.f, -255/2.f);
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
    float h = hue(g);
    float sat = saturation(g);
    float b = brightness(g);
    c.add(new ColVert(g, new PVector(sin(h/255.f*TWO_PI)*sat/2.f, b-255.f/2.f, cos(h/255.f*TWO_PI)*sat/2.f)));
  }
  return c;
}

void drawCylinder( int sides, float r1, float r2, float h)
{
    float angle = 360 / sides;
    float halfHeight = h / 2;
    // top
    beginShape();
    for (int i = 0; i < sides; i++) {
        float x = cos( radians( i * angle ) ) * r1;
        float y = sin( radians( i * angle ) ) * r1;
        vertex( x, y, -halfHeight);
    }
    endShape(CLOSE);
    // bottom
    beginShape();
    for (int i = 0; i < sides; i++) {
        float x = cos( radians( i * angle ) ) * r2;
        float y = sin( radians( i * angle ) ) * r2;
        vertex( x, y, halfHeight);
    }
    endShape(CLOSE);
    // draw body
    beginShape(QUAD_STRIP);
    for (int i = 0; i < sides + 1; i++) {
        float x1 = cos( radians( i * angle ) ) * r1;
        float y1 = sin( radians( i * angle ) ) * r1;
        float x2 = cos( radians( i * angle ) ) * r2;
        float y2 = sin( radians( i * angle ) ) * r2;
        vertex( x1, y1, -halfHeight);
        vertex( x2, y2, halfHeight);
    }
    endShape(CLOSE);
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
    /*
    stroke(255, 0, 0);
    line(0, 0, 0, 10, 0, 0);
    stroke(0, 255, 0);
    line(0, 0, 0, 0, 10, 0);
    stroke(0, 0, 255);
    line(0, 0, 0, 0, 0, 10);
    */
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