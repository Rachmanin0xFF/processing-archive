
Quadcopter quad = new Quadcopter();
ArrayList<Neuron> network = new ArrayList<Neuron>();

Button butt = new Button(10, 10, 100, 100, "Emplace");
Slider target = new Slider(10, 120, 360, 50, "Target Angle");
Theme myTheme = new Theme(color(255, 255), color(0, 255));

void setup() {
  size(800, 600, P2D);
  background(255);
  stroke(0, 255);
  noSmooth();
  frameRate(50);
  butt.set_theme(myTheme);
  target.set_theme(myTheme);
  network = loadNetwork(prompt_file());
  //network = loadNetwork("D:\\Processing\\Fortify_MKI\\output\\ANN2015-4-6-14-17-18-71237.ann");
  println(network.size());
  target.set_range(-PI, PI);
  target.set_value(0.f);
  target.round_digits = true;
}

void draw() {
  background(255);
  
  
  target.update();
  target.display();
  butt.update();
  butt.display();
  if(butt.is_on) {
    quad.angle = 0.f;
    quad.angular_velocity = 0.f;
  }
  
  for(Neuron n : network)
    n.update0(network);
  for(Neuron n : network)
    n.update1();
  quad.setSpeeds((float)network.get(2).activation, -(float)network.get(2).activation);
  network.get(0).activation = (quad.measured_angle + target.value)%TWO_PI;
  network.get(1).activation = clamp((quad.angular_velocity + random(-IMU_noise_radius, IMU_noise_radius))/3.f, -TWO_PI*2.f, TWO_PI*2.f);
  for(int i = 0; i < 10; i++)
    quad.update();
  quad.display(400, 400, 200);
  println(float(frameCount)*20.f/1000.f);
}

void displayNetwork(ArrayList<Neuron> network) {
  stroke(0, 60);
  fill(0, 255);
  strokeCap(SQUARE);
  for(Neuron n : network) {
    stroke(0, 100);
    strokeWeight((float)(0.5-abs((float)n.activation))*20.f);
    stroke(0, 60);
    point((float)n.r.x, (float)n.r.y);
    //text(round_to((float)n.activation, 4), (float)n.r.x, (float)n.r.y);
    strokeWeight(1);
    for(int i : n.inputs) {
      line((float)n.r.x, (float)n.r.y, (float)network.get(i).r.x, (float)network.get(i).r.y);
    }
  }
  stroke(0, 255);
}

float gradePf(ArrayList<Neuron> network) {
  Quadcopter quad = new Quadcopter();
  
  String s = "# rotation log-\n";
  float score = 0.f;
  float[] data = new float[500];
  for(int i = 0; i < 500; i++) {
    //The code in this loop is 20ms in quad-time; the loop itself is 10 seconds (for 500 iterations).
    for(Neuron n : network)
      n.update0(network);
    for(Neuron n : network)
      n.update1();
    quad.setSpeeds((float)network.get(2).activation, -(float)network.get(2).activation);
    network.get(0).activation = quad.measured_angle%TWO_PI;
    network.get(1).activation = clamp((quad.angular_velocity + random(-IMU_noise_radius, IMU_noise_radius))/3.f, -TWO_PI*2.f, TWO_PI*2.f);
    for(int j = 0; j < 10; j++)
      quad.update();
    s += "r " + quad.angle + "\n";
    data[i] = quad.angle;
  }
  s += "\n";
  
  score = standard_deviation(data);
  return score;
}

void saveNetwork(ArrayList<Neuron> network, String location, String... header) {
  ArrayList<String> data = new ArrayList<String>();
  for(String s : header)
    data.add(s);
  data.add("# key:");
  data.add("#     n - neuron I.D. - neuron name");
  data.add("#     b - neuron bias");
  data.add("#     a - is neuron active?");
  data.add("#     w weight1 weight2 weight3 ...");
  data.add("#     i inputID1 inputID2 inputID3 ...");
  int k = 0;
  for(Neuron n : network) {
    data.add("");
    data.add("n " + k + " " + n.name);
    data.add("b " + n.bias);
    data.add("a " + n.active);
    String weights = "";
    String inputs = "";
    for(double d : n.w)
      weights += d + " ";
    for(int i : n.inputs)
      inputs += i + " ";
    data.add("w " + weights);
    data.add("i " + inputs);
    k++;
  }
  String[] s = new String[data.size()];
  for(int i = 0; i < s.length; i++)
    s[i] = data.get(i);
  saveStrings(location, s);
}

ArrayList<Neuron> loadNetwork(String location) {
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
    if(s.startsWith("a") && s.equals("a false")) {
      current_neuron.active = false;
    }
    if(s.startsWith("w")) {
      String[] sq = s.split(" ");
      for(int i = 1; i < sq.length; i++) {
        current_neuron.w.add(Double.parseDouble(sq[i]));
      }
    }
    if(s.startsWith("i")) {
      String[] sq = s.split(" ");
      for(int i = 1; i < sq.length; i++) {
        current_neuron.inputs.add(Integer.parseInt(sq[i]));
      }
    }
  }
  net.add(current_neuron);
  return net;
}

void emplace(ArrayList<Neuron> network) {
  //network = new ArrayList<Neuron>();
  network.add(new Neuron(new VecN(50, height/4 - 10), false));
  network.add(new Neuron(new VecN(50, height/4 + 10), false));
  network.add(new Neuron(new VecN(width - 150, height/4 - 10)));
  //network.add(new Neuron(new VecN(width - 150, height/4 + 10)));
  float count = 10.f;
  
  for(int i = 0; i < count; i++) {
    network.add(new Neuron(random(-1.0, 1.0), new VecN(width/2 + random(-200, 200), random(-200, 200) + height/4)));
    //network.get(network.size() - 1).add_connection(0, random(-0.5, 0.5));
    //network.get(network.size() - 1).add_connection(1, random(-0.5, 0.5));
    //network.get(2).add_connection(network.size() - 1, random(-0.5, 0.5));
    //network.get(3).add_connection(network.size() - 1, random(-0.5, 0.5));
  }
  
  for(int i = 0; i < network.size(); i++) {
    for(int j = 0; j < network.size(); j++) {
      if(network.get(i).r.distance_to(network.get(j).r) < 200.0 && network.get(i).r.x < network.get(j).r.x && i > 2 && j > 2)
        network.get(j).add_connection(i, random(-1, 1));
    }
  }
  
  for(int k = 0; k < 3; k++) {
    double min_x = 1000000.;
    int min_id = 0;
    for(int i = 3; i < network.size(); i++) {
      if(!network.get(i).inputs.contains(0) && network.get(i).r.x < min_x) {
        min_x = network.get(i).r.x;
        min_id = i;
      }
    }
    if(min_x != 1000000.)
      network.get(min_id).add_connection(0, random(-1, 1));
      network.get(min_id).add_connection(1, random(-1, 1));
    double max_x = 0.;
    int max_id = 0;
    for(int i = 3; i < network.size(); i++) {
      if(!network.get(2).inputs.contains(i) && network.get(i).r.x > max_x) {
        max_x = network.get(i).r.x;
        max_id = i;
      }
    }
    if(max_x != 0.)
      network.get(2).add_connection(max_id, random(-1, 1));
    network.get(2).add_connection((int)random(network.size()-1), random(-1, 1));
    network.get(0).add_connection((int)random(network.size()-1), random(-1, 1));
    network.get(1).add_connection((int)random(network.size()-1), random(-1, 1));
  }
}

class Neuron {
  String name = "";
  int id = -1;
  double activation = 0.;
  double bias = 0.;
  ArrayList<Double> w = new ArrayList<Double>();
  ArrayList<Integer> inputs = new ArrayList<Integer>();
  VecN r = new VecN();
  boolean active = true;
  public Neuron() {
  }
  public Neuron(int id) {
    this.id = id;
  }
  public Neuron(int id, double b) {
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
  public Neuron(double b, VecN position) {
    bias = b;
    r = copy_vec(position);
  }
  public Neuron(int id, double b, VecN position) {
    bias = b;
    r = copy_vec(position);
    this.id = id;
  }
  void add_connection(int id, double weight) {
    inputs.add(id);
    w.add(weight);
    this.id = id;
  }
  double temporary_activation = 0.;
  void update0(ArrayList<Neuron> n) {
    if(active) {
      temporary_activation = bias;
      for(int k = 0; k < w.size(); k++) {
        temporary_activation += w.get(k)*n.get(inputs.get(k)).activation;
      }/*
      double q = fast_exp(temporary_activation);
      temporary_activation = q/(1.+q);*/
      temporary_activation = sigmoid((float)temporary_activation);
    }
  }
  void update0(Neuron[] n) {
    if(active) {
      temporary_activation = bias;
      for(int k = 0; k < w.size(); k++) {
        temporary_activation += w.get(k)*n[inputs.get(k)].activation;
      }
      temporary_activation = 1./(1.+fast_exp(-temporary_activation));
    }
  }
  void update1() {
    if(active) {
      activation = temporary_activation;
    }
  }
}

float IMU_noise_radius = 1.5f/57.2957795;
float motor_easing = 0.0002f;
float velocity_dampening = 0.95f;
public class Quadcopter {
  float angle;
  float measured_angle;
  float angular_velocity;
  float target_angle;
  float motor_speed_C = 0.0f; //0.0 - 1.0//0N - 10N (estimated)//
  float motor_speed_A = 0.0f; //0.0 - 1.0//0N - 10N (estimated)//
  float real_motor_speed_C = 0.0f;
  float real_motor_speed_A = 0.0f;
  float prev_time;
  int target_ticks = 0;
  int ticks_done = 0;
  public Quadcopter() {
    angle = 0.f;
    angular_velocity = 0.0f;
    target_angle = 0.f;
    prev_time = millis();
  }
  
  public void update() {
    //Calculate basic information.
    float dt = (float(millis()) - prev_time)/1000.f;
    prev_time = float(millis());
    dt = 2.f/1000.f; // two thousandths of a second (ANN updates every 20 thousandths)
    //target_angle = target.value/57.2957795;
    target_angle = 0.f;
    measured_angle = angle + random(-IMU_noise_radius, IMU_noise_radius);
    //Meanwhile, continue to tick forward the physics as fast as possible.
    
    //Easing formula I got off some forum (takes dt into account) I don't feel very good about this method of approximating motor speedup time, it could use a good amount of improving.
    real_motor_speed_C = motor_speed_C + (real_motor_speed_C - motor_speed_C)*pow(motor_easing, dt);
    real_motor_speed_A = motor_speed_A + (real_motor_speed_A - motor_speed_A)*pow(motor_easing, dt);
    
    //42 is a very approximate measure of the maximum angular acceleration a motor can apply to our quadcopter.
    //I got it from doing very approximate math for the moment of inertia of our quadcopter, and assuming that the max motor output is twice the weight of our quadcopter.
    //I also assumed our quadcopter is 2kg.
    angular_velocity += real_motor_speed_C*dt*42.f;
    angular_velocity -= real_motor_speed_A*dt*42.f;
    //Lockdown lets us simulate the quadcopter not flipping over (an artificial table for it to bang into).
    boolean c = false;
    if(false) {
      if(angle < -PI/4.f) { angle = -PI/4.f; angular_velocity = 0.f; c = true;}
      if(angle > PI/4.f) { angle = PI/4.f; angular_velocity = 0.f; c = true;}
    }
    
    //Dampen & forward euler integration.
    angular_velocity -= angular_velocity*velocity_dampening*dt;
    if(c) angular_velocity = 0.f;
    angle += angular_velocity*dt;
  }
  public void setSpeeds(float A, float C) {
    motor_speed_A = clamp(A + 0.5f, 0.f, 1.f);
    motor_speed_C = clamp(C + 0.5f, 0.f, 1.f);
  }
  float err_vg = 0.f;
  public void display(float x, float y, float radius) {
    float err_vq = abs(angle - target_angle);
    err_vg += 0.01*(err_vq - err_vg);
    println("Error: " + err_vg*57.2957795);
    noFill();
    pushMatrix();
    translate(x, y);
    rotate(angle);
    text("C", -radius, 10);
    text("A", radius, 10);
    rect(-radius/10.f, -radius/10.f, radius/5.f, radius/5.f);
    popMatrix();
    line(x - cos(angle)*radius, y - sin(angle)*radius, x + cos(angle)*radius, y + sin(angle)*radius);
    stroke(0, 255, 0);
    float ll = 1.f;
    line(x - cos(angle)*radius, y - sin(angle)*radius, x - cos(angle)*radius + cos(angle-PI/2)*radius/2.f*real_motor_speed_C*ll, y - sin(angle)*radius + sin(angle-PI/2)*radius/2.f*real_motor_speed_C*ll);
    line(x + cos(angle)*radius, y + sin(angle)*radius, x + cos(angle)*radius + cos(angle-PI/2)*radius/2.f*real_motor_speed_A*ll, y + sin(angle)*radius + sin(angle-PI/2)*radius/2.f*real_motor_speed_A*ll);
    //Grabby grabby code
    if(mousePressed && dist(mouseX, mouseY, x, y) < radius) {
      if(mouseX > x)
        angle = atan2(mouseY - y, mouseX - x);
      else
        angle = atan2(-(mouseY - y), -(mouseX - x));
    }
  }
}

void plotData(float x, float y, float w, float h, ArrayList<Float>... input) {
  stroke(0, 100);
  line(x, y + h/2.f, x + w, y + h/2.f);
  noFill();
  stroke(0, 255);
  rect(x, y, w, h);
  color[] dataColors = new color[]{color(200, 200, 0), color(0, 200, 200), color(200, 0, 200), color(200, 0, 0), color(0, 200, 0), color(0, 0, 200)};
  int k = 0;
  blendMode(SUBTRACT);
  for(ArrayList<Float> data : input) {
    stroke(dataColors[k%dataColors.length]);
    for(float i = 0.f; i < data.size()-1.f; i++) {
      line(map(i, 0.f, data.size(), x, x + w), clamp(map(data.get(int(i)), -1.f, 1.f, y + h, y), y, y + h), map(i + 1.f, 0.f, data.size(), x, x + w), clamp(map(data.get(int(i + 1.f)), -1.f, 1.f, y + h, y), y, y + h));
    }
    k++;
  }
  blendMode(BLEND);
}

boolean bfjwelkfjwe = true;
void keyPressed() {
  if(key == ' ')
    bfjwelkfjwe = !bfjwelkfjwe;
  if(bfjwelkfjwe)
    loop();
  else
    noLoop();
}
