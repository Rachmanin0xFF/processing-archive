
float x_pos = 0.f;
float y_pos = 0.f;
float zoom = 1.f;

ArrayList<Level> world = new ArrayList<Level>();
int activeLevel = 0;

LayerViewer layers;
Button newTile;
Button deleteTile;
Button gridLines;
Button backgroundTiles;
Button physicsLines;
Button b_save;

Button b_brush;
Button b_physics;
Button b_particles;

Theme GUIVisualStyle = new Theme(/*fill*/ color(0, 255), /*border*/ color(255, 255));

void setup() {
  size(1600, 900, P2D);
  surface.setResizable(true);
  noSmooth();
  frameRate(1000);
  world.add(new Level(dataPath("") + "/level0"));
  initGUI();
}
int pwidth = 1600;
int pheight = 900;
boolean pmousePressed = false;
void draw() {
  background(50);
  
  if(pwidth != width || pheight != height) initGUI();
  pwidth = width;
  pheight = height;
  
  pushMatrix();
  translate(width/2, height/2);
  scale(zoom);
  translate(-x_pos, -y_pos);
  
  if(backgroundTiles.is_on) world.get(activeLevel).dispBkgAt(x_pos, y_pos);
  if(gridLines.is_on) drawLines();
  if(physicsLines.is_on) world.get(activeLevel).dispPhysicsLines();
  
  popMatrix();
  strokeWeight(1);
  layers.UD(world.get(activeLevel));
  newTile.UD();
  deleteTile.UD();
  gridLines.UD();
  backgroundTiles.UD();
  physicsLines.UD();
  b_brush.UD();
  b_physics.UD();
  b_particles.UD();
  b_save.UD();
  buttonSwap();
  if(newTile.is_on && newTile.changed) {
    world.get(activeLevel).img_bkg.add(createImage(world.get(activeLevel).bkgRad, world.get(activeLevel).bkgRad, RGB));
  }
  if(deleteTile.is_on && deleteTile.changed) {
    world.get(activeLevel).deleteTile(layers.activeLayer);
  }
  if(b_save.is_on && b_save.changed) {
    world.get(activeLevel).saveTo("level0");
  }
  
  if(mousePressed && mouseButton == LEFT && mouseNotClickyMenu()) {
    if(b_brush.is_on) {
      PVector p = screenToWorld(mouseX, mouseY);
      int x = (int)(p.x/world.get(activeLevel).bkgRad);
      int y = (int)(p.y/world.get(activeLevel).bkgRad);
      if(is_in_bounds_inclusive(x, y, 0, 0, world.get(activeLevel).bkg.length-1, world.get(activeLevel).bkg[0].length-1))
        world.get(activeLevel).bkg[x][y] = layers.activeLayer;
    }
    if(b_physics.is_on && !pmousePressed) {
      world.get(activeLevel).handleMousePressPhysics(screenToWorld(mouseX, mouseY));
    }
  }
  if(keyPressed && world.get(activeLevel).chaining && b_physics.is_on && (key == 'x' || key == 'x')) {
    world.get(activeLevel).endChain();
  }
  
  fill(255/2, 255);
  text(float(round(zoom*1000))/10.f + "% " + (int)frameRate + "FPS AutumnLight2D GameEditor PA-0-1", 10, height - 14);
  pmousePressed = mousePressed;
}

void mouseWheel(MouseEvent me) {
  float e = me.getCount();
  if(is_in_bounds_inclusive(mouseX, mouseY, layers.x, layers.y, layers.w, layers.h)) {
    layers.scrollv -= me.getCount()*2.f;
  } else {
    if(e > 0) zoom /= 1.1f;
    if(e < 0) zoom *= 1.1f;
  }
}

boolean mouseNotClickyMenu() {
  boolean b = false;
  b |= is_in_bounds_inclusive(mouseX, mouseY, layers.x, layers.y, layers.w, layers.h);
  b |= gridLines.inMyBounds();
  b |= backgroundTiles.inMyBounds();
  b |= b_brush.inMyBounds();
  b |= b_physics.inMyBounds();
  b |= b_particles.inMyBounds();
  b |= b_save.inMyBounds();
  return !b;
}

void mouseDragged() {
  if(mouseButton == RIGHT) {
    x_pos += float(pmouseX - mouseX)/zoom;
    y_pos += float(pmouseY - mouseY)/zoom;
  }
}

PVector screenToWorld(float x, float y) {
  return new PVector((x - width/2)/zoom + x_pos, (y - height/2)/zoom + y_pos);
}

class Chain {
  ArrayList<Integer> links;
  boolean loop = false;
  public Chain() {
    links = new ArrayList<Integer>();
  }
  public Chain(int start) {
    links = new ArrayList<Integer>();
    links.add(start);
  }
  public void add(int k) {
    links.add(k);
  }
  public int[] gitstuf() {
    int[] o = new int[links.size()];
    for(int i = 0; i < o.length; i++) {
      o[i] = links.get(i);
    }
    return o;
  }
}

Chain copy_chain(Chain c) {
  Chain o = new Chain();
  for(int i = 0; i < c.links.size(); i++) {
    o.add(c.links.get(i));
  }
  o.loop = c.loop;
  return o;
}

class Level {
  String name = "";
  ArrayList<PImage> img_bkg;
  int[][] bkg;
  int bkgRad = 512;
  float bkgScale = 1.f;
  int w = 0;
  int h = 0;
  ArrayList<PVector> p_nodes = new ArrayList<PVector>();
  ArrayList<Chain> p_edges = new ArrayList<Chain>();
  boolean chaining = false;
  float tile_size = 0.f;
  public Level(String levelPath) {
    load(levelPath);
  }
  void load(String levelPath) {
    File dir = new File(levelPath + "/bkg");
    int num = dir.list().length;
    img_bkg = new ArrayList<PImage>();
    for(int i = 0; i < num; i++) {
      img_bkg.add(loadImage(levelPath + "/bkg/" + i + ".png"));
    }
    bkgRad = img_bkg.get(0).width;
    String[] bkgplc = loadStrings(levelPath + "/bkg_placement.txt");
    int w = bkgplc[0].split(" ").length;
    int h = bkgplc.length;
    bkg = new int[w][h];
    this.w = w;
    this.h = h;
    for(int y = 0; y < h; y++) {
      String[] parts = bkgplc[y].split(" ");
      for(int x = 0; x < w; x++) {
        bkg[x][y] = Integer.parseInt(parts[x]);
      }
    }
    String[] settingsTxt = loadStrings(levelPath + "/settings.txt");
    for(String s : settingsTxt) {
      String[] s2 = s.split(" ");
      if(s2[0].equals("tile_size")) {
        tile_size = float(s2[1]);
      }
    }
    String[] physicsTxt = loadStrings(levelPath + "/physics.txt");
    for(String s : physicsTxt) {
      String[] splt = s.split(" ");
      
      if(splt[0].startsWith("c")) {
        Chain c = new Chain();
        int start = p_nodes.size();
        for(int i = 1; i < splt.length; i+=2) {
          PVector p = new PVector(Float.parseFloat(splt[i])*bkgRad/tile_size, (tile_size*h - Float.parseFloat(splt[i+1]))*bkgRad/tile_size);
          p_nodes.add(p);
          c.add(p_nodes.size()-1);
        }
        if(splt[0].equals("cl")) {
          c.add(start);
          c.loop = true;
        }
        p_edges.add(c);
      }
    }
  }
  void saveTo(String folderloc) {
    String[] settings = new String[]{("tile_size " + tile_size)};
    saveStrings(folderloc + "/settings.txt", settings);
    String[] bkg_placement = new String[h];
    for(int y = 0; y < h; y++) bkg_placement[y] = new String("");
    for(int y = 0; y < h; y++) {
      for(int x = 0; x < w; x++) {
        bkg_placement[y] += bkg[x][y] + " ";
      }
    }
    saveStrings(folderloc + "/bkg_placement.txt", bkg_placement);
    for(int i = 0; i < img_bkg.size(); i++) {
      img_bkg.get(i).save(folderloc + "/bkg/" + i + ".png");
    }
    ArrayList<String> physData = new ArrayList<String>();
    for(Chain c : p_edges) {
      String thisLine = "c ";
      if(c.loop) thisLine = "cl ";
      int max = c.links.size()-1;
      if(!c.loop) max++;
      for(int i = 0; i < max; i++) {
        thisLine += p_nodes.get(c.links.get(i)).x/bkgRad*tile_size + " " + (tile_size*h - p_nodes.get(c.links.get(i)).y/bkgRad*tile_size) + " ";
      }
      physData.add(thisLine);
    }
    saveStrings(folderloc + "/physics.txt", to_array(physData));
    println("Level saved to " + folderloc + ".");
  }
  void deleteTile(int i) {
    img_bkg.remove(i);
    for(int x = 0; x < w; x++) {
      for(int y = 0; y < h; y++) {
        if(bkg[x][y] == i) bkg[x][y] = 0;
        if(bkg[x][y] > i) {
          bkg[x][y]--;
        }
      }
    }
  }
  void dispBkgAt(float xcoord, float ycoord) {
    int dsxrad = max(1, ceil((float)width/((float)bkgRad*zoom)));
    int dsyrad = max(1, ceil((float)height/((float)bkgRad*zoom)));
    
    int xindex = round(xcoord/bkgRad);
    int yindex = round(ycoord/bkgRad);
    
    int xstart = max(0, xindex - dsxrad);
    int xstop = min(bkg.length, xindex + dsxrad);
    int ystart = max(0, yindex - dsyrad);
    int ystop = min(bkg[0].length, yindex + dsyrad);
    
    for(int x = xstart; x < xstop; x++) {
      for(int y = ystart; y < ystop; y++) {
        image(img_bkg.get(bkg[x][y]), x*bkgRad, y*bkgRad, bkgRad, bkgRad);
      }
    }
  }
  void dispPhysicsLines() {
    strokeWeight(1.f/zoom);
    stroke(0, 200, 0, 200);
    noFill();
    for(PVector p : p_nodes) {
      ellipse(p.x, p.y, 15.f/zoom, 15.f/zoom);
    }
    
    for(Chain e : p_edges) {
      beginShape();
      for(int i : e.links) {
        float x = p_nodes.get(i).x;
        float y = p_nodes.get(i).y;
        vertex(x, y);
      }
      endShape();
    }
  }
  Chain nuChain;
  void handleMousePressPhysics(PVector POI) {
    boolean clikonNode = false;
    int nodeClikID = 0;
    int nodeycounty = 0;
    for(PVector p : p_nodes) {
      if(dist(POI.x, POI.y, p.x, p.y) < 15.f/zoom) {
        clikonNode = true;
        nodeClikID = nodeycounty;
        break;
      }
      nodeycounty++;
    }
    if(!clikonNode) {
      p_nodes.add(new PVector(POI.x, POI.y));
      if(!chaining) {
        chaining = true;
        nuChain = new Chain(p_nodes.size()-1);
      } else {
        nuChain.add(p_nodes.size()-1);
      }
    } else {
      if(chaining) {
        nuChain.add(nodeClikID);
        nuChain.loop = true;
        endChain();
      } else {
        //find active chain and store
      }
    }
  }
  void endChain() {
    p_edges.add(copy_chain(nuChain));
    chaining = false;
  }
}

void drawLines() {
  int dsxrad = max(1, ceil((float)width/((float)world.get(activeLevel).bkgRad*zoom)) - 1);
  int dsyrad = max(1, ceil((float)height/((float)world.get(activeLevel).bkgRad*zoom)));
  
  int xindex = round(x_pos/world.get(activeLevel).bkgRad);
  int yindex = round(y_pos/world.get(activeLevel).bkgRad);
  
  int xstart = max(0, xindex - dsxrad);
  int xstop = min(world.get(activeLevel).bkg.length, xindex + dsxrad);
  int ystart = max(0, yindex - dsyrad);
  int ystop = min(world.get(activeLevel).bkg[0].length, yindex + dsyrad);
  
  strokeWeight(1.f/zoom);
  stroke(255, 0, 0, 255);
  for(int x = xstart; x <= xstop; x++) {
    line(x*world.get(activeLevel).bkgRad, -100000.f, x*world.get(activeLevel).bkgRad, 100000.f);
  }
  for(int y = ystart; y <= ystop; y++) {
    line(-100000.f, y*world.get(activeLevel).bkgRad, 100000.f, y*world.get(activeLevel).bkgRad);
  }
}

class LayerViewer {
  float x;
  float y;
  float w;
  float h;
  color fill_color = color(0, 0, 0, 100);
  color border_color = color(255, 255);
  float radius = 0;
  float spacing = 80;
  float scroll = 80;
  float scrollv = 0.f;
  int activeLayer = 0;
  public LayerViewer(float x, float y, float w, float h) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
  }
  void UD(Level l) {
    if(activeLayer >= l.img_bkg.size()) activeLayer = l.img_bkg.size()-1;
    scroll += scrollv;
    scrollv /= 1.05f;
    if(scroll > spacing) { scroll = spacing; scrollv = 0; }
    if(scroll < -spacing*l.img_bkg.size() + spacing*2) { scroll = -spacing*l.img_bkg.size() + spacing*2; scrollv = 0; }
    
    if(mousePressed && mouseButton == LEFT && is_in_bounds_inclusive(mouseX, mouseY, x, y + spacing, w, h - spacing*2.f)) {
      activeLayer = (int)(((mouseY - y) - scroll)/spacing); 
    }
    
    fill(fill_color);
    stroke(border_color);
    rect(x, y, w, h, radius);
    
    textAlign(LEFT, CENTER);
    int stop = min(l.img_bkg.size(), (int)((h - scroll)/spacing));
    
    if(activeLayer < stop && y + spacing*activeLayer + 10 + scroll > y + 10) {
      fill(border_color);
      rect(x, y + spacing*activeLayer + scroll, w, spacing);
    }
    
    for(int i = 0; i < stop; i++) {
      while(y + spacing*i + 10 + scroll < y + 10 && i < l.img_bkg.size()-1) i++;
      if(i == activeLayer) fill(fill_color); else fill(border_color);
      text("" + i, x + 10, y + spacing*i + scroll + spacing/2);
      image(l.img_bkg.get(i), x + 50, y + spacing*i + 10 + scroll, spacing - 20, spacing - 20);
      noFill();
      if(i == activeLayer) stroke(fill_color); else stroke(border_color);
      line(x, y + scroll + spacing*(i+1), x + w, y + scroll + spacing*(i+1));
      rect(x + 48, y + spacing*i + 8 + scroll, spacing - 17, spacing - 17);
    }
    stroke(border_color);
    fill(r(fill_color), g(fill_color), b(fill_color), 255);
    rect(x, y, w, spacing);
    rect(x, y + h - spacing, w, spacing);
  }
  public void set_theme(Theme t) {
    this.fill_color = t.fill_color;
    this.border_color = t.border_color;
    this.radius = t.radius;
  }
}

void buttonSwap() {
  if(b_brush.is_on && b_brush.changed) {
    b_physics.is_on = false;
    b_particles.is_on = false;
  }
  if(b_physics.is_on && b_physics.changed) {
    b_brush.is_on = false;
    b_particles.is_on = false;
  }
  if(b_particles.is_on && b_particles.changed) {
    b_physics.is_on = false;
    b_brush.is_on = false;
  }
  
  if(!physicsLines.is_on && physicsLines.changed) {
    b_physics.is_on = false;
  }
  if(!backgroundTiles.is_on && backgroundTiles.changed) {
    b_brush.is_on = false;
  }
}

//Prepar urself
//4
//da most stylishist
//most fanciest
//most
//attractivest
//funtor
//ever
//;);))))
//:D
void initGUI() {
  GUIVisualStyle.radius = 0;
  layers = new LayerViewer(width - 210, 10, 200, height - 90);
  layers.set_theme(GUIVisualStyle);
  newTile = new Button(layers.x + 10, layers.y + 10, 60, 60, "New\nTile");
  newTile.set_theme(GUIVisualStyle);
  b_save = new Button(10, 10, 60, 60, "Save");
  b_save.set_theme(GUIVisualStyle);
  deleteTile = new Button(layers.x + 80, layers.y + 10, 60, 60, "Delete\nTile");
  deleteTile.set_theme(GUIVisualStyle);
  gridLines = new Button(layers.x - 120, 10, 20, 20, "Gridlines");
  gridLines.set_theme(GUIVisualStyle);
  gridLines.too_da_right = true;
  gridLines.toggle = true;
  gridLines.is_on = true;
  backgroundTiles = new Button(layers.x - 120, 40, 20, 20, "Background");
  backgroundTiles.set_theme(GUIVisualStyle);
  backgroundTiles.too_da_right = true;
  backgroundTiles.toggle = true;
  backgroundTiles.is_on = true;
  physicsLines = new Button(layers.x - 120, 70, 20, 20, "Physics");
  physicsLines.set_theme(GUIVisualStyle);
  physicsLines.too_da_right = true;
  physicsLines.toggle = true;
  physicsLines.is_on = true;
  b_brush = new Button(width - 70, height - 70, 60, 60);
  b_brush.set_theme(GUIVisualStyle);
  b_brush.too_da_right = true;
  b_brush.toggle = true;
  b_brush.useImage("brush.png");
  b_physics = new Button(width - 70 - 70, height - 70, 60, 60);
  b_physics.set_theme(GUIVisualStyle);
  b_physics.too_da_right = true;
  b_physics.toggle = true;
  b_physics.useImage("physics.png");
  b_particles = new Button(width - 70 - 140, height - 70, 60, 60);
  b_particles.set_theme(GUIVisualStyle);
  b_particles.too_da_right = true;
  b_particles.toggle = true;
  b_particles.useImage("particles.png");
}