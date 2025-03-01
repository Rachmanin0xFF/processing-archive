void setup() {
  size(150, 150, P2D);
  background(0);
  try {
    UIManager.setLookAndFeel("com.sun.java.swing.plaf.windows.WindowsLookAndFeel");
  } catch (Exception cnfe) {}
}
void draw() {}
void keyPressed() { executeOperations(); }
void mousePressed() { executeOperations(); }
void executeOperations() {
  String location = promptFile();
  if(location == "")
    return;
  PVector mxb = lineOfBestFit(loadData(location));
  println(mxb.x + " " + mxb.y);
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
