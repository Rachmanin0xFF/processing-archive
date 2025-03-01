
import java.util.Set;
import java.util.HashSet;

PVector cpv(PVector p) {
  return new PVector(p.x, p.y, p.z);
}
PVector cpvxy(PVector p) {
  return new PVector(p.x, p.y);
}

float r = 100;
PVector[] pts;
PVector[] vels = new PVector[]{};

void setup() {
  size(800, 800, P2D);
  background(0);
  surface.setTitle("Hello World!");
  surface.setResizable(true);
  surface.setLocation(100, 100);
  stroke(0, 10);
  noSmooth();
  strokeCap(SQUARE);
  
  pts = new PVector[]{};
}

PVector[] appendArr(PVector[] p, PVector q) {
  PVector[] pp = new PVector[p.length+1];
  PVector[] vv = new PVector[vels.length+1];
  for(int i = 0; i < p.length; i++) {
    pp[i] = p[i];
    vv[i] = vels[i];
  }
  pp[pp.length-1] = q;
  vv[vv.length-1] = new PVector(0, q.z > 0.0 ? 1.0 : -1.0);
  vels = vv;
  return pp;
}

int sgn(float f) {
  if(f > 0.0) return 1;
  if(f < 0.0) return -1;
  return 0;
}

void mousePressed() {
  //background(0);
  if(mouseButton == LEFT)
    pts = appendArr(pts, new PVector(mouseX, mouseY, 1.0));
  else if(mouseButton == RIGHT)
    pts = appendArr(pts, new PVector(mouseX, mouseY, -1.0));
}

void mouseDragged() {
  if(pts.length > 0) {
  //background(0);
  pts[pts.length-1].x = mouseX;
  pts[pts.length-1].y = mouseY;
  vels[pts.length-1].x = 0;
  vels[pts.length-1].y = 0;
  }
}
boolean siml = false;
void keyPressed() {
  if(key == 's') {
    siml = !siml;
  } else {
    pts = new PVector[]{};
    vels = new PVector[]{};
  }
}

int lines_per_source = 0;
int tan_per_source = 10;

void trace_line(PVector efl, float kq, boolean tang, int lnt, float stepsize) {
  PVector eflp = new PVector();
  for(int j = 0; j < lnt; j++) {
    PVector sum = new PVector();
    float cvor = 0;
    for(int i = 0; i < pts.length; i++) {
      float r = sqrt((efl.x - pts[i].x)*(efl.x - pts[i].x) + (efl.y - pts[i].y)*(efl.y - pts[i].y));
      if(r < 3 && kq == -(int)pts[i].z) j = lnt + 1;
      PVector dir = new PVector((efl.x - pts[i].x)/r, (efl.y - pts[i].y)/r);
      sum.add(dir.mult(kq*pts[i].z/(r*r)));
    }
    float mag = sqrt(sum.x*sum.x + sum.y*sum.y);
    sum.normalize();
    eflp = cpv(efl);
    cvor = atan2(sum.y*kq, sum.x*kq);
    colorMode(HSB);
    int lph = 255;
    sum.mult(stepsize);
    if(tang) {
      float tt = sum.x;
      sum.x = -sum.y;
      sum.y = tt;
      lph = 50;
    }
    stroke((cvor + PI)/TWO_PI*255, 1500000*mag + 50, 255, lph);
    efl.add(sum);
    line(efl.x, efl.y, eflp.x, eflp.y);
  }
}

void draw() {
  background(0);
  for(int i = 0; i < pts.length; i++) {
    for(int k = 0; k < lines_per_source; k++) {
      float theta = ((float)k/((float)lines_per_source))*TWO_PI;// + random(TWO_PI);
      PVector srt = new PVector(pts[i].x + cos(theta), pts[i].y + sin(theta));
      trace_line(srt, pts[i].z, false, 150, 8.f);
    }
    
    for(int k = 0; k < tan_per_source; k++) {
      trace_line(new PVector(pts[i].x + k*50 + 5, pts[i].y), 1, true, 100*k, 2.f);
      trace_line(new PVector(pts[i].x + k*50 + 5, pts[i].y), -1, true, 100*k, 2.f);
    }
  }
  colorMode(RGB);
  noStroke();
  rectMode(CENTER);
  for(int i = 0; i < pts.length; i++) {
    if(pts[i].z > 0) fill(255, 50, 50);
    else fill(50, 100, 255);
    ellipse(pts[i].x, pts[i].y, 30, 30);
    fill(255);
    if(pts[i].z > 0) {
      rect(pts[i].x, pts[i].y, 3, 15, 1);
      rect(pts[i].x, pts[i].y, 15, 3, 1);
    } else {
      rect(pts[i].x, pts[i].y, 15, 3, 1);
    }
  }
  
  
  if(siml) {
    for(int i = 0; i < pts.length; i++) {
      PVector sum = new PVector(0, 0);
      for(int j = 0; j < pts.length; j++) {
        if(i != j) {// && !(i%2==0 && j==i+1) && !(j%2==0 && i==j+1)) {
          PVector r = PVector.sub(pts[i], pts[j]);
          float mag2 = r.x*r.x + r.y*r.y;
          r.normalize();
          r.mult(pts[i].z*pts[j].z*1000.f/(mag2));
          sum.add(r);
        }
      }
      vels[i].add(sum);
    }
    
    for(int i = 0; i < pts.length; i++) {
      pts[i].x += vels[i].x; pts[i].y += vels[i].y;
    }
    
    Set<Integer> toRM = new HashSet<Integer>();
    for(int i = 0; i < pts.length; i++) {
      for(int j = 0; j < i; j++) {
        if((pts[i].x-pts[j].x)*(pts[i].x-pts[j].x) + (pts[i].y-pts[j].y)*(pts[i].y-pts[j].y) < 15*15 && pts[i].z == -pts[j].z) {
          toRM.add(i);
          toRM.add(j);
        }
      }
      if(PVector.sub(pts[i], new PVector(width/2, height/2)).mag() > width) toRM.add(i);
    }
    
    ArrayList<PVector> newPts = new ArrayList<PVector>();
    ArrayList<PVector> newVels = new ArrayList<PVector>();
    for(int i = 0; i < pts.length; i++) {
      if(!toRM.contains(i)) newPts.add(pts[i]);
      if(!toRM.contains(i)) newVels.add(vels[i]);
    }
    
    PVector[] pts2 = new PVector[newPts.size()];
    PVector[] vels2 = new PVector[newVels.size()];
    for(int i = 0; i < pts2.length; i++) {
      pts2[i] = newPts.get(i);
      vels2[i] = newVels.get(i);
    }
    
    pts = pts2;
    vels = vels2;
    
    
    
    /*
    for(int i = 1; i < pts.length; i += 2) {
      PVector cen = cpvxy(PVector.add(pts[i], pts[i-1]));
      cen.mult(0.5);
      PVector r1 = cpv(PVector.sub(cpvxy(pts[i-1]), cen)); r1.normalize();
      PVector r2 = cpv(PVector.sub(cpvxy(pts[i]), cen)); r2.normalize();
      r1.mult(100);
      r2.mult(100);
      pts[i-1].x = PVector.add(cen, r1).x;
      pts[i-1].y = PVector.add(cen, r1).y;
      pts[i].x = PVector.add(cen, r2).x;
      pts[i].y = PVector.add(cen, r2).y;
    }
    */
  }
}
