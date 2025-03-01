void render(Chunk c, int ci, int yVal) {
  println(yVal);
  int yStart = max(0, yVal - 12);
  int yEnd = min(Chunk.V, yVal + 12);
  for (int x=0; x<Chunk.U; x++) {
    for (int y=yStart; y<yEnd; y++) {
      int i=c.get(x, y)%1000;
      int typ=floor(c.get(x, y)/1000);
      if (i>0) {
        tint(c.getCol(x, y));
        float pr = r(c.getCol(x, y));
        float pg = g(c.getCol(x, y));
        float pb = b(c.getCol(x, y));
        //lightMultiply.set("tart", pr/255.f, pg/255.f, pb/255.f, 0.5f);
        spriteLib.get(i).display(x, y, ci*Chunk.U*GRID, 0, typ);
      } else {
        //u*GRID+x, (Chunk.V-v)*GRID+y
        //tint(pr, pg, pb, (pr + pg + pb)/3);
        fill(255, 255);
        //tint(c.getCol(x, y));
      }
    }
  }
  noTint();
}

int r(color c) {return (c >> 16) & 255; }
int g(color c) {return (c >> 8) & 255;}
int b(color c) {return c & 255; }

color sunColor = color(150, 150, 200, 255);
HashMap<Integer, Light> blockLights = new HashMap<Integer, Light>();

boolean recalcLighting = false;

void renderWorld(int chunkA) {
  pushMatrix();
  ArrayList<Integer> cids = new ArrayList<Integer>();
  for (int i=-1; i<=3; i++) cids.add(i + chunkA);
  if(recalcLighting) {
    calcLightingRange(map, cids);
    recalcLighting = false;
  }
  for (int i=-1; i<=3; i++) {
    Chunk c=map.get(i+chunkA);
    render(c, i+chunkA, (int)((me.p.y)/float(GRID)));
  }
  for (Light l : blockLights.values()) {
    if(abs(l.chunk - chunkA) < 2) l.drawSprite();
  }
  popMatrix();
}

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
  void drawSprite() {
    getS(300).display(chunk*Chunk.U+x, y);
  }
}

void calcLightingRange(HashMap<Integer, Chunk> map, ArrayList<Integer> toLight) {
  for (int l : toLight) {
    Chunk c = map.get(l);
    c.light = new int[Chunk.U][Chunk.V];
    c.lgtmp = new int[Chunk.U][Chunk.V];
    c.done = new boolean[Chunk.U][Chunk.V];
  }

  for (int k=0; k<Chunk.V-1; k++) {
    for (int l : toLight) {
      Chunk c = map.get(l);
      if (k == 0) for (int j=0; j<Chunk.U; j++) c.light[j][k] = sunColor; 
      else
        for (int j=Chunk.U-1; j>=0; j--) {
          float mult = 1.f;
          if (c.get(j, k) != 0) mult = 0.7f;
          int r = r(c.getCol(j, k-1))/2 + r(c.getCol(j-1, k-1))/4 + r(c.getCol(j+1, k-1))/4; 
          r = int(mult*(float)r);
          int g = g(c.getCol(j, k-1))/2 + g(c.getCol(j-1, k-1))/4 + g(c.getCol(j+1, k-1))/4; 
          g = int(mult*(float)g);
          int b = b(c.getCol(j, k-1))/2 + b(c.getCol(j-1, k-1))/4 + b(c.getCol(j+1, k-1))/4; 
          b = int(mult*(float)b);

          c.light[j][k] = color(r, g, b, 255);
          //c.light[j][k] = color(100, g, b, 255);
        }
    }
  }

  //randomSeed(8);
  int chunk=floor(me.p.x/float(GRID*Chunk.U));
  int block=floor(me.p.x/GRID)-chunk*Chunk.U;
  int blockY=floor(me.p.y/GRID)-1;
  //startRecurse(chunk, block, blockY, color(200, 0, 255), 1.3f, 20);

  for (Light l : blockLights.values()) {
    if (toLight.contains(l.chunk)) {
      startRecurse(l.chunk, l.x, l.y, l.col, l.intensity, 20);
    }
  }
}

int cLightID = 0;

int addBlockLight(Light l) {
  while (true) {
    if (!blockLights.containsKey(cLightID)) break;
    cLightID++;
  }
  blockLights.put(cLightID, l);
  return cLightID;
}


void startRecurse(int chunk, int x, int y, color lval, float brightness, int iter) {
  float pMultNum = 1.f/2147483647.f*2.f*brightness;
  if (x <= Chunk.U-1 && y <= Chunk.V-1 && x >= 0 && y >= 0)
    recurseLight(chunk, x, y, 2147483647, iter);
  for (int i = -1; i <= 1; i++) {
    if (map.containsKey(chunk + i)) {
      
      for (int j=0; j<Chunk.U; j++) {
        for (int k=Chunk.V-1; k>0; k--) {
          if (map.get(chunk+i).done[j][k]) {
            color cCol = map.get(chunk+i).light[j][k];
            float power = (float)(map.get(chunk+i).lgtmp[j][k])*pMultNum;
            color output = color(min(255, int(power*((float)r(lval)) + r(cCol))), 
              min(255, int(power*((float)g(lval)) + g(cCol))), 
              min(255, int(power*((float)b(lval)) + b(cCol))), 255);
            map.get(chunk+i).light[j][k] = output;
            map.get(chunk+i).lgtmp[j][k] = 0;
            map.get(chunk+i).done[j][k] = false;
          }
        }
      }
      
    }
  }
}

void recurseLight(int chunk, int x, int y, int lastLight, int iter) {
  if (lastLight < 8388608) return;
  if (iter == 0) return;
  if (!map.containsKey(chunk)) return;
  float blocking = 0.8f;
  if (map.get(chunk).get(x, y) != 0) blocking = 0.5f;
  int newLight = (int)(blocking*((float)lastLight));
  if (newLight <= map.get(chunk).lgtmp[x][y]) return;
  map.get(chunk).lgtmp[x][y] = newLight;
  map.get(chunk).done[x][y] = true;

  if (x < Chunk.U-1) recurseLight(chunk, x+1, y, newLight, iter-1);
  else recurseLight(chunk+1, 0, y, newLight, iter-1);
  if (x > 0) recurseLight(chunk, x-1, y, newLight, iter-1);
  else recurseLight(chunk-1, Chunk.U-1, y, newLight, iter-1);

  if (y < Chunk.V-1) recurseLight(chunk, x, y+1, newLight, iter-1);
  if (y > 0) recurseLight(chunk, x, y-1, newLight, iter-1);
}