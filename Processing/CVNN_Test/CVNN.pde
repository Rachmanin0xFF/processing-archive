

void dumb_learn_w(CVNN c) {
  float nom = full_cost(c);
  Neuron n = neuron_registry.get((int)random(neuron_registry.size()));
  
  Cpl[] tmp = new Cpl[n.weights.length];
  Cpl tmp2 = new Cpl(n.bias);
  
  n.bias = rand();
  for(int i = 0; i < n.weights.length; i++) {
    tmp[i] = new Cpl(n.weights[i]);
    n.weights[i] = rand();
  }
  
  if(full_cost(c) >= nom) {
    for(int i = 0; i < n.weights.length; i++) {
      n.weights[i] = tmp[i];
    }
    n.bias = tmp2;
  }
}

void dumb_learn_w3(CVNN c) {
  float nom = full_cost(c);
  Neuron n = neuron_registry.get((int)random(neuron_registry.size()));
  
  Cpl[] tmp = new Cpl[n.weights.length];
  Cpl tmp2 = new Cpl(n.bias);
  
  n.bias = add(mult(rand(), 0.1), n.bias);
  for(int i = 0; i < n.weights.length; i++) {
    tmp[i] = new Cpl(n.weights[i]);
    n.weights[i] = add(mult(rand(), 0.1), n.weights[i]);
  }
  
  if(full_cost(c) >= nom) {
    for(int i = 0; i < n.weights.length; i++) {
      n.weights[i] = tmp[i];
    }
    n.bias = tmp2;
  }
}

void dumb_learn_b(CVNN c) {
  float nom = full_cost(c);
  Neuron n = neuron_registry.get((int)random(neuron_registry.size()));
  Cpl tmp = new Cpl(n.bias);
  n.bias = rand();
  if(full_cost(c) >= nom) {
    n.bias = tmp;
  }
}

float full_cost(CVNN c) {
  float cost = 0;
  for(int i = 0; i < c.in_size; i++) {
    c.set_in(onehot(i, c.in_size));
    c.forward_pass();
    cost += c.get_cost2(onehot(i, c.in_size));
  }
  return cost;
}

class CVNN {
  ArrayList<Layer> layers = new ArrayList<Layer>();
  int in_size = 0;
  int out_size = 0;
  
  CVNN(int... layer_sizes) {
    Layer tmp = null;
    for(int i : layer_sizes) {
      if(tmp == null) {
        in_size = i;
        layers.add(new Layer(i));
      } else {
        layers.add(new Layer(i, tmp));
      }
      tmp = layers.get(layers.size()-1);
    }
    out_size = layers.get(layers.size()-1).x.length;
  }
  
  void set_in(float[] data) {
    for(int i = 0; i < layers.get(0).x.length; i++) {
      layers.get(0).x[i].activation = toC(data[i]);
    }
  }
  
  float get_cost(float[] target) {
    float err = 0;
    for(int i = 0; i < layers.get(layers.size()-1).x.length; i++) {
      err += mag2(sub(layers.get(layers.size()-1).x[i].activation, toC(target[i])));
    }
    return err;
  }
  
  float get_cost2(float[] target) {
    float err = 0;
    float w = 0;
    for(int i = 0; i < layers.get(layers.size()-1).x.length; i++) {
      w = mag2(layers.get(layers.size()-1).x[i].activation) - target[i];
      err += w*w;
    }
    return err;
  }
  
  void forward_pass() {
    for(int i = 1; i < layers.size(); i++) {
      layers.get(i).update();
      if(i==2) layers.get(i).x[0].activation.mult(1.0 / (0.001+mod(layers.get(i).x[0].activation)));
    }
  }
  
  void print_self(int depth) {
    println("CVNN: " + layers.size() + " layers");
    if(depth > 1)
      for(Layer l : layers) l.print_self(depth-1);
  }
  
  void display(float center_x, float center_y, float block_size) {
    stroke(50);
    float pos = center_x - layers.size()*block_size;
    rectMode(CENTER);
    colorMode(HSB);
    for(Layer z : layers) {
      float y_pos = center_y-block_size*z.x.length/2.f;
      for(int y = 0; y < z.x.length; y++) {
        float col = mod(z.x[y].activation)*300.0;
        float hu = (arg(z.x[y].activation)/TWO_PI + 0.5)*360.0;
        fill(hu, mousePressed?0:255, col);
        rect(pos, y_pos, block_size, block_size);
        y_pos += block_size;
      }
      pos += block_size*2;
    }
  }
  
  void print_0layer(int k) {
    Layer z = layers.get(k);
    float re = z.x[0].activation.re;
    float im = z.x[0].activation.im;
    println(re + ", " + im);
  }
}
