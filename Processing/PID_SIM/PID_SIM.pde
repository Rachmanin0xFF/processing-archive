
//@author Adam Lastowka

//Really Pretty Simple Quadcopter Simulator 2D Version Deluxe

//Things I noticed--
//The variables that are out of our control in real life yet seem to have the most affect on the program are:
//  -The speed at which the motors react to input (motor_easing),
//  -And the noise coming in from the IMU.

Quadcopter q;

Slider Kp = new Slider(10, 10, 400, 50, "Kp");
Slider Ki = new Slider(10, 70, 400, 50, "Ki");
Slider Kd = new Slider(10, 130, 400, 50, "Kd");
Slider throttle = new Slider(10, 250, 400, 50, "Throttle");
Slider target = new Slider(10, 190, 400, 50, "Target Angle");
Button save = new Button(420, 10, 100, 100, "Save\nPID");
Button load = new Button(530, 10, 100, 100, "Load\nPID");
Theme thm = new Theme(color(255, 255), color(0, 255));
int tick = 0;

float IMU_noise_radius = 1.5f/57.2957795;
float motor_easing = 0.0002f;
float velocity_dampening = 0.95f;
float max_integral = 1.2f;
boolean use_eased_derivatives = false;
boolean lockdown = true;
float Hz = 50.f;

void setup() {
  background(255);
  size(1060, 800, P2D);
  //Themes are still VERY basic.
  Kp.set_theme(thm);
  Ki.set_theme(thm);
  Kd.set_theme(thm);
  save.set_theme(thm);
  load.set_theme(thm);
  throttle.set_theme(thm);
  target.set_theme(thm);
  Kp.display_value = true;
  Ki.display_value = true;
  Kd.display_value = true;
  target.display_value = true;
  target.set_range(-40f, 40f);
  Ki.set_range(0.f, 0.25f);
  target.round_digits = true;
  target.set_value(0.f);
  frameRate(1000);
  q = new Quadcopter();
  smooth(2);
}

void draw() {
  background(255);
  rect(-1, -1, width + 2, height + 2);
  Kp.update();
  Ki.update();
  Kd.update();
  throttle.update();
  save.update();
  load.update();
  target.update();
  Kp.display();
  Ki.display();
  Kd.display();
  throttle.display();
  target.display();
  save.display();
  load.display();
  
  //Some basic saving PID values stuff.
  if(load.is_on) {
    PVector[] p = load_data_PVector("data/PID_VALUES.txt", " ");
    Kp.set_value(p[0].x);
    Ki.set_value(p[0].y);
    Kd.set_value(p[0].z);
  }
  if(save.is_on) {
    String[] s = new String[1];
    s[0] = Kp.value + " " + Ki.value + " " + Kd.value + " ";
    saveStrings("data/PID_VALUES.txt", s);
  }
  
  q.update();
  q.display(400, 500, 200);
  plotData(640, 10, 400, 300, propal, igal, deriv);
  
  tick++;
}

ArrayList<Float> propal = new ArrayList<Float>();
ArrayList<Float> igal = new ArrayList<Float>();
ArrayList<Float> deriv = new ArrayList<Float>();

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
  
  float error = 0.f;
  float previous_error = 0.f;
  float eased_error = 0.f;
  
  float derivative = 0.f;
  float eased_derivative = 0.f;
  
  float integral = 0.f;
  
  public void updatePID() {
    error = target_angle - measured_angle;
    derivative = (error - previous_error)*Hz;
    previous_error = error;
    integral += error;
    
    eased_error = 0.2f*(abs(error) - eased_error);
    eased_derivative += 0.5*(derivative - eased_derivative);
    
    float PID_output = Math.signum(error)*abs(Kp.value*error) + Ki.value*integral + Kd.value*eased_derivative;
    
    propal.add(Kp.value*error);
    igal.add(Ki.value*integral*10.f);
    if(use_eased_derivatives)
      deriv.add(Kd.value*eased_derivative);
    else
      deriv.add(Kd.value*eased_derivative);
    if(propal.size() > 100) {
      propal.remove(0);
      igal.remove(0);
      deriv.remove(0);
    }
    
    float m_a = throttle.value - PID_output;
    float m_c = throttle.value + PID_output;
    float range = max(m_a, m_c, 1.0);
    m_a /= range;
    m_c /= range;
    
    setSpeeds(m_a, m_c);
  }
  
  public void update() {
    //Calculate basic information.
    float dt = (float(millis()) - prev_time)/1000.f;
    prev_time = float(millis());
    target_angle = target.value/57.2957795;
    measured_angle = angle + random(-IMU_noise_radius, IMU_noise_radius);
    
    //Figure out how many ticks should have gone by on the quadcopter by now.
    target_ticks = int(float(millis())/1000.f*Hz);
    //Tick the quadcopter's fake computer forward that many ticks.
    while(ticks_done < target_ticks) {
      updatePID();
      ticks_done++;
    }
    //Meanwhile, continue to tick forward the physics as fast as possible.
    
    //Easing formula I got off some forum (takes dt into account) I don't feel very good about this method of approximating motor speedup time, it could use a good amount of improving.
    real_motor_speed_C = motor_speed_C + (real_motor_speed_C - motor_speed_C)*pow(motor_easing, dt);
    real_motor_speed_A = motor_speed_A + (real_motor_speed_A - motor_speed_A)*pow(motor_easing, dt);
    
    //88 is a very approximate measure of the maximum angular acceleration a motor can apply to our quadcopter.
    //I got it from doing very approximate math for the moment of inertia of our quadcopter, and assuming that the max motor output is twice the weight of our quadcopter.
    //I also assumed our quadcopter is 2kg.
    angular_velocity += real_motor_speed_C*dt*88.f;
    angular_velocity -= real_motor_speed_A*dt*88.f;
    //Lockdown lets us simulate the quadcopter not flipping over (an artificial table for it to bang into).
    if(lockdown) {
      if(angle < -PI/4.f) { angle = -PI/4.f; angular_velocity = 0.f; }
      if(angle > PI/4.f) { angle = PI/4.f; angular_velocity = 0.f; }
    }
    
    //Dampen & forward euler integration.
    angular_velocity -= angular_velocity*velocity_dampening*dt;
    angle += angular_velocity*dt;
  }
  public void setSpeeds(float A, float C) {
    motor_speed_A = clamp(A+0.1, 0.f, 1.f);
    motor_speed_C = clamp(C, 0.f, 1.f);
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
