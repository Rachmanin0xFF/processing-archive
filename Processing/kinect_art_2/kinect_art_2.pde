//--------------------------------------------------------------------------------------------------------------//
//--------------------------------------------------------------------------------------------------------------//

import SimpleOpenNI.*;

PVector[] blobPositions;
PVector[] blobVelocities;
float[] blobSizes;
float latencyCutoff = 100.0f;
float scaleX = 1.6f;
float scaleY = 1.6f;
float sensorZoom = 1.5f;

int passedFrames = 0;

int timeSinceNoBlobs = 0;

boolean printDiagnostics = false;

PShader blurH;
PShader blurV;

int W_W_0 = int(640*scaleX);
int H_H_0 = int(480*scaleY);

float imgC = 230;
float dptC = 1300;

void setup() {
  size(1900, 600, P2D);
  background(255);
  stroke(255);
  setupKinect();
  blurH = loadShader("blur.glsl");
  blurV = loadShader("blur2.glsl");
  for(int x = 0; x < networkDensity.length; x++)
    for(int y = 0; y < networkDensity[0].length; y++)
      qVelocities[x][y] = new PVector();
  smooth(2);
  
  for(int i = 0; i < 150; i++) network.add(new Node(new PVector(random(width), random(height))));
  
  PFont font = loadFont("Batang-60.vlw");
  textFont(font);
}

Timer dgnst = new Timer();

void draw() {
  background(255);
  
  dgnst.startCycle(); //0
  
  updateKinect();
  
  dgnst.breakpoint();
  
  calcNetworkDensities();
  
  dispDensities2();
  
  blurH.set("r", 0.0055f); blurV.set("r", 0.0055f);
  filter(blurH); filter(blurV);
  
  updateNodes();
  updatePings();
  updateDiamonds();
  
  displayNetwork();
  drawPings();
  drawDiamonds();
  
  blurH.set("r", 0.002f); blurV.set("r", 0.002f);
  filter(blurH); filter(blurV);
  blurH.set("r", 0.001f); blurV.set("r", 0.001f);
  filter(blurH); filter(blurV);
  
  displayNetwork();
  drawPings();
  drawDiamonds();
  
  println(blobPositions.length);
  if(blobPositions.length < -2) timeSinceNoBlobs++; else timeSinceNoBlobs = 0;
  if(timeSinceNoBlobs > 200) {
    float z = min(1.5f, (timeSinceNoBlobs-400)/50.f);
    blurH.set("r", 0.002f*z); blurV.set("r", 0.002f*z);
    filter(blurH); filter(blurV);
    blurH.set("r", 0.001f*z); blurV.set("r", 0.001f*z);
    filter(blurH); filter(blurV);
    textAlign(CENTER);
    colorMode(RGB);
    fill(0, 0, 0, z*255.0f);
    text("step up to the line\nand reach forward", width/2, height/2);
  }
  
  colorMode(RGB);
  if(passedFrames == 0) background(0);
  passedFrames++;
  
  dgnst.endCycle();
}

//--------------------------------------------------------------------------------------------------------------//
//--------------------------------------------------------------------------------------------------------------//

ArrayList<Node> network = new ArrayList<Node>();
ArrayList<Edge> edges = new ArrayList<Edge>();

float spreadProbability = 0.25f;
float mutationProbability = 0.00004f;

void displayHandsStyle(float r, float s) {
  noFill();
  stroke(0);
  strokeWeight(s);
  for(int i = 1; i < min(blobPositions.length, 3); i++) {
    ellipse(blobPositions[i].x, blobPositions[i].y, r*2, r*2);
  }
  strokeWeight(1);
}

void displayNetwork() {
  displayEdges();
  displayNodes();
}

void displayNodes() {
  stroke(0);
  colorMode(HSB);
  for(Node n : network) {
    drawNode(n.id, n.position.x, n.position.y, min(20, n.wDegree*10.0f/(float)n.maxDegree + 5), n.luma);
  }
}

void displayEdges() {
  for(Edge e : edges) {
    drawEdge(e.a, e.b, 0, e.strength);
  }
}

void drawNode(int id, float x, float y, float radius) {
  strokeWeight(radius);
  point(x, y);
  stroke(255); strokeWeight(radius/1.2f);
  point(x, y);
  stroke(0); strokeWeight(radius/1.5f);
  point(x, y);
  strokeWeight(1);
}

void drawNode(int id, float x, float y, float radius, float luma) {
  colorMode(HSB);
  strokeWeight(radius);
  point(x, y);
  stroke(255); strokeWeight(radius/1.2f);
  point(x, y);
  stroke(0); strokeWeight(radius/1.5f);
  point(x, y);
  strokeWeight(1);
  if(luma > 3) {
    stroke(luma*5.0f, 255, luma*5.0f);
    noFill();
    ellipse(x, y, luma*2.0f, luma*2.0f);
  }
}

void drawEdge(int id1, int id2, float radius, float str) {
  PVector a = copyVec(network.get(id1).position);
  PVector b = copyVec(network.get(id2).position);
  PVector a2b = PVector.sub(b, a);
  a2b.normalize();
  a2b.mult(radius);
  stroke(0, 0, 0, str*255.0f);
  line(a.x + a2b.x, a.y + a2b.y, b.x - a2b.x, b.y - a2b.y);
}

void updateNodes() {
  for(Node n : network) n.updateConn();
  for(Edge e : edges) e.calcForce();
  for(int i = edges.size()-1; i >= 0; i--) if(edges.get(i).shouldKill()) removeEdge(i);
  for(Edge e : edges) e.updatePhys();
  for(Edge e : edges) { network.get(e.a).wDegree += e.strength; network.get(e.b).wDegree += e.strength; }
  for(Node n : network) n.updatePhys();
}

class Node {
  PVector position = new PVector();
  PVector velocity = new PVector();
  ArrayList<Integer> connectedTo = new ArrayList<Integer>();
  int id;
  PVector col;
  int degree = 0;
  float wDegree = 0.0f;
  float luma = 0.0f;
  int maxDegree;
  public Node(PVector pos) {
    id = network.size();
    position = pos;
    maxDegree = (int)(random(3, 5));
  }
  public void setVelocity(PVector v) {
    velocity = copyVec(v);
  }
  public void updatePhys() {
    for(int i = 1; i < blobPositions.length; i++) {
      if(distance(position, blobPositions[i]) < 200)
      velocity.add(keepUnderLength(blobVelocities[i], 16.0f));
    }
    if(mousePressed && distance(position, new PVector(mouseX, mouseY)) < 200) {
      velocity.add(keepUnderLength(new PVector(mouseX-pmouseX, mouseY-pmouseY), 16.0f));
    }
    
    if(position.x < 20) velocity.x += 20 - position.x;
    if(position.x > width-20) velocity.x += width - 20 - position.x;
    if(position.y < 20) velocity.y += 20 - position.y;
    if(position.y > height - 20) velocity.y += height - 20 - position.y;
    PVector seperationForce = getBilinear(qVelocities, position.x/(float)qDiv-1, position.y/(float)qDiv-1, width/qDiv, height/qDiv);
    velocity.add(seperationForce);
    velocity.mult(0.85f);
    position.add(velocity);
  }
  public void updateConn() {
    wDegree = 0.0f;
    int i = int(random(network.size()-1));
    if(degree < maxDegree && network.get(i).degree < maxDegree && !connectedTo.contains(i) && i != id && distance(position, network.get(i).position) < 50)
      addEdge(id, i);
    
    if(random(100000.f) <= 100000.f*spreadProbability) {
      for(int k = 0; k < connectedTo.size(); k++) {
        luma = max(network.get(connectedTo.get(k)).luma, luma);
      }
    }
    luma *= 0.95f;
    if(random(100000.f) <= 100000.f*mutationProbability*(connectedTo.size()+1)) {
      luma = 60.0f;
      addPing(position.x, position.y, 100, 1);
      addDiamonds(position, 300, 5, velocity);
    }
  }
}

float distance(PVector a, PVector b) {
  return dist(a.x, a.y, b.x, b.y);
}

void addNode(PVector pos) {
  network.add(new Node(pos));
}

void addEdge(int a, int b) {
  network.get(a).connectedTo.add(b);
  network.get(b).connectedTo.add(a);
  network.get(a).degree++;
  network.get(b).degree++;
  edges.add(new Edge(a, b));
}

void removeEdge(int eid) {
  network.get(edges.get(eid).a).connectedTo.remove(network.get(edges.get(eid).a).connectedTo.indexOf(edges.get(eid).b));
  network.get(edges.get(eid).b).connectedTo.remove(network.get(edges.get(eid).b).connectedTo.indexOf(edges.get(eid).a));
  network.get(edges.get(eid).a).degree--;
  network.get(edges.get(eid).b).degree--;
  edges.remove(eid);
}

class Edge {
  int a;
  int b;
  int id;
  float force = 0.0f;
  PVector p1 = new PVector();
  PVector p2 = new PVector();
  float strength = 1.0f;
  public Edge(int a, int b) {
    this.a = a;
    this.b = b;
    this.id = edges.size();
  }
  
  void calcForce() {
    p1 = network.get(a).position;
    p2 = network.get(b).position;
    float luma = max(network.get(a).luma, network.get(b).luma);
    force = (100-luma) - distance(p1, p2);
  }
  
  boolean shouldKill() {
    return force < -100 || strength <= 0.0f;
  }
  
  void updatePhys() {
    PVector forceDirection;
    
    forceDirection = PVector.sub(p1, p2);
    forceDirection.normalize();
    forceDirection.mult(force*0.015f*strength);
    network.get(a).velocity.add(forceDirection);
    
    forceDirection = PVector.sub(p2, p1);
    forceDirection.normalize();
    forceDirection.mult(force*0.015f*strength);
    network.get(b).velocity.add(forceDirection);
    strength -= 0.002f;
  }
}

//--------------------------------------------------------------------------------------------------------------//
//--------------------------------------------------------------------------------------------------------------//

ArrayList<Haze> diamonds = new ArrayList<Haze>();

void addDiamonds(PVector pos, float num, float v, PVector vel) {
  float theta = 0.f;
  float r = v;
  for(int i = 0; i < num; i++) {
    theta = random(10000);
    float r0 = random(1);
    r0 *= r0;
    r = r0*v;
    diamonds.add(new Haze(pos, PVector.add(vel, new PVector(r*cos(theta), r*sin(theta))), 30));
  }
}

void updateDiamonds() {
  for(int i = diamonds.size()-1; i >= 0; i--) {
    diamonds.get(i).update();
    if(diamonds.get(i).dead)
      diamonds.remove(i);
  }
}

void drawDiamonds() {
  for(Haze d : diamonds) {
    stroke(0, (1.f-(float)d.age/(float)d.lifespan)*255.f);
    point(d.p.x, d.p.y);
  }
  strokeWeight(1);
}

class Haze {
  PVector p;
  PVector v;
  int lifespan;
  int age = 0;
  boolean dead = false;
  public Haze(PVector pos, PVector vel, int life) {
    p = copyVec(pos);
    v = copyVec(vel);
    lifespan = life;
  }
  public void update() {
    v.mult(0.98f);
    p.add(v);
    age++;
    dead = age > lifespan;
  }
}

ArrayList<Ping> pingList = new ArrayList<Ping>();

void updatePings() {
  for(int i = pingList.size()-1; i >= 0; i--) {
    pingList.get(i).update();
    if(pingList.get(i).shouldKill)
      pingList.remove(i);
  }
}

void addPing(float x, float y, float rad, float speed) {
  pingList.add(new Ping(x, y, 10.0f, rad, speed));
}

void addPing(float x, float y, int count, float sep, float rad, float speed) {
  for(float i = 0.f; i < count; i++)
    pingList.add(new Ping(x, y, -sep*i, rad, max(0.0f, speed)));
}

void drawPings() {
  for(Ping p : pingList)
    drawPing(p.x, p.y, p.r, 1.0f-p.r/p.tr);
}

void drawPing(float x, float y, float r, float a) {
  colorMode(RGB);
  if(r > 0.0f) {
    stroke(0, 0, 0, a*255.0f);
    noFill();
    strokeWeight(1);
    ellipse(x, y, r*2.f, r*2.f);
    stroke(0);
    fill(0);
  }
}

class Ping {
  float x;
  float y;
  float r = 0.f;
  float tr;
  float deltaR = 0.0f;
  boolean shouldKill = false;
  public Ping(float x, float y, float r, float tr, float deltaR) {
    this.x = x;
    this.y = y;
    this.r = r;
    this.tr = tr;
    this.deltaR = deltaR;
  }
  public void update() {
    r += deltaR;
    shouldKill = r > tr;
  }
}

//--------------------------------------------------------------------------------------------------------------//
//--------------------------------------------------------------------------------------------------------------//

int qDiv = 50;
float expansionStrength = 0.1f;

float[][] networkDensity = new float[W_W_0/qDiv][H_H_0/qDiv];
PVector[][] qVelocities = new PVector[W_W_0/qDiv][H_H_0/qDiv];

void calcNetworkDensities() {
  networkDensity = new float[width/qDiv][height/qDiv];
  for(Node n : network) {
    PVector fPos = PVector.mult(n.position, 1.0f/(float)qDiv);
    networkDensity[clamp(round(fPos.x)-1, 0, width/qDiv-1)][clamp(round(fPos.y)-1, 0, height/qDiv-1)]++;
  }
  for(int x = 0; x < networkDensity.length; x++)
    for(int y = 0; y < networkDensity[0].length; y++)
      qVelocities[x][y].mult(0.6f);
  for(int x = 1; x < networkDensity.length-1; x++)
    for(int y = 1; y < networkDensity[0].length-1; y++)
      qVelocities[x][y].add(calcIndivVelocity(x, y));
}

PVector calcIndivVelocity(int cx, int cy) {
  PVector sum = new PVector();
  for(int x = -1; x <= 1; x++)
    for(int y = -1; y <= 1; y++) {
      if(!(x == 0 && y == 0)) {
        float veltMul = expansionStrength/dist(0, 0, float(x), float(y));
        float deltaDensity = networkDensity[cx][cy] - networkDensity[cx+x][cy+y];
        PVector s = new PVector(x, y);
        s.mult(deltaDensity);
        s.mult(veltMul);
        sum.add(s);
      }
    }
  return sum;
}

//--------------------------------------------------------------------------------------------------------------//
//--------------------------------------------------------------------------------------------------------------//

SimpleOpenNI context;
PImage depthImage0 = new PImage(640, 480);
PImage depthImage;
PVector[] depthCoords = new PVector[640*480];
PVector[] depthCoords0 = new PVector[640*480];
int densDiv = 10;
float[][] densities = new float[640/densDiv][480/densDiv];
int[][] blobNumbers = new int[640/densDiv][480/densDiv];
int currentBlobSize = 0;
float blobCutoff = 30.0f;
float densityDepth = 0.75f;

void setupKinect() {
  context = new SimpleOpenNI(this);
  if(context.isInit() == false) {
     println("Can't init SimpleOpenNI, maybe the camera is not connected!"); 
     exit();
     return;  
  }
  context.enableDepth();
  context.setMirror(true);
  context.update();
  depthImage0.pixels = context.depthImage().pixels;
  PVector[] tmparr = context.depthMapRealWorld();
  for(int i = 0; i < 640*480; i++)
    depthCoords0[i] = new PVector(tmparr[i].x, tmparr[i].y, tmparr[i].z);
  blobPositions = new PVector[]{new PVector(0, 0, 0)};
}

void updateKinect() {
  context.update();
  depthImage = context.depthImage();
  depthCoords = context.depthMapRealWorld();
  
  //calcDensities(300, 245, 1000);
  //calcDensities(300, 145, 1300);
  calcDensities(300, imgC, dptC);
  calcBlobs();
  calcVelocities();
}

int cX(float x) {
  return max(0, min(640/densDiv-1, round(x)));
}

int cY(float y) {
  return max(0, min(480/densDiv-1, round(y)));
}

void calcDensities(float r, float s, float t) {
  for(int x = 0; x < 640/densDiv; x++)
    for(int y = 0; y < 480/densDiv; y++)
      densities[x][y] *= densityDepth;
  int step = 2;
  for(int i = 0; i < 640 * 480; i+= step) {
    if(/*(depthCoords0[i].z - depthCoords[i].z - r > 0) && */r(depthImage.pixels[i]) > s && depthCoords[i].z < t) {
      int x = i%640;
      int y = i/640;
      densities[cX(x/densDiv+random(-1, 1))][cY(y/densDiv+random(-1, 1))]++;
    }
  }
}

void fillWith(int xc, int yc, int colorToFill, int itr) {
  if(blobNumbers[xc][yc] == 0) {
    blobNumbers[xc][yc] = colorToFill;
    currentBlobSize++;
    if(densities[cX(xc+1)][cY(yc)] > blobCutoff) fillWith(cX(xc+1), cY(yc), colorToFill, itr+1);
    if(densities[cX(xc)][cY(yc+1)] > blobCutoff) fillWith(cX(xc), cY(yc+1), colorToFill, itr+1);
    if(densities[cX(xc-1)][cY(yc)] > blobCutoff) fillWith(cX(xc-1), cY(yc), colorToFill, itr+1);
    if(densities[cX(xc)][cY(yc-1)] > blobCutoff) fillWith(cX(xc), cY(yc-1), colorToFill, itr+1);
  }
}

PVector mapBlobsToScreen(PVector inVec) {
  float x = width/2 + (inVec.x*densDiv*scaleX-width/2)*sensorZoom;
  float y = height/2 + (inVec.y*densDiv*scaleY-height/2)*sensorZoom;
  return new PVector(x, y);
}

void calcBlobs() {
  blobNumbers = new int[640/densDiv][480/densDiv];
  int i = 1;
  
  for(int k = 0; k < blobPositions.length; k++) {
    int x = cX(blobPositions[k].x);
    int y = cY(blobPositions[k].y);
    if(blobNumbers[x][y] == 0 && densities[x][y] > blobCutoff) {
      fillWith(x, y, i, 0);
      i++;
    }
  }
  
  for(int x = 0; x < 640/densDiv; x++) {
    for(int y = 0; y < 480/densDiv; y++) {
      if(blobNumbers[x][y] == 0 && densities[x][y] > blobCutoff) {
        fillWith(x, y, i, 0);
        i++;
      }
    }
  }
  blobSizes = new float[i];
  blobPositions = new PVector[i]; for(int k = 0; k < i; k++) blobPositions[k] = new PVector();
  for(int x = 0; x < 640/densDiv; x++)
    for(int y = 0; y < 480/densDiv; y++) {
      blobSizes[blobNumbers[x][y]] += densities[x][y];
      PVector toAdd = mapBlobsToScreen(new PVector(x, y));
      toAdd.mult(densities[x][y]);
      blobPositions[blobNumbers[x][y]].add(toAdd);
    }
  for(int k = 0; k < i; k++)
    blobPositions[k].mult(1.0f/(float)blobSizes[k]);
}

PVector[] prevBlobPositions = new PVector[0];

int[] blobLatency;
void calcLatency() {
  blobLatency = fitArrayToSize(blobLatency, blobVelocities.length);
  for(int i = 0; i < blobVelocities.length; i++) {
    if(blobVelocities[i].mag() > latencyCutoff)
      blobLatency[i] = 0;
    else
      blobLatency[i]++;
  }
}

void calcVelocities() {
  blobVelocities = new PVector[blobPositions.length];
  for(int i = 0; i < blobPositions.length; i++) {
    PVector delta = new PVector();
    float mass = 0.0f;
    if(prevBlobPositions.length > i) {
      delta = PVector.sub(blobPositions[i], prevBlobPositions[i]);
      mass = blobSizes[i];
    }
    blobVelocities[i] = new PVector(delta.x, delta.y, delta.z);
  }
  prevBlobPositions = new PVector[blobPositions.length];
  for(int i = 0; i < blobPositions.length; i++) {
    prevBlobPositions[i] = new PVector(blobPositions[i].x, blobPositions[i].y);
  }
}

void dispDensities() {
  noStroke();
  colorMode(HSB);
  for(int x = 0; x < 640/densDiv; x++) {
    for(int y = 0; y < 480/densDiv; y++) {
      fill((blobNumbers[x][y]*40)%255, 255, densities[x][y] * 3.0f);
      rect(x*densDiv*scaleX, y*densDiv*scaleY, densDiv*scaleX, densDiv*scaleY);
    }
  }
}

void dispDensities2() {
  PImage img = new PImage(640/densDiv, 480/densDiv);
  noStroke();
  colorMode(HSB);
  for(int i = 0; i < 640/densDiv * 480/densDiv; i++) {
    int x = cX(i%(640/densDiv));
    int y = cY(i/(640/densDiv));
    img.pixels[i] = color(255.0f-densities[x][y]*1.0f);
   }
  PVector X0 = mapBlobsToScreen(new PVector(0, 0));
  PVector X1 = mapBlobsToScreen(new PVector(640/densDiv, 480/densDiv));
  image(img, (int)X0.x, (int)X0.y, X1.x-X0.x, X1.y-X0.y);
}

void dispDensities3() {
  noStroke();
  colorMode(HSB);
  for(int x = 0; x < 640/densDiv; x++) {
    for(int y = 0; y < 480/densDiv; y++) {
      fill((blobNumbers[x][y]*40)%255, 255, 255);
      rect(x*densDiv*scaleX, y*densDiv*scaleY, densDiv*scaleX, densDiv*scaleY);
    }
  }
}

//--------------------------------------------------------------------------------------------------------------//
//--------------------------------------------------------------------------------------------------------------//

int r(color c) {return (c >> 16) & 255; }
int g(color c) {return (c >> 8) & 255;}
int b(color c) {return c & 255; }

int[] fitArrayToSize(int[] x, int size) {
  int[] toReturn = new int[size];
  if(x != null)
    for(int i = 0; i < x.length; i++) {
      if(i < size)
        toReturn[i] = x[i];
    }
  return toReturn;
}

PVector[] fitArrayToSize(PVector[] x, int size) {
  PVector[] toReturn = new PVector[size];
  if(x != null)
    for(int i = 0; i < x.length; i++) {
      if(i < size && x[i] != null)
        toReturn[i] = new PVector(x[i].x, x[i].y, x[i].z);
    }
  for(int i = 0; i < toReturn.length; i++) {
    if(toReturn[i] == null || toReturn[i].mag() == 0)
      toReturn[i] = new PVector();
  }
  return toReturn;
}

PVector copyVec(PVector p) {
  return new PVector(p.x, p.y, p.z);
}

PVector keepUnderLength(PVector p, float len) {
  float outLen = min(p.mag(), len);
  PVector outVec = copyVec(p);
  outVec.normalize();
  outVec.mult(outLen);
  return outVec;
}

//Bilinearly interpolates a PVector[][] with length (maxX, maxY) at coordinates (x, y).
PVector getBilinear(PVector[][] arr, float x, float y, int maxX, int maxY) {
  //Calculate corner coordinates of square.
  int lowX = floor(x); int lowY = floor(y);
  int highX = ceil(x); int highY = ceil(y);
  
  //If the sample point is out of bounds, return an empty vector.
  if(lowX < 0 || lowY < 0 || highX >= maxX || highY >= maxY) 
    return new PVector();
  
  //Take sample points with copyVec() so java doesn't modify the actual array values.
  PVector samp_00 = copyVec(arr[lowX][lowY]);
  PVector samp_01 = copyVec(arr[lowX][highY]);
  PVector samp_10 = copyVec(arr[highX][lowY]);
  PVector samp_11 = copyVec(arr[highX][highY]);
  
  //Find the area of the squares in the opposite corners.
  float mul_00 = (float(highX)-x)*(float(highY)-y);
  float mul_01 = (float(highX)-x)*(y-float(lowY));
  float mul_10 = (x-float(lowX))*(float(highY)-y);
  float mul_11 = (x-float(lowX))*(y-float(lowY));
  
  //Multiply our sample points by their corresponding squares.
  samp_00.mult(mul_00);
  samp_01.mult(mul_01);
  samp_10.mult(mul_10);
  samp_11.mult(mul_11);
  
  PVector sum = new PVector();
  
  //Add all the values to the output vector and return it (we don't need to normalize anything, the square has an area of one).
  sum.add(samp_00);
  sum.add(samp_01);
  sum.add(samp_10);
  sum.add(samp_11);
  
  return sum;
}

float clamp(float a, float x, float y) {
  return max(x, min(y, a));
}

int clamp(int a, int x, int y) {
  return max(x, min(y, a));
}

class Timer {
  int ms = 0;
  int ticks = 0;
  void breakpoint() {
    if(printDiagnostics) println("Cycle " + ticks + " ran with an elapsed time of " + (millis()-ms) + ".");
    ticks++;
    ms = millis();
  }
  void endCycle() {
    if(printDiagnostics) println("Final cycle ran with an elapsed time of " + (millis()-ms) + ".");
  }
  void startCycle() {
    ms = millis();
    ticks = 0;
  }
}

//--------------------------------------------------------------------------------------------------------------//
//--------------------------------------------------------------------------------------------------------------//

boolean sketchFullScreen() {
  return true;
}

void keyPressed() {
  if(key == 'r') {
    depthImage0.pixels = context.depthImage().pixels;
    PVector[] tmparr = context.depthMapRealWorld();
    for(int i = 0; i < 640*480; i++)
      depthCoords0[i] = new PVector(tmparr[i].x, tmparr[i].y, tmparr[i].z);
  }
  if(key == ' ') {
    network = new ArrayList<Node>();
    edges = new ArrayList<Edge>();
  }
}