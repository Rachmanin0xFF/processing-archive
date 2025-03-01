import processing.net.*;
Client myClient;

Buffer accel_buffer = new Buffer(10);
Buffer gyro_buffer = new Buffer(10);
PVector p_r_accel = new PVector();
PVector p_r_gyros = new PVector();
PVector rotation = new PVector();
int minDataLen = 20;

float prevMillis = 0;

int passedITR = 0;

ArrayList<Float> d1 = new ArrayList<Float>();
ArrayList<Float> d2 = new ArrayList<Float>();
ArrayList<Float> d3 = new ArrayList<Float>();
ArrayList<Float> d4 = new ArrayList<Float>();
ArrayList<Float> d5 = new ArrayList<Float>();

void setup() {
  size(1280, 720);
  myClient = new Client(this, "192.168.1.24", 25501);
  stroke(255);
  background(0);
}

void draw() {
  background(0);
  if(myClient.available() > 0) {
    String dataIn = "";
    PVector r_accel = new PVector();
    PVector r_gyros = new PVector();
    dataIn = myClient.readString(); 
    if (dataIn.length() > minDataLen) {
      String[] dataPackets = dataIn.split("%");
      if(dataPackets.length > 1){
        float w1 = 0.0f;
        float w2 = 0.0f;
        for(int i = 0; i < dataPackets.length; i++) {
          String chunk = dataPackets[i];
          if(chunk.split("~").length>5){
            float w12 = 1.0f;
            float w22 = 1.0f;
            PVector vec1 = new PVector();
            PVector vec2 = new PVector();
            vec1.x += float(chunk.split("~")[0]);
            vec1.y += float(chunk.split("~")[1]);
            vec1.z += float(chunk.split("~")[2]);
            vec2.x += float(chunk.split("~")[3]);
            vec2.y += float(chunk.split("~")[4]);
            vec2.z += float(chunk.split("~")[5]);
            vec1.mult(w12);
            vec2.mult(w22);
            w1 += w12;
            w2 += w22;
            r_accel.add(vec1);
            r_gyros.add(vec2);
          }
        }
        r_accel.mult(1.0f/w1);
        r_gyros.mult(1.0f/w2);
      }
    }
    
    if((abs(r_accel.x) < 0.0000001f && abs(r_accel.y) < 0.0000001f && abs(r_accel.z) < 0.0000001f))
      r_accel = p_r_accel;
    p_r_accel = r_accel;
    if((abs(r_gyros.x) < 0.0000001f && abs(r_gyros.y) < 0.0000001f && abs(r_gyros.z) < 0.0000001f))
      r_gyros = p_r_gyros;
    p_r_gyros = r_gyros;
    
    accel_buffer.addVal(r_accel);
    gyro_buffer.addVal(r_gyros);
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    rotation = mulV(rotation, 0.95f);
    
    PVector q2 = calcAngles(accel_buffer.getLinearAvg());
    PVector q = accel_buffer.getLinearAvg();
    d1.add(q.x);
    d2.add(q.y);
    d3.add(q.z);
    d4.add(q2.x);
    d5.add(q2.y);
    passedITR++;
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    println(millis()-prevMillis);
    prevMillis = millis();
  }
  stroke(255, 0, 0);
  //dispData(d1, true, -3.5, 3.5);
  stroke(0, 255, 0);
  //dispData(d2, true, -3.5, 3.5);
  stroke(0, 0, 255);
  //dispData(d3, true, -3.5, 3.5);
  
  stroke(255, 0, 255);
  dispData(d4, true, -3.5, 3.5);
  stroke(255, 255, 0);
  dispData(d5, true, -3.5, 3.5);
}

public PVector calcAngles(PVector in) {
  float outX = atan2(in.z, in.y);
  float outY = atan2(in.z, in.x);
  float outZ = atan2(in.y, in.x);
  return new PVector(outX, outY, outZ);
}

class Buffer {
  public PVector[] data;
  public Buffer(int capacity) {
    data = new PVector[capacity];
    for(int i = 0; i < data.length; i++)
      data[i] = new PVector();
  }
  public void addVal(PVector val) {
    for(int i = 0; i < data.length-1; i++) {
      data[i] = data[i+1];
    }
    data[data.length-1] = val;
  }
  public PVector getAvg() {
    PVector p = new PVector();
    for(int i = 0; i < data.length; i++)
      p.add(data[i]);
    p.div((float)data.length);
    return p;
  }
  public PVector getLinearAvg() {
    PVector p = new PVector();
    float w = 0.0f;
    for(int i = 0; i < data.length; i++) {
      w += (float)i + 1.0f;
      PVector t = new PVector(data[i].x, data[i].y, data[i].z);
      t.mult((float)i + 1.0f);
      p.add(t);
    }
    p.div((float)w);
    return p;
  }
}

void dispData(ArrayList<Float> ls, boolean useMinMax, float minRange, float maxRange) {
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

PVector addV(PVector a, PVector b) {
  return new PVector(a.x + b.x, a.y + b.y, a.z + b.z);
}

PVector subV(PVector a, PVector b) {
  return new PVector(a.x - b.x, a.y - b.y, a.z - b.z);
}

PVector mulV(PVector a, float x) {
  return new PVector(a.x * x, a.y * x, a.z * x);
 }
