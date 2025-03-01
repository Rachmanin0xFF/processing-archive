
int DPTH = 4;
Geometry curve;

PGraphics pg;
int disp_wid = 200;

void setup() {
  size(1800, 900, P2D);
  curve = new Geometry(makeLSystem(DPTH), 1.f/pow(2, DPTH));
  background(0);
}

void draw() {
  fill(0);
  noStroke();
  rect(0, 0, 900, 900);
  stroke(255);
  curve.display();
  PVector mapped = curve.screen_to_coords(mouseX, mouseY);
  stroke(0, 255, 0);
  float q = curve.get_gauss(mapped.x, mapped.y, 0.1, 10)/pow(2, DPTH);
  strokeWeight(1);
  noFill();
  ellipse(mouseX, mouseY, q, q);
  strokeWeight(3);
  strokeCap(SQUARE);
  for(int i = 0; i < 1000; i++) {
    float x = random(0, 900);
    float y = random(0, 900);
    mapped = curve.screen_to_coords(x, y);
    q = curve.get_gauss(mapped.x, mapped.y, 0.1, 10)/pow(2, DPTH);
    stroke(q, q*2, q*0.5, 255);
    point(x + 900, y);
  }
  stroke(255);
  strokeWeight(1);
}

class Geometry {
  PVector[][] segments;
  float xmin = 100000; float xmax = -100000;
  float ymin = 100000; float ymax = -100000;
  int vx = 10;
  int vy = 10;
  int vw = 900-20;
  int vh = 900-20;
  Geometry(PVector[][] s, float xmn, float xmx, float ymn, float ymx) {
    segments = s;
    xmin = xmn;
    xmax = xmx;
    ymin = ymn;
    ymax = ymx;
  }
  Geometry(String Lsys, float scl) {
    segments = LtoSegments(Lsys, scl);
    getBB();
  }
  float get_gauss(float x, float y, float sigma, int samples) {
    return sumSegmentsGauss(segments, x, y, sigma, samples);
  }
  PVector screen_to_coords(float x, float y) {
    return new PVector(map(x, vx, vx+vw, xmin, xmax), map(y, vy, vy + vh, ymin, ymax));
  }
  PVector coords_to_screen(float x, float y) {
    return new PVector(map(x, xmin, xmax, vx, vx+vw), map(y, ymin, ymax, vy, vy + vh));
  }
  void getBB() {
    for(int i = 0; i < segments.length; i++) {
      if(segments[i][0].x > xmax) xmax = segments[i][0].x;
      if(segments[i][0].x < xmin) xmin = segments[i][0].x;
      if(segments[i][0].y > ymax) ymax = segments[i][0].y;
      if(segments[i][0].y < ymin) ymin = segments[i][0].y;
      if(segments[i][1].x > xmax) xmax = segments[i][1].x;
      if(segments[i][1].x < xmin) xmin = segments[i][1].x;
      if(segments[i][1].y > ymax) ymax = segments[i][1].y;
      if(segments[i][1].y < ymin) ymin = segments[i][1].y;
    }
  }
  void display() {
    for(int i = 0; i < segments.length; i++) {
      line(map(segments[i][0].x, xmin, xmax, vx, vx+vw),
           map(segments[i][0].y, ymin, ymax, vy, vy+vh),
           map(segments[i][1].x, xmin, xmax, vx, vx+vw),
           map(segments[i][1].y, ymin, ymax, vy, vy+vh));
    }
  }
  
  float sumSegmentsGauss(PVector[][] e, float xm, float ym, float sigma, int samples) {
  float sum = 0;
  for(int i = 0; i < e.length; i++) {
    float len = dist(e[i][0].x, e[i][0].y, e[i][1].x, e[i][1].y)/samples;
    for(int j = 0; j < samples; j++) {
      float lrpval = (float)j/(samples-1);
      float lerpx = lerp(e[i][0].x, e[i][1].x, lrpval);
      float lerpy = lerp(e[i][0].y, e[i][1].y, lrpval);
      //              1/sqrt(2pi)
      float gaussVal = 0.39894228*exp(-0.5*((lerpx-xm)*(lerpx-xm)+(lerpy-ym)*(lerpy-ym))/(sigma*sigma));
      if(gaussVal*10 > 0.2) {
        PVector p = coords_to_screen(lerpx, lerpy);
      }
      sum += gaussVal/len;
    }
  }
  return sum;
}
}

PVector[][] LtoSegments(String s, float scale) {
  int xmin = 100000; int xmax = -100000;
  int ymin = 100000; int ymax = -100000;
  int x = 0; int y = 0;
  int px = 0; int py = 0;
  int dir = 0;
  ArrayList<PVector> pts = new ArrayList<PVector>();
  pts.add(new PVector(x, y));
  for(int i = 0; i < s.length(); i++) {
    switch(s.charAt(i)) {
        case '+':
          dir = (dir+1)%4;
          break;
        case '-':
          dir = (dir+3)%4;
          break;
        case 'F':
          if(dir%2 == 0) x -= dir-1;
          else y += dir-2;
          break;
    }
    if(px != x || py != y) {
      if(x > xmax) xmax = x; if(x < xmin) xmin = x;
      if(y > ymax) ymax = y; if(y < ymin) ymin = y;
      pts.add(new PVector(x*scale, y*scale));
    }
    px = x;
    py = y;
  }
  
  PVector[][] segments = new PVector[pts.size()-1][2];
  for(int i = 0; i < pts.size()-1; i++) {
    segments[i][0] = pts.get(i).copy();
    segments[i][1] = pts.get(i+1).copy();
  }
  return segments;
}

String makeLSystem(int depth) {
  String s = "A";
  for(int i = 0; i < depth; i++) {
    String cat = "";
    for(int j = 0; j < s.length(); j++) {
      switch(s.charAt(j)) {
        case 'A':
          cat += "+BF-AFFA-FB+";
          break;
        case 'B':
          cat += "-AF+BFFB+FA-";
          break;
        default:
          cat += s.charAt(j);
          break;
      }
    }
    s = cat;
  }
  return s;
}
