
//Neuron output is calculated as sigmoid(sum(weights[i]*inputs[i]) + bias)
class Neuron {
  String name = "";
  int id = -1;
  float activation = 0.f;
  float bias = 0.f;
  float bias_gradient = 0.f;
  ArrayList<Float> w = new ArrayList<Float>();
  ArrayList<Float> w_gradient = new ArrayList<Float>();
  ArrayList<Integer> inputs = new ArrayList<Integer>();
  VecN r = new VecN();
  boolean active = true;
  //0 - x/(1+|x|)
  //1 - 1/(1+e^(-x))
  //2 - tanh(x)
  short SIGMOID_MODE = 0;
  boolean EXP_MOID = false; // if true, then y = e^(-x^2) is swapped out for the actual activation fucntion.
  boolean OVERRIDE_BIPARTITE_UPDATE = false;
  public void printInfo() {
    println("\nName: " + name);
    println("I.D.: " + id);
    println("Bias: " + bias);
    print("Weights: [ ");
    for(float f : w) print(f + " "); print("]\n");
    println("Active: " + active);
  }
  public Neuron() {
  }
  public Neuron(int id) {
    this.id = id;
  }
  public Neuron(int id, float b) {
    bias = b;
    this.id = id;
  }
  public Neuron(VecN position) {
    r = copy_vec(position);
  }
  public Neuron(int id, VecN position) {
    r = copy_vec(position);
    this.id = id;
  }
  public Neuron(VecN position, boolean active) {
    r = copy_vec(position);
    this.active = active;
  }
  public Neuron(int id, VecN position, boolean active) {
    r = copy_vec(position);
    this.active = active;
    this.id = id;
  }
  public Neuron(float b, VecN position) {
    bias = b;
    r = copy_vec(position);
  }
  public Neuron(int id, float b, VecN position) {
    bias = b;
    r = copy_vec(position);
    this.id = id;
  }
  void add_connection(int id, float weight) {
    inputs.add(id);
    w.add(weight);
    this.id = id;
  }
  //@param n the list of neurons that this particular neuron is a member of.
  float temporary_activation = 0.f;
  void update0(ArrayList<Neuron> n) {
    if(active) {
      temporary_activation = bias;
      for(int k = 0; k < w.size(); k++) {
        temporary_activation += w.get(k)*n.get(inputs.get(k)).activation;
      }
      if(EXP_MOID)
        temporary_activation = exp(temporary_activation*temporary_activation);
      else if(SIGMOID_MODE==0)
        temporary_activation = temporary_activation/(1.f + abs(temporary_activation));
      else if(SIGMOID_MODE==1)
        temporary_activation = sigmoid(temporary_activation);
      else if(SIGMOID_MODE==2)
        temporary_activation = (float)Math.tanh(temporary_activation);
      if(OVERRIDE_BIPARTITE_UPDATE)
        activation = temporary_activation;
    }
  }
  void update0(Neuron[] n) {
    if(active) {
      temporary_activation = bias;
      for(int k = 0; k < w.size(); k++) {
        temporary_activation += w.get(k)*n[inputs.get(k)].activation;
      }
      if(EXP_MOID)
        temporary_activation = exp(-temporary_activation*temporary_activation);
      else if(SIGMOID_MODE==0)
        temporary_activation = temporary_activation/(1.f + abs(temporary_activation));
      else if(SIGMOID_MODE==1)
        temporary_activation = sigmoid(temporary_activation);
      else if(SIGMOID_MODE==2)
        temporary_activation = (float)Math.tanh(temporary_activation);
      if(OVERRIDE_BIPARTITE_UPDATE)
        activation = temporary_activation;
    }
  }
  //A two-step update is nessecary when inputs are volatile.
  void update1() {
    if(active) {
      activation = temporary_activation;
    }
  }
}

//Copies a neuron, pretty straightforwards
Neuron copy_neuron(Neuron i) {
  Neuron o = new Neuron();
  o.id = i.id;
  o.name = i.name;
  o.activation = i.activation;
  o.bias = i.bias;
  o.bias_gradient = i.bias_gradient;
  for(float f : i.w) o.w.add(f);
  for(float f : i.w_gradient) o.w_gradient.add(f);
  for(int k : i.inputs) o.inputs.add(k);
  o.r = copy_vec(i.r);
  o.active = i.active;
  o.EXP_MOID = i.EXP_MOID;
  o.SIGMOID_MODE = i.SIGMOID_MODE;
  o.OVERRIDE_BIPARTITE_UPDATE = i.OVERRIDE_BIPARTITE_UPDATE;
  return o;
}