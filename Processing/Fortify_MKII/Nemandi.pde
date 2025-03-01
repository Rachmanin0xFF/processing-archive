//--------------------------------------------------------------------------------//

///////////////////////////////////////////////////////
//   ___  __   __  ___    ___                        //
//  |__  /  \ |__)  |  | |__  \ /     |\/| |__/ | |  //
//  |    \__/ |  \  |  | |     |      |  | |  \ | |  //
///////////////////////////////////////////////////////
//@author Adam Lastowka

//--------------------------------------------------------------------------------//
//Goals:
//  -Reinforcement learning
//  -Indep. program (maybe tack onto util?)
//  -Easy to use
//  -Supports multiple learning types
//  -Learning types are easily swappable
//
//Crystallium

//Pseudo-code:
/*
  Nemandi n = new Nemandi();
  n.mode = "ANN" | "MATRIX" | "BRUTEFORCE" | ???;
  
  loop {
    n.transform(vargs);
    usable_data = n.outputs;
    
    grade usable data performance
    
    n.score(calculated_score);
    n.learn();
  }
*/

//Stick with key 3 transform()->score()->learn() (TSL) functions for learning center
//Note - alternatively use transform()->score()->transform()->score()...->transform()->score()->learn() for multisampling
//Have a sort of "simulation queue" that Nemandi's TSL process eats up
//Individual classes handle the actual learning and organizing queues themselves, Nemandi simply holds them.

import java.lang.Math.*;

//Icelandic for "learner"
class Nemandi {
  ArrayList<Float> inputs = new ArrayList<Float>();
  ArrayList<Float> outputs = new ArrayList<Float>();
  int input_dimensions = 0;
  int output_dimensions = 0;
  String mode = "";
  //Display coordinates
  float s_x;
  float s_y;
  float s_w;
  float s_h;
  public Nemandi(int in_d, int out_d, float x, float y, float w, float h) {
    input_dimensions = in_d;
    output_dimensions = out_d;
    s_x = x; s_y = y;
    s_w = w; s_h = h;
  }
  //Take an input vector (sensor data, etc.) and put the resulting output (motor speeds, etc.) into the outputs ArrayList.
  public float[] transform(float... inputs) {
    return null;
  }
  //Gives Nemandi a score on how well her current configuration is working.
  public void score(float c) {
    
  }
  //Tells Nemandi to learn based on the scores you gave it.
  public void learn() {
    
  }
}