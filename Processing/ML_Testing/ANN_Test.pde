
CVNN c;
int LATENT_LAYER = 2;
PFont font;

float wait_time = 0;

void setup() {
  size(1280, 720, P3D);
  
  neuron_registry = new ArrayList<Neuron>();
  c = new CVNN(24, 6, 3, 8, 24);
  c.layers.get(LATENT_LAYER).reg = true;
  c.forward_pass();
  font = createFont("AtkinsonHyperlegible-Bold.ttf", 32);
}

void keyPressed() {
  println("=================");
  for(int k = 0; k < c.in_size; k++) {
    c.set_in(onehot(k, c.in_size));
    c.forward_pass();
    println("");
    for(Neuron n : c.layers.get(LATENT_LAYER).x) {
      print(n.activation + " ");
    }
  }
}

void draw() {
  background(0);
  
  textSize(32);
  textFont(font);
  fill(255); noStroke();
  textAlign(CENTER, CENTER);
  text("Network", width/4 - 20, 50);
  text("Latent Space", width*3/4, 50);
  
  translate(0, 40);
  if(millis() < wait_time*1000) { text((float)(wait_time*1000 - millis())/1000.0, width/2, height/2); return; }
  int k = (frameCount/2)%(c.in_size);
  
  c.set_in(onehot(k, c.in_size));
  c.forward_pass();
  c.display(width/4, height/2, 20);
  for(int i = 0; i < 60; i++) {
    dumb_learn_w3(c);
  }
  
  pushMatrix();
  
  translate(width*3/4 - 50, height/2);
  float sc = 300;
  //translate(sc/4, sc/4);
  rotateY(millis()/2000.0f);
  stroke(255);
  noFill();
  box(sc);
  strokeWeight(4);
  for(int j = 0; j < c.in_size; j++) {
    c.set_in(onehot(j, c.in_size));
    c.forward_pass();
    println("");
    float x = c.layers.get(LATENT_LAYER).x[0].activation;
    float y = c.layers.get(LATENT_LAYER).x[1].activation;
    float z = c.layers.get(LATENT_LAYER).x[2].activation;
    
    point(x*sc - sc/2, -y*sc + sc/2, z*sc - sc/2);
  }
  strokeWeight(1);
  popMatrix();
}

float[] onehot(int x, int len) {
  float[] out = new float[len];
  if(x >= 0 && x < len)
  out[x] = 1;
  return out;
}

float[] randhot(int len) {
  float[] out = new float[len];
  for(int i = 0; i < len; i++) {
    if(random(10)>7) out[i] = 1;
  }
  return out;
}
