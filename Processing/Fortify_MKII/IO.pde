
//Just a class mostly for making backups in Tank_ANN1L look nicer
class Struct1L {
  ArrayList<Neuron> inputs;
  ArrayList<Neuron> hidden;
  ArrayList<Neuron> outputs;
  public Struct1L() {}
  void save(String folder_location, String... header) {
    save_network(inputs, folder_location + "/inputs.ann", header);
    save_network(hidden, folder_location + "/hidden.ann", header);
    save_network(outputs, folder_location + "/outputs.ann", header);
  }
  void copy_from(ArrayList<Neuron> inputs, ArrayList<Neuron> hidden, ArrayList<Neuron> outputs) {
    this.inputs = new ArrayList<Neuron>();
    this.hidden = new ArrayList<Neuron>();
    this.outputs = new ArrayList<Neuron>();
    for(Neuron n : inputs) this.inputs.add(copy_neuron(n));
    for(Neuron n : hidden) this.hidden.add(copy_neuron(n));
    for(Neuron n : outputs) this.outputs.add(copy_neuron(n));
  }
}

ArrayList<Neuron> copy_of(ArrayList<Neuron> source) {
  ArrayList<Neuron> output = new ArrayList<Neuron>();
  for(Neuron n : source) output.add(copy_neuron(n));
  return output;
}

//TODO - Add x/y display coordinates into saving

//I took these functions from Fortify_MKI, they're pretty standard, plaintext, etc.
//In cases where bipartite updates are overriden and the layers of the network are stored in individual ArrayLists, the layers will be saved seperately.
void save_network(ArrayList<Neuron> network, String location, String... header) {
  ArrayList<String> data = new ArrayList<String>();
  for(String s : header)
    data.add(s);
  data.add("# key:");
  data.add("#     n - neuron I.D. - neuron name");
  data.add("#     b - neuron bias");
  data.add("#     a - is neuron active?");
  data.add("#     s - sigmoid mode [0: x/(1+|x|), 1: 1/(1+e^(-x)), 2: tanh(x)]");
  data.add("#     OBU - override bipartite update?");
  data.add("#     w weight1 weight2 weight3 ...");
  data.add("#     i inputID1 inputID2 inputID3 ...");
  data.add("#     wgrad weightGradient1 weightGradient2 weightGradient3 ... [gradients are relative to a predetermined cost function of the network]");
  data.add("#     bgrad biasGradient1 biasGradient2 biasGradient3");
  int k = 0;
  for(Neuron n : network) {
    data.add("");
    data.add("n " + k + " " + n.name);
    data.add("b " + n.bias);
    data.add("a " + n.active);
    data.add("s " + n.SIGMOID_MODE);
    data.add("OBU " + n.OVERRIDE_BIPARTITE_UPDATE);
    String weights = "";
    String weight_gradient = "";
    String inputs = "";
    for(float f : n.w)
      weights += f + " ";
    for(float f : n.w_gradient)
      weight_gradient += f + " ";
    for(int i : n.inputs)
      inputs += i + " ";
    data.add("w " + weights);
    data.add("i " + inputs);
    data.add("wgrad " + weight_gradient);
    data.add("bgrad " + n.bias_gradient);
    k++;
  }
  String[] s = new String[data.size()];
  for(int i = 0; i < s.length; i++)
    s[i] = data.get(i);
  saveStrings(location, s);
}


ArrayList<Neuron> load_network(String location) {
  ArrayList<Neuron> net = new ArrayList<Neuron>();
  String[] in = loadStrings(location);
  Neuron current_neuron = new Neuron();
  int k = 0;
  for(String s : in) {
    if(s.startsWith("n")) {
      if(k != 0)
        net.add(current_neuron);
      current_neuron = new Neuron();
      current_neuron.id = k;
      k++;
    }
    if(s.startsWith("b")) {
      current_neuron.bias = Float.parseFloat(s.substring(2));
    }
    if(s.equals("a false")) {
      current_neuron.active = false;
    }
    if(s.startsWith("s")) {
      current_neuron.SIGMOID_MODE = Short.parseShort(s.substring(2));
    }
    if(s.equals("OBU true")) {
      current_neuron.OVERRIDE_BIPARTITE_UPDATE = true;
    }
    if(s.startsWith("w")) {
      String[] sq = s.split(" ");
      for(int i = 1; i < sq.length; i++) {
        current_neuron.w.add(Float.parseFloat(sq[i]));
      }
    }
    if(s.startsWith("i")) {
      String[] sq = s.split(" ");
      for(int i = 1; i < sq.length; i++) {
        current_neuron.inputs.add(Integer.parseInt(sq[i]));
      }
    }
    if(s.startsWith("wgrad")) {
      String[] sq = s.split(" ");
      for(int i = 1; i < sq.length; i++) {
        current_neuron.w_gradient.add(Float.parseFloat(sq[i]));
      }
    }
    if(s.startsWith("bgrad")) {
      current_neuron.bias_gradient = Float.parseFloat(s.substring(6));
    }
  }
  net.add(current_neuron);
  return net;
}