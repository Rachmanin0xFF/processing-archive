import java.util.Collections;

PPF testPPF;

void setup() {
  size(1280, 900, P2D);
  smooth(8);
  background(255);
  testPPF = new PPF();
  testPPF.add_member(new Member(100, 20, "high slope", color(0, 0, 200, 255)));
  testPPF.add_member(new Member(20, 100, "low slope", color(200, 0, 0, 255)));
  testPPF.add_member(new Member(55, 55, "medium slope", color(0, 200, 0, 255)));
  testPPF.add_member(new Member(25, 80, "another", color(200, 200, 0, 255)));
  strokeCap(ROUND);
}
float xoff = 40;
float yoff = 40;
float z = 2f;
float ez = 2f;

float strokeScale = 2.f;

void draw() {
  background(255);
  
  if(keyPressed && key == 'g' && frameCount%5==0) testPPF.add_member(new Member(random(100), random(100), "", color(random(200), random(200), random(200))));
  if(keyPressed && key == 'c') { testPPF.parties.clear(); testPPF.add_member(new Member(random(100), random(100), "", color(random(200), random(200), random(200)))); }
  
  stroke(0);
  testPPF.draw_components();
  testPPF.draw_curve();
  noStroke();
  fill(255, 255);
  rect(0, 0, width, yoff);
  rect(width - xoff, 0, xoff, height);
  rect(0, 0, xoff, height);
  rect(0, height - yoff, width, yoff);
  stroke(0, 255);
  strokeWeight(strokeScale*1);
  line(xoff, height - yoff, width - xoff, height - yoff);
  line(xoff, yoff, xoff, height - yoff);
  strokeWeight(strokeScale*1);
  z += 0.1*(ez-z);
}

class PPF {
  ArrayList<Member> parties = new ArrayList<Member>();
  float targetm = 1.f;
  float psize = 0;
  public PPF() {}
  void add_member(Member m) { parties.add(m); }
  void draw_curve() {
    if(mousePressed && mouseX > xoff && mouseY < height - yoff) {
      targetm = (height - mouseY - yoff)/(mouseX - xoff);
    }
    if(mousePressed)
    if(mouseX < xoff) targetm = 1000000.f; else if(mouseY > height - yoff) targetm = 0.f;
    stroke(0, 100);
    if(targetm < 1)
      dline(0, 0, 2000.f/z, 2000.f*targetm/z);
    else
      dline(0, 0, 2000.f/targetm/z, 2000.f/z);
    
    stroke(0, 255);
    if(parties.size() != psize) Collections.sort(parties);
    psize = parties.size();
    float sumMaxY = 0.f;
    for(Member m : parties)
      sumMaxY += m.b;
    float xs = 0.f;
    float ys = sumMaxY;
    for(Member m : parties) {
      ys -= m.m*m.max_x;
      m.display(xs, ys);
      stroke(0);
      strokeWeight(strokeScale*4);
      dpoint(xs, ys + m.b);
      strokeWeight(strokeScale*1);
      xs += m.max_x;
    }
    
    strokeWeight(2);
    stroke(100, 0, 100);
    for(int i = 0; i < 300; i++) {
      float theta = (((float)i)/300.f*PI);
      float sumx = 0.f;
      float sumy = 0.f;
      for(Member m : parties) {
        float x = m.intersection(tan(theta));
        float y = -m.m*x + m.b;
        sumx += x;
        sumy += y;
      }
      dpoint(sumx, sumy);
    }
    
    noFill();
    stroke(0, 255);
    strokeWeight(strokeScale*1);
    float sumx = 0.f;
    float sumy = 0.f;
    for(Member m : parties) {
      float x = m.intersection(targetm);
      float y = -m.m*x + m.b;
      dellipse(x, -m.m*x + m.b, 5);
      sumx += x;
      sumy += y;
    }
    dellipse(sumx, sumy, 5);
  }
  void draw_components() {
    for(Member m : parties)
      m.display(0.f, 0.f);
  }
}

class Member implements Comparable<Member> {
  float max_x;
  float max_y;
  float m;
  float b;
  String name;
  color col = color(0, 0, 0, 255);
  Member(float my, float mx, String name) {
    max_x = mx;
    max_y = my;
    m = my/mx;
    b = my;
    this.name = name;
  }
  Member(float my, float mx, String name, color col) {
    max_x = mx;
    max_y = my;
    m = my/mx;
    b = my;
    this.name = name;
    this.col = col;
  }
  float intersection(float slope) {
    return b/(slope+m);
  }
  //PVector intersects(float xff, float yff) {
    // TODO
  //}
  void display(float xff, float yff) {
    stroke(col);
    dline(xff, max_y + yff, max_x + xff, yff);
  }
  public boolean equals(Object x) {
    if(!(x instanceof Member))
      return false;
    return ((Member)x).m == m;
  }
  public int compareTo(Member x) {
    if(!(x instanceof Member))
      return 0;
    return Float.compare(this.m, x.m);
  }
  public int hashCode(){
    return ((Float)m).hashCode();
  }
}

void dpoint(float x, float y) {
  point(x*z + xoff, height - y*z - yoff);
}

void dellipse(float x, float y, float r) {
  ellipse(x*z + xoff, height - y*z - yoff, r*2.f, r*2.f);
}

void dline(float x, float y, float x1, float y1) {
  line(x*z + xoff, height - y*z - yoff, x1*z + xoff, height - y1*z - yoff);
}

void mouseWheel(MouseEvent me) {
  if(me.getCount() < 0)
    ez *= 1.09;
  else
    ez /= 1.09;
}