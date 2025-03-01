
//Adam Lastowka//
ArrayList<Circle> circles = new ArrayList<Circle>();
ArrayList<Line> permaLines = new ArrayList<Line>();
float dt = 0.05f;
int balTik = 0;

void setup() {
  size(1920-150, 1080-150, P2D);
  //smooth(8);
  noSmooth();
  //noFill();
  //circles.add(new Circle(128, 256 + 39.7, 2, 0, 20));
  //circles.add(new Circle(374, 256, -1, 0, 20));
  frameRate(1000000);
}

void mousePressed() {
  for(int i = 0; i < 40; i++)
    circles.add(new Circle(mouseX, mouseY, random(-24f, 24f), random(-7f, 7f), 7));
  //circles.add(new Circle(mouseX, mouseY, 0, 0, 40));
}

void draw() {
  background(0);
 // line(0, height-10, width, height-10);
  noFill();
  rect(10, 10, width-20, height-20);
  fill(255);
  stroke(255);
 // line(0, 10, width, 10);
  for(Circle c : circles) {
    c.update();
  }
  for(Circle c : circles) {
    c.update2();
  }
  //drawPermaLines();              
  for(Circle c : circles) {
    //c.display();
  }
  for(Circle c : circles) {
    c.display2();
  }
}

void drawPermaLines() {
  stroke(0, 150, 0);                              
  for(Line l : permaLines)
    l.display();
  for(int i = permaLines.size()-1; i >= 0; i--) {
    if(permaLines.get(i).shouldDie())
      permaLines.remove(i);
  }
  stroke(0, 0, 0);
}

class Line {
  PVector start;
  PVector end;
  int iter = 100;
  public Line(float x, float y, float a, float b) {
    start = new PVector(x, y);
    end = new PVector(a, b);
  }
  void display() {
    stroke(0, 150, 0, (float)iter*2.55f);
    line(start.x, start.y, end.x, end.y);
    iter--;
  }
  boolean shouldDie() {
    return iter <= 0;
  }
}
void lin(float x, float y, float a, float b) {
  permaLines.add(new Line(x, y, a, b));
}

class Circle {
  int i = -1;
  PVector p;
  PVector v;
  float r;
  float restitution = 0.3f;
  float mass = 0.f;
  PVector a;
  ArrayList<PVector> positions;
  public Circle(float x, float y, float xv, float yv, float r) {
    p = new PVector(x, y);
    v = new PVector(xv, yv);
    this.r = r;
    mass = r*r;
    this.i = balTik++;
    positions = new ArrayList<PVector>();
  }
  public void update() {
    float clump = 400.f;
    a = new PVector();
    for(Circle c : circles) {
      if(c.i != i) {
        float distance_to = dist(p.x, p.y, c.p.x, c.p.y);
        if(distance_to < 50) {
          
          PVector pointAt = new PVector(c.p.x - p.x, c.p.y - p.y);
          pointAt.normalize();
          pointAt.mult(clump/(distance_to*distance_to + c.r*2.f + r*2.f)*dt);
          a.add(pointAt);
          if(distance_to < c.r + r) {
            PVector normal = PVector.sub(c.p, p);
            normal.normalize();
            PVector relative_velocity = PVector.sub(c.v, v);
            float v_along_normal = PVector.dot(relative_velocity, normal);
            if(v_along_normal > 0) return;
            a.add(PVector.mult(normal, v_along_normal/dt));
            lin(p.x, p.y, p.x + normal.x*100.f, p.y + normal.y*100.f);
          }
        }
      }
    }
  }
  public void update2() {
    if(p.y + r > height-10 && v.y > 0) {v.y = -v.y*.95f;} else {
      if(keyPressed) a.add(new PVector(0, 0.1f));
    }
    if(p.y - r < 10 && v.y < 0) {v.y = -v.y*.95f;} else {
      //a.add(new PVector(0, 0.1f));
    }
    if(p.x + r > width-10 && v.x > 0) {v.x = -v.x*.95f;} else {
      //a.add(new PVector(0, 0.1f));
    }
    if(p.x - r < 10 && v.x < 0) {v.x = -v.x*.95f;} else {
      //a.add(new PVector(0, 0.1f));
    }
    v.mult(0.999f);
    v.add(new PVector(0, 0.1f));
    v.add(PVector.mult(a, dt));
    p.add(PVector.mult(v, dt));
    positions.add(new PVector(p.x, p.y));
  }
  public void display() {
    if(positions.size() > 100)
      positions.remove(0);
    for(int k = 2; k < positions.size(); k++) {
      stroke(0, k*2.55f);
      line(positions.get(k).x, positions.get(k).y, positions.get(k-1).x, positions.get(k-1).y);
    }
    stroke(0, 255);
  }
  public void display2() {
    ellipse(p.x, p.y, r*2.f, r*2.f);
    
  }
}
