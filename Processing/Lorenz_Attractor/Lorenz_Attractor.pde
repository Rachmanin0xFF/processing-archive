float rho = 85.5;
float sigma = 10.0;
float beta = 8.0/3.0;

PVector r;
PVector pr;
PVector dr;
PVector pdr;

PVector cpv(PVector p) {
  return new PVector(p.x, p.y, p.z);
}

PGraphics pg;

void setup() {
  size(1280, 720, P3D);
  pg = createGraphics(1920*2, 1080*2, P3D);
  pg.noSmooth(); // since when did this break background()???
  r = new PVector(-0.1, 0.2, 0);
  pr = new PVector(0, 0, 0);
  pdr = new PVector(0, 0, 0);
}

float rx = 4.67;
float rz = 5.89;
void mouseDragged() {
  rx = (float)mouseY/100.f;
  rz = (float)mouseX/100.f;
  println(rx, rz);
}
void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  if(e > 0) {
    rho += 0.1;
  } else {
    rho -= 0.1;
  }
}
void keyPressed() {
  pg.save("hiresfart.png");
}
float get_depth(float x, float y, float z) {
  float x2 = x*cos(rz) - y*sin(rz);
  float y2 = x*sin(rz) + y*cos(rz);
  
  float y1 = y2*cos(rx) - z*sin(rx);
  float z1 = y2*sin(rx) + z*cos(rx);
  
  return z1;
}
float dt = 0.0005;
float zoom = 20;
float yoff = -50;
boolean pmousep = false;
int tk = 0;
void draw() {
  pg.beginDraw();
  pg.pushMatrix();
  pg.translate(pg.width/2, pg.height/2);
  pg.rotateX(rx);
  pg.rotateZ(rz);
  if(mousePressed) {
    pg.blendMode(BLEND);
    pg.fill(20, 20, 20);
    pg.background(0);
    pg.stroke(255, 255);
    pg.box(zoom*10);
    pg.noFill();
    pg.box(zoom*100);
    pmousep = true;
    tk = 0;
  } else {
    if(tk < 4) {
      pg.fill(0, 255);
      pg.background(0, 255);
    }
    pmousep = false;
    pg.blendMode(ADD);
    tk++;
  }
  pg.stroke(255, 10);
  float alph = 2.f;
  float dith = 255.f/alph;
  for(int j = 0; j < 10; j++) {
    for(int i = 0; i < 1000; i++) {
      dr = new PVector(sigma*(r.y - r.x),
                               r.x*(rho - r.z) - r.y,
                               r.x*r.y - beta*r.z);
      dr.mult(dt);
      r.add(dr);
      float k = 0.f;
      if(mousePressed) {
        yoff += 0.0001*(-r.z - yoff);
        pg.stroke(255);
      } else {
        float depth = get_depth(r.x*zoom, r.y*zoom, r.z*zoom + yoff*zoom);
        //pg.strokeWeight(rad);
        float v = sqrt(dr.x*dr.x + dr.y*dr.y + dr.z*dr.z)/dt;
        PVector dd = PVector.sub(dr, pdr);
        float a = sqrt(dd.x*dd.x + dd.y*dd.y + dd.z*dd.z)/dt;
        k = abs(depth)/100.f;
        float vd = depth - width/2;
        float br = 1000000/(vd*vd);
        pg.stroke(br*(255 - a*22 + random(-dith, dith)), br*(a*22 + random(-dith, dith)), br*(255 + random(-dith, dith)), 4);
      }
      //pg.line(r.x*zoom + random(-k, k), r.y*zoom + random(-k, k), r.z*zoom + yoff*zoom + random(-k, k), pr.x*zoom + random(-k, k), pr.y*zoom + random(-k, k), pr.z*zoom + yoff*zoom + random(-k, k));
      pg.point(r.x*zoom + random(-k, k), r.y*zoom + random(-k, k), r.z*zoom + yoff*zoom + random(-k, k));
      
      pr = cpv(r);
      pdr = cpv(dr);
    }
  }
  if(mousePressed) {
    pg.stroke(255, 0, 0);
    pg.line(0, 0, 0, 1000, 0, 0);
    pg.stroke(0, 255, 0);
    pg.line(0, 0, 0, 0, 1000, 0);
    pg.stroke(0, 0, 255);
    pg.line(0, 0, 0, 0, 0, 1000);
  }
  pg.popMatrix();
  pg.endDraw();
  
  image(pg, 0, 0, width, height);
  blendMode(BLEND);
  fill(0, 255);
  noStroke();
  rect(0, 0, 100, 50);
  fill(255);
  text(rho, 5, 10);
  text(sigma, 5, 20);
  text(beta, 5, 30);
}
