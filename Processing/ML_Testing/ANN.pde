

void dumb_learn_w(CVNN c) {
  float nom = full_cost(c);
  Neuron n = neuron_registry.get((int)random(neuron_registry.size()));
  
  float[] tmp = new float[n.weights.length];
  float tmp2 = n.bias;
  
  n.bias = randomGaussian();
  for(int i = 0; i < n.weights.length; i++) {
    tmp[i] = n.weights[i];
    n.weights[i] = randomGaussian();
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
  
  float[] tmp = new float[n.weights.length];
  float tmp2 = n.bias;
  
  n.bias += randomGaussian()*0.2;
  for(int i = 0; i < n.weights.length; i++) {
    tmp[i] = n.weights[i];
    n.weights[i] += randomGaussian()*0.15;
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
  float tmp = n.bias;
  n.bias = randomGaussian();
  if(full_cost(c) >= nom) {
    n.bias = tmp;
  }
}

float full_cost(CVNN c) {
  float cost = 0;
  for(int i = 0; i < c.in_size*5; i++) {
    c.set_in(onehot(i, c.in_size));
    //c.set_in(randhot(c.in_size));
    c.forward_pass();
    cost += c.get_cost(onehot(i, c.in_size));
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
      layers.get(0).x[i].activation = data[i];
    }
  }
  
  float get_cost(float[] target) {
    float err = 0;
    for(int i = 0; i < layers.get(layers.size()-1).x.length; i++) {
      float d = layers.get(layers.size()-1).x[i].activation - target[i];
      err += d*d;
    }
    return err;
  }
  
  void forward_pass() {
    for(int i = 1; i < layers.size(); i++) {
      layers.get(i).update();
    }
  }
  
  void display(float center_x, float center_y, float block_size) {
    stroke(50);
    float pos = center_x - layers.size()*block_size;
    rectMode(CENTER);
    colorMode(HSB);
    for(Layer z : layers) {
      float y_pos = center_y-block_size*z.x.length/2.f;
      for(int y = 0; y < z.x.length; y++) {
        float col = z.x[y].activation*255.0;
        fill(0, 0, col);
        rect(pos, y_pos, block_size, block_size);
        y_pos += block_size;
      }
      pos += block_size*2;
    }
  }
}
