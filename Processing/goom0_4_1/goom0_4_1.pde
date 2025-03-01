//LIGHTING REWRITE
//Right-click to make a light
//Left-click to mine thru stuff
//Increased map hht by 4x
//Lights exist and propagate thru space
//Sun/moonlight casts soft shadows
//Switched renderer to P2D seigo stuff still runs >60FPS
//Goomspook now flips directions
//Improved terrain generation
//More cave-like caves
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
  image(bkd1, (mp_scroll/2)%1280-1280, 0);
  image(bkd1, (mp_scroll/2)%1280, 0);
  image(bkd1, (mp_scroll/2)%1280+1280, 0);
  //image(bkd1, (mp_scroll/2)%640+1280, 0);
  translate(0, floor(me.p.y - height*3 - height/2 ));

  //Draw chunks that are visible
  float shift=mp_scroll+chunkA*(Chunk.CHUNK_U*SPRITE_GRID);//%(Chunk.CHUNK_U*SPRITE_GRID);
  //println(shift);
  ArrayList<Integer> cids = new ArrayList<Integer>();
  for (int i=-1; i<4; i++) {
  Chunk c=map.get(i+chunkA);
  render(c, int(shift+i*(Chunk.CHUNK_U*SPRITE_GRID)));
  cids.add(i + chunkA);
  }
  calcLightingRange(map, cids);
  //Draw peepl
  //spriteLib.get(100).display(20, 12);
  me.display(mp_scroll);
  me.update();
  physics(me.p);
  //Draw overlay
  ArrayList<Edge> vis=buildLocal(toChunk(me.p.x),bicX(me.p.x),bicY(me.p.y),10);
  for(Edge e: vis){
    stroke(255,0,0);
    line(e.a.x+mp_scroll,height-e.a.y,e.b.x+mp_scroll,height-e.b.y);
  }
  mp_scroll = -(int)me.p.x + width/2;
  println(cLightID);
}
class Thing {
}

boolean key(char c) {
  return keyStates.get(c);
}
boolean key(int c) {
  return keyCodeStates.get(c);
}