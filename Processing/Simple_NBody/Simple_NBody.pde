import peasy.*;
PeasyCam cam;

Solver univ;

void setup() {
  size(1280, 720, P3D);
  cam = new PeasyCam(this, 100);
  cam.setMinimumDistance(50);
  cam.setMaximumDistance(3000);
  univ = new Solver();
  
  univ.add_body(100, 0, 0, 0, 4, -0.4, 1000);
  univ.add_body(-100, 0, 0, 0, -4, -0.4, 1000);
  univ.add_body(0, 0, 0, 0.0, 0, 8, 100);
  //univ.add_body(-5, 0, 0, 0, -1.1, 0, 10);
  
  //for(int i = 0; i < 1; i++)
  //univ.add_body(random(-100, 100), random(-100, 100), random(-100, 100), random(-3, 3), random(-3, 3), random(-3, 3), random(1000));
  
  smooth(16);
  
  background(0);
}

ArrayList<String> yrec = new ArrayList<String>();

void keyPressed() {
  String[] yr = new String[yrec.size()];
  for(int i = 0; i < yr.length; i++) {
    yr[i] = yrec.get(i);
  }
  saveStrings("out.txt", yr);
}

void draw() {
  println(frameRate);
  background(0);
  univ.update(mousePressed?10:100000);
  
  yrec.add(((float)univ.bodies.get(2).r.z) + "");
  
  drawAxes(50);
  noStroke();
  univ.display();
}

void drawAxes(float r) {
  strokeWeight(3);
  stroke(255, 100, 0);
  line(0, 0, 0, r, 0, 0);
  stroke(50, 200, 50);
  line(0, 0, 0, 0, r, 0);
  stroke(30, 120, 255);
  line(0, 0, 0, 0, 0, r);
}
