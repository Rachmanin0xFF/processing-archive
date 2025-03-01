
void setup() {
  size(1024, 1024, P2D);
  background(0);
  stroke(255);
  translate(512, 512);
  strokeWeight(1);
  String[] parts = loadStrings("dat.txt");
  float ppx = 0;
  float ppy = 0;
  boolean penon = false;
  for(int i = 0; i < parts.length; i++) {
    if(parts[i].startsWith("setxy") && parts[i].split(" ").length > 2) {
      float px = -float(parts[i].split(" ")[1]);
      float py = float(parts[i].split(" ")[2]);
      point(px, py);
      println(px, py);
      //if(penon && (px != 0 || py != 0)) line(px, py, ppx, ppy);
      ppx = px;
      ppy = py;
    }
    if(parts[i].startsWith("penup")) penon = false;
    if(parts[i].startsWith("pendown")) penon = true;
    
    if(parts[i].startsWith("cubic")) {
      for(int k = 0; k < 1; k++) {
        float px = -float(parts[i].split(" ")[1+k*2]);
        float py = float(parts[i].split(" ")[2+k*2]);
        point(px, py);
        println(px, py);
        //if(penon) line(px, py, ppx, ppy);
        ppx = px;
        ppy = py;
      }
    }
  }
  saveFrame("out.png");
}




void draw() {
}
