//R.A.N.N.E.
//Recursive Artificial Neural Network Emulator

Node[] cells = new Node[7000];
int frames = 0;

void setup() {
  size(512, 512, P2D);
  colorMode(RGB);
  for(int i = 0; i < cells.length; i++)
    cells[i] = new Node(i, random(width), random(height));
  println("Cells successfully created.");
  int tick = 0;
  for(int i = 0; i < cells.length; i++) {
    tick = 0;
    for(int k = 0; k < cells.length; k++)
      if(dist(cells[i].x, cells[i].y, cells[k].x, cells[k].y) < 22 && !cells[k].inputs.contains(i)) {
        tick++;
        cells[i].input(k);
      }
    cells[i].createArray();
  }
}
void draw() {
  background(0);
  for(int i = 0; i < cells.length; i++) {
    cells[i].update();
    if(dist(cells[i].x, cells[i].y, mouseX, mouseY) < 40 && mousePressed)
    cells[i].outputPower = 2.0;
  }
  fill(0, 0, 255);
  text(frames, 10, 10);
  frames++;
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
      inputWeights[i] = random(-.5, .5);
  }
  public float getCurrent() {
    return outputPower;
  }
  public void update() {
    stroke(outputPower*40.0f, 50);
    float sum = 0.0f;
    for(int i = 0; i < inputWeights.length; i++) {
      //inputWeights[i] += cells[inputs.get(i)].getCurrent()/10;
      //inputWeights[i] = -sigmoid(inputWeights[i]);
      sum += inputWeights[i]*cells[inputs.get(i)].getCurrent();
      line(x, y, cells[inputs.get(i)].x, cells[inputs.get(i)].y);
    }
    point(x, y);
    outputPower = sigmoid(sum);
  }
}

public float sigmoid(float x) {
  return 1/(1+exp(10*-x));
}
