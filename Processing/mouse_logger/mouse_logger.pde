
import java.awt.*;
import java.util.Date;
PointerInfo a;
Point b;
int px = 0;
int py = 0;
PrintWriter writer;
ArrayList<String> to_add = new ArrayList<String>();
void setup() {
  size(180, 100, P2D);
  background(255, 0, 0);
  a = MouseInfo.getPointerInfo();
  b = a.getLocation();
  px = (int) b.getX();
  py = (int) b.getY();
  long t = (new Date()).getTime();
  try {
    writer = createWriter("log_" + t + ".csv");
  } catch(Exception e) {}
  to_add.add("" + t);
}

void draw() {
  background(10, 65, 13);
  a = MouseInfo.getPointerInfo();
  b = a.getLocation();
  int x = (int) b.getX();
  int y = (int) b.getY();
  if(x != px || y != py) {
    to_add.add(millis() + "," + x + "," + y);
    }
  px = x;
  py = y;
  textAlign(CENTER, CENTER);
  textSize(24);
  text(px + ", " + py + "\n" + millis(), width/2, height/2 - 4);
  if(frameCount % 1000 == 0 && to_add.size() > 0) {
    for(int i = 0; i < to_add.size(); i++) {
      writer.println(to_add.get(i));
    }
    writer.flush();
    to_add.clear();
  }
}
