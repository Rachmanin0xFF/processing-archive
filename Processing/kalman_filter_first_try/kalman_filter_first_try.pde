ArrayList<Float> list1 = new ArrayList<Float>();
ArrayList<Float> list2 = new ArrayList<Float>();
ArrayList<Float> list3 = new ArrayList<Float>();

float deltaTime = 0.0f;
float prevMillis = 0.0f;

boolean useMinMax = true;
float minRange = -10000.0f;
float maxRange = 10000.0f;

float errorRange = 50.0f;
float errorDrift = 0f;
float trueSum = 0.0f;
float sensorSum = 0.0f;
float easedVal = 0.0f;
float easedSum = 0.0f;

void setup() {
  size(1280, 720, P2D);
  background(0);
  blendMode(ADD);
  frameRate(1000);
}

void draw() {
  background(0);
  deltaTime = float(millis()) - prevMillis;
  text(int(1000.0f/deltaTime) + " HZ", 10, 10);
  prevMillis = float(millis());
  
  float trueReading = float(mouseX-width/2)/10.0f;
  float sensorReading = trueReading + random(-errorRange, errorRange) + errorDrift;
  
  easedVal += 0.1*(sensorReading - easedVal);
  easedSum += easedVal;
  trueSum += trueReading;
  sensorSum += sensorReading;
  
  list1.add(trueSum);
  list2.add(sensorSum);
  list3.add(easedSum);
  
  stroke(255, 0, 0);
  dispData(list1);
  stroke(0, 255, 0);
  dispData(list2);
  stroke(0, 0, 255);
  dispData(list3);
}

void dispData(ArrayList<Float> ls) {
  float max = 0.0f;
  float min = 0.0f;
  for(float f : ls) if(f > max) max = f;
  for(float f : ls) if(f < min) min = f;
  if(useMinMax) {
    min = minRange;
    max = maxRange;
  }
  for(float i = 0.0f; i < ls.size(); i += 1.0f) {
    float thisVal = ls.get((int)i);
    float prevVal = thisVal;
    if(i > 0.0f) prevVal = ls.get((int)(i-1));
    thisVal = map(thisVal, min, max, height, 0);
    prevVal = map(prevVal, min, max, height, 0);
    line((i-1.0f)*float(width)/float(ls.size()-1), prevVal, i*float(width)/float(ls.size()-1), thisVal);
  }
}
