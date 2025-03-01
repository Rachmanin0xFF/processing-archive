/*
0   -> air
 1   -> ground surface
 
 100 -> goom
 */

// GLOBAL VARIABLES
int SPRITE_GRID=32;
int s_spaceX=80;
int s_spaceY=40;
float noise_strength=0.1;

//KEY HANDLER
HashMap<Character, Boolean> keyStates=new HashMap<Character, Boolean>();
HashMap<Integer, Boolean> keyCodeStates=new HashMap<Integer, Boolean>();
void initKeyTracker() {
  int[]temp_key_codes={LEFT, RIGHT};
  char[]temp_keys={'w', 's', 'a', 'd', 'W', 'A', 'S', 'D'};
  for (char c : temp_keys) {
    keyStates.put(c, false);
  }

  for (int c : temp_key_codes) {
    keyCodeStates.put(c, false);
  }
}

// MAP DATA
HashMap<Integer, Chunk> map=new HashMap<Integer, Chunk>();
HashMap<Integer, Sprite> spriteLib=new HashMap<Integer, Sprite>();

// IMAGE STORAGE
PImage bkd1;
//PImage bkd2;


// GAME VARIABLES
int mp_scroll=0; // in screen-space
Player me=new Player();

//////////////////////////////////////////////////////////////////////////
void setup() {
  size(1280, 640, P2D);

  // LOAD IMAGES
  initializeSpriteLib();

  // LOAD IMAGES
  bkd1=loadImage("BlueSpace.jpg");
  //bkd2=loadImage("bkd2.png");
  loadSpriteAlpha(1, 32, "grass/grass.bmp", "grass/grass_Lramp.bmp", "grass/grass_Rramp.bmp", "grass/grass_Lone.bmp", "grass/grass_Bump.bmp", "grass/grass_Lhang.bmp", "grass/grass_Rhang.bmp");
  loadSpriteAlpha(2, 32, "rock/rock.bmp", "rock/rock_GrassL.bmp", "rock/rock_GrassR.bmp", "rock/rock_GrassLR.bmp");
  loadSpriteAlpha(3, 32, "light.bmp");
  loadSpriteAlpha(4, 32, "lite.bmp");
  loadSpriteAlpha(100, "goom/goom.png", "goom/goomcoat.png", "goom/goomded.png");
  loadSpriteAlpha(200, 32, "goomspook.bmp");
  
  //Initialize keyStates
  initKeyTracker();
}

void draw() {
  background(20);


  if (key(LEFT)) {
    mp_scroll+=12;
  }
  if (key(RIGHT)) {
    mp_scroll-=12;
  }

  //Test for need to gen chunks
  //println(-(mp_scroll/float(SPRITE_GRID*Chunk.CHUNK_U)));
  int chunkA=floor(-(mp_scroll/float(SPRITE_GRID*Chunk.CHUNK_U)));
  //println("Chunk A", chunkA);
  for (int i=-1; i<4; i++) {
    if (!map.containsKey(i+chunkA)) {
      genChunk(i+chunkA);
    }
  }

  //Draw Background
  //image(bkd1, (mp_scroll/2)%1280-1280, 0);
  //image(bkd1, (mp_scroll/2)%1280, 0);
  //image(bkd1, (mp_scroll/2)%1280+1280, 0);
  
  image(bkd1, (mp_scroll/2)%1280-1280, (me.y/2.f)%640);
  image(bkd1, (mp_scroll/2)%1280, (me.y/2.f)%640);
  image(bkd1, (mp_scroll/2)%1280+1280, (me.y/2.f)%640);
  image(bkd1, (mp_scroll/2)%1280-1280, (me.y/2.f)%640 - 640);
  image(bkd1, (mp_scroll/2)%1280, (me.y/2.f)%640 - 640);
  image(bkd1, (mp_scroll/2)%1280+1280, (me.y/2.f)%640 - 640);
  //image(bkd1, (mp_scroll/2)%640+1280, 0);
  translate(0, floor(me.y - height*3 - height/2 ));

  //Draw chunks that are visible
  float shift=mp_scroll+chunkA*(Chunk.CHUNK_U*SPRITE_GRID);//%(Chunk.CHUNK_U*SPRITE_GRID);
  //println(shift);
  ArrayList<Integer> cids = new ArrayList<Integer>();
  for (int i=-1; i<4; i++) {
    Chunk c=map.get(i+chunkA);
    render(c, int(shift+i*(Chunk.CHUNK_U*SPRITE_GRID)));
    cids.add(i + chunkA);
  }
  drawLights(shift);
  calcLightingRange(map, cids);
  //Draw peepl
  //spriteLib.get(100).display(20, 12);
  me.display(mp_scroll);
  me.update();
  me.physics();
  //Draw overlay
  mp_scroll = -(int)me.x + width/2;
  println(cLightID);
}

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

void drawLights(float shift) {
  for(Light l : blockLights.values()) {
    int offset = int(shift + l.chunk*(Chunk.CHUNK_U*SPRITE_GRID));
    spriteLib.get(4).display(l.x, l.y, offset, 0, 0);
  }
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
  int chunk=floor(me.x/float(SPRITE_GRID*Chunk.CHUNK_U));
  int block=floor(me.x/SPRITE_GRID)-chunk*Chunk.CHUNK_U;
  int blockY=floor(me.y/SPRITE_GRID)-1;
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

void mousePressed() {
  if(mouseButton == RIGHT) {
    int chunk=floor(me.x/float(SPRITE_GRID*Chunk.CHUNK_U));
    int block=floor(me.x/SPRITE_GRID)-chunk*Chunk.CHUNK_U;
    int blockY=floor(me.y/SPRITE_GRID)-1;
    colorMode(HSB);
    while(!blockLights.containsKey(cLightID)) cLightID++;
    addBlockLight(new Light(chunk, block, blockY, color(random(255), 255, 255), random(0.5, 2.5)));
    colorMode(RGB);
  } else {
    int chunk=floor(me.x/float(SPRITE_GRID*Chunk.CHUNK_U));
    int block=floor(me.x/SPRITE_GRID)-chunk*Chunk.CHUNK_U;
    int blockY=floor(me.y/SPRITE_GRID)-1;
    
    for(int x = -1; x <= 1; x++) {
      for(int y = -1; y <= 2; y++) {
        map.get(chunk).smartSet(block + x, blockY + y, 0);
      }
    }
  }
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

int isum(int... data) {
  int o = 0;
  for(int i : data) o += i;
  return o;
}

int imax(int... data) {
  int fm = -2147483648;
  for(int i : data) if(i > fm) fm = i;
  return fm;
}

boolean is_occupied(float xCoord, float yCoord2) {
  float yCoord = yCoord2 - Chunk.CHUNK_V/5;
  if((int)yCoord == Chunk.CHUNK_V-1) return false;
  boolean occupied = false;
  float n = max(0, noise((float)xCoord/150.f-1000.f)*2.f-0.3f);
  float caves = ridged_noise(xCoord/200.f - 4002.321, yCoord/100.f);
  float f = noise((float)xCoord/16.f+ 1000.f, (float)yCoord/16.f)-0.5f;
  float yMap = yCoord/Chunk.CHUNK_V - 0.5f;
  if(f*n > yMap) occupied = true;
  if(caves - max(0, -yCoord-Chunk.CHUNK_V/20)/200.f > 0.985f) occupied = false;
  return occupied || yCoord < -Chunk.CHUNK_V/5;
}
public float ridged_noise(float x, float y) {
  float r = noise(x, y)*2.0;
  return r > 1.0 ? -r + 2.0 : r;
}

void genChunk(int i) {
  map.put(i, new Chunk(i));
  Chunk c=map.get(i);
  for (int j=0; j<Chunk.CHUNK_U; j++) {
    for (int k=Chunk.CHUNK_V-1; k>=0; k--) {
      int xCoord = j + Chunk.CHUNK_U*i;
      int yCoord = k;
      int blockType = 0;
      int blockSlope = 0;
      boolean occupied = is_occupied(xCoord, yCoord);
      if(occupied) {
        blockType = 1;
        if(is_occupied(xCoord, yCoord + 1)) {
          blockType = 2;
          if(!is_occupied(xCoord, yCoord + 2)) {
            boolean UR = is_occupied(xCoord + 1, yCoord + 1);
            boolean UL = is_occupied(xCoord - 1, yCoord + 1);
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
            boolean under = is_occupied(xCoord, yCoord - 1);
            if(!under) blockSlope = 5;
          }
          else if(left && !right) {
            blockSlope = 2;
            boolean under = is_occupied(xCoord, yCoord - 1);
            if(!under) blockSlope = 6;
          }
          else if(!left && !right) {
            if(!is_occupied(xCoord, yCoord - 1)) blockSlope = 3; else blockSlope = 4;
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

class Chunk {
  /*
  get( sprite x, sprite y) -> return value at location (in chunk space)
   set( sprite x, sprite y,int val) -> set value at location (in chunk space)
   data -> int[25][75] of sprite data: x first
   */
  static final int CHUNK_U=20;
  static final int CHUNK_V=80;
  int[][] data=new int[CHUNK_U][CHUNK_V];
  int[][] light=new int[CHUNK_U][CHUNK_V];
  int[][] lgtmp = new int[Chunk.CHUNK_U][Chunk.CHUNK_V];
  int[][] lightLink = new int[Chunk.CHUNK_U][Chunk.CHUNK_V];
  boolean[][] done = new boolean[Chunk.CHUNK_U][Chunk.CHUNK_V];
  int id = 0;
  Chunk() {
    for (int i=0; i<CHUNK_U; i++) {
      for (int j=0; j<CHUNK_V; j++) {
        data[i][j]=0;
        light[i][j]=0;
        lgtmp[i][j]=0;
        done[i][j]=false;
        lightLink[i][j]=-1;
      }
    }
  }
  Chunk(int id) {
    this.id = id;
    for (int i=0; i<CHUNK_U; i++) {
      for (int j=0; j<CHUNK_V; j++) {
        data[i][j]=0;
        light[i][j]=0;
        done[i][j]=false;
        lightLink[i][j]=-1;
      }
    }
  }
  int get(int u, int v) {
    return data[u][v];
  }
  color getCol(int u, int v) {
    if(u < 0 && map.containsKey(id-1)) return map.get(id-1).getCol(CHUNK_U-1, min(CHUNK_V-1, max(0, v)));
    if(u > Chunk.CHUNK_U-1 && map.containsKey(id+1)) return map.get(id+1).getCol(0, min(CHUNK_V-1, max(0, v)));
    return light[min(CHUNK_U-1, max(0, u))][min(CHUNK_V-1, max(0, v))];
  }
  void set(int u, int v, int val) {
    data[u][v]=val;
  }
  void smartSet(int u, int v, int val) {
    if(v < 0 || v > CHUNK_V-1) return;
    if(u < 0 && map.containsKey(id-1)) { map.get(id-1).smartSet(u + CHUNK_U, v, val); return; }
    if(u > CHUNK_U-1 && map.containsKey(id+1)) { map.get(id+1).smartSet(u - CHUNK_U, v, val); return; }
    if(val == 0 && lightLink[u][v] != -1) blockLights.remove(lightLink[u][v]);
    data[u][v] = val;
  }
}

class Sprite {
  ArrayList<PImage> img=new ArrayList<PImage>();
  int dir=0;
  boolean mirror=false;

  void display(int u, int v) {
    this.display(u, v, 0, 0);
  }
  void display(int u, int v, int x, int y) {
    pushMatrix();
    translate(u*SPRITE_GRID+x, (Chunk.CHUNK_V-v)*SPRITE_GRID+y);
    if(mirror) { translate(img.get(0).width, 0); scale(-1, 1); }
    image(img.get(0), 0, 0);
    popMatrix();
  }
  
  void setMirror(boolean tru) {
    mirror = tru;
  }

  void display(int u, int v, int x, int y, int typ) {
    pushMatrix();
    translate(u*SPRITE_GRID+x, (Chunk.CHUNK_V-v)*SPRITE_GRID+y);
    if(mirror) { translate(img.get(typ).width, 0); scale(-1, 1); }
    image(img.get(typ), 0, 0);
    popMatrix();
  }
}

void loadSprite(int i, String ... name) {
  spriteLib.put(i, new Sprite());
  Sprite s=spriteLib.get(i);
  for (int j=0; j<name.length; j++) {
    s.img.add(loadImage(name[j]));
  }
}
void loadSprite(int i, int size, String ... name) {
  spriteLib.put(i, new Sprite());
  Sprite s=spriteLib.get(i);
  for (int j=0; j<name.length; j++) {
    s.img.add(loadImage(name[j]));
  }
  for (int j=0; j<name.length; j++) {
    PImage wk=s.img.get(j);
    wk.resize(size, size);
  }
}
void loadSpriteAlpha(int i, String ... name) {
  spriteLib.put(i, new Sprite());
  Sprite s=spriteLib.get(i);
  for (int j=0; j<name.length; j++) {
    s.img.add(loadImage(name[j]));
  }
  for (int j=0; j<name.length; j++) {
    PImage wk=s.img.get(j);
    PImage mask=wk.copy();
    mask.filter(INVERT);
    mask.filter(THRESHOLD, 0.05);
    wk.mask(mask);
  }
}
void loadSpriteAlpha(int i, int size, String ... name) {
  spriteLib.put(i, new Sprite());
  Sprite s=spriteLib.get(i);
  for (int j=0; j<name.length; j++) {
    s.img.add(loadImage(name[j]));
  }
  for (int j=0; j<name.length; j++) {
    PImage wk=s.img.get(j);
    PImage mask=wk.copy();
    mask.filter(INVERT);
    mask.filter(THRESHOLD, 0.05);
    wk.mask(mask);
    wk.updatePixels();
    int[] px=wk.pixels;
    wk.resize(size, size);
    int npx[]=new int[px.length*4];
    for (int p=0; p<npx.length; p++) {
      npx[p]=px[((p%size)/2)+(floor(p/size)/2)*size/2];
    }
    wk.pixels=npx;
    wk.loadPixels();
  }
}

void initializeSpriteLib() {
  spriteLib.put(0, new Sprite());
  PGraphics err=createGraphics(SPRITE_GRID, SPRITE_GRID);
  err.beginDraw();
  err.noStroke();
  err.fill(255, 0, 255);
  err.rect(0, 0, SPRITE_GRID/2, SPRITE_GRID/2);
  err.rect(SPRITE_GRID/2, SPRITE_GRID/2, SPRITE_GRID/2, SPRITE_GRID/2);
  err.endDraw();
  spriteLib.get(0).img.add(err.get());
}

Sprite getS(int i) {
  i=i%1000;
  Sprite s;
  if (spriteLib.containsKey(i)) {
    s=spriteLib.get(i);
  } else {
    s=spriteLib.get(0);
  }
  return s;
}

class Player {
  float x=0;
  float y=5000;
  int body=200;
  int equip=0;
  int hat=0;
  float HV=4;
  PVector facing;
  PVector v=new PVector(0, 0);

  int jumps=0;
  int maxJumps=2;
  boolean jumped=false;
  
  boolean facingLeft = false;

  void display(int scroll) {
    int lx=int(x+scroll);
    int blockY=floor(y/SPRITE_GRID);
    float YY=(y/SPRITE_GRID)%1f;
    getS(body).display(0, blockY, lx, SPRITE_GRID-(int)(YY*SPRITE_GRID));
  }

  void update() {
    if (key('a')||key('A')) {
      v.x-=0.5;
      facingLeft = true;
    }
    if (key('d')||key('D')) {
      v.x+=0.5;
      facingLeft = false;
    }
    getS(body).setMirror(facingLeft);
  }


  void physics() {
    int chunk=floor(x/float(SPRITE_GRID*Chunk.CHUNK_U));
    int block=floor(x/SPRITE_GRID)-chunk*Chunk.CHUNK_U;
    int block_place=floor(x)%SPRITE_GRID;
    int blockY=floor(y/SPRITE_GRID)-1;

    //println(block, blockY);
    Chunk c=map.get(chunk);
    int in;
    int below;
    if (blockY<=0)below=999;
    else if (blockY>Chunk.CHUNK_V)below=0;
    else {
      below=c.get(block, blockY-1);
      if(x%SPRITE_GRID>4){
        if(block>Chunk.CHUNK_U-3)below=max(below,map.get(chunk+1).get(0,blockY-1));
        else below=max(below,c.get(block+1,blockY-1));
      }
    }
    if (blockY<Chunk.CHUNK_V-1)in=c.get(block, blockY+1);
    else in=0;
    int left;
    int right;
    //println("dbg",blockY,y,v.y);
    if(in>0){
      v.y=min(0,v.y);
    }
    if (y<0||blockY>=Chunk.CHUNK_V) {
      left=0;
      right=0;
    } else {
      if (block==0) {
        left=map.get(chunk-1).get(Chunk.CHUNK_U-1, blockY);
      } else left=c.get(block-1, blockY);


      if (block==Chunk.CHUNK_U-1) {
        right=map.get(chunk+1).get(0, blockY);
      } else right=c.get(block+1, blockY);


      //getS(0).display(block, blockY);
      //getS(200).display(0, 0);
    }
    //println(below, left, right, jumps);

    float dist=y%SPRITE_GRID;
    if (below>0&&v.y<=0) {
      if (v.y>0&&v.y<dist) {
        y+=v.y;
      } else {
        y-=dist*.5;
        v.y=0;
        jumps=0;
      }
    } else {
      v.y-=0.5;
      y+=v.y;
    }

    float distX=x%SPRITE_GRID;
    if (v.x*HV>0) {
      if (right>0) {
        if (abs(v.x*HV)<distX) {
          x+=v.x*HV;
        } else {
          //x+=SPRITE_GRID-distX;
          v.x=0;
        }
      } else x+=v.x*HV;
    }
    
    if (v.x*HV<0) {
      if (left>0) {
        if (abs(v.x*HV)<distX) {
          x+=v.x*HV;
        } else {
          x+=-distX;
          v.x=0;
        }
      } else x+=v.x*HV;
    }

    //x+=v.x*HV;
    v.x/=2;
  }


  void keyAction(char keyP, boolean down) {
    if (keyP=='w'||keyP=='W') {
      if (!jumped) {
        if (down) {
          if (jumps<maxJumps) {
            v.y+=10;
            jumps++;
          }
        } else {
          v.y=max(v.y, 0);
        }
      }
      jumped=down;
    }
  }
}

class Thing {
}

boolean key(char c) {
  return keyStates.get(c);
}
boolean key(int c) {
  return keyCodeStates.get(c);
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

int r(color c) {return (c >> 16) & 255; }
int g(color c) {return (c >> 8) & 255;}
int b(color c) {return c & 255; }