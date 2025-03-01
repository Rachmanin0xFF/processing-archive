//KEY HANDLER
HashMap<Character, Boolean> keyStates=new HashMap<Character, Boolean>();
HashMap<Integer, Boolean> keyCodeStates=new HashMap<Integer, Boolean>();
void initKeyTracker() {
  int[]temp_key_codes={LEFT, RIGHT, SHIFT};
  char[]temp_keys={'w', 's', 'a', 'd', 'W', 'A', 'S', 'D','q'};
  for (char c : temp_keys) {
    keyStates.put(c, false);
  }

  for (int c : temp_key_codes) {
    keyCodeStates.put(c, false);
  }
}



void mousePressed() {
  if (menuOpen) {
    title.clik(0,(1-menuness)*height);
    begin.clik(0,(1-menuness)*height);
    settings.clik(0,(1-menuness)*height);
    clickbait.clik(0,(1-menuness)*height);
  } else{
    if (mouseButton == RIGHT) {
      int chunk=floor(me.p.x/float(GRID*Chunk.U));
      int block=floor(me.p.x/GRID)-chunk*Chunk.U;
      int blockY=floor(me.p.y/GRID)-1;
      colorMode(HSB);
      while (!blockLights.containsKey(cLightID)) cLightID++;
      addBlockLight(new Light(chunk, block, blockY, color(random(255), 255, 255), random(0.5, 2.5)));
      recalcLighting=true;
      colorMode(RGB);
    } else {
      triggerAudio("rockbop");
      int chunk=floor(me.p.x/float(GRID*Chunk.U));
      int block=floor(me.p.x/GRID)-chunk*Chunk.U;
      int blockY=floor(me.p.y/GRID)-1;
      recalcLighting=true;
      for (int x = -1; x <= ceil(me.p.size/32f); x++) {
        for (int y = -1; y <= 2+floor(me.p.size/32f); y++) {
          map.get(chunk).smartSet(block + x, blockY + y, 0);
        }
      }
    }
  }
}
void mouseReleased(){
    
    title.unclik(0,(1-menuness)*height);
    begin.unclik(0,(1-menuness)*height);
    settings.unclik(0,(1-menuness)*height);
    clickbait.unclik(0,(1-menuness)*height);

  
}

void keyPressed() {
  if (key!=CODED) {

    me.keyAction(key, true);
    keyStates.put(key, true);
    if (key=='h') {
      p.use();
    }
    if(key=='\t')menuOpen=!menuOpen;
    if (key=='j')p.maxCharges++;
  } else keyCodeStates.put(keyCode, true);
}

void keyReleased() {
  if (key!=CODED) {
    keyStates.put(key, false);
    me.keyAction(key, false);
  } else keyCodeStates.put(keyCode, false);
}