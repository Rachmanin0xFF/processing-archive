//R.A.N.N.E.
//Recursive Artificial Neural Network Emulator

ArrayList<Node> cells = new ArrayList<Node>();
int frames = 0;
int index = 0;
int mouseBall = 0;
boolean mouseGrab = false;
boolean p = true;

void setup() {
  size(512, 512);
}
void draw() {
  if(mousePressed&&mouseGrab==false&&mouseButton==RIGHT)
    for(Node n : cells)
      if(dist(n.x, n.y, mouseX, mouseY)<25)
        n.outputPower = 1.0;
  background(0);
  for(Node n : cells)
    n.update();
  fill(0, 0, 255);
  text(frames, 10, 10);
    frames++;
  if(mouseGrab) {
    line(cells.get(mouseBall).x, cells.get(mouseBall).y, mouseX, mouseY);
    for(Node n : cells)
      if(dist(n.x, n.y, mouseX, mouseY)<10&&n.netID!=mouseBall&&!(cells.get(n.netID).inputs.contains(mouseBall))) {
        cells.get(n.netID).input(mouseBall);
        cells.get(n.netID).createArray();
        mouseGrab = false;
      }
  }
}
void mousePressed() {
  if(mouseButton==LEFT) {
  boolean b = true;
  for(Node n : cells)
    if(dist(n.x, n.y, mouseX, mouseY)<20) {
      b = false;
      mouseBall = n.netID;
      mouseGrab = true;
    }
  if(b) {
    cells.add(new Node(index, mouseX, mouseY));
    cells.get(index).createArray();
    index++;
  }
  }
}
void keyPressed() {
  if(key=='f'||key=='F')
    for(Node n : cells)
      if(dist(n.x, n.y, mouseX, mouseY) < 15)
        n.fixed = !n.fixed;
}
class Node {
  int netID;
  ArrayList<Integer> inputs = new ArrayList<Integer>();
  float[] inputWeights;
  float outputPower;
  float x;
  float y;
  boolean fixed;
  public Node(int netID) {
    this.netID = netID;
  }
  public Node(int netID, float x, float y) {
    this.netID = netID;
    this.x = x;
    this.y = y;
  }
  public void input(int connectionID) {
    inputs.add(connectionID);
  }
  public void createArray() {
    inputWeights = new float[inputs.size()];
    for(int i = 0; i < inputWeights.length; i++)
      inputWeights[i] = random(-1, 1);
  }
  public float getCurrent() {
    return outputPower;
  }
  public void update() {
    stroke(outputPower, 255, 0, 255);
    fill(outputPower*255, 0, 255, 255);
    float sum = 0.0f;
    if(!fixed||!p)
      for(int i = 0; i < inputWeights.length; i++) {
        sum += inputWeights[i]*cells.get(inputs.get(i)).getCurrent();
        line2(x, y, cells.get(inputs.get(i)).x, cells.get(inputs.get(i)).y, inputWeights[i]);
      }
    noStroke();
    fill(outputPower*255, 0, 255, 255);
    ellipse(x, y, outputPower*3+10, outputPower*3+10);
    stroke(outputPower, 255, 0, 255);
    fill(0, 0, 0, 0);
    ellipse(x, y, 20, 20);
    fill(255, 255, 0);
    text(outputPower, x, y);
    if(!fixed||!p)
      outputPower = sigmoid(sum);
  }
}

public void line2(float x, float y, float x1, float y1, float w) {
  line(x, y, x1, y1);
  PVector v = new PVector(x1-x, y1-y);
  v.normalize();
  ellipse(x+v.x*30, y+v.y*30, 10, 10);
  fill(255, 255, 0);
  text(w, x+v.x*40, y+v.y*40);
}

public float sigmoid(float x) {
  return 1/(1+exp(10*-x))-0.5;
}
