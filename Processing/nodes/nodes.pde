//OpenGL can be used as a renderer. (Though it doesn't do much)
import processing.opengl.*;

//--System Variables--//
ArrayList<Node> nodes = new ArrayList<Node>();
ArrayList<Quanta> quantas = new ArrayList<Quanta>();
int globalTick = 0;
int passedFrames = 0;
int passedCalcs = 0;
float camAng = 0.0f;
float zoomie = 0.20f;

//--Input variables--//
int bucketSize = -1; //This is the Bucket size, or the minimum number of particles inside a group. Not good to change.
int maxIterations = 90*3; //This is the maximum number of iterations. Also probably do not change.
boolean showTree = false; //Don't change.
boolean showCenter = false; //Don't change this either.
boolean showAttraction = false; //This is for debugging, probably not change.
boolean calc = false; //You should not change this.
boolean buildTreeEtc = false;
int frameDivideStepNumber = 0;

boolean noiseDisplace = true; //Okay, you can change this. If true, it displaces all the particles with perlin noise at the simulation's beginning. Looks nicer that way.
boolean savePics = false; //Set true to save pictures into the sketch folder.
boolean camRoll = true; //Set true to have an automated camera when rendering.
boolean drawLines = false;
boolean renderTree = false;
boolean colorVelocity = false;
boolean dispRandom = false; //IF THIS IS SET TO TRUE THE SYSTEM WILL ONLY DISPLAY ALL THE PARTICLES WHEN IT NEEDS TO TAKE A PICTURE
float velocityColorMultiplier = 400f;
float treeOpacity = 6f;
float lineLength = 5f;
float particleAlpha = 40f;
float pointScale = 1f; //This is the size multiplier for initial point distribution. Smaller = closer together, bigger = farther apart.

float accuratenessConstant = 0.001f; //Accurateness constant one. This basically dictates the detail of the groups a particle is attracted to. Smaller = more detailed, bigger = less detailed.
float eventHorizon = 60f; //Accurateness constant two. This is the "event horizon" of accurateness. If the distance between two particles is less than this number, those two particles will be normally attracted to one another.
float gravityConstant = 12800f; //This is the gravity constant. Smaller = less gravity, bigger = more gravity.
int particleListSize = 100000; //This is the number of particles in the simulation.
int frameDivide = 10; //THIS IS THE NUMBER OF SUB-FRAMES EVERYTHING IS SPLIT INTO.

//--Controls--//
//'i' - Begin simulating
//'o' - End simulating (hold down)
//'b' - Show K-D Tree (hold down)
//'p' - Show system center and midpoints. (hold down) (Mostly for debugging)
//Mouse - Camera Control

//NOTE THAT VISUALS MAY NOT BE QUITE AS IMPRESSIVE AT FIRST DUE TO THE FACT THAT 3D SPACE IS MORE COMPLEX AND REQUIRES MORE PARTICLES IN ORDER TO MAKE A STABLE SYSTEM//

void setup() {
  size(1024, 1024, P3D);
  stroke(255, 255, 255, 130);
  eventHorizon = eventHorizon*eventHorizon;
  createQuantainer();
  frameRate(100000);
}
void draw() {
  randomSeed(millis());
  float scale = min(standardDevX(quantas), min(standardDevY(quantas), standardDevZ(quantas)));
  PVector focusPoint = avgPos(quantas);
  focusPoint.mult(0.25f);
  scale = min(0.25f, 120f/scale);
  //////////////////////////////
  translate(width/2, height/2, width/2);
  if(camRoll&&calc) {
    rotateY(camAng);
    rotateX(-10);
  } else {  
    rotateY(float(mouseX)/200f);
    rotateX(float(mouseY)/200f);
  }
  //translate(-focusPoint.x, -focusPoint.y, -focusPoint.z);
  scale(scale);
  println(frameRate);
  if(keyPressed&&key=='b') showTree = true; else showTree = renderTree&&calc;
  if(keyPressed&&key=='p')
    showCenter = true;
  else
    showCenter = false;
  if(buildTreeEtc) {
    nodes = new ArrayList<Node>();
    globalTick = 0;
    nodes.add(new Node());
  }
  background(0);
  println("\n\n\n\n");
  passedFrames++;
  strokeWeight(1);
  stroke(255, 255, 255, 60);
  noFill();
  box(width, width, width);
  //////////////////////////////
  blendMode(ADD);
  hint(DISABLE_DEPTH_TEST);
  stroke(200, 200, 255, treeOpacity);
  int sssc = 1;
  if(buildTreeEtc) {
    treeSplitRecurX(quantas, 0, 0, 0, 0, 0, 0, 0, 0, (float)width);
    for(Node n : nodes) { if(n.regionWidth==0) n.regionWidth = 1f; }
  }
  stroke(255, 255, 255, 30);
  hint(ENABLE_DEPTH_TEST);
  strokeWeight(2);
  
  if(buildTreeEtc) {
    vec4 appl = nodes.get(0).calcC();
  }
  
  //if(showCenter||showTree) for(Node n : nodes) point(n.xc, n.yc, n.zc);
  
  /*
  stroke(0, 255, 0);
  nodes.get(0).attract2(0, 0);
  strokeWeight(10);
  stroke(255, 255, 0);
  point(quantas.get(0).x, quantas.get(0).y, quantas.get(0).z);
  strokeWeight(2);
  quantas.get(0).update();
  */
  
  hint(DISABLE_DEPTH_TEST);
  if(showCenter) {
    strokeWeight(10);
    stroke(70, 120, 255, 100);
    point(nodes.get(0).xc, nodes.get(0).yc, nodes.get(0).zc);
    strokeWeight(2);
  }
  hint(ENABLE_DEPTH_TEST);
  
  //CALCULATION LOOP//
  int localTick = 0;
  int loopStart = quantas.size()/frameDivide*frameDivideStepNumber;
  int loopEnd = quantas.size()/frameDivide*frameDivideStepNumber + quantas.size()/frameDivide;
  for(int i = loopStart; i < loopEnd; i++) {
    if(localTick%1000==0&&calc)
      println(((float)localTick/(float)particleListSize*100+(float)frameDivideStepNumber/(float)frameDivide*100f) + "% done frame");
    if(calc) {
      quantas.get(i).updateLin();
      nodes.get(0).attract2(i, 0);
      quantas.get(i).update();
    }
    localTick++;
  }
  hint(DISABLE_DEPTH_TEST);
  //DISPLAY LOOP//
  randomSeed(19521);
  localTick = 0;
  for(Quanta q : quantas) {
    strokeWeight(2);
    blendMode(ADD);
    if(!showCenter) {
      if(dispRandom) {
        if(random(20)>19||(frameDivideStepNumber==0||(keyPressed&&key=='q'))&&calc) {
          q.display();
        }
      } else {
        q.display();
      }
    }
    //q.attract(mouseX-width/2, mouseY-height/2, (float)width*(noise(float(passedFrames)/100f)-0.5f), mousePressed?400000:0);
    localTick++;
  }
  randomSeed(millis());
  
  if(calc) {
    camAng+=0.02f/(float)frameDivide;
    if(savePics&&frameDivideStepNumber==0){ println("Picture Saved."); saveFrame(passedCalcs/frameDivide + ".jpg"); }
    passedCalcs++;
  }
  
  if(keyPressed&&key=='i')
    calc = true;
  if(keyPressed&&key=='o')
    calc = false;
  if(keyPressed&&key=='r')
    createQuantainer();
  if(buildTreeEtc)
    println("w " + nodes.get(10).regionWidth);
  if(calc) {
  if(frameDivideStepNumber<frameDivide-1)
    frameDivideStepNumber++;
  else
    frameDivideStepNumber = 0;
  }
  println(frameDivideStepNumber);
  buildTreeEtc = calc;
}

int returnNav(int start, String n) {
  char[] p = n.toCharArray();
  int nub = start;
  for(int i = 0; i < p.length; i++) {
    if(p[i] == '^')
      nub = nodes.get(nub).parent;
    if(p[i] == '1')
      nub = nodes.get(nub).children.get(0);
    if(p[i] == '2')
      nub = nodes.get(nub).children.get(1);
  }
  return nub;
}

void createQuantainer() {
  quantas.clear();
  for(int i = 0; i < particleListSize; i++) {
    float x = random(-width/2*pointScale, width/2*pointScale);
    float y = random(-height/2*pointScale, height/2*pointScale);
    float z = random(-width/2*pointScale, width/2*pointScale);
    PVector vel = new PVector(x, y, z);
    vel.normalize();
    vel.mult(random(10f));
    PVector pos = new PVector(x, y, z);
    pos.normalize();
    pos.mult(random((float)width/2f*pointScale));
    if(noiseDisplace) {
      x += noise(x/300f, y/300f, z/300f)*600f-300f;
      y += noise(x/300f+2402, y/300f, z/300f)*600f-300f;
      z += noise(x/300f+2402, y/300f, z/300f+2490)*600f-300f;
    }
    quantas.add(new Quanta(x, y, z, 0, 0, 0, i));
  }
}

void createQuantainerGalactica() {
  quantas.clear();
  for(int i = 0; i < particleListSize; i++) {
    float r = random(1);
    r = sqrt(r);
    r *= width/2*pointScale;
    float t = random(100000f);
    PVector vel = new PVector(r*sin(t), r*cos(t));
    float theta = 3*PI/2;
    PVector nv = new PVector(vel.x*cos(theta)-vel.y*sin(theta), vel.x*sin(theta)+vel.y*cos(theta), 0f);
    nv.normalize();
    nv.mult(3);
    
    quantas.add(new Quanta(vel.x, vel.y, random(80), nv.x, nv.y, nv.z, i));
  }
}

void createQuantainerSpheroidica(float x, float y, float z, float r, int idx) {
  if(idx==0)
    quantas.clear();
  for(int i = particleListSize*idx; i < particleListSize*(idx+1); i++) {
    PVector v1 = new PVector(random(-1, 1), random(-1, 1), random(-1, 1));
    v1.normalize();
    v1.mult(sqrt(random(1))*r);
    
    quantas.add(new Quanta(v1.x+x, v1.y+y, v1.z+z, 0, 0, 0, i));
  }
}

void treeSplitRecurX(ArrayList<Quanta> q, int nodeID, int x0, int y0, int z0, int x1, int y1, int z1, int iter, float wid) {
  nodes.get(nodeID).setWidth(wid);
  
  if(iter<maxIterations&&q.size()>bucketSize) {
    if(q.size() > 1) {
      float x = 0;
      for(Quanta k : q)
        x += k.x;
      x /= q.size();
      ArrayList<Quanta> A1 = new ArrayList<Quanta>();
      ArrayList<Quanta> A2 = new ArrayList<Quanta>();
      for(int i = 0; i < q.size(); i++) {
        if(q.get(i).x <= x)
          A1.add(q.get(i));
        else
          A2.add(q.get(i));
      }
      int id = nodes.get(nodeID).addNode();
      int id2 = nodes.get(nodeID).addNode();
      treeSplitRecurY(A1, id,  x0, y0, z0, (int)x, y1, z1, iter+1, wid/1.259);
      treeSplitRecurY(A2, id2, (int)x, y0, z0, x1, y1, z1, iter+1, wid/1.259);
    } else {
      if(q.size()>0) {
        q.get(0).setNode(nodeID);
        nodes.get(nodeID).addLink(q.get(0).id);
      }
    }
  } else {
    for(Quanta p : q) {
      p.setNode(nodeID);
      nodes.get(nodeID).addLink(p.id);
    }
  }
}

void treeSplitRecurY(ArrayList<Quanta> q, int nodeID, int x0, int y0, int z0, int x1, int y1, int z1, int iter, float wid) {
  nodes.get(nodeID).setWidth(wid);
  
  if(iter<maxIterations&&q.size()>bucketSize) {
    if(q.size() > 1) {
      float y = 0;
      for(Quanta k : q)
        y += k.y;
      y /= q.size();
      ArrayList<Quanta> A1 = new ArrayList<Quanta>();
      ArrayList<Quanta> A2 = new ArrayList<Quanta>();
      for(int i = 0; i < q.size(); i++) {
        if(q.get(i).y <= y)
          A1.add(q.get(i));
        else
          A2.add(q.get(i));
      }
      int id = nodes.get(nodeID).addNode();
      int id2 = nodes.get(nodeID).addNode();
      treeSplitRecurZ(A1, id, x0, y0, z0, x1, (int)y, z1, iter+1, wid/1.259);
      treeSplitRecurZ(A2, id2, x0, (int)y, z0, x1, y1, z1, iter+1, wid/1.259);
    } else {
      if(q.size()>0) {
        q.get(0).setNode(nodeID);
        nodes.get(nodeID).addLink(q.get(0).id);
      }
    }
  } else {
    for(Quanta p : q) {
      p.setNode(nodeID);
      nodes.get(nodeID).addLink(p.id);
    }
  }
}

void treeSplitRecurZ(ArrayList<Quanta> q, int nodeID, int x0, int y0, int z0, int x1, int y1, int z1, int iter, float wid) {
  nodes.get(nodeID).setWidth(wid);
  
  if(showTree) doLines(x0, y0, z0, x1, y1, z1);
  if(iter<maxIterations&&q.size()>bucketSize) {
    if(q.size() > 1) {
      float z = 0;
      for(Quanta k : q)
        z += k.z;
      z /= q.size();
      ArrayList<Quanta> A1 = new ArrayList<Quanta>();
      ArrayList<Quanta> A2 = new ArrayList<Quanta>();
      for(int i = 0; i < q.size(); i++) {
        if(q.get(i).z <= z)
          A1.add(q.get(i));
        else
          A2.add(q.get(i));
      }
      int id = nodes.get(nodeID).addNode();
      int id2 = nodes.get(nodeID).addNode();
      treeSplitRecurX(A1, id, x0, y0, z0, x1, y1, (int)z,iter+1, wid/1.259);
      treeSplitRecurX(A2, id2, x0, y0, (int)z, x1, y1, z1, iter+1, wid/1.259);
    } else {
      if(q.size()>0) {
        q.get(0).setNode(nodeID);
        nodes.get(nodeID).addLink(q.get(0).id);
      }
    }
  } else {
    for(Quanta p : q) {
      p.setNode(nodeID);
      nodes.get(nodeID).addLink(p.id);
    }
  }
}

float standardDevX(ArrayList<Quanta> qListT) {
  float avg = 0;
  float div = 0;
  for(Quanta q : qListT) {
    avg += q.x;
    div++;
  }
  avg /= div;
  float sumSqr = 0;
  for(Quanta q : qListT)
    sumSqr += (avg-q.x)*(avg-q.x);
  sumSqr /= div;
  return sqrt(sumSqr);
}
float standardDevY(ArrayList<Quanta> qListT) {
  float avg = 0;
  float div = 0;
  for(Quanta q : qListT) {
    avg += q.y;
    div++;
  }
  avg /= div;
  float sumSqr = 0;
  for(Quanta q : qListT)
    sumSqr += (avg-q.y)*(avg-q.y);
  sumSqr /= div;
  return sqrt(sumSqr);
}
float standardDevZ(ArrayList<Quanta> qListT) {
  float avg = 0;
  float div = 0;
  for(Quanta q : qListT) {
    avg += q.z;
    div++;
  }
  avg /= div;
  float sumSqr = 0;
  for(Quanta q : qListT)
    sumSqr += (avg-q.z)*(avg-q.z);
  sumSqr /= div;
  return sqrt(sumSqr);
}

PVector avgPos(ArrayList<Quanta> qListT) {
  PVector p = new PVector(0, 0, 0);
  float div = 0;
  for(Quanta q : qListT) {
    p.add(new PVector(q.x, q.y, q.z));
    div++;
  }
  p.mult(1.0f/div);
  return p;
}

float getW(ArrayList<Quanta> qListT) {
  float xm = 0f;
  float ym = 0f;
  float zm = 0f;
  float xmi = 0f;
  float ymi = 0f;
  float zmi = 0f;
  for(Quanta q : qListT) {
    if(q.x<xmi)xmi=q.x;
    if(q.x>xm)xm=q.x;
    
    if(q.y<ymi)ymi=q.y;
    if(q.y>ym)ym=q.y;
    
    if(q.y<ymi)ymi=q.y;
    if(q.y>ym)ym=q.y;
  }
  return ((xm-xmi)+(ym-ymi)+(zm-zmi))/3f;
}

void doLines(float x0, float y0, float z0, float x1, float y1, float z1) {
  line(x0, y0, z0, x1, y0, z0);
  line(x0, y0, z0, x0, y1, z0);
  line(x0, y0, z0, x0, y0, z1);
  
  line(x0, y1, z0, x1, y1, z0);
  line(x0, y0, z1, x0, y1, z1);
  line(x1, y0, z0, x1, y0, z1);
  
  line(x0, y0, z1, x1, y0, z1);
  line(x1, y0, z0, x1, y1, z0);
  line(x0, y1, z0, x0, y1, z1);
}

class Node {
  int id;
  int parent;
  ArrayList<Integer> children = new ArrayList<Integer>();
  ArrayList<Integer> links = new ArrayList<Integer>();
  float xc;
  float yc;
  float zc;
  float mass;
  float regionWidth;
  public Node(int parentID, int objIdLink, float w) {
    id = globalTick++;
    parent = parentID;
    nodes.get(parentID).children.add(id);
    links.add(objIdLink);
    regionWidth = w;
  }
  public Node(boolean b, int parentID, float w) {
    id = globalTick++;
    parent = parentID;
    nodes.get(parentID).children.add(id);
    xc = 0;
    yc = 0;
    zc = 0;
    regionWidth = w;
  }
  public Node(int parentID, int objIdLink) {
    id = globalTick++;
    parent = parentID;
    nodes.get(parentID).children.add(id);
    links.add(objIdLink);
  }
  public Node(int parentID) {
    id = globalTick++;
    parent = parentID;
    nodes.get(parentID).children.add(id);
    xc = 0;
    yc = 0;
    zc = 0;
  }
  public Node() {
    id = globalTick;
    globalTick++;
    xc = 0;
    yc = 0;
    zc = 0;
  }
  public void setWidth(float w) {
    regionWidth = w;
  }
  public void addLink(int lnum) {
    links.add(lnum);
    xc = quantas.get(lnum).x;
    yc = quantas.get(lnum).y;
    zc = quantas.get(lnum).z;
  }
  public void setC(float x, float y, float z) {
    xc = x;
    yc = y;
    zc = z;
  }
  public void attract2(int qLink, int iter) {
    float xp = quantas.get(qLink).x;
    float yp = quantas.get(qLink).y;
    float zp = quantas.get(qLink).z;
    float dx = xp-xc;
    float dy = yp-yc;
    float dz = zp-zc;
    float f = dx*dx+dy*dy+dz*dz;
    if((!(children.size()==0))&&(mass/f>accuratenessConstant||f<eventHorizon)) {
      for(int i : children)
        nodes.get(i).attract2(qLink, iter+1);
    } else {
      if(quantas.get(qLink).node!=id) quantas.get(qLink).attract(xc, yc, zc, mass*gravityConstant);
      if(showAttraction) {strokeWeight(max(2, mass/4f)); point(xc, yc, zc); strokeWeight(1);}
    }
  }
  public vec4 calcC() {
    if(children.size()==0) {
      mass = 1f;
      return new vec4(xc, yc, zc, 1);
    } else {
      vec4 a = new vec4(0, 0, 0, 0);
      float f = 0;
      for(int q : children) {
        vec4 v = nodes.get(q).calcC();
        f += v.w;
        a.add(v, v.w);
      }
      float tx = a.x/f;
      float ty = a.y/f;
      float tz = a.z/f;
      xc = tx;
      yc = ty;
      zc = tz;
      mass = a.w;
      return new vec4(tx, ty, tz, a.w);
    }
  }
  public void printID() {
    println("ID: " + id);
    println("Parent: " + parent);
    print("Children- ");
    for(int i : children)
      print(i + " ");
    print("\n\n");
  }
  public int getParent() {
    return parent;
  }
  public int getID() {
    return id;
  }
  public int addNode() {
    nodes.add(new Node(id));
    return children.get(children.size()-1);
  }
  public int addNode(int objIdLink) {
    nodes.add(new Node(id, objIdLink));
    return children.get(children.size()-1);
  }
  public int addNodeW(float w) {
    nodes.add(new Node(false, id, w));
    return children.get(children.size()-1);
  }
  public int addNodeW(float w, int objIdLink) {
    nodes.add(new Node(id, objIdLink, w));
    return children.get(children.size()-1);
  }
  public void recursiveDisplay(int x, int i, float sc) {
    strokeWeight(5);
    point(x, i);
    strokeWeight(1);
    int q = -children.size()/2*15;
    for(int r : children) {
      int f = (int)0;
      line(x, i, x+int((q+f)*sc), i+int(10*sc));
      nodes.get(r).recursiveDisplay(x+int((q+f)*sc), int(i+10*sc), sc/2f);
      q += 30;
    }
  }
}
public class Quanta {
  float x;
  float y;
  float z;
  float px;
  float py;
  float pz;
  float xv;
  float yv;
  float zv;
  PVector a = new PVector();
  PVector normVec = new PVector();
  int id = -1;
  int node = -1;
  float p = 0;
  public Quanta(float x, float y, float z, int idex) {
    this.x = x;
    this.y = y;
    this.z = z;
    id = idex;
  }
  public Quanta(float x, float y, float z, float xv, float yv, float zv, int idex) {
    this.x = x;
    this.y = y;
    this.z = z;
    this.xv = xv;
    this.yv = yv;
    this.zv = zv;
    id = idex;
  }
  public void setNode(int nodeId) {
    this.node = nodeId;
  }
  public void display() {
    float d = dist(0, 0, 0, xv, yv, zv)*50f;
    if(colorVelocity)
      stroke(abs(normVec.x)*velocityColorMultiplier, abs(normVec.y)*velocityColorMultiplier, abs(normVec.z)*velocityColorMultiplier, particleAlpha);
    else
      stroke(255, 255, 255, particleAlpha);
    if(drawLines)
      line(x, y, z, x+normVec.x*lineLength, y+normVec.y*lineLength, z+normVec.z*lineLength);
    else
      point(x, y, z);
  }
  public void update() {
    x += xv;
    y += yv;
    z += zv;
  }
  public void updateLin() {
    normVec = new PVector(xv, yv, zv);
    normVec.normalize();
  }
  public void attract(float xt, float yt, float zt, float density) {
    float d = max(dist(x, y, z, xt, yt, zt), 0.0)+1f;
    a.x = xt-x;
    a.y = yt-y;
    a.z = zt-z;
    //if(!mousePressed) a = new PVector(0, 0, 0);
    a.normalize();
    a.x = (a.x/(d*d/30))/40000.0f;
    a.y = (a.y/(d*d/30))/40000.0f;
    a.z = (a.z/(d*d/30))/40000.0f;
    xv += a.x*density;
    yv += a.y*density;
    zv += a.z*density;
  }
}

public class vec4 {
  float x;
  float y;
  float z;
  float w;
  public vec4(float x, float y, float z, float w) {
    this.x = x;
    this.y = y;
    this.z = z;
    this.w = w;
  }
  public void add(vec4 v) {
    x += v.x;
    y += v.y;
    z += v.z;
    w += v.w;
  }
  public void add(vec4 v, float s) {
    x += v.x*s;
    y += v.y*s;
    z += v.z*s;
    w += v.w;
  }
}
