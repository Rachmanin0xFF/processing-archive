ArrayList<Neuron> neuron_registry;

class Neuron {
  float activation;
  Layer input;
  float[] weights;
  float bias;
  
  Neuron() {
    activation = 0;
    weights = new float[0];
    bias = 0;
  }
  
  Neuron(Layer L) {
    activation = 0;
    input = L;
    weights = new float[L.x.length];
    bias = randomGaussian();
    for(int i = 0; i < L.x.length; i++) {
      weights[i] = randomGaussian();
    }
    neuron_registry.add(this);
  }
  
  void fetch() {
    activation = bias;
    for(int i = 0; i < input.x.length; i++) {
      activation += input.x[i].activation * weights[i];
    }
    activation = clamp(activation);
  }
}

float clamp(float x) {
  float ep = exp(x);
  float em = exp(-x);
  //return (ep - em)/(ep + em);
  return 1/(1+em);
  //return max(0.02*x, x);
}
