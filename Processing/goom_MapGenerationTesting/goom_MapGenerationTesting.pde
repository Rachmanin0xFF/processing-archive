boolean is_occupied(float xCoord, float yCoord2) {
  float yCoord = (Chunk.V - yCoord2) - Chunk.V/5;
  if((int)yCoord == Chunk.V-1) return false;
  boolean occupied = false;
  float n = max(0, noise((float)xCoord/150.f-1000.f)*2.f-0.3f);
  float caves = ridged_noise(xCoord/75.f - 4002.321, yCoord/75.f - 100);
  float f = noise((float)xCoord/16.f+ 1000.f, (float)yCoord/16.f)-0.5f;
  float yMap = yCoord/Chunk.V - 0.5f;
  if(f*n > yMap) occupied = true;
  if(caves - max(0, -yCoord-Chunk.V/20)/200.f > 0.985f) occupied = false;
  return occupied || yCoord < -Chunk.V/5;
}
public float ridged_noise(float x, float y) {
  float r = noise(x, y)*2.0;
  return r > 1.0 ? -r + 2.0 : r;
}

class Chunk {
  static final float U = 20.f;
  static final float V = 320.f;
}

int scrX = 0;
void setup() {
  size(1280, 320, P2D);
  noSmooth();
  strokeCap(SQUARE);
  background(255);
}
void draw() {
  background(255);
  for(int x = 0; x < width; x++) {
    for(int y = 0; y < height; y++) {
      if(is_occupied(x + scrX, y)) point(x, y);
    }
  }
  int v = 10;
  if(mousePressed) if(mouseButton == RIGHT) scrX -= v; else scrX += v;
}