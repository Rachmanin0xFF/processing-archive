// Block id code: ppSssiii : i=sprite_id, s=sub_sprite S=state, p=physics_shape
class Sprite {
  ArrayList<PImage> img=new ArrayList<PImage>();
  int dir=0;
  boolean mirror=false;
  //ArrayList<Integer> phys=new ArrayList<Integer>();
  void display(int u, int v) {
    this.display(u, v, 0, 0);
  }
  void display(int u, int v, int x, int y) {
    pushMatrix();
    translate(u*GRID+x, v*GRID+y);
    if (mirror) { 
      translate(img.get(0).width, 0); 
      scale(-1, 1);
    }
    image(img.get(0), 0, 0);
    popMatrix();
  }

  void setMirror(boolean tru) {
    mirror = tru; // WHYYYYYYY!!?!?!?!?!
  }

  void display(int u, int v, int x, int y, int typ) {
    pushMatrix();
    translate(u*GRID+x, v*GRID+y);
    if (mirror) { 
      translate(img.get(typ).width, 0); 
      scale(-1, 1);
    }
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
  PGraphics err=createGraphics(GRID, GRID);
  err.beginDraw();
  err.noStroke();
  err.fill(255, 0, 255);
  err.rect(0, 0, GRID/2, GRID/2);
  err.rect(GRID/2, GRID/2, GRID/2, GRID/2);
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

int getBlock(int chunk, int u, int v) {
  //println("Gettin:",u,v);
  while (u<0) {
    chunk--; 
    u+=Chunk.U;
  }
  while (u>=Chunk.U) {
    chunk++; 
    u-=Chunk.U;
  }
  //println("Gettin 2:",u,v);
  if(v<0||v>Chunk.V)return 0;//println("There's about to be an error. It's from here, getSprite. awhjfou <- somthing unique to ctrl-f for");
  else{return map.get(chunk).get(u,v);}
  
}




int getBlockPhys(int chunk, int u, int v) {
  return floor(getBlock(chunk, u, v)/1000);
}