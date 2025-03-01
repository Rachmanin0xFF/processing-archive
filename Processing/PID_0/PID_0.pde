float Kp = 0.3f;
float Ki = 0.02f;
float Kd = 0.16f;

float error = 0.f;
float previous_error = 0.f;
float setpoint = 1.f;
float measured_value = 0.f;
float output = 0.f;

float integral = 0.f;
float derivative = 0.f;

float dt = 0.1f;

void setup() {
  size(512, 512, P2D);
  Kp = 0.5f;
  Ki = 0.2f;
  Kd = 0.1f;
}

ArrayList<Float> data = new ArrayList<Float>();
ArrayList<Float> setpoint_data = new ArrayList<Float>();
void draw() {
  background(255);
  line(0, map(setpoint, 2.0f, 0.0f, 0, height), width, map(setpoint, 2.0f, 0.0f, 0, height));
  if (mousePressed) line(0, mouseY, width, mouseY);
  stroke(0, 100);
  float fh = map(measured_value, 0.f, 2.f, height, 0.f);
  line(0, fh, width, fh);
  stroke(0, 255);
  data.add(measured_value);
  setpoint_data.add(setpoint);
  if (data.size() > 200)
    data.remove(0);
  if (setpoint_data.size() > 200)
    setpoint_data.remove(0);
  dispData(data, true, 0.f, 2.f);
  stroke(0, 255, 0);
  dispData(setpoint_data, true, 0.f, 2.f);
  stroke(0);
  
  float f = float(mouseX)/width;
  error = setpoint - measured_value;
  integral = integral + error*dt;
  derivative = (error - previous_error)/dt;
  output = f*Kp*error + f*Ki*integral + f*Kd*derivative;
  previous_error = error;

  //measured_value += map(mouseY, 0, height, 0.1f, -0.1f);
  setpoint = map(mouseY, 0, height, 2.0f, 0.0f);
  measured_value += output;
}

void mousePressed() {
  measured_value = map(mouseY, 0, height, 2.f, 0.f);
}

void dispData(ArrayList<Float> ls, boolean useMinMax, float minRange, float maxRange) {
  float max = 0.0f;
  float min = 0.0f;
  for (float f : ls) if (f > max) max = f;
  for (float f : ls) if (f < min) min = f;
  if (useMinMax) {
    min = minRange;
    max = maxRange;
  }
  for (float i = 0.0f; i < ls.size (); i += 1.0f) {
    float thisVal = ls.get((int)i);
    float prevVal = thisVal;
    if (i > 0.0f) prevVal = ls.get((int)(i-1));
    thisVal = map(thisVal, min, max, height, 0);
    prevVal = map(prevVal, min, max, height, 0);
    line((i-1.0f)*float(width)/float(ls.size()-1), prevVal, i*float(width)/float(ls.size()-1), thisVal);
  }
}

