
ArrayList<PVector> pts = new ArrayList<PVector>();
void setup() {
  size(1920, 540, P2D);
  String[] s = loadStrings("../log_1667186167323.csv");
  for(int i = 1; i < s.length; i++) {
    pts.add(new PVector(int(s[i].split(",")[1]), int(s[i].split(",")[2])));
  }
  smooth(16);
}
void draw() {
  background(0);
  stroke(255, 50);
  scale(0.5);
  for(int i = 1; i < pts.size(); i++) {
    line(pts.get(i-1).x, pts.get(i-1).y, pts.get(i).x, pts.get(i).y);
  }
  saveFrame("pictur.png");
}
