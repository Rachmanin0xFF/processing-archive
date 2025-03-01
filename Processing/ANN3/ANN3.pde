//R.A.N.N.E.
//Recursive Artificial Neural Network Emulator

ArrayList<Node> cells = new ArrayList<Node>();
int frames = 0;
int index = 0;
int mouseBall = 0;
boolean mouseGrab = false;
boolean p = true;

PImage in;
PImage in2;

void setup() {
  size(1300, 900);
  in = loadImage("circle.png");
  in2 = loadImage("notcircle.png");
  for(int i = 0; i < in.pixels.length; i++) {
    for(int k = 0; k < i; k++) {
      cells.add(new Node(i, -i*30+500, k*30+200));
      cells.get(cells.size()-1).createArray();
    }
  }
}
void draw() {
  background(0);
  image(in, 0, 0, 128, 128);
  image(in2, 128, 0, 128, 128);
  for(Node n : cells)
    n.update();
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
