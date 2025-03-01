
void setup() {
  size(256, 256);
  PVector[] datOt = new PVector[270];
  for(int i = 0; i < datOt.length; i++)
    datOt[i] = new PVector();
  for(int i = 0; i < 100; i++) {
    String[] s = loadStrings("input/c_" + i + ".csv");
    for(int j = 0; j < 270; j++) {
      datOt[j].add(new PVector(Float.parseFloat(s[j].split(",")[0]), Float.parseFloat(s[j].split(",")[1])));
    }
  }
  for(int i = 0; i < datOt.length; i++)
    datOt[i].mult(1.f/100.f);
  String[] so = new String[270];
  for(int i = 0; i < so.length; i++) {
    so[i] = int(datOt[i].x) + ", " + datOt[i].y;
  }
  saveStrings("hooop.txt", so);
  println("Done!");
}
