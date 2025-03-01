String fileName = "";
void setup() {
  size(1280, 820);
  smooth(8);
  reg = loadFont("TimesNewRomanPSMT-25.vlw");
  big = loadFont("TimesNewRomanPSMT-35.vlw");
  genPlot("c_0.csv");
  fileName = promptFile();
  if (frame != null) {
    frame.setResizable(true);
  }
}
int selectedFile = -1;
void draw() {
  genPlot(fileName);
}
void mouseDragged() {
  offset.add(new PVector(map(pmouseX - mouseX, 0, width, 0, max.x - min.x), map(mouseY - pmouseY, 0, height, 0, max.y - min.y)));
}
void mouseWheel(MouseEvent event) {
  int e = int(event.getCount());
  selectedFile -= e;
  selectedFile = min(99, max(selectedFile, -1));
}
void keyPressed() {
  if(key == CODED && keyCode == RIGHT) {
    selectedFile++;
  }
  if(key == CODED && keyCode == LEFT) {
    selectedFile--;
  }
  selectedFile = min(99, max(selectedFile, -2));
}

PVector[] data;
PFont reg;
PFont big;
PVector min = new PVector(0.f, 0.f);
PVector max = new PVector(0.f, 0.f);
PVector offset = new PVector(0.f, 0.f);
PVector majorTick = new PVector(20, 400000);
PVector minorTick = new PVector(5.f, 100000);
float tickSizeX = 0.f;
float tickSizeY = 0.f;
String xAxis = "Hyperedge Degree";
String yAxis = "Hyperedge Impact";
void genPlot(String file) {
  min = new PVector(100000000000.f, 100000000000.f);
  max = new PVector(-100000000000.f, -100000000000.f);
  textFont(reg);
  background(255);
  stroke(0);
  fill(0);
  data = loadData(file);
  String[] ts = loadStrings(file);
  xAxis = ts[0].split(",")[0];
  yAxis = ts[0].split(",")[1];
  int xbone = 0;
  int ybone = 0;
  for(int i = 0; i < data.length; i++) {
    if(data[i].x < min.x)
      min.x = data[i].x;
    if(data[i].y < min.y)
      min.y = data[i].y;
    if(data[i].x > max.x) {
      max.x = data[i].x;
      xbone = i;
    }
    if(data[i].y > max.y) {
      max.y = data[i].y;
      ybone = i;
    }
  }
  println(xbone + " " + ybone);
  max.add(offset);
  min.add(offset);
  float deltaX = max.x - min.x;
  float deltaY = max.y - min.y;
  min.x -= deltaX*0.2f;
  max.x += deltaX*0.2f;
  min.y -= deltaY*0.2f;
  max.y += deltaY*0.2f;
  println(max.y);
  tickSizeX = deltaY*0.005f;
  tickSizeY = deltaX*0.005f;
  
  println("(" + min.x + ", " + min.y + ") (" + max.x + ", " + max.y + ")");
  strokeWeight(6);
  for(PVector p : data) {
    mapPoint(p.x, p.y);
  }
  strokeWeight(1);
  mapLine(-1000000.f, 0, 1000000.f, 0);
  mapLine(0, -1000000.f, 0, 1000000.f);
  PVector p = lineOfBestFit(data);
  stroke(0, 100);
  println(p.x);
  mapLine(-10000.f, -10000.f*p.x + p.y, 10000.f, 10000.f*p.x + p.y);
  stroke(0, 40);
  for(float i = 0.f; i <= max.x; i += minorTick.x) {
    mapLine(i, -1000000.f, i, 1000000.f);
    mapLine(-i, -1000000.f, -i, 1000000.f);
  }
  for(float i = 0.f; i <= max.y; i += minorTick.y) {
    mapLine(-1000000.f, i, 1000000.f, i);
    mapLine(-1000000.f, -i, 1000000.f, -i);
  }
  for(float i = 0.f; i >= min.x; i -= minorTick.x) {
    mapLine(i, -1000000.f, i, 1000000.f);
    mapLine(-i, -1000000.f, -i, 1000000.f);
  }
  for(float i = 0.f; i >= min.y; i -= minorTick.y) {
    mapLine(-1000000.f, i, 1000000.f, i);
    mapLine(-1000000.f, -i, 1000000.f, -i);
  }
  stroke(0, 255);
  for(float i = 0.f; i <= max.x; i += minorTick.x) {
    mapLine(i, -tickSizeX, i, tickSizeX);
    mapLine(-i, -tickSizeX, -i, tickSizeX);
  }
  for(float i = 0.f; i <= max.y; i += minorTick.y) {
    mapLine(-tickSizeY, i, tickSizeY, i);
    mapLine(-tickSizeY, -i, tickSizeY, -i);
  }
  for(float i = 0.f; i >= min.x; i -= minorTick.x) {
    mapLine(i, -tickSizeX, i, tickSizeX);
    mapLine(-i, -tickSizeX, -i, tickSizeX);
  }
  for(float i = 0.f; i >= min.y; i -= minorTick.y) {
    mapLine(-tickSizeY, i, tickSizeY, i);
    mapLine(-tickSizeY, -i, tickSizeY, -i);
  }
  
  textAlign(CENTER, TOP);
  for(float i = 0.f; i <= max.x; i += majorTick.x) {
    mapLine(i, -tickSizeX*2, i, tickSizeX*2);
    mapLine(-i, -tickSizeX*2, -i, tickSizeX*2);
    textMap(int(i) + "", i, -tickSizeX*3);
  }
  textAlign(RIGHT, CENTER);
  for(float i = 0.f; i <= max.y; i += majorTick.y) {
    mapLine(-tickSizeY*2, i, tickSizeY*2, i);
    mapLine(-tickSizeY*2, -i, tickSizeY*2, -i);
    textMap(int(i) + "", -tickSizeY*3, i);
    textMap(int(i) + "", -tickSizeY*3, -i);
  }
  textAlign(CENTER, TOP);
  
  for(float i = 0.f; i >= min.x; i -= majorTick.x) {
    mapLine(i, -tickSizeX*2, i, tickSizeX*2);
    mapLine(-i, -tickSizeX*2, -i, tickSizeX*2);
    textMap(int(i) + "", i, -tickSizeX*3);
  }
  textAlign(RIGHT, CENTER);
  for(float i = 0.f; i >= min.y; i -= majorTick.y) {
    mapLine(-tickSizeY*2, i, tickSizeY*2, i);
    mapLine(-tickSizeY*2, -i, tickSizeY*2, -i);
    textMap(int(i) + "", -tickSizeY*3, i);
    textMap(int(i) + "", -tickSizeY*3, -i);
  }
  double r = pearsonCorrelation(data);
  textFont(big);
  text("r = " + r, width - 50, 50);
  textAlign(LEFT, CENTER);
  if(selectedFile == -1)
    text("File: input/c_real.csv", 50, 50);
  else if(selectedFile == -2)
    text("File: input/c_avg.csv", 50, 50);
  else
    text("File: input/c_" + selectedFile + ".csv", 50, 50);
  textAlign(CENTER, TOP);
  textMap(xAxis, (min.x + max.x)/2.f, -tickSizeX*12);
  textAlign(CENTER, BOTTOM);
  translate(map(-tickSizeY*20, min.x, max.x, 0, width), map((min.y + max.y)/2.f, min.y, max.y, height, 0));
  rotate(-PI/2);
  text(yAxis, 0, 0);
}

void mapLine(float x, float y, float a, float b) {
  line(map(x, min.x, max.x, 0, width), map(y, min.y, max.y, height, 0), map(a, min.x, max.x, 0, width), map(b, min.y, max.y, height, 0));
}

void mapPoint(float x, float y) {
  point(map(x, min.x, max.x, 0, width), map(y, min.y, max.y, height, 0));
}

void textMap(String t, float x, float y) {
  text(t, map(x, min.x, max.x, 0, width), map(y, min.y, max.y, height, 0));
}

public PVector[] loadData(String location) {
  String[] f = loadStrings(location);
  int offset = 0;
  boolean numberFound = false;
  while(!numberFound) {
    try {
      float x = Float.parseFloat(f[offset].split(",")[0]);
      numberFound = true;
    } catch(NumberFormatException nfe) {
      offset++;
    }
  }
  PVector[] p = new PVector[f.length-offset];
  for(int i = 0; i < f.length-offset; i++) {
    String[] r = f[i+offset].split(",");
    try {
      p[i] = new PVector(Float.parseFloat(r[0]), Float.parseFloat(r[1]));
    } catch(NumberFormatException nfe) {
      println("Number formatting error!");
      p[i] = new PVector();
    }
  }
  return p;
}

PVector lineOfBestFit(PVector[] data) {
  PVector o = new PVector();
  float sX = 0.f;
  float sY = 0.f;
  float sX2 = 0.f;
  float sXY = 0.f;
  for(PVector p : data) {
    sX += p.x;
    sY += p.y;
    sX2 += p.x*p.x;
    sXY += p.x*p.y;
  }
  float xM = sX/float(data.length);
  float yM = sY/float(data.length);
  float slope = (sXY - sX*yM) / (sX2 - sX*xM);
  float y_int = yM - slope*xM;
  return new PVector(slope, y_int);
}

double pearsonCorrelation(PVector[] data) {
  double o = 0.0;
  double sX = 0.0;
  double sY = 0.0;
  for(PVector p : data) {
    sX += p.x;
    sY += p.y;
  }
  double xM = sX/float(data.length);
  double yM = sY/float(data.length);
  double numerator = 0.0;
  double denom1 = 0.0;
  double denom2 = 0.0;
  for(PVector p : data) {
    numerator += (p.x - xM) * (p.y - yM);
    denom1 += (p.x - xM) * (p.x - xM);
    denom2 += (p.y - yM) * (p.y - yM);
  }
  denom1 = java.lang.Math.sqrt(denom1);
  denom2 = java.lang.Math.sqrt(denom2);
  double denominator = denom1*denom2;
  o = numerator/denominator;
  return o;
}
import javax.swing.*;
public String promptFile() {
  try {
    UIManager.setLookAndFeel("com.sun.java.swing.plaf.windows.WindowsLookAndFeel");
  } catch (Exception cnfe) {}
  final JFileChooser fc = new JFileChooser();
  int returnVal = fc.showOpenDialog(null);
  if (returnVal == JFileChooser.APPROVE_OPTION) {
    File file = fc.getSelectedFile();
    return file.getAbsolutePath();
  }
  return "";
}
