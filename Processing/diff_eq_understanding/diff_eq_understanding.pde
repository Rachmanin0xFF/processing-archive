
float a = 1; float b = 2;
float c = 0.5; float d = 1;

Slider sa;
Slider sb;
Slider sc;
Slider sd;

PVector func(PVector pos) {
  float x = pos.x; float y = pos.y;
  float dx = a*x + b*y;
  float dy = c*x + d*y;
  return new PVector(dx, dy);
}

PVector tsf_by_mat(PVector p) {
  return new PVector(p.x*a + p.y*b, p.x*c + p.y*d);
}

ArrayList<Path> paths = new ArrayList<Path>();

void setup() {
  size(900, 900, P2D);
  background(0);
  stroke(255);
  frameRate(500);
  
  float[] gamma = eigenvals(a, b, c, d);
  print(gamma[0] + " " + gamma[1]);
  
  sa = new Slider(10, height-100, 150, 30);
  sb = new Slider(170, height-100, 150, 30);
  sc = new Slider(10, height-50, 150, 30);
  sd = new Slider(170, height-50, 150, 30);
  sa.set_range(-20.f, 20.f);
  sb.set_range(-20.f, 20.f);
  sc.set_range(-20.f, 20.f);
  sd.set_range(-20.f, 20.f);
  sa.display_value = true;
  sb.display_value = true;
  sc.display_value = true;
  sd.display_value = true;
  sa.set_value(3);
  sb.set_value(-1);
  sc.set_value(9);
  sd.set_value(-3);
}

float[] eigenvals(float a, float b, float c, float d) {
  println(a + " " + b + " " + c + " " + d);
  println(sqrt(a*a-2*a*d+4*b*c+d*d));
  float E1 = 1.f/2.f*(-sqrt(a*a-2*a*d+4*b*c+d*d)+a+d);
  float E2 = 1.f/2.f*(sqrt(a*a-2*a*d+4*b*c+d*d)+a+d);
  return new float[]{E1, E2};
}

float zoom = 100.0;
PVector screen_to_math(PVector a) {
  return new PVector((a.x - width/2)/zoom, (-a.y + height/2)/zoom);
}
PVector math_to_screen(PVector a) {
  return new PVector(a.x*zoom + width/2, -a.y*zoom + height/2);
}

void mousePressed() {
  paths.add(new Path(screen_to_math(new PVector(mouseX, mouseY))));
}
void mouseWheel(MouseEvent event) {
  background(0);
  float e = event.getCount();
  if(e > 0) zoom /= 1.1f;
  else zoom *= 1.1f;
}

boolean path_destro = false;
void draw() {
  if(sa.dragging || sb.dragging || sc.dragging || sd.dragging) {
    background(0);
    for(int i = 0; i < 10; i++) {
      paths.add(new Path(screen_to_math(new PVector(random(0, width), random(0, height)))));
    }
    path_destro = true;
    /*
    stroke(0, 255, 255, 150);
    for(int x = -5; x < 5; x++) {
      for(int y = -5; y < 5; y++) {
        PVector p0 = new PVector(x, y);
        PVector p0t = math_to_screen(tsf_by_mat(p0));
        PVector p1 = new PVector(x+1, y);
        PVector p1t = math_to_screen(tsf_by_mat(p1));
        PVector p2 = new PVector(x, y+1);
        PVector p2t = math_to_screen(tsf_by_mat(p2));
        
        line(p0t.x, p0t.y, p1t.x, p1t.y);
        line(p0t.x, p0t.y, p2t.x, p2t.y);
      }
    }*/
    stroke(255, 50);
  }
  paths.add(new Path(screen_to_math(new PVector(random(-width/2, width*3/2), random(-height/2, height*3/2)))));
  for(int i = paths.size() - 1; i >= 0; i--) {
    for(int j = 0; j < 10; j++) {
      paths.get(i).nextPos();
      paths.get(i).disp();
    }
    if(paths.get(i).iter > 3000) { paths.remove(i); i--; if(i < 0) break;}
    float r = (float)width/zoom;
    if(path_destro && (paths.get(i).pos.x < -r || paths.get(i).pos.x > r || paths.get(i).pos.y < -r || paths.get(i).pos.y > r)) paths.remove(i);
  }
  if(keyPressed) {
    if(key == ' ')
    for(int i = 0; i < 10; i++) {
      paths.add(new Path(screen_to_math(new PVector(random(-width/2, width*3/2), random(-height/2, height*3/2)))));
    }
    if(key == 'c') {
      background(0);
      paths.clear();
    }
  }
  fill(0);
  noStroke();
  rect(0, 0, 150, 50);
  fill(255);
  text(paths.size(), 3, 10);
  float[] gamma = eigenvals(a, b, c, d);
  text(gamma[0] + ", " + gamma[1], 3, 20);
  stroke(255);
  sa.update();
  sb.update();
  sc.update();
  sd.update();
  sa.display();
  sb.display();
  sc.display();
  sd.display();
  a = sa.value;
  b = sb.value;
  c = sc.value;
  d = sd.value;
  PVector v1 = new PVector(-(-a+d+sqrt(a*a+4*b*c-2*a*d+d*d))/(2*c), 1);
  PVector v2 = new PVector(-(-a+d-sqrt(a*a+4*b*c-2*a*d+d*d))/(2*c), 1);
  println(v1.x, v1.y, v2.x, v2.y);
  v1.normalize();
  v1.mult(gamma[0]);
  v2.normalize();
  v2.mult(gamma[1]);
  v1 = math_to_screen(v1);
  v2 = math_to_screen(v2);
  stroke(0, 255, 0);
  line(width/2, height/2, v1.x, v1.y);
  stroke(255, 0, 0);
  line(width/2, height/2, v2.x, v2.y);
  stroke(255, 20);
}

class Path {
  float dt = 0.0025;
  PVector pos;
  int iter;
  public Path(float x0, float y0) {
    this.pos = new PVector(x0, y0);
  }
  public Path(PVector pos) {
    this.pos = pos;
  }
  void nextPos() {
    pos.add(PVector.mult(func(pos), dt));
    iter++;
  }
  void disp() {
    PVector tsfd = math_to_screen(this.pos);
    point(tsfd.x, tsfd.y);
  }
}
