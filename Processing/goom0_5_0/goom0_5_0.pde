
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
PImage menuBkd;


PShader lightMultiply;
PShader lightMultiply2;

// GAME VARIABLES
int mp_x_scroll=0; // in screen-space
int mp_y_scroll=-100; // in screen-space
Player me=new Player();

Power p=new Power(1, 2, "bob", color(243, 234, 43));
//////////////////////////////////////////////////////////////////////////
void setup() {
  size(1280, 720, P2D);
     
  //fullScreen(P2D);

  initAudio();
  startAudio();

  // LOAD SHADERS
  lightMultiply = loadShader("lmult.shader");
  lightMultiply2 = loadShader("lmult2.shader");

  // LOAD IMAGES
  initializeSpriteLib();

  // LOAD IMAGES
  bkd1=loadImage("BlueSpace.jpg");
  menuBkd=loadImage("BlueSpace.jpg");
  loadSpriteAlpha(1, 32, "grass/grass.bmp", "grass/grass_Lramp.bmp", "grass/grass_Rramp.bmp", "grass/grass_Lone.bmp", "grass/grass_Bump.bmp", "grass/grass_Lhang.bmp", "grass/grass_Rhang.bmp");
  loadSpriteAlpha(2, 32, "rock/rock.bmp", "rock/rock_GrassL.bmp", "rock/rock_GrassR.bmp", "rock/rock_GrassLR.bmp");
  loadSpriteAlpha(3, 32, "light.bmp");
  loadSpriteAlpha(100, "goom/goom.png", "goom/goomcoat.png", "goom/goomded.png");
  loadSpriteAlpha(200, 32, "goomspook.bmp");
  loadSpriteAlpha(201, "trump.bmp");
  loadSpriteAlpha(300, 32, "lamp.png");

  //Initialize keyStates
  initKeyTracker();
  frameRate(60);
  PFont font=createFont("eurosti.ttf", 72);
  textFont(font);
  title.x=width/2;
  begin.x=width/2;
  settings.x=width/2;
  clickbait.x=width/2;
  
  //ArrayList<Integer> cids2 = new ArrayList<Integer>();
  //for(int i = 0; i < 1000; i++) { genChunk(i); cids2.add(i); }
  //calcLightingRange(map, cids2);
  triggerIntro(floor(random(0,intros.size())));
}

void draw() {
  background(0);
  tint(255);
  int k = ((GRID*Chunk.V)/1280)*1280 - 320;
  if (me.p.y>k) {
    me.p.y = 0;
  }
  //Draw Background
  int qx = mp_x_scroll/4;
  int qy = mp_y_scroll/4;
  image(bkd1, qx%1280, qy%640f);
  image(bkd1, qx%1280 + 1280, qy%640f);
  image(bkd1, qx%1280 + 1280, qy%640f + 640);
  image(bkd1, qx%1280, qy%640f + 640);
  image(bkd1, qx%1280 + 1280, qy%640f - 640);
  image(bkd1, qx%1280, qy%640f - 640);
  image(bkd1, qx%1280 + 1280, qy%640f + 640 + 640);
  image(bkd1, qx%1280, qy%640f + 640 + 640);

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
  boolean buildlighting=false;
  ArrayList<Integer> cids2 = new ArrayList<Integer>();
  for (int i=-1; i<4; i++) {
    if (!map.containsKey(i+chunkA)) {
      genChunk(i+chunkA);
      buildlighting=true;
      
    }
    cids2.add(i+chunkA);
  }
  if(buildlighting)calcLightingRange(map,cids2);
  //GOES IN SETUP
if(random(100) > 98) recalcLighting = true;
renderWorld(chunkA);
  //Draw chunks that are visible
  float shift=chunkA*(Chunk.U*GRID);//%(Chunk.U*GRID);
  //println(shift);

  //Draw peepl
  //spriteLib.get(100).display(20, 12);\
  me.display();
  renderSpecular(toChunk(me.p.x), bicX(me.p.x), bicY(me.p.y), 6);
  if (menuOpen) {
    menuness=min(1, menuness+0.05);
  } else {
    menuness=max(0, menuness-0.05);


    me.update();
    physics(me.p);
  }
  //Draw overlay
  mp_x_scroll = -(int)me.p.x + width/2;
  mp_y_scroll= -(int)me.p.y + height/2;
  popMatrix();
  fill(255, 0, 0);
  textSize(12);
  textAlign(LEFT, CENTER);
  text(1000.f/frameRate + " " + k, 20, 20);
  p.hue1=100;
  p.hue2=140;
  p.update();
  //p.draw(10, 10);
  me.drawStat();
  menuDraw();
  lightMultiply.set("time", ((float)(millis()))/1000.f);
  lightMultiply.set("trippiness", 5f);
  lightMultiply.set("sineOffset", me.p.x, -me.p.y);
  lightMultiply2.set("time", ((float)(millis()))/1000.f);
  lightMultiply2.set("ASPECT", float(width)/float(height));
  filter(lightMultiply2);
  filter(lightMultiply);
  //filter(lightMultiply2);
}
class Thing {
}

boolean key(char c) {
  return keyStates.get(c);
}
boolean key(int c) {
  return keyCodeStates.get(c);
}