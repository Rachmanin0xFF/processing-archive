
PVector readout = new PVector(0, 0, 0);

void setup() {
  size(512, 512);
}

void draw() {
  background(255);
  readout = new PVector(mouseX - width/2, mouseY - width/2, 0.0);
  readout.normalize();
  displayVec(readout);
  
  PVector direction = new PVector(readout.x, -readout.y, readout.z);
  displayVec(direction);
}

void displayVec(PVector q) {
  line(width/2, height/2, width/2 + q.x * 100.0f, height/2 + q.y * 100.0f);
}
