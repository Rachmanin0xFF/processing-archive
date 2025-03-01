//Hypergraph visualization code for muscle/bone networks//

float cameraZoom = 1.4f*1.5f; //Camera's zoom.
PVector camFocus = new PVector(); //Camera's focus point (in pixels).

ArrayList<Node> network = new ArrayList<Node>(); //Node list.
ArrayList<Edge> edgenet = new ArrayList<Edge>(); //Edge list.

int ffRes = 50;
float fieldMult = 70.0f;
PVector[][][] forceField = new PVector[ffRes][ffRes][ffRes];

int springRes = 8; //The number of segments in every spring + 1.
float springStrength = 0.1f; //The amount strings want to stay together.
float springDamp = 0.1f; //The higher this number, the more the dampening increases.

PVector camFocusAdd = new PVector(-150, -150, -400);

PVector scalingVec = new PVector(1.0f, 1.0f, 0.5f);
PVector invScalingVec = new PVector(1.0f, 1.0f, 4.0f);

boolean showField = true;

boolean useCurves = false;

boolean gravity = false;

boolean fieldActive = false;

void keyPressed() {
  if(key == 'p')
    saveFrame("Hypergraph Bone-Muscle Bipartite Incidence Graph " + year() + "-" + month() + "-" + day() + "-" + hour() + "-" + minute() + "-" + second() + "-" + millis() + ".jpg");
}

void setup() {
  //P3D is faster than OpenGL and can be exported easily.
  size(int(600f*1.5f), int(1000f*1.5f), P3D);
  ortho();
  smooth(8);
  
  //Load data into the lists.
  loadBipartiteData("bipartite.csv");
  loadNodeCoordinateData("boneCoords.csv");
  loadEdgeCoordinateData("handCorrectedMuscleCoords.csv");
  loadCommunityData("CommunityAssignments.csv");
  
  addEdgeSprings(); //Add springs onto the edges
  calcCamFocus();
  
  fieldMult = 700.0f/float(ffRes);
  //calculateForceField();
}

void draw() {
  pushMatrix();
  runCamControls();
  doThings();
  //drawThings();
  popMatrix();
  runCamControlsMirror();
  drawThings();
}

//Returns the minimum of the input vector and the vector (b, b, b).
PVector pMin(PVector a, float b) {
  return new PVector(min(a.x, b), min(a.y, b), min(a.z, b));
}

//Simple vector multiplication.
PVector pMult(PVector a, PVector b) {
  return new PVector(a.x*b.x, a.y*b.y, a.z*b.z);
}

//Draws a line from PVector a to PVector b.
void pLine(PVector a, PVector b) {
  line(a.x, a.y, a.z, b.x, b.y, b.z);
}

//Runs once, this is where to put per-frame operations (physics, updates, etc.).
void doThings() {
  updateSpringPhysics();
  showField = keyPressed && key == ENTER;
  useCurves = mousePressed && mouseButton == LEFT;
  gravity = keyPressed && key == 'g';
  fieldActive = keyPressed && key == 'f';
}

//Runs twice to mirror, this is where to put things you want to draw.
void drawThings() {
  stroke(0, 100);
  dispEdgesCommunities();
  /*
  if(!showField) {
    stroke(255, 0, 0);
    pLine(ffIntToSpace(new PVector(0, 0, 0)), ffIntToSpace(new PVector(ffRes, 0, 0)));
    stroke(0, 255, 0);
    pLine(ffIntToSpace(new PVector(0, 0, 0)), ffIntToSpace(new PVector(0, ffRes, 0)));
    stroke(0, 0, 255);
    pLine(ffIntToSpace(new PVector(0, 0, 0)), ffIntToSpace(new PVector(0, 0, ffRes)));
  }
  */
}

//Simple display, a point at every node.
void dispNodePoints() {
  for(Node n : network)
    point(n.position.x, n.position.y, n.position.z);
}

//Displays the BRAND NEW muscle coordinates with NO BAD HAND STUFF.
void correctHands() {
  float bound = 330;
  for(int i = 0; i < edgenet.size(); i++) {
    if(edgenet.get(i).position.x < bound) {
      PVector sum = new PVector();
      for(int k : edgenet.get(i).connectedVerts) {
        sum.add(network.get(k).position);
      }
      sum.mult(1.0f/float(edgenet.get(i).connectedVerts.size()));
      edgenet.get(i).position = sum;
    }
  }
  saveMuscleCoords("handCorrectedCoords.csv");
}

//Saves whatever is in the edge array to a new file given by the input string.
void saveMuscleCoords(String location) {
  String[] strout = new String[edgenet.size()+1];
  strout[0] = "# Auto-generated save file.";
  for(int i = 0; i < edgenet.size(); i++) {
    strout[i+1] = edgenet.get(i).position.x + "," + edgenet.get(i).position.y + "," + edgenet.get(i).position.z;
  }
  saveStrings(location, strout);
}

//Draws lines between bone and muscle coordinates, displays the bipartite graph.
void dispEdgesCommunities() {
  float fadeBorder = 180;
  float fadeSpeed = 80.0f;
  stroke(0, 100);
  strokeWeight(0.9f);
  for(Edge e : edgenet) {
    beginShape(LINES);
    for(int i : e.connectedVerts) {
      PVector q = network.get(i).position;
      stroke(0, 0, 0, min(100, (fadeBorder-q.y)*fadeSpeed+100));
      vertex(q.x, q.y, q.z);
      stroke(0, 0, 0, min(100, (fadeBorder-e.position.y)*fadeSpeed));
      vertex(e.position.x, e.position.y, e.position.z);
    }
    endShape(CLOSE);
  }
  strokeWeight(6);
  
  /*
  stroke(255, 0, 0);
  line(camFocus.x, camFocus.y, camFocus.z, camFocus.x+500, camFocus.y, camFocus.z);
  stroke(0, 255, 0);
  line(camFocus.x, camFocus.y, camFocus.z, camFocus.x, camFocus.y+500, camFocus.z);
  stroke(0, 0, 255);
  line(camFocus.x, camFocus.y, camFocus.z, camFocus.x, camFocus.y, camFocus.z+500);
  */
  
  /*
  for(Node n : network) {
    stroke(0, 0, 0, min(255, (fadeBorder-n.position.y)*255.0f/100.0f*fadeSpeed));
    point(n.position.x, n.position.y, n.position.z);
  }
  for(Edge n : edgenet) {
    stroke(255, 0, 0, min(255, (fadeBorder-n.position.y)*255.0f/100.0f*fadeSpeed));
    point(n.position.x, n.position.y, n.position.z);
  }
  */
}

//Draws lines between bone and muscle coordinates, displays the bipartite graph. The red end of each line is a muscle coordinate, and the blue end is a bone coordinate.
void dispEdgesBasic() {
  for(Edge e : edgenet) {
    beginShape(LINES);
    for(int i : e.connectedVerts) {
      PVector q = network.get(i).position;
      stroke(0, 0, 255);
      vertex(q.x, q.y, q.z);
      stroke(255, 0, 0);
      vertex(e.position.x, e.position.y, e.position.z);
    }
    endShape(CLOSE);
  }
}

//Displays the springs in the dot-line-dot-line-dot fashion.
void dispEdgesSpring() {
  for(Edge e : edgenet)
    e.display();
}

//Displays the springs using curveVertex() and no dots.
void dispEdgesSpringCurve() {
  for(Edge e : edgenet)
    e.displayCurve();
}

//Cycles through and calculates the physics for each spring vertex in each edge.
void updateSpringPhysics() {
  for(Edge e : edgenet)
    e.springPhys();
}

void dispForceField() {
  float s = 600.0f;
  noStroke();
  hint(DISABLE_DEPTH_TEST);
  blendMode(ADD);
  for(int x = 0; x < ffRes; x++)
    for(int y = 0; y < ffRes; y++)
      for(int z = 0; z < ffRes; z++) {
        pushMatrix();
        PVector coord = ffIntToSpace(new PVector(x, y, z));
        fill(forceField[x][y][z].x*s, forceField[x][y][z].y*s, forceField[x][y][z].z*s);
        translate(coord.x, coord.y, coord.z);
        box(fieldMult, fieldMult, fieldMult);
        popMatrix();
      }
}

void calculateForceField() {
  println("Beginning calculation...");
  for(int x = 0; x < ffRes; x++)
    for(int y = 0; y < ffRes; y++)
      for(int z = 0; z < ffRes; z++) {
        forceField[x][y][z] = new PVector();
        PVector focusCoord = ffIntToSpace(new PVector(x, y, z));
        for(Node n : network) {
          PVector toNode = PVector.sub(n.position, focusCoord);
          toNode.normalize();
          float r = PVector.dist(n.position, focusCoord);
          r = max(r, 5.0f);
          toNode.mult(200.0f/(r*r));
          
          forceField[x][y][z].add(toNode);
        }
        forceField[x][y][z].mult(1.0f/float(network.size()));
      }
  println("Force field created.");
}

PVector ffIntToSpace(PVector v) {
  return PVector.add(PVector.mult(v, fieldMult), PVector.add(camFocus, camFocusAdd));
}

PVector ffSpaceToInt(PVector v) {
  return PVector.mult(PVector.sub(v, PVector.add(camFocus, camFocusAdd)), 1.0f/fieldMult);
}

//Simple camera controls.
void runCamControls() {
  if(showField) background(0); else background(255);
  if(showField) stroke(255); else stroke(0);
  lights();
  scale(cameraZoom);
  translate(width/2/cameraZoom, height/2/cameraZoom);
  //rotateY(map(mouseX*2,0,width,-PI,PI));
  //rotateX(map(mouseY*2,0,height,-PI,PI));
  rotateY(-PI);
  rotateX(PI/2);
  if(keyPressed && key != CODED && key == 'w')
    camFocus.z++;
  if(keyPressed && key != CODED && key == 's')
    camFocus.z--;
  if(keyPressed && key != CODED && key == 'a')
    camFocus.x--;
  if(keyPressed && key != CODED && key == 'd')
    camFocus.x++;
  if(keyPressed && key != CODED && key == 'e')
    camFocus.y++;
  if(keyPressed && key != CODED && key == 'q')
    camFocus.y--;
  translate(-camFocus.x, -camFocus.y, -camFocus.z);
  hint(DISABLE_DEPTH_TEST);
}

//Camera controls in reverse, run pushMatrix() before runCamControls(), then popMatrix after, then this function, then display again.
void runCamControlsMirror() {
  if(showField) stroke(255); else stroke(0);
  scale(cameraZoom);
  translate(width/2/cameraZoom, height/2/cameraZoom);
  //rotateY(map(mouseX*2,0,width,-PI,PI));
  //rotateX(map(mouseY*2,0,height,-PI,PI));
  rotateY(-PI);
  rotateX(PI/2);
  scale(-1, 1, 1);
  translate(-camFocus.x, -camFocus.y, -camFocus.z);
}

//Prints out all 3 components of a PVector to the command line.
void printVec(PVector v) {
  println("X: " + v.x + " Y: " + v.y + " Z: " + v.z);
}

//Calculates the camera focus by averaging all the bone coords.
void calcCamFocus() {
  PVector avg = new PVector();
  for(Node n : network)
    avg.add(n.position);
  avg.mult(1.0f/network.size());
  camFocus = avg;
}

//Loads the bipartite array.
void loadBipartiteData(String location) {
  println("Loading bipartite data from: " + location);
  network = new ArrayList<Node>();
  edgenet = new ArrayList<Edge>();
  String[] data = loadStrings(location);
  int edgeNetSize = 0;
  
  //This just figures out the number of columns in the array (the number of edges).
  for(int i = 0; i < data.length; i++)
    if(!data[i].startsWith("#")) //If it starts with a hashtag, ignore it. Python-style comments ftw.
      edgeNetSize = data[i].split(",").length;
  
  //Add a bunch of empty edges into the array.
  for(int i = 0; i < edgeNetSize; i++)
    edgenet.add(new Edge()); 
  
  //Add a bunch of empty nodes into the array.
  for(int i = 0; i < data.length; i++)
    if(!data[i].startsWith("#"))
      network.add(new Node());
  
  int cLine = 0; //This is used to keep indexing consistent when comments are involved.
  for(int i = 0; i < data.length; i++) {
    if(!data[i].startsWith("#")) {
      parseLine(data[i].split(","), cLine); //Send the data over to another function.
      cLine++;
    } else
      println("\t" + data[i].substring(1)); //Print the comments, they could be important!
  }
}

//Loads the node coordinate data (in this case, bone coordinates).
void loadNodeCoordinateData(String location) {
  println("Loading node coordinate data from: " + location);
  String[] data = loadStrings(location);
  int cLine = 0; //Keeps indexing consistent when comments are involved.
  for(int i = 0; i < data.length; i++) {
    if(!data[i].startsWith("#")) {
      //Just split apart the xyz values and use them, hoping that everything is ordered correctly.
      String[] vals = data[i].split(",");
      float x = Float.parseFloat(vals[0]);
      float y = Float.parseFloat(vals[1]);
      float z = Float.parseFloat(vals[2]);
      network.get(cLine).setPosition(x, y, z);
      cLine++;
    } else
      println("\t" + data[i].substring(1));
  } 
}

//Loads the edge coordinate data (in this case, muscle coordinates).
void loadEdgeCoordinateData(String location) {
  println("Loading edge coordinate data from: " + location);
  String[] data = loadStrings(location);
  int cLine = 0; //Keeps indexing consistent when comments are involved.
  for(int i = 0; i < data.length; i++) {
    if(!data[i].startsWith("#")) {
      //Just split apart the xyz values and use them, hoping that everything is ordered correctly.
      String[] vals = data[i].split(",");
      float x = Float.parseFloat(vals[0]);
      float y = Float.parseFloat(vals[1]);
      float z = Float.parseFloat(vals[2]);
      edgenet.get(cLine).setPosition(x, y, z);
      cLine++;
    } else
      println("\t" + data[i].substring(1));
  } 
}

void loadCommunityData(String location) {
    println("\nLoading community assignment data from: " + location);
    String[] data = loadStrings(location);
    int cLine = 0;
    for(int i = 0; i < data.length; i++) {
      if(!data[i].startsWith("#")) {
        String[] vals = data[i].split(",");
        int id = Integer.parseInt(vals[0]);
        int community = Integer.parseInt(vals[2]);
        edgenet.get(id-1).setCommunity(community);
        edgenet.get(id-1).setName(vals[1]);
        cLine++;
      } else
        println("\t" + data[i].substring(1));
    }
}

//This just lets the edges start up their springs.
void addEdgeSprings() {
  for(int i = 0; i < edgenet.size(); i++)
    edgenet.get(i).addSprings();
}

//Prints all the connections of each edge.
void printEdgeConnections() {
  for(Edge e : edgenet) {
    for(int i : e.connectedVerts)
      print(i + " ");
    print("\n");
  }
}

//This function takes in the split String[] of a single row from the bipartite file and figures out what to do with it.
void parseLine(String[] s, int row) {
  for(int i = 0; i < s.length; i++) {
    int item = Integer.parseInt(s[i]); //A 0-1 value.
    if(item == 1) {
      //If it's one, we tell the edge where the node is and the node where the edge is.
      edgenet.get(i).addNode(row);
      network.get(row).degree++;
    }
  }
}

//The hyper-edge class that holds springs, connected nodes, and a position. I'm treating it all like a bipartite graph because it's easier to program that way (I'm not sure if there is another way).
public class Edge {
  ArrayList<Integer> connectedVerts = new ArrayList<Integer>(); //A list of all the ids of the connected nodes.
  ArrayList<Spring> springs = new ArrayList<Spring>(); //A list of springs the same size as connectedVerts.
  int id = -1; //The edge's index in the edgenet list.
  int degree = -1; //The degree of the edge.
  int commAssignment = 0;
  PVector position = new PVector(0, 0, 0);
  String name = "";
  
  //Our regular constructor sets the id to what it should be.
  public Edge() {
    id = edgenet.size();
    degree = 0;
  }
  
  //I have no idea why you would want to use this.
  public Edge(int k) {
    id = k;
    degree = 0;
  }
  
  //This adds a node to the edge and increases the edge's degree.
  public void addNode(int id) {
    connectedVerts.add(id);
    degree++;
  }
  
  //This sets up new springs connected from the edge's position to all of it's connected vertices.
  public void addSprings() {
    for(int k : connectedVerts)
      springs.add(new Spring(position, network.get(k).position));
  }
  
  public void setCommunity(int k) {
    commAssignment = k;
  }
  
  public void setName(String s) {
    name = new String(s.toCharArray());
  }
  
  //Sets 3D coordinate.
  public void setPosition(PVector pos) {
    position = pos;
  }
  
  //setPosition() overload taking 3 floats instead of a PVector.
  public void setPosition(float x, float y, float z) {
    position = new PVector(x, y, z);
  }
  
  //Displays the springs in the dot-line-dot-line-dot fashion.
  public void display() {
    for(int i = 0; i < springs.size(); i++)
      springs.get(i).display();
  }
  
  //Displays the springs using curveVertex() with no dots at the spring corners.
  public void displayCurve() {
    for(int i = 0; i < springs.size(); i++)
      springs.get(i).displayCurve();
  }
  
  //Cycles through all springs and does the physics for 'em.
  public void springPhys() {
    for(int i = 0; i < springs.size(); i++)
      springs.get(i).doPhys();
  }
}

//A short node class, holding a degree, id, and position.
public class Node {
  int id = -1; //The node's index in the network list.
  int degree = -1;
  PVector position = new PVector(0, 0, 0);
  
  //Sets the index to what it should be and switches degree to a non-error code.
  public Node() {
    id = network.size();
    degree = 0;
  }
  
  //I have no idea why anyone would want to use this, either.
  public Node(int id) {
    this.id = id;
    degree = 0;
  }
  
  //Sets position.
  public void setPosition(PVector pos) {
    position = pos;
  }
  
  //setPosition() overload taking 3 floats instead of a PVector.
  public void setPosition(float x, float y, float z) {
    position = new PVector(x, y, z);
  }
}

//Spring class for doing bendy lines.
public class Spring {
  PVector[] parts = new PVector[springRes]; //List of all the vertices in the spring.
  PVector[] partsVel = new PVector[springRes]; //List of the velocities of all the vertices in the spring.
  float regDist = 0.0f;
  
  //Sets up a spring with a start and end vector.
  public Spring(PVector start, PVector end) {
    for(int i = 0; i < parts.length; i++) {
      parts[i] = mix(float(i)/float(parts.length-1), start, end); //mix() the start and end to get the "ideal" regular coordinate.
      partsVel[i] = new PVector();
    }
    regDist = PVector.dist(start, end)/float(parts.length); //Find the regular "resting" distance.
  }
  
  //Displays itself in the dot-line-dot-line-dot fashion.
  void display() {
    hint(DISABLE_DEPTH_TEST);
    for(int i = 1; i < parts.length; i++) {
      line(parts[i-1].x, parts[i-1].y, parts[i-1].z, parts[i].x, parts[i].y, parts[i].z);
    }
    strokeWeight(3); //Make the dots a little larger than the lines to stand out just a bit.
    for(int i = 0; i < parts.length; i++)
      if(i == 0 || i == parts.length - 1) point(parts[i].x, parts[i].y, parts[i].z);
    strokeWeight(1);
  }
  
  //Displays itself with curveVertex();
  void displayCurve() {
    beginShape(POLYGON); //It draws an unclosed polygon with no fill to make a line (have to do this with curveVertex()).
    noFill();
    curveVertex(parts[0].x, parts[0].y, parts[0].z); //Have to call this twice for some reason (probably curveVertex() finding second derivative).
    curveVertex(parts[0].x, parts[0].y, parts[0].z);
    for(int i = 1; i < parts.length; i++)
      curveVertex(parts[i].x, parts[i].y, parts[i].z);
    curveVertex(parts[parts.length-1].x, parts[parts.length-1].y, parts[parts.length-1].z);
    endShape();
  }
  
  //Figure out physics with Hooke's law.
  void doPhys() {
    for(int i = 1; i < parts.length-1; i++) {
      if(gravity) partsVel[i].add(new PVector(0, 0, -0.15));
      if(fieldActive) {
        PVector p = ffSpaceToInt(parts[i]);
        partsVel[i].add(getTrilinear(forceField, p.x, p.y, p.z, ffRes, ffRes, ffRes));
      }
      
      //copyVec() so we don't change anything!
      PVector current = copyVec(parts[i]);
      PVector ahead = copyVec(parts[i+1]);
      PVector behind = copyVec(parts[i-1]);
      
      //Calculate force between itself and the node a space ahead.
      float d0 = PVector.dist(current, ahead);
      float x0 = d0 - regDist; //Returning force proportional to displacement.
      //Find the target direction.
      PVector dir0 = PVector.sub(ahead, current);
      dir0.normalize();
      dir0.mult(x0*springStrength); //Multiply direction by force.
      partsVel[i].add(dir0); //Add acceleration to velocity.
      
      //Calculate force between itself and the node a space behind (same as above, using behind instead of ahead).
      float d1 = PVector.dist(current, behind);
      float x1 = d1 - regDist;
      PVector dir1 = PVector.sub(behind, current);
      dir1.normalize();
      dir1.mult(x1*springStrength);
      partsVel[i].add(dir1);
      
      parts[i].add(partsVel[i]); //Add velocity to position.
      partsVel[i].mult(1.0f-springDamp); //Dampen velocity using unorthodox methods.
    }
  }
}

//Similar to GLSL's mix, blends two PVectors based on a number from 0-1. 0 = closer to a, 1 = closer to b.
PVector mix(float x, PVector a, PVector b) {
  float tx = a.x * (1.0f - x) + b.x * x;
  float ty = a.y * (1.0f - x) + b.y * x;
  float tz = a.z * (1.0f - x) + b.z * x;
  return new PVector(tx, ty, tz);
}

//Just copies a PVector to another one, Java passes by reference (sort of), so this is useful when you don't want to modify your function arguments.
PVector copyVec(PVector x) {
  return new PVector(x.x, x.y, x.z);
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

//Trilinearly interpolates a PVector[][][] with length (maxX, maxY, maxZ) at coordinates (x, y, z).
PVector getTrilinear(PVector[][][] arr, float x, float y, float z, int maxX, int maxY, int maxZ) {
  //Calculate corner coordinates of cube.
  int lowX = floor(x); int lowY = floor(y); int lowZ = floor(z);
  int highX = ceil(x); int highY = ceil(y); int highZ = floor(z);
  
  //If the sample point is out of bounds, return an empty vector.
  if(lowX < 0 || lowY < 0 || lowZ < 0 || highX >= maxX || highY >= maxY || highZ >= maxZ) 
    return new PVector();
  
  //Take sample points with copyVec() so java doesn't modify the actual array values.
  PVector samp_000 = copyVec(arr[lowX][lowY][lowZ]);
  PVector samp_010 = copyVec(arr[lowX][highY][lowZ]);
  PVector samp_100 = copyVec(arr[highX][lowY][lowZ]);
  PVector samp_110 = copyVec(arr[highX][highY][lowZ]);
  
  PVector samp_001 = copyVec(arr[lowX][lowY][highZ]);
  PVector samp_011 = copyVec(arr[lowX][highY][highZ]);
  PVector samp_101 = copyVec(arr[highX][lowY][highZ]);
  PVector samp_111 = copyVec(arr[highX][highY][highZ]);
  
  //Find the volume of the rectangular prisims in the opposite corners.
  float mul_000 = (float(highX)-x)*(float(highY)-y)*(float(highZ)-z);
  float mul_010 = (float(highX)-x)*(y-float(lowY))*(float(highZ)-z);
  float mul_100 = (x-float(lowX))*(float(highY)-y)*(float(highZ)-z);
  float mul_110 = (x-float(lowX))*(y-float(lowY))*(float(highZ)-z);
  
  float mul_001 = (float(highX)-x)*(float(highY)-y)*(z-float(lowZ));
  float mul_011 = (float(highX)-x)*(y-float(lowY))*(z-float(lowZ));
  float mul_101 = (x-float(lowX))*(float(highY)-y)*(z-float(lowZ));
  float mul_111 = (x-float(lowX))*(y-float(lowY))*(z-float(lowZ));
  
  //Multiply our sample points by their corresponding prisims.
  samp_000.mult(mul_000);
  samp_010.mult(mul_010);
  samp_100.mult(mul_100);
  samp_110.mult(mul_110);
  
  samp_000.mult(mul_001);
  samp_010.mult(mul_011);
  samp_100.mult(mul_101);
  samp_110.mult(mul_111);
  
  PVector sum = new PVector();
  
  //Add all the values to the output vector and return it (we don't need to normalize anything, the cube has a volume of one).
  sum.add(samp_000);
  sum.add(samp_010);
  sum.add(samp_100);
  sum.add(samp_110);
  
  sum.add(samp_001);
  sum.add(samp_011);
  sum.add(samp_101);
  sum.add(samp_111);
  return sum;
}
