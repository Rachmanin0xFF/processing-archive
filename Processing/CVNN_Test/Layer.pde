class Layer {
  Neuron[] x;
  
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
    for(Neuron n : x) {
      n.fetch();
    }
  }
  
  void set_one_hot(int j) {
    for(int i = 0; i < x.length; i++) {
      x[i].activation = (i==j ? toC(1) : toC(0));
    }
  }
  
  void print_self(int depth) {
    println("--Layer: " + x.length + " neurons");
    if(depth > 1) {
      for(Neuron y : x) y.print_self(depth - 1);
    }
  }
}
