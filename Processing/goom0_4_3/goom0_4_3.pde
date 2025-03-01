
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
int GRID=32;
int s_spaceX=80;
int s_spaceY=40;
float noise_strength=0.1;

// MAP DATA
HashMap<Integer, Chunk> map=new HashMap<Integer, Chunk>();
HashMap<Integer, Sprite> spriteLib=new HashMap<Integer, Sprite>();

// IMAGE STORAGE
PImage bkd1;
//PImage bkd2;


PShader lightMultiply;

// GAME VARIABLES
int mp_x_scroll=0; // in screen-space
int mp_y_scroll=-100; // in screen-space
Player me=new Player();

//////////////////////////////////////////////////////////////////////////
void setup() {
  size(1280, 640, P2D);
  
  initAudio();
  startAudio();

  // LOAD SHADERS
  lightMultiply = loadShader("lmult.shader");

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
  loadSpriteAlpha(300,32,"lamp.png");

  //Initialize keyStates
  initKeyTracker();
  //frameRate(1000);
  ArrayList<Integer> cids2 = new ArrayList<Integer>();
  for(int i = 0; i < 1000; i++) { genChunk(i); cids2.add(i); }
  calcLightingRange(map, cids2);
}

void draw() {
  background(0);
  
  //Draw Background
  int qx = mp_x_scroll/4;
  int qy = mp_y_scroll/4;
  image(bkd1, qx%1280 + 1280, qy%640 - 640);
  image(bkd1, qx%1280, qy%640 - 640);
  image(bkd1, qx%1280, qy%640);
  image(bkd1, qx%1280 + 1280, qy%640);
  image(bkd1, qx%1280 + 1280, qy%640 + 640);
  image(bkd1, qx%1280, qy%640 + 640);
  
  pushMatrix();
  translate(mp_x_scroll, mp_y_scroll);

  if (key(LEFT)) {
    mp_x_scroll+=12;
  }
  if (key(RIGHT)) {
    mp_x_scroll-=12;
  }

  //Test for need to gen chunks
  //println(-(mp_scroll/float(GRID*Chunk.U)));
  int chunkA=floor(-(mp_x_scroll/float(GRID*Chunk.U)));
  //println("Chunk A", chunkA);
  for (int i=-1; i<4; i++) {
    if (!map.containsKey(i+chunkA)) {
      genChunk(i+chunkA);
    }
  }

  //Draw chunks that are visible
  float shift=chunkA*(Chunk.U*GRID);//%(Chunk.U*GRID);
  renderWorld(chunkA);
  
  me.display();
  me.update();
  physics(me.p);
  //Draw overlay
  mp_x_scroll = -(int)me.p.x + width/2;
  mp_y_scroll= -(int)me.p.y + height/2;
  popMatrix();
  fill(255, 0, 0);
  text(frameRate, 20, 20);
  if(random(100) > 98) recalcLighting = true;
  //filter(lightMultiply);
}
class Thing {
}

boolean key(char c) {
  return keyStates.get(c);
}
boolean key(int c) {
  return keyCodeStates.get(c);
}