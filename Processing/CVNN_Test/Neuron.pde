ArrayList<Neuron> neuron_registry;

class Neuron {
  Cpl activation;
  Layer input;
  Cpl[] weights;
  Cpl bias;
  
  Neuron() {
    activation = new Cpl();
    weights = new Cpl[0];
    bias = new Cpl();
  }
  
  Neuron(Layer L) {
    activation = new Cpl();
    input = L;
    weights = new Cpl[L.x.length];
    bias = rand();
    for(int i = 0; i < L.x.length; i++) {
      weights[i] = rand();
    }
    neuron_registry.add(this);
  }
  
  void fetch() {
    activation = new Cpl(bias);
    for(int i = 0; i < input.x.length; i++) {
      activation.add(mult(input.x[i].activation, weights[i]));
    }
    activation = clamp(activation);
  }
  
  void print_self(int depth) {
    println("----Neuron: " + weights.length + " weights. Activation: (" + activation.re + " + " + activation.im + "i)");
  }
  
  void print_weights() {
    println(weights.length + " weights:");
    for(Cpl c : weights) {
      println(c.re + ", " + c.im);
    }
  }
}
