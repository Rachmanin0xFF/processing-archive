
void setup() {
  size(1000, 800, P2D);
  frameRate(400);
  background(255);
  println("No explosions yet.");
  initNetwork();
  noSmooth();
  goodness.add(0.f);
}
Tank_ANN1L net;
void initNetwork() {
  net = new Tank_ANN1L(1, 1, 10, 10, width - 20, height - 20);
}

void getSamples() {
  for(int i = 0; i < 50; i++) {
    float x = random(-2, 2);
    float y = net.transform(x)[0];
    float score = abs(func(x) - y);
    net.score(abs(func(x) - y));
  }
}
float func(float x) {
  return cos(3*x);
}

void keyPressed() {
  if(key == 's') {
    net.save_best("best i guesst");
  }
}

ArrayList<Float> goodness = new ArrayList<Float>();
ArrayList<Float> goodnessDelta = new ArrayList<Float>();

void draw() {
  background(255);
  if(frameCount == 0) println("All systems are go.");
  
  for(int i = 0; i < 100; i++) {
    getSamples();
    net.learn();
  }
  
  while(net.history.size() > width) net.history.remove(0);
  while(net.historyDelta.size() > width) net.historyDelta.remove(0);
  
  fill(0, 255);
  text(net.score_sum/(float)(net.scores_given), 10, 20);
  
  if(keyPressed && key == 'g') {
    net.grad_cycle = true;
  }
  if(keyPressed && key == 'a') {
    net.add_cycle = true;
  }
  
  plotData(0, 0, width, height/4, net.history);
  plotData(0, height/4*3, width, height/4, net.historyDelta);
  
  stroke(0, 255, 0, 255);
  noFill();
  float py = 0.f;
  boolean start = true;
  float del = 0.001f;
  for(float i = -2.f; i < 2.f; i+=del) {
    float y = -func(i)*200.f + height/2;
    if(!start) {
      line((i - del)*200.f + width/2, py, i*200.f + width/2, y);
    }
    py = y;
    if(start) start = false;
  }
  py = 0.f;
  start = true;
  stroke(0, 255);
  for(float i = -2.f; i < 2.f; i+=del) {
    float y = -net.transform(i)[0]*200.f + height/2;
    if(mousePressed) y = -net.transform_best(i)[0]*200.f + height/2;
    if(!start) {
      line((i - del)*200.f + width/2, py, i*200.f + width/2, y);
    }
    py = y;
    if(start) start = false;
  }
}

void plotData(float x, float y, float w, float h, ArrayList<Float>... input) {
  stroke(0, 100);
  line(x, y + h/2.f, x + w, y + h/2.f);
  noFill();
  stroke(0, 255);
  rect(x, y, w, h);
  color[] dataColors = new color[]{color(200, 200, 0), color(0, 200, 200), color(200, 0, 200), color(200, 0, 0), color(0, 200, 0), color(0, 0, 200)};
  int k = 0;
  blendMode(SUBTRACT);
  for(ArrayList<Float> data : input) {
    float min = 100000000.f;
    float max = -100000000.f;
    for(int i = 0; i < data.size()-1; i++) {
      if(data.get(i) < min) min = data.get(i);
      if(data.get(i) > max) max = data.get(i);
    }
    if(min == max) {
      min = -1.f;
      max = 1.f;
    }
    stroke(dataColors[k%dataColors.length]);
    for(float i = 0.f; i < data.size()-1.f; i++) {
      line(map(i, 0.f, data.size(), x, x + w), clamp(map(data.get(int(i)), min, max, y + h, y), y, y + h), map(i + 1.f, 0.f, data.size(), x, x + w), clamp(map(data.get(int(i + 1.f)), min, max, y + h, y), y, y + h));
    }
    k++;
  }
  blendMode(BLEND);
}