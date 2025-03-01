class Layer {
  Neuron[] x;
  boolean reg;
  
  Layer(int size) {
    x = new Neuron[size];
    for(int i = 0; i < size; i++) {
      x[i] = new Neuron();
    }
  }
  
  Layer(int size, Layer prev_layer) {
    x = new Neuron[size];
    for(int i = 0; i < size; i++) {
      x[i] = new Neuron(prev_layer);
    }
  }
  
  void update() {
    float sum = 0;
    for(Neuron n : x) {
      n.fetch();
      if(reg) {
        n.activation -= 0.5;
        sum += n.activation*n.activation;
      }
    }
    if(reg) {
      float l2 = sqrt(sum);
      for(Neuron n : x) {
        n.activation /= l2*2.0;
        n.activation += 0.5;
      }
    }
  }
  
  void set_one_hot(int j) {
    for(int i = 0; i < x.length; i++) {
      x[i].activation = (i==j ? 1 : 0);
    }
  }
}
