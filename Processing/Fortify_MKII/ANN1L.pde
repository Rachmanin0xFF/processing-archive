
//This class exists to make the code more understandable. It acts as the director for the growth and processes of the ANN1L class.
//I chose to do this over throwing all the code in Nemandi, as I'm sure that would get messy later on.
class Tank_ANN1L extends ANN1L {
  Struct1L backup = new Struct1L();
  ANN1L best_network;
  public Tank_ANN1L(int num_inputs, int num_outputs, float x, float y, float w, float h) {
    super(num_inputs, num_outputs, x, y, w, h);
    historyDelta.add(0.f);
  }
  public float[] transform(float... args) {
    return super.transform(args);
  }
  public void score(float c) {
    super.score(c);
  }
  //Transforms inputs using the best network created so far
  public float[] transform_best(float... args) {
    return best_network.transform(args);
  }
  
  //Logs of the network's efficency score (not including in-cycle efficency scores)
  ArrayList<Float> history = new ArrayList<Float>();
  ArrayList<Float> historyDelta = new ArrayList<Float>();
  
  boolean ENABLE_BUMPS = true; //If set to true, normal ditribution activation functions in addition to standard sigmoid activation functions will be enabld.
  
  int ADD_TRIES = 60; //Number of times to try adding a randomized neuron to the hidden network before picking one to carry on with.
  Struct1L best_addition = new Struct1L();
  Neuron current_addition;
  float best_add_score = 10000000000.f;
  
  //Our stage counters for different cycles
  int add_stage = 0;
  int grad_stage = 0;
  
  //The number of free iterations passed since an add cycle / since our best network setup thus far
  int iter_since_add = 0;
  int iter_since_best = 0;
  
  float best_score = 10000000000.f; //The best job our network's done so far
  
  //When either of these booleans are set to true, the network will remain in a 'cycle' for some number of turns.
  //When the cycle is completed, the booleans reset to false.
  //You can check to see if a cycle is currently occuring by checking if the 'working' variable is set to true.
  
  boolean grad_cycle = false; //Performing a gradient calculation/descent
  boolean add_cycle = false; //Adding a new neuron to the network
  
  boolean working = false; //Are we currently in a cycle?
  //stage 1 - calculate gradient
  //stage 2 - descend
  public void learn() {
    if(!working) {
      //Make sure we've had an adequate amount of time to get started...
      if(history.size() > 30) {
        iter_since_add++;
        //Calculate the average score for the last ten iterations, and then the average another ten before that.
        float avgNow = 0.f;
        float avgThen = 0.f;
        for(int i = 0; i < 10; i++) {
          avgNow += history.get(history.size()-i-1);
          avgThen += history.get(history.size()-i-10-1);
        }
        boolean reoptimize_grad = false; //Throw in a little bit of random gradient descent reoptimization to make our best case look a little better
        //If the scores we've been getting recently aren't looking so good compared to the ones we've been getting in the recent past, try adding a new neuron.
        //Also make sure we didn't add anything too recently, and that we're not reoptimizing the gradient.
        //Otherwise, start a gradient descent cycle.
        if(avgNow > avgThen && iter_since_add > 10 && !reoptimize_grad) {
          inputs = copy_of(backup.inputs);
          hidden = copy_of(backup.hidden);
          outputs = copy_of(backup.outputs);
          ADD_TRIES = 40; //We can afford a decently sized addition trial count, considering the number of synaptic weights in a gradient calculation.
                          //(with a sufficently large network)
          add_cycle = true;
          iter_since_add = 0;
        } else {
          //TODO: remove this??? (may be kinda redundant with momentum learning mode?)
          //If we are reoptimizing, turn up the precision a little.
          //if(reoptimize_grad) LEARNING_RATE = 0.3f; else LEARNING_RATE = 0.6f;
          grad_cycle = true;
        }
      } else {
        //If we just started things, start the neuron addition cycle.
        if(learn_count == 0) add_cycle = true;
        else grad_cycle = true;
      }
    }
    
    if(grad_cycle) {
      working = true;
      weight_epsilon = 0.2f;
      bias_epsilon = 0.2f;
      //If we're in a gradient cycle, and something has incremented our stage counter in that cycle, move the cycle forwards.
      switch(grad_stage) {
        case 1:
          GRAD_CALC = true;
          break;
        case 2:
          GRAD_DESC = true;
          break;
        default:
          break;
      }
    }
    
    super.learn();
    
    if(add_cycle) {
      working = true;
      
      if(add_stage != 0) {
        //Check to see if the last neuron we added did anything innovative.
        if(last_score < best_add_score) {
          best_add_score = last_score;
          best_addition.copy_from(inputs, hidden, outputs);
        }
        //Remove the last neuron we tried to add to the network (carefully)
        hidden.remove(hidden.size()-1);
        for(int i = 0; i < outputs.size(); i++) { //We have to remove the output network weights and inputs, too.
          outputs.get(i).inputs.remove(outputs.get(i).inputs.size()-1);
          outputs.get(i).w.remove(outputs.get(i).w.size()-1);
        }
      }
      //Add a randomized neuron to the network.
      current_addition = new Neuron(hidden.size(), random(-5.f, 5.f));
      if(ENABLE_BUMPS && random(2) > 1.f) current_addition.EXP_MOID = true; //Add in normal distribution curves to the sigmoids, if we want.
      for(int i = 0; i < inputs.size(); i++) {
        current_addition.add_connection(i, random(-2.f, 2.f));
      }
      hidden.add(current_addition);
      for(int i = 0; i < outputs.size(); i++) {
        outputs.get(i).add_connection(hidden.size()-1, random(-2.f, 2.f));
      }
      add_stage++;
      //Once we've tried adding enough neurons, wrap things up by copying the version of the netowrk with our best recorded addition to our network.
      if(add_stage == ADD_TRIES) {
        inputs = copy_of(best_addition.inputs);
        hidden = copy_of(best_addition.hidden);
        outputs = copy_of(best_addition.outputs);
        add_stage = 0;
        add_cycle = false;
        working = false;
      }
    }
    
    if(grad_cycle && !busy) {
      //If the network's core (ANN1L, the super) is idling, move the gradient descent stage forwards.
      grad_stage++;
      //Reset stuff once we're done.
      if(grad_stage == 3) {
        grad_stage = 0;
        grad_cycle = false;
        working = false;
      }
    }
    if(last_score < best_score) {
      //If we just got a better score than was previously recorded, throw a party and back up our network.
      //TODO: Merge 'best_network' and 'backup' (probably go with the 'best_network' name, more descriptive).
      best_score = last_score;
      iter_since_best = 0;
      backup.copy_from(inputs, hidden, outputs);
      best_network = new ANN1L(inputs.size(), outputs.size(), s_x, s_y, s_w, s_h);
      best_network.inputs = copy_of(inputs);
      best_network.hidden = copy_of(hidden);
      best_network.outputs = copy_of(outputs);
    } else iter_since_best++; //If we didn't get a new score, record our progress (though it is technically a failure, I'm being optimistic here for sake's sake).
    if(grad_stage == 0) {
      //Record our history if we're not doing anything.
      history.add(last_score);
      if(history.size() > 1)
        historyDelta.add(history.get(history.size()-1) - history.get(history.size()-2));
    }
  }
  void save_best(String location) {
    backup.save(location);
  }
}

//Usbased gradient descent (ADAGRAD?)

class ANN1L {
  //Possibly for future neurons store information in 2D arrays? Would fit with the mathematical matrix thinking.
  //Not having one mega-neuron arraylist makes for neater indexing.
  ArrayList<Neuron> inputs = new ArrayList<Neuron>();
  ArrayList<Neuron> hidden = new ArrayList<Neuron>();
  ArrayList<Neuron> outputs = new ArrayList<Neuron>();
  int input_dimensions = 0;
  int output_dimensions = 0;
  //Updated when score() is called
  float score_sum = 0.f;
  int scores_given = 0;
  //Network score-surface gradient vectors
  VecN w_gradient;
  VecN bias_gradient;
  
  //Display coordinates
  float s_x = 0.f;
  float s_y = 0.f;
  float s_w = 0.f;
  float s_h = 0.f;
  public ANN1L(int in_d, int out_d, float x, float y, float w, float h) {
    input_dimensions = in_d;
    output_dimensions = out_d;
    s_x = x; s_y = y;
    s_w = w; s_h = h;
    //TODO - Add coordinates for displaying in the initialization here (a VecN after the id#)
    for(int i = 0; i < input_dimensions; i++)
      inputs.add(new Neuron(i));
    for(int i = 0; i < output_dimensions; i++)
      outputs.add(new Neuron(i));
  }
  
  int num_W = 0; //Number of weights in the network (total)
  int num_HW = 0; //Number of weights in the hidden layer
  int num_OW = 0; //Number of weights in the output layer
  //Refreshes the number of meaningful synaptic weights in the network.
  public void refresh_num_weights() {
    num_HW = 0;
    num_OW = 0;
    for(Neuron n : hidden)
      num_HW += n.inputs.size();
    for(Neuron n : outputs)
      num_OW += n.inputs.size();
    num_W = num_HW + num_OW;
  }
  
  //This function is good for use outside the learning environment so long as all processes have been completed
  //(and if they haven't it should probably still work just fine)
  public float[] transform(float... args) {
    if(hidden.size() == 0) return new float[]{0.f};
    if(args.length != input_dimensions) {
      System.err.println("Warning! Input vector link does not correspond to initial supplied input vector length!");
    }
    for(int i = 0; i < args.length; i++) {
      //Neuron 'positions' are within [0.f, 1.f] with inputs on the left, hidden in the middle, and outputs on the right.
      inputs.set(i, new Neuron(i, new VecN(0.1f, (i+1)/(args.length + 1)), false));
      inputs.get(i).activation = args[i];
    }
    //We don't have to use a two-step updating process (bypassed by override), we sort of do it manually to speed things up here.
    //Hidden layer processes data from the inputs
    for(Neuron n : hidden) {
      //Ensure we're overriding for every neuron, SHOULD REMOVE THIS LATER ONCE NEUROGENESIS SYSTEM IS IN PLACE
      //Same for outputs
      n.OVERRIDE_BIPARTITE_UPDATE = true;
      n.update0(inputs);
    }
    //Outputs process data from the hidden layer
    for(Neuron n : outputs) {
      n.OVERRIDE_BIPARTITE_UPDATE = true;
      n.update0(hidden);
    }
    //Dump the output layer activations into an array
    float[] results = new float[outputs.size()];
    for(int i = 0; i < results.length; i++) {
      results[i] = outputs.get(i).activation;
    }
    return results;
  }
  
  //Scoring is cumulative and is refreshed when learn() is called
  public void score(float c) {
    score_sum += c;
    scores_given++;
  }
  
  //learn() has various things it can do to modify the network or processes it can carry out.
  //Make sure to start processes directly before a TSL cycle.
  boolean busy = false;
  boolean GRAD_CALC = false;
  boolean GRAD_DESC = false;
  float weight_epsilon = 0.00001f; //the h in lim as h->0 ((f(x+h)-f(x))/h for computing partial derivatives when finding gradients. Turn up if scoring is noisy.
  float bias_epsilon = 0.00001f;
  
  //Learning rate mode
  //0 - SGD
  //1 - Momentum/Velocity
  //2 - ADAGRAD //Here and below not yet implemented
  //3 - ADADELTA
  //4 - RMSPROP
  short LR_MODE = 0;
  
  //Universal learning rate variable. We're always gonna need it.
  float LEARNING_RATE = 1.0f;
  
  //For momentum method
  float MOMENTUM_EASING = 0.9f;
  VecN w_gradient_vel = new VecN();
  VecN bias_gradient_vel = new VecN();
  
  boolean grad_up2date = false;
  boolean grad_w_done = false;
  boolean grad_bias_done = false;
  int grad_index = -1;
  
  boolean grad_w_hidden_done = false;
  int grad_w_index0 = 0; //Neuron index
  int grad_w_index1 = 0; //Connections leading to a neuron index
  int prev_grad_w_index0 = 0;
  int prev_grad_w_index1 = 0;
  
  float last_score = 0.f;
  
  float grad_samp_0 = 0.f;
  long learn_count = 0; //Number of times this function has been called
  public void learn() {
    //Normalize the score input by the number of scores given so the user doesn't have to keep the test run sample size constant.
    last_score = score_sum/(float)scores_given;
    score_sum = 0.f;
    scores_given = 0;
    
    //Gradient calculation
    
    if(GRAD_CALC) {
      busy = true;
      //If the index is 0, reset the gradient vectors and get our base sample.
      if(grad_index == 0) {
        //Get initial zero sample
        grad_samp_0 = last_score;
        if(!grad_bias_done) { bias_gradient = new VecN(); bias_gradient.name = "Bias Gradient"; }
        if(!grad_bias_done) {
          w_gradient = new VecN();
          w_gradient.name = "Weight Gradient";
          for(Neuron n : hidden) n.w_gradient = new ArrayList<Float>();
          for(Neuron n : outputs) n.w_gradient = new ArrayList<Float>();
        }
        grad_w_index0 = 0;
        grad_w_index1 = 0;
        refresh_num_weights();
      }
      
      if(!grad_w_done && grad_index > -1) {
        //WEIGHT GRADIENT CALCULATION
        //Neurons in outer loop, connections in inner loop.
        //I can't use a simple for loop here if I want to give the user freedom with the TSL testing structure.
        //So naturally the code has a lot of indices and things in it, tends to happen when you're writing a loop that ticks forward every time a function is called.
        //Biases are simpler because there will always be exactly one bias per neuron. Weights, however, are per-connection.
        if(!grad_w_hidden_done) {
          //HIDDEN LAYER WEIGHTS
          if(grad_index > 0) {
            float df = last_score - grad_samp_0;
            float dx = weight_epsilon;
            float derivative = df/dx;
            w_gradient.add(derivative);
            hidden.get(prev_grad_w_index0).w_gradient.add(derivative);
            //Reset the weight in the neural network modified last time learn() was called.
            //This operation is carried out again once hidden weight partial derivatives are calculated.
            hidden.get(prev_grad_w_index0).w.set(prev_grad_w_index1, hidden.get(prev_grad_w_index0).w.get(prev_grad_w_index1) - weight_epsilon);
          }
          prev_grad_w_index0 = grad_w_index0;
          prev_grad_w_index1 = grad_w_index1;
          
          //Modify the next value
          hidden.get(grad_w_index0).w.set(grad_w_index1, hidden.get(grad_w_index0).w.get(grad_w_index1) + weight_epsilon);
          
          grad_w_index1++;
          //If we've gone through all the connections in the neuron, move on to the next one.
          if(grad_w_index1 == hidden.get(grad_w_index0).inputs.size()) {
            grad_w_index1 = 0;
            grad_w_index0++;
            //Nest this if statement for efficiency
            if(grad_w_index0 == hidden.size()) {
              grad_w_index0 = 0;
              grad_w_index1 = 0;
              grad_w_hidden_done = true;
            }
          }
        } else {
          //This if statement has nothing to do with the output layer, it's just gathering the final derivative and setting the network back to it's old state.
          if(grad_index == num_HW) {
            float df = last_score - grad_samp_0;
            float dx = weight_epsilon;
            float derivative = df/dx;
            w_gradient.add(derivative);
            hidden.get(prev_grad_w_index0).w_gradient.add(derivative);
            hidden.get(prev_grad_w_index0).w.set(prev_grad_w_index1, hidden.get(prev_grad_w_index0).w.get(prev_grad_w_index1) - weight_epsilon);
          }
          
          //OUTPUT LAYER WEIGHTS
          //This section is basically a copy of the hidden layer weights section. No need for comments here.
          if(grad_index > num_HW) {
            float df = last_score - grad_samp_0;
            float dx = weight_epsilon;
            float derivative = df/dx;
            w_gradient.add(derivative);
            outputs.get(prev_grad_w_index0).w_gradient.add(derivative);
            outputs.get(prev_grad_w_index0).w.set(prev_grad_w_index1, outputs.get(prev_grad_w_index0).w.get(prev_grad_w_index1) - weight_epsilon);
          }
          prev_grad_w_index0 = grad_w_index0;
          prev_grad_w_index1 = grad_w_index1;
          
          outputs.get(grad_w_index0).w.set(grad_w_index1, outputs.get(grad_w_index0).w.get(grad_w_index1) + weight_epsilon);
          
          grad_w_index1++;
          if(grad_w_index1 == outputs.get(grad_w_index0).inputs.size()) {
            grad_w_index1 = 0;
            grad_w_index0++;
            if(grad_w_index0 == outputs.size()) {
              grad_w_done = true;
            }
          }
        }
        
        //Yes, the indexing is correct here, I check *after* incrementing grad_index so there's no ArrayIndexOutOfBoundsException.
        //Same for the biases.
        grad_index++;
        if(grad_index == num_W)
          grad_w_done = true;
      } else if(!grad_bias_done && grad_index > -1) {
        //Again, this next if statement has nothing to do with biases, just getting the last weight gradient and resetting the network.
        if(grad_index == num_W) {
          float df = last_score - grad_samp_0;
          float dx = weight_epsilon;
          float derivative = df/dx;
          w_gradient.add(derivative);
          outputs.get(prev_grad_w_index0).w_gradient.add(derivative);
          outputs.get(prev_grad_w_index0).w.set(prev_grad_w_index1, outputs.get(prev_grad_w_index0).w.get(prev_grad_w_index1) - weight_epsilon);
        }
        
        //BIAS GRADIENT CALCULATION
        
        //Note that the input layer doesn't have weights as the entities in it aren't really neurons. (maybe make this an option later?)
        
        //HIDDEN LAYER BIASES
        //I don't really need special index variables here, too messy, anyway. I just figure out where I'm at with grad_index.
        int bias_hidden_index = grad_index - num_W;
        //I'm seperating the resetting and getting new values from the actual modification of the values because indexing is simpler now.
        if(bias_hidden_index > 0 && bias_hidden_index <= hidden.size()) {
          //Collect and record data
          float df = last_score - grad_samp_0;
          float dx = weight_epsilon;
          float derivative = df/dx;
          bias_gradient.add(derivative);
          hidden.get(bias_hidden_index - 1).bias_gradient = derivative;
          //Reset previous bias edit
          hidden.get(bias_hidden_index - 1).bias -= bias_epsilon;
        }
        //Edit new bias
        if(bias_hidden_index < hidden.size()) {
          hidden.get(bias_hidden_index).bias += bias_epsilon;
        }
        
        //OUTPUT LAYER BIASES
        //Pretty much identical to hidden biases, no need for comments here.
        int bias_output_index = grad_index - num_W - hidden.size();
        if(bias_output_index > 0 && bias_output_index <= outputs.size()) {
          float df = last_score - grad_samp_0;
          float dx = weight_epsilon;
          float derivative = df/dx;
          bias_gradient.add(derivative);
          outputs.get(bias_output_index - 1).bias_gradient = derivative;
          outputs.get(bias_output_index - 1).bias -= bias_epsilon;
        }
        if(bias_output_index >= 0 && bias_output_index < outputs.size()) {
          outputs.get(bias_output_index).bias += bias_epsilon;
        }
        
        //Wrap everything up.
        if(bias_output_index == outputs.size()) {
          grad_bias_done = true;
        }
        
        grad_index++;
        if(grad_index == hidden.size() + output_dimensions)
          grad_bias_done = true;
      } else if(grad_index > -1) {
        grad_index = 0;
        grad_w_index0 = 0;
        grad_w_index1 = 0;
        prev_grad_w_index0 = 0;
        prev_grad_w_index1 = 1;
        grad_w_hidden_done = false;
        grad_w_done = false;
        grad_bias_done = false;
        grad_up2date = true;
        GRAD_CALC = false;
        busy = false;
      }
      if(grad_index == -1) {
       //network reset stuff goes here if there is any
       grad_index++;
      }
      return;
    }
    
    //Gradient Descent
    
    if(GRAD_DESC == true) {
      grad_up2date = false;
      VecN network_w_change = copy_vec(w_gradient);
      VecN network_bias_change = copy_vec(bias_gradient);
      //ADAPTIVE LEARNING RATE ALGORITHMS
      
      switch(LR_MODE) {
        case 1:
          //MOMENTUM
          w_gradient_vel.add(w_gradient);
          bias_gradient_vel.add(bias_gradient);
          w_gradient_vel.mult(MOMENTUM_EASING);
          bias_gradient_vel.mult(MOMENTUM_EASING);
          network_w_change = copy_vec(w_gradient_vel);
          network_bias_change = copy_vec(bias_gradient_vel);
        case 2:
          //ADAGRAD
          
        case 3:
          //ADADELTA
        
        case 4:
          //RMSPROP
          
      }
      
      network_w_change.mult(LEARNING_RATE);
      network_bias_change.mult(LEARNING_RATE);
      //MODIFICATION OF NETWORK
      //Modify network weights
      int desc_index_w = 0;
      for(Neuron n : hidden) {
        for(int i = 0; i < n.w.size(); i++) {
          n.w.set(i, n.w.get(i) - network_w_change.v[desc_index_w]);
          desc_index_w++;
        }
      }
      for(Neuron n : outputs) {
        for(int i = 0; i < n.w.size(); i++) {
          n.w.set(i, n.w.get(i) - network_w_change.v[desc_index_w]);
          desc_index_w++;
        }
      }
      //Modify network biases
      int desc_index_bias = 0;
      for(Neuron n : hidden) {
        n.bias = n.bias - network_bias_change.v[desc_index_bias];
        desc_index_bias++;
      }
      for(Neuron n : outputs) {
        n.bias = n.bias - network_bias_change.v[desc_index_bias];
        desc_index_bias++;
      }
      GRAD_DESC = false;
      return;
    }
    learn_count++;
  }
}

//Retrospectively,
//I think this would have been made a lot simpler
//if I had set up the neural networks
//with matrices

//-- Adam
//¯`·.¸¸.·´¯`·.¸  ><(((º>