
import processing.opengl.*;

////////////////////////////
//Written by Adam Lastowka//
////////////////////////////

float zoom = 1;
int t;
DataPoint[] testP;
String ax1;
String ax2;
String ax3;
String ax4;
float mX;
float mY;
float scaleX = 0.1;
float scaleY = 0.1;
float scaleZ = 0.1;

////////////////////////////////////////////////////////////////////////////////
//  0    1     2     3     4     5     6     7     8      9      10     11    //
//{min1, max1, min2, max2, min3, max3, min4, max4, meanX, meanY, meanZ, meanW}//
////////////////////////////////////////////////////////////////////////////////
float[] minmaxes = new float[8];

void setup() {
   perspective(PI/3.0,(float)width/height,1,1000000);
  sphereDetail(15);
  size(1920, 1080, P3D);
  
  /********************************************/
  //Usage: loadFile(String fileLocation, boolean haveNames, int numValues, String delimiterChars);
  testP = loadFile("tempA.txt", false, 3, ",");
  /********************************************/
  
  minmaxes = minMaxDataPointArray(testP);
  println(minmaxes[1]);
  println(minmaxes[3]);
  println(minmaxes[5]);
}

void draw() {
  pushMatrix();
  background(0);
  cameraSet(t);
  scale(1, -1, 1);
  fakeDraw();
  t++;
  scale(1, -1, 1);
  popMatrix();
  
  fill(255, 255, 0);
  stroke(255, 255, 0);
  text(ax1, 50, 20);
  line(10, 15, 45, 15);
  
  fill(0, 255, 255);
  stroke(0, 255, 255);
  text(ax2, 50, 40);
  line(10, 35, 45, 35);
  
  fill(255, 0, 255);
  stroke(255, 0, 255);
  text(ax3, 50, 60);
  line(10, 55, 45, 55);
  
  colorMode(HSB);
  fill(t%255, 255, 255);
  stroke(t%255, 255, 255);
  text(ax4, 50, 80);
  line(10, 75, 45, 75);
  if(keyPressed) {
    if(key=='a')
      zoom /= 1.01;
    if(key=='s')
      zoom *= 1.01;
  }
  mX += 0.01*(mouseX-mX);
  mY += 0.01*(mouseY-mY);
}

void cameraSet(float t) {
  //zoom = map(pow(1.01, mouseY), 0, pow(1.01, height), 0.1/(minmaxes[1] + minmaxes[3] + minmaxes[5])/3, 50);
  scale(zoom);
  translate(width/2/zoom, height/2/zoom);
  rotateY(map(mX*2,0,width,-PI,PI));
  rotateX(map(mY*2,0,height,-PI,PI));
  rotateX(PI);
  translate(scaleX*-minmaxes[8], scaleY*minmaxes[9], scaleZ*-minmaxes[10]);
}

void fakeDraw() {
  stroke(255);
  colorMode(HSB);
  for(int i = 0; i < testP.length; i++) {
    testP[i].drawPoint(false);
  }
  println(testP.length);
  colorMode(HSB);
  stroke(t%255, 255, 255);
  colorMode(RGB);
  strokeWeight(1);
  pushMatrix();
  translate(minmaxes[8]*scaleX, minmaxes[9]*scaleY, minmaxes[10]*scaleZ);
  rotateX(float(t)/100);
  sphere(200*(scaleX+scaleY+scaleZ)/3);
  rotateY(-float(t)/100);
  rotateX(-float(t)/100);
  sphere(100*(scaleX+scaleY+scaleZ)/3);
  popMatrix();
  stroke(255, 255, 255);
  strokeWeight(1);
  
  noFill();
  pushMatrix();
  scale(scaleX, scaleY, scaleZ);
  translate((minmaxes[0] + minmaxes[1])/2, (minmaxes[2] + minmaxes[3])/2, (minmaxes[4] + minmaxes[5])/2);
  box(-minmaxes[0] + minmaxes[1], -minmaxes[2] + minmaxes[3], -minmaxes[4] + minmaxes[5]);
  popMatrix();
  strokeWeight(5);
  stroke(255, 255, 0);
  line(minmaxes[0]*scaleX, 0, 0, minmaxes[1]*scaleX, 0, 0);
  stroke(0, 255, 255);
  line(0, minmaxes[2]*scaleY, 0, 0, minmaxes[3]*scaleY, 0);
  stroke(255, 0, 255);
  line(0, 0, minmaxes[4]*scaleZ, 0, 0, minmaxes[5]*scaleZ);
  
  fill(255);
}

class DataPoint {
  
  ArrayList<Float> coordinates;
  String myName;
  
  public DataPoint(String name, float... vals) {
    coordinates = new ArrayList<Float>();
    for(float k : vals)
      coordinates.add(new Float(k));
    myName = name;
  }
  
  public void drawPoint(boolean showName) {
    ArrayList<Float> c = new ArrayList<Float>();
    c.add(coordinates.get(0)*scaleX);
    c.add(coordinates.get(1)*scaleY);
    c.add(coordinates.get(2)*scaleZ);
    c.add(coordinates.get(3));
    strokeWeight(2);
    stroke(255, 0, 255, 255);
      switch(c.size()) {
        case 1:
          go(c.get(0), 0, 0);
          if(showName)
            text(" " + myName, c.get(0), 0, 0);
          break;
          
        case 2:
        if(showName)
            text(" " + myName, c.get(0), c.get(1), 0);
          go(c.get(0), c.get(1), 0);
          break;
          
        case 3:
        stroke(c.get(3));
        if(showName)
            text(" " + myName, c.get(0), c.get(1), c.get(2));
          go(c.get(0), c.get(1), c.get(2));
          break;
        case 4:
        stroke(map(c.get(3), minmaxes[6], minmaxes[7], 0, 255), 255, 255);
        strokeWeight(map(c.get(3), minmaxes[6], minmaxes[7], 1, 5));
        if(showName)
            text(" " + myName, c.get(0), c.get(1), c.get(2));
          go(c.get(0), c.get(1), c.get(2));
          break;
          
        default:
        if(showName)
            text(" " + myName, c.get(0), c.get(1), c.get(2));
          go(c.get(0), c.get(1), c.get(2));
          break;
      }
  }
}
void go(float x, float y, float z) {
  noFill();
  strokeWeight(2);
  point(x, y, z);
}

float[] minMaxDataPointArray(DataPoint[] dps) {
  float[] returnArray = new float[12];
  float hi;
  float lo;
  float meanX = 0;
  float meanY = 0;
  float meanZ = 0;
  float meanW = 0;
  for(int i = 0; i < dps.length; i++) {
    DataPoint tempP = dps[i];
    meanX += tempP.coordinates.get(0);
    if(tempP.coordinates.size()>0) {
      meanX += tempP.coordinates.get(0);
      if(tempP.coordinates.get(0)<returnArray[0])
        returnArray[0] = tempP.coordinates.get(0);
      if(tempP.coordinates.get(0)>returnArray[1])
        returnArray[1] = tempP.coordinates.get(0);
    }
    if(tempP.coordinates.size()>1) {
      meanY += tempP.coordinates.get(1);
      if(tempP.coordinates.get(1)<returnArray[2])
        returnArray[2] = tempP.coordinates.get(1);
      if(tempP.coordinates.get(1)>returnArray[3])
        returnArray[3] = tempP.coordinates.get(1);
    }
    if(tempP.coordinates.size()>2) {
      meanZ += tempP.coordinates.get(2);
      if(tempP.coordinates.get(2)<returnArray[4])
        returnArray[4] = tempP.coordinates.get(2);
      if(tempP.coordinates.get(2)>returnArray[5])
        returnArray[5] = tempP.coordinates.get(2);
    }
    if(tempP.coordinates.size()>3) {
      meanW += tempP.coordinates.get(3);
      if(tempP.coordinates.get(3)<returnArray[6])
        returnArray[6] = tempP.coordinates.get(3);
      if(tempP.coordinates.get(3)>returnArray[7])
        returnArray[7] = tempP.coordinates.get(3);
    }
  }
  meanX /= float(dps.length);
  meanY /= float(dps.length);
  meanZ /= float(dps.length);
  meanW /= float(dps.length);
  returnArray[8] = meanX;
  returnArray[9] = meanY;
  returnArray[10] = meanZ;
  returnArray[11] = meanW;
  return returnArray;
}

public DataPoint[] loadFile(String fileLocation, boolean names, int len, String delimiterChar) {
  println("Loading File " + fileLocation);
  String[] lines = loadStrings(fileLocation);
  String[] axes = lines[0].split(delimiterChar);
  if(axes.length > 0)
    ax1 = axes[0];
  if(axes.length > 1)
    ax2 = axes[1];
  if(axes.length > 2)
    ax3 = axes[2];
  if(axes.length > 3)
    ax4 = axes[3];
  DataPoint[] out = new DataPoint[lines.length-1];
  for(int i = 1; i < out.length+1; i++) {
    String k = Integer.toString(i);
    String[] subLines = lines[i].split(delimiterChar);
    
    if(names) {
      println("Names on.");
    switch(len) {
      case 1:
        out[i-1] = new DataPoint(subLines[0]);
        break;
      case 2:
        out[i-1] = new DataPoint(subLines[0], float(subLines[1]));
        break;
      case 3:
        out[i-1] = new DataPoint(subLines[0], float(subLines[1]), float(subLines[2]));
        break;
      case 4:
        out[i-1] = new DataPoint(subLines[0], float(subLines[1]), float(subLines[2]), float(subLines[3]));
        break;
      default:
        out[i-1] = new DataPoint(subLines[0], float(subLines[1]), float(subLines[2]), float(subLines[3]), float(subLines[4]));
        break;
    }
    } else {
    switch(len) {
      case 1:
        out[i-1] = new DataPoint(k, float(subLines[0]));
        break;
      case 2:
        out[i-1] = new DataPoint(k, float(subLines[0]), float(subLines[1]));
        break;
      case 3:
        out[i-1] = new DataPoint(k, float(subLines[0]), float(subLines[1]), float(subLines[2]));
        break;
      case 4:
        out[i-1] = new DataPoint(k, float(subLines[0]), float(subLines[1]), float(subLines[2]), float(subLines[3]));
        break;
      default:
        out[i-1] = new DataPoint(k, float(subLines[0]), float(subLines[1]), float(subLines[2]), float(subLines[3]), float(subLines[4]));
        break;
    }
  }
  }
  return out;
}
