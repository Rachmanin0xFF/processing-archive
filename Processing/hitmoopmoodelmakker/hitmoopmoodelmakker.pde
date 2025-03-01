
ArrayList<String> txtOut = new ArrayList<String>();
PImage loadedHMap;
void setup() {
  size(100, 100);
  loadedHMap = loadImage("EarthHeightMap2.jpg");
  PImage saa = loadImage("seas.png");
  //loadedHMap = loadImage("stripes.png");
  for(int x = 0; x < loadedHMap.width; x++) {
    println((100.f*float(x)/float(loadedHMap.width)) + "% Done...");
    for(int y = 0; y < loadedHMap.height; y++) {
      float latitude = float(y)/float(loadedHMap.height)*PI;
      float longitude = float(x)/float(loadedHMap.width)*TWO_PI;
      float theta = latitude;
      float phi = longitude;
      float h = brightness(loadedHMap.get(x, y));
      int s = (int)brightness(saa.get(x, y));
      float r = 2.f + h/555.f;
      if(s < 2)
        r = 2.f;
      PVector p = new PVector(r*sin(theta)*cos(phi), r*sin(theta)*sin(phi), r*cos(theta));
      txtOut.add("v " + p.x + " " + p.y + " " + p.z);
    }
  }
  int vertNum = txtOut.size();
  int min = 10000000;
  int max = -10000000;
  
  for(int x = 0; x < loadedHMap.width-1; x++) {
    println((100.f*float(x)/float(loadedHMap.width)) + "% Done triangle generation...");
    for(int y = 0; y < loadedHMap.height; y++) {
      if(index(x, y) < min) min = index(x, y);
      if(index(x, y) > max) max = index(x, y);
      //txtOut.add("f " + index(x, y) + " " + index(x+1, y) + " " + index(x, y+1));
      //txtOut.add("f " + index(x+1, y+1) + " " + index(x, y+1) + " " + index(x+1, y));
      txtOut.add("f " + index(x+1, y+1) + " " + index(x, y+1) + " " + index(x, y) + " " + index(x+1, y));
    }
  }
  println(vertNum + " " + min + " " + max);
  String[] dataOut = new String[txtOut.size()];
  for(int i = 0; i < dataOut.length; i++) dataOut[i] = txtOut.get(i);
  saveStrings("EarthModel.obj", dataOut);
}
int index(int x, int y) {
  int x2 = 0;
  int y2 = 0;
  //if(x2 < 0) x2 = loadedHMap.width-1;
  //if(y2 < 0) y2 = loadedHMap.height-1;
  if(x == loadedHMap.width) x2 = 0; else x2 = x;
  if(y == loadedHMap.height) y2 = 0; else y2 = y;
  return y2*loadedHMap.width + x2 + 1;
}
