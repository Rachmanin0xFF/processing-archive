void render(Chunk c, int xb) {
  for (int x=0; x<Chunk.CHUNK_U; x++) {
  for (int y=0; y<Chunk.CHUNK_V; y++) {
    int i=c.get(x, y)%1000;
    int typ=floor(c.get(x, y)/1000);
    if (i>0) {
      tint(c.getCol(x, y));
      spriteLib.get(i).display(x, y, xb, 0, typ);
    } else {
      //u*SPRITE_GRID+x, (Chunk.CHUNK_V-v)*SPRITE_GRID+y
      tint(c.getCol(x, y));
      fill(255, 255);
      //tint(c.getCol(x, y));
    }
  }
  }
  noTint();
}

color sunColor = color(150, 150, 200, 255);
HashMap<Integer, Light> blockLights = new HashMap<Integer, Light>();

class Light {
  int chunk;
  int x;
  int y;
  color col;
  float intensity;
  public Light(int chunk, int x, int y, color col, float intensity) {
  this.chunk = chunk;
  this.x = x;
  this.y = y;
  this.col = col;
  this.intensity = intensity;
  }
}

void calcLightingRange(HashMap<Integer, Chunk> map, ArrayList<Integer> toLight) {
  for(int l : toLight) {
  Chunk c = map.get(l);
  c.light = new int[Chunk.CHUNK_U][Chunk.CHUNK_V];
  c.lgtmp = new int[Chunk.CHUNK_U][Chunk.CHUNK_V];
  c.done = new boolean[Chunk.CHUNK_U][Chunk.CHUNK_V];
  }
 
  for(int k=Chunk.CHUNK_V-1; k>=0; k--) {
  for(int l : toLight) {
    Chunk c = map.get(l);
    if(k == Chunk.CHUNK_V-1) for(int j=0; j<Chunk.CHUNK_U; j++) c.light[j][k] = sunColor; else
    for(int j=0; j<Chunk.CHUNK_U; j++) {
      float mult = 1.f;
      if(c.get(j, k) != 0) mult = 0.7f;
      int r = r(c.getCol(j, k+1))/2 + r(c.getCol(j-1, k+1))/4 + r(c.getCol(j+1, k+1))/4; r = int(mult*(float)r);
      int g = g(c.getCol(j, k+1))/2 + g(c.getCol(j-1, k+1))/4 + g(c.getCol(j+1, k+1))/4; g = int(mult*(float)g);
      int b = b(c.getCol(j, k+1))/2 + b(c.getCol(j-1, k+1))/4 + b(c.getCol(j+1, k+1))/4; b = int(mult*(float)b);
      
      c.light[j][k] = color(r, g, b, 255);
    }
  }
  }
 
  //randomSeed(8);
  int chunk=floor(me.p.x/float(SPRITE_GRID*Chunk.CHUNK_U));
  int block=floor(me.p.x/SPRITE_GRID)-chunk*Chunk.CHUNK_U;
  int blockY=floor(me.p.y/SPRITE_GRID)-1;
  //startRecurse(chunk, block, blockY, color(200, 0, 255), 1.3f, 20);
 
  for(Light l : blockLights.values()) {
  if(toLight.contains(l.chunk)) {
    startRecurse(l.chunk, l.x, l.y, l.col, l.intensity, 20);
  }
  }
}

int cLightID = 0;

int addBlockLight(Light l) {
  while(true) {
  if(!blockLights.containsKey(cLightID)) break;
  cLightID++;
  }
  blockLights.put(cLightID, l);
  return cLightID;
}


void startRecurse(int chunk, int x, int y, color lval, float brightness, int iter) {
  float pMultNum = 1.f/2147483647.f*2.f*brightness;
  if(x <= Chunk.CHUNK_U-1 && y <= Chunk.CHUNK_V-1 && x >= 0 && y >= 0)
  recurseLight(chunk, x, y, 2147483647, iter);
  for(int i = -1; i <= 1; i++) {
  if(map.containsKey(chunk + i)) {
    for(int j=0; j<Chunk.CHUNK_U; j++) {
      for(int k=Chunk.CHUNK_V-1; k>0; k--) {
        if(map.get(chunk+i).done[j][k]) {
          color cCol = map.get(chunk+i).light[j][k];
          float power = (float)(map.get(chunk+i).lgtmp[j][k])*pMultNum;
          color output = color(min(255, int(power*((float)r(lval)) + r(cCol))),
                               min(255, int(power*((float)g(lval)) + g(cCol))),
                               min(255, int(power*((float)b(lval)) + b(cCol))), 255);
         map.get(chunk+i).light[j][k] = output;
        }
      }
    }
    map.get(chunk+i).lgtmp = new int[Chunk.CHUNK_U][Chunk.CHUNK_V];
    map.get(chunk+i).done = new boolean[Chunk.CHUNK_U][Chunk.CHUNK_V];
  }
  }
}

void recurseLight(int chunk, int x, int y, int lastLight, int iter) {
  if(lastLight < 8388608) return;
  if(iter == 0) return;
  if(!map.containsKey(chunk)) return;
  float blocking = 0.8f;
  if(map.get(chunk).get(x, y) != 0) blocking = 0.5f;
  int newLight = (int)(blocking*((float)lastLight));
  if(newLight <= map.get(chunk).lgtmp[x][y]) return;
  map.get(chunk).lgtmp[x][y] = newLight;
  map.get(chunk).done[x][y] = true;
 
  if(x < Chunk.CHUNK_U-1) recurseLight(chunk, x+1, y, newLight, iter-1);
  else recurseLight(chunk+1, 0, y, newLight, iter-1);
  if(x > 0) recurseLight(chunk, x-1, y, newLight, iter-1);
  else recurseLight(chunk-1, Chunk.CHUNK_U-1, y, newLight, iter-1);
 
  if(y < Chunk.CHUNK_V-1) recurseLight(chunk, x, y+1, newLight, iter-1);
  if(y > 0) recurseLight(chunk, x, y-1, newLight, iter-1);
}