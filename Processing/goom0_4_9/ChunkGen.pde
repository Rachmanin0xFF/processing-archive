
boolean is_occupied(float xCoord, float yCoord2) {
  float yCoord = (Chunk.V - yCoord2) - Chunk.V/5;
  if((int)yCoord == Chunk.V-1) return false;
  boolean occupied = false;
  float n = max(0, noise((float)xCoord/150.f-1000.f)*2.f-0.3f);
  float caves = ridged_noise(xCoord/200.f - 4002.321, yCoord/100.f);
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

void genChunk(int i) {
  map.put(i, new Chunk(i));
  Chunk c=map.get(i);
  for (int j=0; j<Chunk.U; j++) {
  for (int k=Chunk.V-1; k>=0; k--) {
    int xCoord = j + Chunk.U*i;
    int yCoord = k;
    int blockType = 0;
    int blockSlope = 0;
    boolean occupied = is_occupied(xCoord, yCoord);
    if(occupied) {
      blockType = 1;
      if(is_occupied(xCoord, yCoord - 1)) {
        blockType = 2;
        if(!is_occupied(xCoord, yCoord - 2)) {
          boolean UR = is_occupied(xCoord + 1, yCoord - 1);
          boolean UL = is_occupied(xCoord - 1, yCoord - 1);
          if(!UL && UR && is_occupied(xCoord - 1, yCoord)) blockSlope = 1;
          else if(UL && !UR && is_occupied(xCoord + 1, yCoord)) blockSlope = 2;
          else if(!UL && !UR && is_occupied(xCoord + 1, yCoord) && is_occupied(xCoord - 1, yCoord)) blockSlope = 3;
          else if(!UL && !UR && is_occupied(xCoord - 1, yCoord)) blockSlope = 1;
          else if(!UL && !UR && is_occupied(xCoord + 1, yCoord)) blockSlope = 2;
        }
      } else {
        boolean left = is_occupied(xCoord - 1, yCoord);
        boolean right = is_occupied(xCoord + 1, yCoord);
        if(!left && right) {
          blockSlope = 1;
          boolean under = is_occupied(xCoord, yCoord + 1);
          if(!under) blockSlope = 5;
        }
        else if(left && !right) {
          blockSlope = 2;
          boolean under = is_occupied(xCoord, yCoord + 1);
          if(!under) blockSlope = 6;
        }
        else if(!left && !right) {
          if(!is_occupied(xCoord, yCoord + 1)) blockSlope = 3; else blockSlope = 4;
        }
      }
    }
    
    if(occupied && random(100) > 99.5) {
      blockType = 3;
      blockSlope = 0;
      colorMode(HSB);
      c.lightLink[j][k] = addBlockLight(new Light(i, j, k, color(random(255), 255, 255), 2.5f));
      colorMode(RGB);
    }
    
    c.set(j, k, blockType + blockSlope*1000);
  }
  }
}