//Hypergraph visualization code for muscle/bone networks//

//Dampening coefficent - 1.0
//Iterations - 100
//Displacing by 200.0 units

float zmult = 0.9f;
float cameraZoom = 1.43f*zmult; //Camera's zoom.
PVector camFocus = new PVector(); //Camera's focus point (in pixels).

ArrayList<Node> network = new ArrayList<Node>(); //Node list.
ArrayList<Edge> edgenet = new ArrayList<Edge>(); //Edge list.

PVector camFocusAdd = new PVector(-150, -150, -400);

//------------------------------//
//If none of these values are set to true, targetNode wil be displaced for iterations iterations.
boolean calculateValues = false; //This displaces each node in the network with different cutoff values (not important anymore).
boolean calculateValues2 = false; //This will displace each node in the network and find the net impact each node has on the network.
boolean calculateValues3 = true; //This will displace each edge in the network and find the net impact each edge has on the network.

boolean fixMidpoints = true; //Set to false to free the system.
boolean dispW = true;

float timePassed = 0.0f;
float deltaTime = 0.1f; //dt
float dampeningCoefficent = 1.0f; //β
float springForce = 1.0f; //k
int iterations = 100;

int targetNode = 0;
int targetEdge = 0;
float displacementAmount = 200.0f;

//------------------------------//
float cutoff = 0.25f;
//------------------------------//

//Drawing stuff
boolean useMinMax = true;
float[] importanceValues;
float minImportance = 0.0f;
float maxImportance = 302.102f;
int framesPassed = 0;

PImage gradient;
//------------------------------//

float mCutoff = 0.0f;
float xCutoff = 25.0f;
float dCutoff = 0.25f;

float effectCutoff = 0.0f;

ArrayList<PVector> displacementList = new ArrayList<PVector>();

//------------------------------//

void setup() {
  //P3D is faster than OpenGL and can be exported easily.
  size(int(1200*zmult), int(1000*zmult), P3D);
  
  //Load data into the lists.
  
  //loadBipartiteData("bipartite.csv");
  loadBipartiteData("data/newPermHypergraphs/", 0);
  loadNodeCoordinateData("boneCoords.csv");
  loadEdgeCoordinateData("handCorrectedMuscleCoords.csv");
  gradient = loadImage("gradient.jpg");
  loadCommunityData("CommunityAssignments.csv");
  String[] s = loadStrings("data/newPermHypergraphs/permHypergraphs1.txt");
  
  
  String[][] sF = new String[s.length][s[4].split(" ").length];
  for(int i = 0; i < s.length; i++) {
    sF[i] = s[i].split(" ");
  }
  for(int i = 0; i < sF[0].length; i++) {
    int j = 0;
    for(int k = 0; k < sF.length; k++) {
      if(sF[k][i].equals("1"))
        j++;
    }
  }
  
  println("\n");
  
  importanceValues = new float[network.size()];
  
  calcCamFocus();
  
  physicsSetup();
  
  //smooth(8);
  
  if(calculateValues3) println("degree\timpact");
}

void draw() {
  background(255);
  doThings();
  
  //Drawing things slows everything down a bit.
  //ortho();
  pushMatrix();
  runCamControls();
  drawThings();
  popMatrix();
  pushMatrix();
  runCamControlsMirror();
  drawThings();
  popMatrix();
  runCamControls();
  stroke(255, 0, 0, 255);
  line(camFocusAdd.x + 500, camFocusAdd.y + 200, camFocusAdd.z - 200, camFocusAdd.x + 600, camFocusAdd.y + 200, camFocusAdd.z - 200);
  stroke(0, 255, 0);
  line(camFocusAdd.x + 500, camFocusAdd.y + 200, camFocusAdd.z - 200, camFocusAdd.x + 500, camFocusAdd.y + 100 + 200, camFocusAdd.z - 200);
  stroke(0, 0, 255);
  line(camFocusAdd.x + 500, camFocusAdd.y + 200, camFocusAdd.z - 200, camFocusAdd.x + 500, camFocusAdd.y + 200, camFocusAdd.z - 200 + 100);
}

//Returns the minimum of the input vector and the vector (b, b, b).
PVector pMin(PVector a, float b) {
  return new PVector(min(a.x, b), min(a.y, b), min(a.z, b));
}

//Simple vector multiplication. (Hadamard product)
PVector pMult(PVector a, PVector b) {
  return new PVector(a.x*b.x, a.y*b.y, a.z*b.z);
}

//Draws a line from PVector a to PVector b.
void pLine(PVector a, PVector b) {
  line(a.x, a.y, a.z, b.x, b.y, b.z);
}

//This IS used to get the "error" of the network.
float getError() {
  float sum = 0.0f;
  for(Node n : network)
    sum += dist(n.physPos.x, n.physPos.y, n.physPos.z, n.position.x, n.position.y, n.position.z);
  return sum;
}

//This returns the "error" of the network where each node
float getErrorCutoff() {
  float sum = 0.0f;
  for(Node n : network)
    sum += (dist(n.physPos.x, n.physPos.y, n.physPos.z, n.position.x, n.position.y, n.position.z) > cutoff) ? 1.0f : 0.0f;
  return sum;
}

float distance(float x, float y, float z, float w, float xx, float yy, float zz, float ww) {
  return sqrt((xx-x)*(xx-x) + (yy-y)*(yy-y) + (zz-z)*(zz-z) + (ww-w)*(ww-w));
}

void physicsSetup() {
  for(Node n : network) n.setUpPhys();
}

void updatePhysics() {
  if(calculateValues3)
    for(int i : edgenet.get(targetEdge).connectedVertices) {
      //network.get(i).physPos.setW(displacementAmount/float(edgenet.get(targetEdge).connectedVertices.size()));
      network.get(i).physPos.setW(displacementAmount);
    }
  else
    network.get(targetNode).physPos.setW(displacementAmount);
  
  for(Node n : network) n.physCalculate();
  for(Node n : network) n.physIntegrate();
  timePassed += deltaTime;
  
  if(calculateValues3)
    for(int i : edgenet.get(targetEdge).connectedVertices) {
      //network.get(i).physPos.setW(displacementAmount/float(edgenet.get(targetEdge).connectedVertices.size()));
      network.get(i).physPos.setW(displacementAmount);
    }
  else
    network.get(targetNode).physPos.setW(displacementAmount);
}

int getEffectedNodes() {
  int o = 0;
  for(int i = 0; i < network.size(); i++) {
    if(dist(network.get(i).physPos.x, network.get(i).physPos.y, network.get(i).physPos.z, network.get(i).position.x, network.get(i).position.y, network.get(i).position.z) >= effectCutoff)
      o++;
  }
  return o;
}


ArrayList<String> correlationOut = new ArrayList<String>();
int current_dataset = 0;
//Runs once, this is where to put per-frame operations (physics, updates, etc.).
void doThings() {
  if(keyPressed) physicsSetup();
  
  if(calculateValues) {
    if(framesPassed == 1) {
      println("\nStarting Calculation!");
      for(float i = mCutoff; i <= xCutoff; i += i/10.0f+0.01f) {
        float avgE = 0.0f;
        effectCutoff = i;
        print("\n::" + effectCutoff + ":");
        for(int j = 0; j < network.size(); j++) {
          if(j%5==0) print(":" + j);
          targetNode = j;
          physicsSetup();
          for(int k = 0; k < iterations; k++)
            updatePhysics();
          avgE += (float)getEffectedNodes();
        }
        avgE /= (float)network.size();
        print("    " + avgE);
        displacementList.add(new PVector(effectCutoff, avgE));
      }
      println("\nCalculation Finished!");
      saveDisplacement("Displacement_Values-" + year() + "-" + month() + "-" + day() + "-" + hour() + "-" + minute() + "-" + second() + "-" + millis() + ".csv");
      print("\n");
    }
  } else if(calculateValues2) {
    if(framesPassed == 1) {
      for(int j = 0; j < network.size(); j++) {
        targetNode = j;
        physicsSetup();
        for(int k = 0; k < iterations; k++)
          updatePhysics();
        println(network.get(targetNode).degree + "\t" + getErrorCutoff()/* + "\t" + getError()*/);
      }
    }
  } else if(calculateValues3) {
    if(framesPassed < edgenet.size()) {
      //if(framesPassed%5==0)
        //print(framesPassed + ":");
      targetEdge = framesPassed;
      physicsSetup();
      for(int k = 0; k < iterations; k++)
        updatePhysics();
      println(edgenet.get(targetEdge).degree + "\t" + getError());
      correlationOut.add(edgenet.get(targetEdge).degree + ", " + getError());
    } else {
      println("\n\n" + correlationOut.size() + " " + edgenet.size() + "\n\n");
      println(correlationOut);
      framesPassed = -1;
      String[] x = new String[correlationOut.size()];
      for(int j = 0; j < x.length; j++) {
        x[j] = new String(correlationOut.get(j).toCharArray());
      }
      saveStrings("output/c_" + current_dataset + ".csv", x);
      current_dataset++;
      correlationOut = new ArrayList<String>();
      loadBipartiteData("randomBipartite.csv", current_dataset);
      loadNodeCoordinateData("boneCoords.csv");
      loadEdgeCoordinateData("handCorrectedMuscleCoords.csv");
      loadCommunityData("CommunityAssignments.csv");
      physicsSetup();
      print("\n" + current_dataset + "-");
    }
  } else {
    if(mousePressed && mouseButton == RIGHT)
      updatePhysics();
    for(int i = 0; i < importanceValues.length; i++)
      importanceValues[i] = dist(network.get(i).physPos.x, network.get(i).physPos.y, network.get(i).physPos.z, network.get(i).position.x, network.get(i).position.y, network.get(i).position.z);
    println(getError());
  }
  if(useMinMax) calcMinMaxImportance();
  framesPassed++;
}

void calcMinMaxImportance() {
  minImportance = 10000000.0f;
  maxImportance = 0.0f;
  for(float f : importanceValues) {
    if(f < minImportance) minImportance = f;
    if(f > maxImportance) maxImportance = f;
  }
}

void saveStress(String location) {
  println("Saving stress values to " + location + "...");
  String[] data = new String[importanceValues.length+1];
  data[0] = "# Bone 'importance' values.";
  for(int i = 0; i < importanceValues.length; i++)
    data[i+1] = importanceValues[i] + "";
  saveStrings(location, data);
  println("Stress values saved!");
}

void dispNetworkElasticImportance() {
  for(int i = 0; i < network.size(); i++) {
    stroke(getColor(i, 255));
    if(dispW)
      point(network.get(i).physPos.x, network.get(i).physPos.w, network.get(i).physPos.z);
    else
      point(network.get(i).physPos.x, network.get(i).physPos.y, network.get(i).physPos.z);
  }
  colorMode(RGB);
}

color getColor(int nodeID, float alpha) {
  color c = gradient.pixels[max(0, min(round(map(importanceValues[nodeID], minImportance, maxImportance, -200, 1600)), gradient.pixels.length-1))];
  //c = color(importanceValues[nodeID], alpha/3.0f);
  c = color(255, 255, 255, alpha);
  return color(r(c), g(c), b(c), alpha);
}

void dispNetworkElasticImportanceEdges() {
  beginShape(LINES);
  for(Edge e : edgenet)
    for(int i : e.connectedVertices)
      for(int k : e.connectedVertices) {
        VecN v1 = network.get(i).physPos;
        VecN v2 = network.get(k).physPos;
        stroke(getColor(i, 155.0f/(float)e.connectedVertices.size()));
        if(dispW)
          vertex(v1.x, v1.w, v1.z);
        else
          vertex(v1.x, v1.y, v1.z);
        stroke(getColor(k, 155.0f/(float)e.connectedVertices.size()));
        if(dispW)
          vertex(v2.x, v2.w, v2.z);
        else
          vertex(v2.x, v2.y, v2.z);
      }
  endShape();
}

void dispNetworkPaper() {
  stroke(0, 25);
  strokeWeight(1.f/zmult);
  for(Edge e : edgenet) {
    for(int i = 0; i < e.connectedVertices.size(); i++)
      for(int k = 0; k < i; k++) {
        VecN v1 = network.get(e.connectedVertices.get(i)).physPos;
        VecN v2 = network.get(e.connectedVertices.get(k)).physPos;
        line(v1.x, v1.y, v1.z, v2.x, v2.y, v2.z);
      }
  }
}

//Runs twice to mirror, this is where to put things you want to draw.
void drawThings() {
  //ortho();
  dispNetworkPaper();
  hint(DISABLE_DEPTH_TEST);
  stroke(0, 255);
  strokeWeight(7.f);
  dispNodePoints();
  stroke(255, 255);
  strokeWeight(4.f);
  dispNodePoints();
  strokeWeight(1);
}

//Simple display, a point at every node.
void dispNodePoints() {
  for(Node n : network)
    point(n.physPos.x, n.physPos.y, n.physPos.z);
}

//Saves whatever is in the edge array to a new file given by the input string.
void saveMuscleCoords(String location) {
  println("Saving muscle coordinates to " + location + "...");
  String[] strout = new String[edgenet.size()+1];
  strout[0] = "# Auto-generated save file.";
  for(int i = 0; i < edgenet.size(); i++)
    strout[i+1] = edgenet.get(i).position.x + "," + edgenet.get(i).position.y + "," + edgenet.get(i).position.z;
  saveStrings(location, strout);
  println("Muscle coordinates saved!");
}

void saveDisplacement(String location) {
  println("Saving displacement values to " + location + "...");
  ArrayList<String> lout = new ArrayList<String>();
  lout.add("val, affected");
  for(PVector p : displacementList)
    lout.add(p.x + ", " + p.y);
  String[] strout = new String[lout.size()];
  for(int i = 0; i < strout.length; i++)
    strout[i] = lout.get(i);
  saveStrings(location, strout);
  println("Displacement values saved!");
}

//Draws lines between bone and muscle coordinates, displays the bipartite graph.
void dispEdgesBasic() {
  stroke(0, 100);
  strokeWeight(1);
  for(Edge e : edgenet) {
    beginShape(LINES);
    for(int i : e.connectedVertices) {
      VecN q = network.get(i).position;
      line(q.x, q.w, q.z, e.position.x, e.position.y, e.position.z);
    }
    endShape(CLOSE);
  }
  strokeWeight(4);
  stroke(255, 0, 0);
  for(Node n : network)
    point(n.position.x, n.position.y, n.position.z);
  stroke(0);
  for(Edge n : edgenet)
    point(n.position.x, n.position.y, n.position.z);
}

void dispNetworkPhys() {
  stroke(0, 15);
  strokeWeight(1);
  for(Edge e : edgenet)
    for(int i : e.connectedVertices)
      for(int k : e.connectedVertices)
        if(i != k) {
          VecN v0 = network.get(i).physPos;
          VecN v1 = network.get(k).physPos;
          if(dispW)
            line(v0.x, v0.w, v0.z, v1.x, v1.w, v1.z);
          else
            line(v0.x, v0.y, v0.z, v1.x, v1.y, v1.z);
        }
  stroke(0);
  strokeWeight(4);
  for(Node n : network)
    if(dispW)
      point(n.physPos.x, n.physPos.w, n.physPos.z);
    else
      point(n.physPos.x, n.physPos.y, n.physPos.z);
  strokeWeight(1);
  stroke(255, 0, 0);
  for(Node n : network)
    if(dispW)
      line(n.physPos.x, n.physPos.w, n.physPos.z, n.position.x, n.position.w, n.position.z);
    else
      line(n.physPos.x, n.physPos.y, n.physPos.z, n.position.x, n.position.y, n.position.z);
  stroke(0);
}

//Simple camera controls.
void runCamControls() {
  lights();
  scale(cameraZoom);
  translate(width/2/cameraZoom, height/2/cameraZoom);
  rotateY(map(framesPassed*2,0,width,-PI,PI));
  rotateX(map(0,0,height,PI/2,PI));
  translate(-camFocus.x, -camFocus.y, -camFocus.z);
}

//Camera controls in reverse, run pushMatrix() before runCamControls(), then popMatrix after, then this function, then display again.
void runCamControlsMirror() {
  scale(cameraZoom);
  translate(width/2/cameraZoom, height/2/cameraZoom);
  rotateY(map(framesPassed*2,0,width,-PI,PI));
  rotateX(map(0,0,height,PI/2,PI));
  scale(-1, 1, 1);
  translate(-500, -camFocus.y, -camFocus.z);
}

//Prints out all 3 components of a PVector to the command line.
void printVec(PVector v) {
  println("X: " + v.x + " Y: " + v.y + " Z: " + v.z);
}

//Calculates the camera focus by averaging all the bone coords.
void calcCamFocus() {
  VecN avg = new VecN(0, 0, 0);
  for(Node n : network)
    avg.addition(n.position);
  avg.multiply(1.0f/network.size());
  camFocus = avg.toPVector();
}

//Loads the bipartite array.
void loadBipartiteData(String location) {
  //println("Loading bipartite data from: " + location);
  network = new ArrayList<Node>();
  edgenet = new ArrayList<Edge>();
  String[] data = loadStrings(location);
  int edgeNetSize = 0;
  
  //This just figures out the number of columns in the array (the number of edges).
  for(int i = 0; i < data.length; i++)
    if(!data[i].startsWith("#")) //If it starts with a hashtag, ignore it. Python-style comments ftw.
      edgeNetSize = data[i].split(" ").length;
  
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
      parseLine(data[i].split(" "), cLine); //Send the data over to another function.
      cLine++;
    } //else
      //println(data[i].substring(1)); //Print the comments, they could be important!
  }
}

//Loads the bipartite array from David's mega .txt
void loadBipartiteData(String location, int index) {
  
  println("Loading bipartite data from: " + "data/newPermHypergraphs/permHypergraphs" + (index) + ".txt");
  network = new ArrayList<Node>();
  edgenet = new ArrayList<Edge>();
  loadBipartiteData("data/newPermHypergraphs/permHypergraphs" + (index) + ".txt");
  /*
  String[] fromFile = loadStrings(location);
  String q = fromFile[index];
  String[] data = new String[173];
  for(int i = 0; i < 540*173; i += 540) {
    data[i/540] = q.substring(i, i+540-1);
  }
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
      println(data[i].substring(1)); //Print the comments, they could be important!
  }
  */
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
    } //else
      //println(data[i].substring(1));
  } 
}

//Loads the edge coordinate data (in this case, muscle coordinates).
void loadEdgeCoordinateData(String location) {
  //println("Loading edge coordinate data from: " + location);
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
    } //else
      //println(data[i].substring(1));
  }
}

void loadCommunityData(String location) {
    //println("\nLoading community assignment data from: " + location);
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
      } //else
        //println("\t" + data[i].substring(1));
    }
}

//Prints all the connections of each edge.
void printEdgeConnections() {
  for(Edge e : edgenet) {
    for(int i : e.connectedVertices)
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
  ArrayList<Integer> connectedVertices = new ArrayList<Integer>(); //A list of all the ids of the connected nodes.
  int id = -1; //The edge's index in the edgenet list.
  int degree = -1; //The degree of the edge.
  VecN position = new VecN(0, 0, 0);
  String name;
  int community = 0;
  
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
  public void addNode(int nid) {
    connectedVertices.add(nid);
    network.get(nid).addEdge(id);
    degree++;
  }
  
  //Sets 3D coordinate.
  public void setPosition(VecN pos) {
    position = pos;
  }
  
  void setCommunity(int i) {
    community = i;
  }
  
  void setName(String s) {
    name = new String(s.toCharArray());
  }
  
  //setPosition() overload taking 3 floats instead of a PVector.
  public void setPosition(float x, float y, float z) {
    position = new VecN(x, y, z);
  }
  
  //Displays the springs in the dot-line-dot-line-dot fashion.
  public void display() {
    for(int i = 0; i < connectedVertices.size(); i++)
      line(position.x, position.y, position.z, network.get(i).position.x, network.get(i).position.y, network.get(i).position.z);
  }
}

//A short node class, holding a degree, id, and position.
public class Node {
  int id = -1; //The node's index in the network list.
  int degree = -1;
  VecN position = new VecN(0, 0, 0);
  ArrayList<Integer> connectedEdges = new ArrayList<Integer>();
  
  ArrayList<Integer> nodeSpringIDs = new ArrayList<Integer>();
  ArrayList<Float> nodeSpringInitDists = new ArrayList<Float>();
  ArrayList<Float> nodeSpringStrengths = new ArrayList<Float>();
  ArrayList<Float> nodeSpringPreviousDisplacements = new ArrayList<Float>();
  VecN physAcc = new VecN(0, 0, 0, 0);
  VecN physVel = new VecN(0, 0, 0, 0);
  VecN physPos = new VecN(0, 0, 0, 0);
  
  boolean fixed = false;
  
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
  public void setPosition(VecN pos) {
    position = pos;
  }
  
  //setPosition() overload taking 3 floats instead of a PVector.
  public void setPosition(float x, float y, float z) {
    position = new VecN(x, y, z);
  }
  
  public void addEdge(int i) {
    connectedEdges.add(i);
  }
  
  //Re-assigns positions, creates springs .
  public void setUpPhys() {
    physAcc = new VecN(0, 0, 0, 0);
    physVel = new VecN(0, 0, 0, 0);
    physPos = new VecN(0, 0, 0, 0);
    nodeSpringIDs = new ArrayList<Integer>();
    nodeSpringInitDists = new ArrayList<Float>();
    nodeSpringStrengths = new ArrayList<Float>();
    //Simple (if kind of kludge-y) way of figuring out if a node should be fixed (all the nodes in the middle have an x-coordinate of 443).
    if(position.x == 443.0) fixed = true;
    physPos = new VecN(position.x, position.y, position.z, 0.0f);
    if(!fixed && fixMidpoints) {
      for(int i : connectedEdges) {
        for(int j : edgenet.get(i).connectedVertices) {
          nodeSpringIDs.add(j);
          nodeSpringInitDists.add(position.distance(network.get(j).position));
          //Nodes with higher degrees have weaker springs.
          nodeSpringStrengths.add(1.0f/float(edgenet.get(i).connectedVertices.size()-1));
          nodeSpringPreviousDisplacements.add(0.f);
        }
      }
    }
  }
  
  public void physCalculate() {
    
    physAcc = new VecN(0, 0, 0, 0);
    
    for(int i = 0; i < nodeSpringIDs.size(); i++) {
      if(nodeSpringIDs.get(i) != id) {
        //Find direction to target node and displacement from resting length.
        VecN toTarget = copyVec(network.get(nodeSpringIDs.get(i)).physPos);
        toTarget.subtract(copyVec(physPos));
        float displacement = nodeSpringInitDists.get(i) - toTarget.magnitude();
        float deltaDisplacement = displacement - nodeSpringPreviousDisplacements.get(i);
        nodeSpringPreviousDisplacements.set(i, displacement);
        toTarget.normalizeC();
        //Hooke's law w/dampening.
        float actingForce = nodeSpringStrengths.get(i) * (springForce * -displacement - dampeningCoefficent * deltaDisplacement / deltaTime);
        //Add force to acceleration.
        physAcc.addition(toTarget.multiplyV(actingForce));
      }
    }
  }
  
  //Explicit euler integration.
  public void physIntegrate() {
    physVel = physVel.additionV(physAcc.multiplyV(deltaTime));
    physPos = physPos.additionV(physVel.multiplyV(deltaTime));
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

VecN copyVec(VecN x) {
  return new VecN(x.data);
}


//Processing's built-in PVector class can't really handle more than 3 dimensions, so this is just a quick n-D vector class.
class VecN {
  ArrayList<Float> data = new ArrayList<Float>();
  float x = 0.0f;
  float y = 0.0f;
  float z = 0.0f;
  float w = 0.0f;
  void updateSwizzles() {
    if(data.size() >= 1) x = data.get(0);
    if(data.size() >= 2) y = data.get(1);
    if(data.size() >= 3) z = data.get(2);
    if(data.size() >= 4) w = data.get(3);
  }
  VecN(ArrayList<Float> list) {
    for(float f : list)
      data.add(f);
    updateSwizzles();
  }
  VecN(float x) {
    this.x = x;
    data.add(x);
  }
  VecN(float x, float y) {
    this.x = x;
    this.y = y;
    data.add(x);
    data.add(y);
  }
  VecN(float x, float y, float z) {
    this.x = x;
    this.y = y;
    this.z = z;
    data.add(x);
    data.add(y);
    data.add(z);
  }
  VecN(float x, float y, float z, float w) {
    this.x = x;
    this.y = y;
    this.z = z;
    this.w = w;
    data.add(x);
    data.add(y);
    data.add(z);
    data.add(w);
  }
  float magnitude() {
    float sum = 0.0f;
    for(float x : data)
      sum += x*x;
    return sqrt(sum);
  }
  float distance(VecN x) {
    float sum = 0.0f;
    for(int i = 0; i < max(data.size(), x.data.size()); i++) {
      float a = 0.0f; if(i < data.size()) a = data.get(i);
      float b = 0.0f; if(i < x.data.size()) b = x.data.get(i);
      sum += (b-a)*(b-a);
    }
    return sqrt(sum);
  }
  void multiply(float x) {
    for(int i = 0; i < data.size(); i++)
      data.set(i, data.get(i)*x);
    updateSwizzles();
  }
  VecN multiplyV(float x) {
    VecN v = copyVec(this);
    v.multiply(x);
    return v;
  }
  void addition(VecN x) {
    while(data.size() < x.data.size())
      data.add(0.0f);
    for(int i = 0; i < x.data.size(); i++) {
      data.set(i, data.get(i) + x.data.get(i));
    }
    updateSwizzles();
  }
  VecN additionV(VecN x) {
    VecN v = copyVec(this);
    v.addition(x);
    return v;
  }
  void subtract(VecN x) {
    while(data.size() < x.data.size())
      data.add(0.0f);
    for(int i = 0; i < x.data.size(); i++) {
      data.set(i, data.get(i) - x.data.get(i));
    }
    updateSwizzles();
  }
  VecN subtractV(VecN x) {
    VecN v = copyVec(this);
    v.subtract(x);
    return v;
  }
  void absoluteValue() {
    for(int i = 0; i < data.size(); i++)
      if(data.get(i) < 0.0f)
        data.set(i, -data.get(i));
  }
  VecN absoluteValueV() {
    VecN v = copyVec(this);
    v.absoluteValue();
    return v;
  }
  PVector toPVector() {
    return new PVector(x, y, z);
  }
  void normalizeC() {
    if(magnitude() > 0.0f)
      multiply(1.0f/magnitude());
  }
  void printSelf() {
    String toP = "";
    toP += "{";
    for(int i = 0; i < data.size(); i++) {
      toP += data.get(i);
      if(i != data.size()-1) toP += ", ";
    }
    toP += "}\n";
    print(toP);
  }
  void setX(float x) {
    if(data.size() >= 1) data.set(0, x);
  }
  void setY(float y) {
    if(data.size() >= 2) data.set(1, y);
  }
  void setZ(float z) {
    if(data.size() >= 3) data.set(2, z);
  }
  void setW(float x) {
    if(data.size() >= 4) data.set(3, x);
  }
}

int r(color c) {return (c >> 16) & 255; }
int g(color c) {return (c >> 8) & 255;}
int b(color c) {return c & 255; }

//Taking pictures & saving information
void keyPressed() {
  if(key == 'p' || key == 'P') {
    println("Saving screenshot to " + "Hypergraph_Bone-Muscle_Bipartite_Incidence_Graph-" + year() + "-" + month() + "-" + day() + "-" + hour() + "-" + minute() + "-" + second() + "-" + millis() + ".jpg...");
    //saveFrame("Hypergraph_Bone-Muscle_Bipartite_Incidence_Graph-" + year() + "-" + month() + "-" + day() + "-" + hour() + "-" + minute() + "-" + second() + "-" + millis() + ".jpg");
    saveFrame("pics/Hypergraph " + edgenet.get(targetEdge).name + " t" + (hour()*60*60 + minute()*60 + second()) + ".jpg");
    println("Screeshot saved!");
  }
  if(key == 's' || key == 'S')
    saveStress("Bone_Importances-" + year() + "-" + month() + "-" + day() + "-" + hour() + "-" + minute() + "-" + second() + "-" + millis() + ".csv");
  if(key == 'd' || key == 'D')
    saveDisplacement("Displacement_Values-" + year() + "-" + month() + "-" + day() + "-" + hour() + "-" + minute() + "-" + second() + "-" + millis() + ".csv");
}
