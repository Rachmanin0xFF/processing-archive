Vertex[] verts = new Vertex[4];

boolean sprig = true;
PVector center = new PVector();

float lowThig = 100000.0f;
int pf = 0;

void setup() {
  size(1280, 720, P2D);
  background(0);
  smooth();
  stroke(255, 255, 255, 50);
  PFont font = loadFont("DilleniaUPCBold-48.vlw");
  textFont(font);
  for(int i = 0; i < verts.length; i++)
    verts[i] = new Vertex(random(width), random(height), verts.length, i);
}

void draw() {
  background(0);
  float spoog = getAvg();
  String s = spoog + "";
  if(spoog < lowThig && pf > 10)
    lowThig = spoog;
  String s2 = lowThig + "";
  if(s.length() > 5)
    s = s.substring(0, 5);
  if(s2.length() > 5)
    s2 = s2.substring(0, 5);
  fill(255);
  text("Variance: " + s, 10, 30);
  text("Best: " + s2, 10, 70);
  fill(0);
  center = getCenter();
  translate(-center.x + width/2.0f, -center.y + height/2.0f);
  for(Vertex v : verts)
    v.update();
  for(Vertex v : verts)
    v.display();
  pf++;
}

class Vertex {
  PVector pos;
  PVector vel = new PVector();
  int id;
  float[] nb;
  float totalDiff;
  public Vertex(float x, float y, int nbrs, int id) {
    nb = new float[nbrs];
    for(int i = id + 1; i < nb.length; i++)
      nb[i] = 400;
    pos = new PVector(x, y);
    this.id = id;
  }
  public void display() {
    totalDiff = 0.0f;
    for(int i = id; i < verts.length; i++) {
      float diffDist = dist(pos.x, pos.y, verts[i].pos.x, verts[i].pos.y) - nb[i];
      totalDiff += abs(diffDist);
      if(diffDist < 0.0) {
        stroke(-diffDist/3.0f, 0, 0);
        strokeWeight(-diffDist/20.0f);
      } else {
        stroke(0, 0, diffDist/3.0f);
        //strokeWeight(diffDist/20.0f);
      }
      line(pos.x, pos.y, verts[i].pos.x, verts[i].pos.y);
      strokeWeight(1);
    }
    stroke(0);
    fill(0);
    blendMode(BLEND);
    ellipse(pos.x, pos.y, 10, 10);
    blendMode(ADD);
    fill(255, 255, 255, 80);
    ellipse(pos.x, pos.y, 10, 10);
  }
  public void update() {
    float deltaX = 0.0f;
    float deltaY = 0.0f;
    for(int i = id + 1; i < verts.length; i++) {
      PVector dir = new PVector(pos.x, pos.y);
      dir.sub(verts[i].pos);
      dir.normalize();
      float distTo = dist(pos.x, pos.y, verts[i].pos.x, verts[i].pos.y);
      float force = (nb[i] - distTo) * 0.01f;
      deltaX += dir.x * force;
      deltaY += dir.y * force;
    }
    if(mousePressed) {
      float q = verts.length;
      deltaX += random(-q, q);
      deltaY += random(-q, q);
    }
    if(sprig) {
      float damp = 30.0f;
      vel.add(new PVector(deltaX/damp, deltaY/damp));
      vel.div(1.02f);
      pos.add(vel);
    } else {
      pos.add(new PVector(deltaX, deltaY));
    }
  }
}

float getAvg() {
  float sum = 0.0f;
  for(int i = 0; i < verts.length; i++) {
    sum += verts[i].totalDiff;
  }
  return sum / (verts.length*(verts.length-1)/2);
}

PVector getCenter() {
  float sumx = 0.0f;
  float sumy = 0.0f;
  for(int i = 0; i < verts.length; i++) {
    sumx += verts[i].pos.x;
    sumy += verts[i].pos.y;
  }
  sumx /= verts.length;
  sumy /= verts.length;
  return new PVector(sumx, sumy);
}