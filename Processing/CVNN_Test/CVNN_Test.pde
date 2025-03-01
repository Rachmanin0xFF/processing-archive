
CVNN c;

void setup() {
  size(512, 512, P2D);
  
  neuron_registry = new ArrayList<Neuron>();
  c = new CVNN(8, 4, 1, 4, 8);
  c.print_self(3);
  c.forward_pass();
  c.print_self(3);
}

void keyPressed() {
  println("=================");
  for(int k = 0; k < c.in_size; k++) {
    c.set_in(onehot(k, c.in_size));
    c.forward_pass();
    c.print_0layer(2);
  }
}

void draw() {
  background(0);
  
  int k = (mouseX/8)%8;
  
  c.set_in(onehot(k, c.in_size));
  c.forward_pass();
  c.display(width/2, height/2, 32);
  for(int i = 0; i < 10000; i++) {
    dumb_learn_w3(c);
    dumb_learn_w3(c);
    dumb_learn_w(c);
    dumb_learn_b(c);
  }
}

float[] onehot(int x, int len) {
  float[] out = new float[len];
  if(x >= 0 && x < len)
  out[x] = 1;
  return out;
}
