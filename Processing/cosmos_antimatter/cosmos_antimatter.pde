
float forceOfGravity = 20.2f;
float explosionForce = 0.0003f;

ArrayList<Bal> bals = new ArrayList<Bal>();
int passedF = 0;
int dnSize = 140;
float[][] display;
boolean fanCBals = false;
boolean addMasses = true;

void setup() {
  size(1000, 1000, P2D);
  //smooth(8);
  strokeWeight(3f);
  addSphr(width/2, 400, 200, 500);                                             
  addAntiSphr(width/2, 600, 200, 500);
  //bals.add(new Bal(300, height/2, true, 12000.f));
  //bals.add(new Bal(width-300, height/2, true, 1000.f));
  colorMode(RGB);
  display = new float[width][height];
  clearHDR();
  frameRate(100000);

  blendMode(ADD);
  hint(DISABLE_DEPTH_TEST);
  background(0);
}
void mousePressed() {
 addSphr(mouseX, mouseY, 100, 100);
 }
void addSphr(float x, float y, float rad, int count) {
  for (float i = 0; i < count; i++) {
    float theta = random(TWO_PI);
    float r = sqrt(random(1))*rad;
    float x2 = cos(theta)*r;
    float y2 = sin(theta)*r;
    bals.add(new Bal(x + x2, y + y2, true));
  }
}
void addAntiSphr(float x, float y, float rad, int count) {
  for (float i = 0; i < count; i++) {
    float theta = random(TWO_PI);
    float r = sqrt(random(1))*rad;
    float x2 = cos(theta)*r;
    float y2 = sin(theta)*r;
    bals.add(new Bal(x + x2, y + y2, false));
  }
}
void addMixSphr(float x, float y, float rad, int count) {
  for (float i = 0; i < count; i++) {
    float theta = random(TWO_PI);
    float r = sqrt(random(1))*rad;
    float x2 = cos(theta)*r;
    float y2 = sin(theta)*r;
    boolean isMatter = random(10)>5;
    bals.add(new Bal(x + x2, y + y2, isMatter));
  }
}
void draw() {
  minCol = 100000.f;
  maxCol = -100000.f;
  fill(0, 0, 0, 20);
  blendMode(BLEND);
  rect(0, 0, width, height);
  blendMode(ADD);
  background(0);
  stroke(255, 0, 0, 40);
  for(int i = bals.size()-1; i >= 0; i--) {
    if(!bals.get(i).active)
      bals.remove(i);
  }

  for (int k = 0; k < bals.size (); k++)
    for (int i = 0; i < bals.size (); i++)
      bals.get(i).attract(bals.get(k).p, bals.get(k).mass);

  for (int k = 0; k < bals.size (); k++)
    if (bals.get(k).active)
      for (int i = 0; i < k; i++) {
        if (bals.get(i).mass > 0 && bals.get(k).mass > 0 && dist(bals.get(i).p.x, bals.get(i).p.y, bals.get(k).p.x, bals.get(k).p.y) < (bals.get(i).radius + bals.get(k).radius)/2.f && bals.get(i).active) {
          if (bals.get(i).isMatter ^ bals.get(k).isMatter) {
            float minW = min(bals.get(i).mass, bals.get(k).mass);
            float wi = bals.get(i).mass - bals.get(k).mass;
            float wk = bals.get(k).mass - bals.get(i).mass;
            println(wi + " " + wk);
            bals.get(i).mass = max(0.f, wi);
            bals.get(k).mass = max(0.f, wk);
            if(wi == 0.f) wi = 0.0000001f;
            for (int j = 0; j < bals.size(); j++)
              bals.get(j).attract(PVector.mult(PVector.add(bals.get(i).p, bals.get(k).p), 0.5f), -105.f*abs(minW)/abs(wi)*explosionForce);
          } else if(addMasses) {
            bals.get(k).active = false;
            if (bals.get(k).mass > bals.get(i).mass) bals.get(i).p = bals.get(k).p;
            float w = bals.get(k).mass;
            bals.get(i).v = PVector.mult(PVector.add(PVector.mult(bals.get(i).v, bals.get(i).mass), PVector.mult(bals.get(k).v, bals.get(k).mass)), 1.f/bals.get(i).mass);
            bals.get(i).p = PVector.mult(PVector.add(PVector.mult(bals.get(i).p, bals.get(i).mass), PVector.mult(bals.get(k).p, bals.get(k).mass)), 1.f/(bals.get(i).mass + bals.get(k).mass));
            bals.get(i).mass += w;
            bals.get(i).v.mult(1.f/bals.get(i).mass);
            bals.get(k).mass = 0.f;
          }
        }
      }
  for (Bal b : bals) b.updateP();
  
  for (Bal b : bals) {
    //b.drawBalThicker();
  }
  //blur(3);
  //filter(BLUR, 1);
  //blur(1);
  //filter(BLUR, 1);
  //drawDNS();
  //glow(5, 4);
  //glow(2, 2);
  for (Bal b : bals) {
    b.drawBal();
  }
  //saveFrame("frame" + passedF + ".jpg");
  passedF++;
  println(passedF);
  if (mousePressed)
    displayHDR();
}
PVector mix(PVector x, PVector y, float a) {
  return new PVector(x.x*(1.f - a) + y.x*a, x.y*(1.f - a) + y.y*a);
}
void clearHDR() {
  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      display[x][y] = 0.f;
    }
  }
}
void displayHDR() {
  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      color c = color(min(255, display[x][y]), 255);
      set(x, y, c);
    }
  }
}
float minCol = 100000.f;
float maxCol = -100000.f;
class Bal {
  PVector p;
  PVector np;
  PVector v;
  PVector a;
  color c;
  float mass = 0.f;
  boolean isMatter;
  boolean active = true;
  float radius = 0.f;
  public Bal(float x, float y, boolean b) {
    np = new PVector(0, 0);
    p = new PVector(x, y);
    float theta = random(100);
    float radi = random(0.000);
    v = new PVector(radi*sin(theta), radi*cos(theta));
    a = new PVector(0, 0);
    float rgbx = (x/(float)width);
    float rgby = (y/(float)height/2);
    color ul = color(255);
    color ur = color(255, 0, 0);
    color ll = color(150, 100, 255);
    color lr = color(255, 100, 0);
    c = mix(mix(ul, ur, rgbx), mix(ll, lr, rgbx), rgby);
    isMatter = b;
    mass = random(1.f, 3.f);
    if (random(100)>99)
      mass = 100.f;
    mass = 2.f + random(0.001f);
    radius = sqrt(mass);
  }
  public Bal(float x, float y, boolean b, float w) {
    np = new PVector(0, 0);
    p = new PVector(x, y);
    float theta = random(100);
    float radi = random(0.000);
    v = new PVector(radi*sin(theta), radi*cos(theta));
    a = new PVector(0, 0);
    float rgbx = (x/(float)width);
    float rgby = (y/(float)height/2);
    color ul = color(255);
    color ur = color(255, 0, 0);
    color ll = color(150, 100, 255);
    color lr = color(255, 100, 0);
    c = mix(mix(ul, ur, rgbx), mix(ll, lr, rgbx), rgby);
    isMatter = b;
    mass = w;
    radius = sqrt(mass);
  }
  public void attract(PVector posit) {
    if (mass <= 0.f) active = false;
    if (active) {
      float d = max(dist(p.x, p.y, posit.x, posit.y), 0.0)+5;
      a.x = posit.x-p.x;
      a.y = posit.y-p.y;
      a.normalize();
      a.x = (a.x/(d*d/140))/2667000f*forceOfGravity;
      a.y = (a.y/(d*d/140))/2667000f*forceOfGravity;
      v.add(a);
      np.add(v);
      if (v.mag() < minCol) minCol = v.mag();
      if (v.mag() > maxCol) maxCol = v.mag();
    }
  }
  public void attract(PVector posit, float force) {
    radius = sqrt(mass);
    if (mass <= 0.f) active = false;
    if (active) {
      float d = max(dist(p.x, p.y, posit.x, posit.y), 0.0)+5;
      a.x = posit.x-p.x;
      a.y = posit.y-p.y;
      a.normalize();
      a.x = (a.x/(d*d/140))/2667000f*forceOfGravity*force;
      a.y = (a.y/(d*d/140))/2667000f*forceOfGravity*force;
      v.add(a);
      np.add(v);
      if (v.mag() < minCol) minCol = v.mag();
      if (v.mag() > maxCol) maxCol = v.mag();
    }
  }
  public void attractCubic(PVector posit, float force) {
    radius = sqrt(mass);
    if (mass <= 0.f) active = false;
    if (active) {
      float d = max(dist(p.x, p.y, posit.x, posit.y), 0.0)+5;
      a.x = posit.x-p.x;
      a.y = posit.y-p.y;
      a.normalize();
      a.x = (a.x/(d*d*d/140))/2667000f*forceOfGravity*force;
      a.y = (a.y/(d*d*d/140))/2667000f*forceOfGravity*force;
      v.add(a);
      np.add(v);
      if (v.mag() < minCol) minCol = v.mag();
      if (v.mag() > maxCol) maxCol = v.mag();
    }
  }
  public void updateP() {
    if (mass <= 0.f) active = false;
    p.add(np);
    np = new PVector(0, 0);
  }
  public void drawBal() {
    if (mass <= 0.f) active = false;
    if (active) {
      //stroke(map(v.mag(), minCol, maxCol, 0, 255), 255, 255);
      //if (isMatter) stroke(0, 255, 255, 255); 
      //else stroke(100, 255, 255, 255);
      stroke(0, 0, 0, 0);
      if(fanCBals) {
        if(isMatter) stroke(100, 100, 255, 255); else stroke(200, 50, 30, 255);
        strokeWeight(radius);
        point(p.x, p.y);
        if(isMatter) stroke(100, 100, 255, 200); else stroke(200, 50, 30, 200);
        strokeWeight(max(1.f, radius/2.f));
        point(p.x, p.y);
      } else {
        if(isMatter) stroke(100, 100, 255, 255); else stroke(200, 50, 30, 255);
        strokeWeight(radius);
        point(p.x, p.y);
      }
      if ((int)p.x >= 0 && (int)p.x < width && (int)p.y >= 0 && (int)p.y < height)
        display[(int)p.x][(int)p.y]+=10;
    }
  }
  public void drawBalThicker() {
    if (mass <= 0.f) active = false;
    if (active) {
      //stroke(map(v.mag(), minCol, maxCol, 0, 255), 255, 255);
      //if (isMatter) stroke(0, 255, 255, 255); 
      //else stroke(100, 255, 255, 255);
      stroke(0, 0, 0, 0);
      if(fanCBals) {
        if(isMatter) stroke(100, 100, 255, 255); else stroke(200, 50, 30, 255);
        strokeWeight(radius*2.f);
        point(p.x, p.y);
        if(isMatter) stroke(100, 100, 255, 200); else stroke(200, 50, 30, 200);
        strokeWeight(max(1.f, radius));
        point(p.x, p.y);
      } else {
        if(isMatter) stroke(100, 100, 255, 255); else stroke(200, 50, 30, 255);
        strokeWeight(radius*2.f);
        point(p.x, p.y);
      }
      if ((int)p.x >= 0 && (int)p.x < width && (int)p.y >= 0 && (int)p.y < height)
        display[(int)p.x][(int)p.y]+=10;
    }
  }
}

void keyPressed() {
  if (key == 'r') {
    background(0);
    clearHDR();
  }
}

color mix(color a, color b, float x) {
  return color(r(a)*x+r(b)*(1.0-x), g(a)*x+g(b)*(1.0-x), b(a)*x+b(b)*(1.0-x));
}

// GLOWING
 
// Martin Schneider
// October 14th, 2009
// k2g2.org
 
 
// use the glow function to add radiosity to your animation :)
 
// r (blur radius) : 1 (1px)  2 (3px) 3 (7px) 4 (15px) ... 8  (255px)
// b (blur amount) : 1 (100%) 2 (75%) 3 (62.5%)        ... 8  (50%)
   
void glow(int r, int b) {
  loadPixels();
  blur(1); // just adding a little smoothness ...
  int[] px = new int[pixels.length];
  arrayCopy(pixels, px);
  blur(r);
  mix(px, b);
  updatePixels();
}
 
void blur(int dd) {
   int[] px = new int[pixels.length];
   for(int d=1<<--dd; d>0; d>>=1) { 
      for(int x=0;x<width;x++) for(int y=0;y<height;y++) {
        int p = y*width + x;
        int e = x >= width-d ? 0 : d;
        int w = x >= d ? -d : 0;
        int n = y >= d ? -width*d : 0;
        int s = y >= (height-d) ? 0 : width*d;
        int r = ( r(pixels[p+w]) + r(pixels[p+e]) + r(pixels[p+n]) + r(pixels[p+s]) ) >> 2;
        int g = ( g(pixels[p+w]) + g(pixels[p+e]) + g(pixels[p+n]) + g(pixels[p+s]) ) >> 2;
        int b = ( b(pixels[p+w]) + b(pixels[p+e]) + b(pixels[p+n]) + b(pixels[p+s]) ) >> 2;
        px[p] = 0xff000000 + (r<<16) | (g<<8) | b;
      }
      arrayCopy(px,pixels);
   }
}
 
void mix(int[] px, int n) {
  for(int i=0; i< pixels.length; i++) {
    int r = (r(pixels[i]) >> 1)  + (r(px[i]) >> 1) + (r(pixels[i]) >> n)  - (r(px[i]) >> n) ;
    int g = (g(pixels[i]) >> 1)  + (g(px[i]) >> 1) + (g(pixels[i]) >> n)  - (g(px[i]) >> n) ;
    int b = (b(pixels[i]) >> 1)  + (b(px[i]) >> 1) + (b(pixels[i]) >> n)  - (b(px[i]) >> n) ;
    pixels[i] =  0xff000000 | (r<<16) | (g<<8) | b;
  }
}
 
int r(color c) {return (c >> 16) & 255; }
int g(color c) {return (c >> 8) & 255;}
int b(color c) {return c & 255; }
