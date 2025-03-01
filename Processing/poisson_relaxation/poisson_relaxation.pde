// made in october 2022 to numerically convince myself that superposition works in linear PDEs

import peasy.*;
PeasyCam cam;


final int w = 60;

Smooer S1 = new Smooer();
Smooer S2 = new Smooer();
Smooer S_1P2;
Smooer SU = new Smooer();
Smooer FU = new Smooer();

boolean do_red = false;

void setup() {
  size(1280, 720, P3D);
  cam = new PeasyCam(this, 100);
  cam.setMinimumDistance(0.1);
  cam.setMaximumDistance(5000);
  smooth(16);
  
  for(int x = 0; x < w; x++) {
    S1.u[x][w-1] = sin(3*PI*(float)x/(float)w)*20.0;
    
    SU.u[x][w-1] = sin(3*PI*(float)x/(float)w)*20.0;
  }
  S2.push = true;
  SU.push = true;
  //S1.u[0][0] /= 2;
  //S2.u[0][0] /= 2;
  
  FU = floater();
}

void draw() {
  background(0);
  stroke(255);
  noFill();
  //box(w*5);
  stroke(0);
  scale(5);
  strokeWeight(0.2);
  
  translate(-w, 0, 0);
  S1.disp();
  translate(2*w, 0, 0);
  S2.disp();
  translate(-w, 0, 0);
  S_1P2 = add(S1, S2);
  //S_1P2.disp();
  
  do_red = true;
  SU.disp();
  do_red = false;
  
  S1.relax(1);
  S2.relax(1);
  SU.relax(1);
  
  //translate(0, w, 0);
  FU = add(S1, S2);
  FU.disp();
}

class Smooer {
  double[][] u;
  double[][] tu;
  boolean push = false;
  Smooer() {
    u = new double[w][w];
    tu = new double[w][w];
  }
  void relax(int iter) {
    for(int i = 0; i < iter; i++) {
      for(int x = 1; x < w-1; x++) for(int y = 1; y < w-1; y++) {
        tu[x][y] = (u[x+1][y] + u[x-1][y] + u[x][y+1] + u[x][y-1])/4.0;
        if(push) tu[x][y] += sin(2.f*PI*(float)x/(float)w)*0.09;
      }
      for(int x = 1; x < w-1; x++) {
        //u[x][0] = tu[x][1];
        for(int y = 1; y < w-1; y++) {
        u[x][y] = tu[x][y];
        }
      }
    }
  }
  void disp() {
    beginShape(QUADS);
    for(int x = 0; x < w-1; x++) for(int y = 0; y < w-1; y++) {
      fill(getcol(u[x][y]));
      vertex(x-w/2, y-w/2, (float)u[x][y]);
      fill(getcol(u[x+1][y]));
      vertex(x+1-w/2, y-w/2, (float)u[x+1][y]);
      fill(getcol(u[x+1][y+1]));
      vertex(x+1-w/2, y+1-w/2, (float)u[x+1][y+1]);
      fill(getcol(u[x][y+1]));
      vertex(x-w/2, y+1-w/2, (float)u[x][y+1]);
    }
    endShape();
  }
}

Smooer add(Smooer a, Smooer b) {
  Smooer o = new Smooer();
  for(int x = 0; x < w; x++) for(int y = 0; y < w; y++) {
    o.u[x][y] = a.u[x][y] + b.u[x][y];
  }
  return o;
}

// analytic solution, floating like intangible moth
Smooer floater() {
  Smooer o = new Smooer();
  for(int x = 0; x < w; x++) for(int y = 0; y < w; y++) {
    o.u[x][y] = funx((double)x/(double)w, (double)y/(double)w)*w;
  }
  return o;
}

double funx(double x, double y) {
  double sm = 0;
  for(int n = 1; n < 200; n++) {
    sm += (Math.sin(n*Math.PI*(1-y))*sinh(n*Math.PI*(1-x)) + Math.sin(n*Math.PI*x)*sinh(n*Math.PI*y))*2/(n*Math.PI*sinh(n*Math.PI));
  }
  println(sm);
  return sm;
}

double sinh(double t) {
  return (Math.exp(t) - Math.exp(-t))*0.5;
}

color getcol(double f) {
  if(do_red) return color(255, 0, 0);
  return color((float)f*7, 255-abs((float)f*4), 100+abs((float)f*7));
}
