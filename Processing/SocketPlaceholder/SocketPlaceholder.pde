
import processing.net.*; 
Client myClient; 
String dataIn; 
 
boolean useMinMax = true;
float minRange = -3.1416f;
float maxRange = 3.1516f;

float rx = 0;
float ry = 0;
float rz = 0;
float prx = 0;
float pry = 0;
float prz = 0; 

ArrayList<Float> R = new ArrayList<Float>();
 
void setup() { 
  size(720, 1000, P3D);
  frameRate(1000000000);
  myClient = new Client(this, "192.168.1.5", 25501); 
} 
 
void draw() {
  fill(255);
  stroke(0);
  if(!keyPressed)
    background(255);
  if (myClient.available() > 0) {
    dataIn = myClient.readString(); 
    try {
      try {
        if(dataIn != null) {
          String[] cmds = dataIn.split("~");
          rx = 0; ry = 0; rz = 0;
          for(String s : cmds) {
            String[] cmds2 = s.split("`");
            float x = Float.parseFloat(cmds2[0]);
            float y = Float.parseFloat(cmds2[1]);
            float z = Float.parseFloat(cmds2[2]);
            rx += x; ry += y; rz += z;
          }
          rx /= float(cmds.length);
          ry /= float(cmds.length);
          rz /= float(cmds.length);
          if(abs(rx - prx) > 10 || rx == 0) rx = prx;
          if(abs(ry - pry) > 10 || ry == 0) ry = pry;
          if(abs(rz - prz) > 10 || rz == 0) rz = prz;
          prx = rx;
          pry = ry;
          prz = rz;
          R.add(rx);
        }
      } catch(NumberFormatException nfe) {}
    } catch(ArrayIndexOutOfBoundsException aiobe) {}
  }
  /*
  if(!keyPressed) {
    translate(width/2, height/2);
    rotateZ(-ry);
    rotateX(rx);
    stroke(255, 0, 0);
    strokeWeight(3);
    line(0, 0, 0, 0, -200, 0);
    stroke(0);
    strokeWeight(1);
    translate(0, -200, 0);
    sphere(30);
  }
  */
  dispData(R);
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
  //beginShape();
  for(float i = 0.0f; i < ls.size(); i += 1.0f) {
    float thisVal = ls.get((int)i);
    float prevVal = thisVal;
    if(i > 0.0f) prevVal = ls.get((int)(i-1));
    thisVal = map(thisVal, min, max, height, 0);
    prevVal = map(prevVal, min, max, height, 0);
    //curveVertex(i*float(width)/float(ls.size()-1), thisVal);
    strokeWeight(1);
    line((i-1.0f)*float(width)/float(ls.size()-1), prevVal, i*float(width)/float(ls.size()-1), thisVal);
  }
  //endShape();
}

