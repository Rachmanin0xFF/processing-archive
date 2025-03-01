//KEY HANDLER
HashMap<Character, Boolean> keyStates=new HashMap<Character, Boolean>();
HashMap<Integer, Boolean> keyCodeStates=new HashMap<Integer, Boolean>();
void initKeyTracker() {
  int[]temp_key_codes={LEFT, RIGHT,SHIFT};
  char[]temp_keys={'w', 's', 'a', 'd', 'W', 'A', 'S', 'D'};
  for (char c : temp_keys) {
  keyStates.put(c, false);
  }

  for (int c : temp_key_codes) {
  keyCodeStates.put(c, false);
  }
}



void mousePressed() {
  if(mouseButton == RIGHT) {
  int chunk=floor(me.p.x/float(GRID*Chunk.U));
  int block=floor(me.p.x/GRID)-chunk*Chunk.U;
  int blockY=floor(me.p.y/GRID)-1;
  colorMode(HSB);
  while(!blockLights.containsKey(cLightID)) cLightID++;
  addBlockLight(new Light(chunk, block, blockY, color(random(255), 255, 255), random(0.5, 2.5)));
  colorMode(RGB);
  recalcLighting = true;
  } else {
  triggerAudio("rockpik");
  int chunk=floor(me.p.x/float(GRID*Chunk.U));
  int block=floor(me.p.x/GRID)-chunk*Chunk.U;
  int blockY=floor(me.p.y/GRID)-1;
    
  for(int x = -1; x <= 1; x++) {
    for(int y = -1; y <= 2; y++) {
      map.get(chunk).smartSet(block + x, blockY + y, 0);
    }
  }
  recalcLighting = true;
  }
}

void keyPressed() {
  if (key!=CODED) {

  me.keyAction(key, true);
  keyStates.put(key, true);
  } else keyCodeStates.put(keyCode, true);
}

void keyReleased() {
  if (key!=CODED) {
  keyStates.put(key, false);
  me.keyAction(key, false);
  } else keyCodeStates.put(keyCode, false);
}