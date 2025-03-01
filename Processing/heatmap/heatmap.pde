import javax.swing.*;

float zoomX = 100.0f;
float zoomY = 1.0f;

void setup() {
  size(1920, 1080);
  colorMode(HSB);
  //String[] data = loadStrings(promptFile());
  String[] data = loadStrings("hyperzapSpec.csv");
  PVector[] values = new PVector[data.length];
  for(int i = 0; i < values.length; i++) {
    values[i] = new PVector(Float.parseFloat(data[i].split(",")[0]), Float.parseFloat(data[i].split(",")[1]));
  }
  float prevSum = 0.0f;
  for(float x = 0.f; x < width; x++)
    for(float y = height; y >= 0.0f; y--) {
      float sum = 0.0f;
      for(PVector p : values)
        sum += d2(x, y, new PVector(p.x*zoomX, p.y*zoomY));
      sum *= 15000.0f;
      if(random(100) > 97 && sum > prevSum)
        stroke(sum%255, 0, sum);
      point(x, y);
      prevSum = sum;
    }
  stroke(0);
  strokeWeight(5);
  for(PVector p : values) {
    //point(p.x*zoomX, p.y*zoomY);
  }
  saveFrame("output4.jpg");
}

public String promptFile() {
  final JFileChooser fc = new JFileChooser();
  int returnVal = fc.showOpenDialog(null);
  if (returnVal == JFileChooser.APPROVE_OPTION) {
    File file = fc.getSelectedFile();
    if (file.getName().endsWith("csv")) {
      return file.getAbsolutePath();
    }
  }
  return "";
}

public float d2(float x, float y, PVector p) {
  return 1.0f/((x-p.x)*(x-p.x) + (y-p.y)*(y-p.y));
}
