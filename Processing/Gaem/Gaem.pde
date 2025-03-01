
SettingsHandler gameSettings = new SettingsHandler();
Player you;
Level testLevel;

void setup() {
  size(1280, 720, P2D);
  surface.setResizable(true);
  noSmooth();
  frameRate(60);
  
  gameSettings.loadSettings();
  initInput();
  you = new Player();
  testLevel = new Level(dataPath("") + "/level0");
}

void draw() {
  println(frameRate);
  background(0);
  updateInput();
  you.update();
  
  translate(-you.x + width/2, -you.y + height/2);
  
  for(int i = 0; i < 10; i++)
  testLevel.dispBkgAt(you);
  strokeWeight(2);
  stroke(255, 0, 0, 255);
  point(you.x, you.y);
  noFill();
  ellipse(you.x, you.y, 20, 20);
}

class Player {
  float x = 0;
  float y = 0;
  float xv = 0;
  float yv = 0;
  float direction;
  void update() {
    if(IE.u) yv--;
    if(IE.d) yv++;
    if(IE.l) xv--;
    if(IE.r) xv++;
    x += xv;
    y += yv;
    xv *= 0.95;
    yv *= 0.95;
  }
}

import java.util.Iterator;

class SettingsHandler {
  String fileName = "settings.txt";
  HashMap<String, Float> values;
  float getSetting(String s) {
    return values.get(s);
  }
  void loadSettings() {
    values = new HashMap<String, Float>();
    String[] s = loadStrings(fileName);
    println("Loading settings...");
    for(int i = 0; i < s.length; i++) {
      if(!(s[i].contains("#") || s[i].contains("//"))) {
        String[] conts = s[i].split(" ");
        String name = conts[0];
        float value = Float.parseFloat(conts[1]);
        values.put(name, value);
        println(name, value);
      }
    }
    println("Settings loaded.");
  }
  void saveSettings() {
    println("Saving settings...");
    String[] toSave = new String[values.size()];
    Iterator it = values.entrySet().iterator();
    int i = 0;
    while(it.hasNext()) {
      HashMap.Entry pair = (HashMap.Entry)it.next();
      toSave[i] = pair.getKey() + " " + pair.getValue();
      println(toSave[i]);
      it.remove();
      i++;
    }
    saveStrings("data/" + fileName, toSave);
    println("Settings saved.");
  }
}