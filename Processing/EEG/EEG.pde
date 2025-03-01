import processing.serial.*;

Serial myPort;
int baud = 9600;
int fileSize = 1;

void setup() {
  size(1800, 600, P2D);
  String portName = Serial.list()[0];
  myPort = new Serial(this, portName, 9600);
  println("start");
  int k = -1;
  while(k == -1) {
    k = myPort.read();
    println(k);
    delay(1);
  }
  frameRate(1000);
}

ArrayList<Float> log = new ArrayList<Float>();

void draw() {
  while(true) {
    background(255);
    int buff0 = myPort.read();
    if(buff0 == -1) break;
    int buff1 = myPort.read();
    if(buff1 == -1) break;
    int i = buff0 + buff1*256;
    if(mousePressed) i = buff1 + buff0*256;
    log.add((float)i);
    if(log.size() > (width-20)/spacing) log.remove(0);
  }
  plotData(10, 10, width - 20, height - 20, log);
}

int spacing = 1;

void plotData(float x, float y, float w, float h, ArrayList<Float> data) {
  noFill();
  stroke(0, 255);
  rect(x, y, w, h);
  stroke(100, 0, 0, 255);
  float max = -10000000000.f;
  float min = 10000000000.f;
  for(float f : data) {
    if(f > max) max = f;
    if(f < min) min = f;
  }
  for(int i = 0; i < data.size() - 1; i++) {
    line(i*spacing+x, map(data.get(i), min, max, y, y + h), (i+1)*spacing+x, map(data.get(i+1), min, max, y, y + h));
  }
}

public static int toInt(byte[] bytes, int offset) {
  int ret = 0;
  for (int i=0; i<4 && i+offset<bytes.length; i++) {
    ret <<= 8;
    ret |= (int)bytes[i] & 0xFF;
  }
  return ret;
}