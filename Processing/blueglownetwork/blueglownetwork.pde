ArrayList<Neuron> glowers = new ArrayList<Neuron>();

float kb = 2600.f;
Button b = new Button(40, 40 + 00, 350, 60, "Connect");
Button b2 = new Button(40, 120 + 00, 350, 60, "Disconnect");
Button b3 = new Button(40, 200 + 00, 350, 60, "Exit");
Slider wop = new Slider(40, 280 + 00, 350, 60, "P");
Slider woi = new Slider(40, 360 + 00, 350, 60, "I");
Slider wod = new Slider(40, 440 + 00, 350, 60, "D");
GoPad gopa = new GoPad(40 + 370, 40, 400, 400);
Theme them = new Theme(color(0, 140), color(70*1.2f, 120*1.2f, 255, 255));
void setup() {
  size(1280, 720, P3D);
  float k = 1600.f;
  for(int i = 0; i < 4000; i++) {
    glowers.add(new Neuron(i, new PVector(random(-kb, kb), random(-kb, kb), random(-kb, kb))));
  }/*
  if (frame != null) {
    frame.setResizable(true);
  }*/
  PFont font = loadFont("CellblockNBP-48.vlw");
  textFont(font);
  textSize(24);
  them.radius = 5;
  b.set_theme(them);
  b2.set_theme(them);
  b3.set_theme(them);
  wop.set_theme(them);
  woi.set_theme(them);
  wod.set_theme(them);
  gopa.set_theme(them);
  //smooth(4);
  noSmooth();
}

float emx = 0.f;
float emy = 0.f;
float emx2 = 0.f;
float emy2 = 0.f;
ImprovedNoise imp = new ImprovedNoise();
void draw() {
  pushMatrix();
  hint(DISABLE_DEPTH_TEST);
  background(0);
  strokeCap(SQUARE);
  emx += 0.1*(-(mouseX - width*3/2)/2.f-emx);
  emy += 0.1*(-(mouseY - height*3/2)/2.f-emy);
  emx2 += 0.1*(mouseX - width/2 - emx2);
  emy2 += 0.1*(mouseY - height/2 - emy2);
  translate(emx, emy, -400);
  rotateX(emy2/float(height)/8.f);
  rotateY(-emx2/float(width)/8.f);
  blendMode(ADD);
  float t = 0.f;
  for(Neuron n : glowers) {
    n.update();
    t+=PI/7.f;
    pushMatrix();
    float focal_dist = abs(modelZ(n.r.x, n.r.y, n.r.z));
    //float focal_dist = abs((float)n.r.z);
    float r = focal_dist/50.f;
    float r2 = min(1.f, 30.f/(r*r));
    beginShape(LINES);
    for(int i = 0; i < n.inputs.size(); i++) {
      stroke(n.red*r2*n.ages.get(i), n.green*r2*n.ages.get(i), n.blue*r2*n.ages.get(i));
      vertex(n.r.x, n.r.y, n.r.z);
      float focal_dist0 = abs(modelZ(glowers.get(n.inputs.get(i)).r.x, glowers.get(n.inputs.get(i)).r.y, glowers.get(n.inputs.get(i)).r.z));
      float r0 = focal_dist0/50.f;
      float r20 = min(1.f, 30.f/(r0*r0));
      stroke(glowers.get(n.inputs.get(i)).red*r20*n.ages.get(i), glowers.get(n.inputs.get(i)).green*r20*n.ages.get(i), glowers.get(n.inputs.get(i)).blue*r20*n.ages.get(i));
      vertex(glowers.get(n.inputs.get(i)).r.x, glowers.get(n.inputs.get(i)).r.y, glowers.get(n.inputs.get(i)).r.z);
    }
    endShape();
    for(int i = n.inputs.size() - 1; i >= 0; i--) {
      int i1 = n.inputs.get(i);
      if(dist(glowers.get(i1).r.x, glowers.get(i1).r.y, glowers.get(i1).r.z, n.r.x, n.r.y, n.r.z) > 350)
        n.active.set(i, false);
    }
    stroke(n.red*r2, n.green*r2, n.blue*r2);
    strokeWeight(max(1.f, r));
    point(n.r.x,  n.r.y, n.r.z);
    //fill(n.red*r2, n.green*r2, n.blue*r2);
    //noStroke();
    //polygon(n.r.x, n.r.y, n.r.z, max(1.f, r), 6);
    popMatrix();
    strokeWeight(1);
  }
  for(int i = 0; i < 2000; i++) {
    int i1 = (int)random(glowers.size());
    int i2 = (int)random(glowers.size());
    if(i1 != i2 && dist(glowers.get(i1).r.x, glowers.get(i1).r.y, glowers.get(i1).r.z, glowers.get(i2).r.x, glowers.get(i2).r.y, glowers.get(i2).r.z) < 350 && glowers.get(i1).inputs.size() < 3 && !glowers.get(i1).inputs.contains(i2) && !glowers.get(i2).inputs.contains(i1)) {
      glowers.get(i1).add_connection(i2);
    }
  }
  popMatrix();
  blendMode(BLEND);
  
  /*
  translate(width/2, height/2);
  rotateY(-(mouseX-width/2)/5000.f);
  rotateX((mouseY-height/2)/5000.f);
  translate(-width/2, -height/2);
  */
  
  /*
  b.update();
  b.display();
  b2.update();
  b2.display();
  b3.update();
  b3.display();
  gopa.update();
  gopa.display();
  wop.update();
  wop.display();
  woi.update();
  woi.display();
  wod.update();
  wod.display();
  */
  
  if(b3.is_on)
    exit();
}

class Neuron {
  String name = "";
  int id = -1;
  ArrayList<Integer> inputs = new ArrayList<Integer>();
  ArrayList<Float> ages = new ArrayList<Float>();
  ArrayList<Boolean> active = new ArrayList<Boolean>();
  PVector r = new PVector();
  PVector v = new PVector();
  float red = random(255);
  float green = random(255);
  float blue = random(255);
  public Neuron(int id, PVector position) {
    r = copy_vec(position);
    v = new PVector(0, 0, 0);
    this.id = id;
    float rand = random(1);
    PVector bob = mix(pow(rand, 30), new PVector(70, 120, 255), new PVector(410, 120, 70));
    red = bob.x;
    green = bob.y;
    blue = bob.z;
  }
  float c = 600.f;
  float q = 0.2f;
  float e = 0.95f;
  float t = 0.f;
  public void update() {
    for(int i = 0; i < ages.size(); i++) {
      if(ages.get(i) < 1.f && active.get(i))
        ages.set(i, ages.get(i) + 0.004f);
      if(!active.get(i)) {
        ages.set(i, ages.get(i) - 0.004f);
      }
    }
    for(int i = inputs.size() - 1; i >= 0; i--) {
      if(ages.get(i) < 0.f) {
        rem_connection(i);
      }
    }
    t += 0.003f;
    v.add(new PVector((noise(r.x/c+id, r.y/c, r.z/c+t)-0.5f)*q, (noise(r.y/c+id, r.z/c, r.x/c+t)-0.5f)*q, (noise(r.z/c+id, r.x/c, r.y/c+t)-0.5f)*q));
    v.mult(e);
    r.add(v);
  }
  void rem_connection(int id) {
    ages.remove(id);
    inputs.remove(id);
    active.remove(id);
  }
  void add_connection(int id) {
    inputs.add(id);
    ages.add(0.f);
    active.add(true);
  }
}

public static double fast_exp(double val) {
    final long tmp = (long) (1512775 * val + (1072632447));
    return Double.longBitsToDouble(tmp << 32);
}

void polygon(float x, float y, float z, float radius, int npoints) {
  float angle = TWO_PI / npoints;
  beginShape();
  for (float a = 0; a < TWO_PI; a += angle) {
    float sx = x + cos(a) * radius;
    float sy = y + sin(a) * radius;
    vertex(sx, sy, z);
  }
  endShape(CLOSE);
}
