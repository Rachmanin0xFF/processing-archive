import processing.net.*; 
import java.net.*;

Client myClient;
Client myClient2;
int dataIn; 
Slider throt = new Slider(100, 100, 900, 100, 100, "Throttle");
Slider corr = new Slider(100, 250, 900, 100, 100, "Correction");
Button scan = new Button(1150, 100, 175, 100, false, "Scan For\nQuadcopter");
LoadingBar scanProgress = new LoadingBar("Scanning network for Quadcopter...","Initializing..");
ConfirmationDialog confirm; //I’m leaving the choice of putting in the test confirmation slider up to you
String lastCMD = "";
boolean connected = false;
int mode = 0;
boolean lightTheme = false;
boolean posterTheme = false;
float killcol = 0.f;
float throtErrorFade = 0.f;
PImage bkg;
float deltaCube = 0.f;
boolean useCursor = false;
boolean disableSliders = false;


boolean scanning = false;
boolean foundQuad = false;
String quadIP = "";
int scanIndex = 1;
int portNum = 0;

color statusC=color(128,245,94,255);

int quadPort = 42042;

void setup() {
  size(1425, 450, P3D);
  PFont font = createFont("AR DECODE", 24);
  textFont(font);
  textAlign(CENTER, CENTER);
  bkg = loadImage("bkg.png");
  bkg.filter(BLUR, 3);
  confirm = new ConfirmationDialog(300, 200, "Are you sure you\nwant to do a thing\nor something?");
  scanProgress.init();
  scanProgress.active = false;
  frameRate(12000);
  smooth(4);
  noCursor();
  println(PFont.list());
}

void draw() {
  if(useCursor)
    noCursor();
  else
    cursor(ARROW);
  
  if(lightTheme)
    background(0);
  else
    image(bkg, 0, 0);
  
  textSize(18);
  textAlign(LEFT,TOP);
  fill(statusC);
  text("FPS: "+str(int(frameRate)),10,10);
  textSize(24);
  textAlign(CENTER,CENTER);
  
  
  disableSliders = confirm.alpha > 1.f || scanProgress.active;
  throt.takeInput = !disableSliders;
  corr.takeInput = !disableSliders;


  //button and slider updates
  
  throt.update();
  corr.update();
  scan.update();
  
  
  // Scanning
  scanProgress.active = scanning;
  if(connected && !scanning) {
    fill(100, 100, 255, 170);
    textAlign(LEFT, LEFT);
    fill(128,245,94,170);
    text("Linked to " + quadIP + " on port " + quadPort, 100, 80);
    textAlign(CENTER, CENTER);
  }
  
  if(scanning) {
    killcol = 0.f;
    
    /// Send stuff to scanning bar
    scanProgress.percent = int(min(30.0f, scanIndex)*100.0f/30.0f);
    scanProgress.subtitle = "ip: 192.168.1."+min(30, scanIndex)+"      port: "+quadPort;
    
    
    if(foundQuad) {
      scanIndex++;
    } else {
      if(isServerUp("192.168.1." + scanIndex, portNum)) {
        println("Found Quadcopter at 192.168.1." + scanIndex + "!");
        quadIP = "192.168.1." + scanIndex;
        foundQuad = true;
        connect();
      }
    }
    scanIndex++;
    if(scanIndex >= 30) foundQuad = true;
    if(scanIndex >= 40) { /////////////////////////////////////////////////////////////////////WHAT IS THIS FOR?????????????????????
      scanIndex = 2;
      scanning = false;
      foundQuad = false;
      scanProgress.percent = 0;
    }
  } else { // This else is so the custom cursor disappears while scanning
    if(useCursor) {
      hint(DISABLE_DEPTH_TEST);
      fill(0, 0, 0);
      stroke(100, 100, 255, 255);
      ellipse(mouseX, mouseY, 15, 15);
      stroke(140, 140, 255, 255);
      strokeWeight(8);
      point(mouseX, mouseY);
      hint(ENABLE_DEPTH_TEST);
    }
    if(connected) {
      myClient.write(throt.value + "~" + corr.value + "%");
    }
  }
  
  fill(255, 120, 82, min(170.0f, throtErrorFade));
  textAlign(LEFT, TOP);
  text("Can't scan while throttled up!", 100, 360);
  textAlign(CENTER, CENTER);
  
  
  //Update bars and dialogs
  hint(DISABLE_DEPTH_TEST);
  scanProgress.update();
  confirm.update();
  hint(ENABLE_DEPTH_TEST);
  
  noStroke();
  fill(255, 120, 82, killcol);
  rect(0, 0, width, height);
  killcol /= 1.02f;
  throtErrorFade /= 1.02f; /////////////////////////////////////////////       WHAT IS throtErrorFade ???????????????????????? 
  if(scan.isOn)
    if((throt.value <= 0.f && corr.value <= 0.f) || !connected)
      scanForQuad(quadPort);
    else
      throtErrorFade = 1000.f;
      
      
      
  //Apply Themes
  if(lightTheme) filter(INVERT);
  if(posterTheme) filter(POSTERIZE, 16);
}







public void connect() {
  println("Connecting to quadcopter...");
  delay(500);
  myClient = new Client(this, quadIP, portNum);
  myClient2 = new Client(this, quadIP, portNum+1);
  println("Connected!");
  connected = true;
}


void scanForQuad(int port) {  ///////////////////////////////// WHAT IS THIS ABOUT???????????????????????????????
  filter(BLUR, 1);
  stroke(255, 0, 0);
  quadIP = "";
  scanning = true;
  connected = false;
  myClient = null;
  portNum = port;
}


public static boolean isServerUp(String ip, int port) { 
  print("Checking with ip " + ip + " on port " + port + "... ");
  try {
    Socket s = new Socket();
    s.connect(new InetSocketAddress(ip, port), 500);
    return true;
  } catch(IOException ex) {}
  println("nothing found.");
  return false;
}


void drawCube(float x, float y, float size, float rotation) {
  hint(DISABLE_DEPTH_TEST);
  pushMatrix();
  ortho();
  translate(x, y);
  stroke(100, 100, 255, 170);
  noFill();
  rotateX(noise(rotation)*TWO_PI);
  rotateY(noise(rotation+25125)*TWO_PI*8.f);
  rotateZ(noise(rotation+19011)*TWO_PI*8.f);
  box(size, size, size);
  popMatrix();
  hint(ENABLE_DEPTH_TEST);
}

void keyPressed() {
  if(key!=CODED){
    switch(key){
      case 'k':
        throt.value = 0.f;
        corr.value = 0.f;
        killcol = 100;
        break;
      case '!':
        posterTheme = !posterTheme;
        break;
      case '@':
        lightTheme= !lightTheme;
        break;
      case '#':
        useCursor = !useCursor;
        break;
      case 'c':
        confirm.active = true;
        break;

    }  
  }
}




//           _             _             _                  _           _            _           _        
//         /\ \           _\ \          / /\               / /\        / /\         /\ \        / /\      
//        /  \ \         /\__ \        / /  \             / /  \      / /  \       /  \ \      / /  \     
//       / /\ \ \       / /_ \_\      / / /\ \           / / /\ \__  / / /\ \__   / /\ \ \    / / /\ \__  
//      / / /\ \ \     / / /\/_/     / / /\ \ \         / / /\ \___\/ / /\ \___\ / / /\ \_\  / / /\ \___\ 
//     / / /  \ \_\   / / /         / / /  \ \ \        \ \ \ \/___/\ \ \ \/___// /_/_ \/_/  \ \ \ \/___/ 
//    / / /    \/_/  / / /         / / /___/ /\ \        \ \ \       \ \ \     / /____/\      \ \ \       
//   / / /          / / / ____    / / /_____/ /\ \   _    \ \ \  _    \ \ \   / /\____\/  _    \ \ \      
//  / / /________  / /_/_/ ___/\ / /_________/\ \ \ /_/\__/ / / /_/\__/ / /  / / /______ /_/\__/ / /      
// / / /_________\/_______/\__\// / /_       __\ \_\\ \/___/ /  \ \/___/ /  / / /_______\\ \/___/ /       
// \/____________/\_______\/    \_\___\     /____/_/ \_____\/    \_____\/   \/__________/ \_____\/        
                                                                                                        
public class Slider {
  float value;
  float x;
  float y;
  float len; //length
  float hit; //height
  float slen; //slider length
  String name = "";
  boolean takeInput;

  
  
  public Slider(float x, float y, float len, float hit, float slen, String name) {
    this.x = x;
    this.y = y;
    this.len = len;
    this.hit = hit;
    this.slen = slen;
    this.name = name;
    takeInput = true;

  }
  
  public void update() {
    textAlign(CENTER);
    fill(0, 0, 0, 100);
    stroke(100, 100, 255, 170);
    strokeWeight(2);
    rect(x, y, len+slen, hit, 7);
    
    fill(50, 50, 100, 150);
    rect(x + value*len, y, slen, hit, 7);
    fill(#FF7852);
    String pval = str(round(value*1000)/1000.0);
    text(pval, x + value*len + slen/2, y + hit/4);
    
    fill(100, 100, 255, 255);
    text(name, x+len/2+slen/2, y+hit/2);
    if(takeInput&&mousePressed && mouseX < x+len+slen && mouseX > x && mouseY < y+hit && mouseY > y) {
        value = (((mouseX+15)*len/(len+slen))-x-slen/2)/len/(len/(len+slen));
    }
    value = min(1.0, max(0.0, value));
    
    textAlign(LEFT);
  }
}









class Button {
  boolean toggle = true;
  boolean wasMousePressed = false;
  boolean isOn = false;
  String text = "";
  float x0;
  float y0;
  float x1;
  float y1;
  float alpha = 1.f;


  public Button(float xC, float yC, float xS, float yS, boolean t) {
    x0 = xC;
    y0 = yC;
    x1 = xC + xS;
    y1 = yC + yS;
    toggle = t;
  }
  public Button(float xC, float yC, float xS, float yS, boolean t, String txt) {
    x0 = xC;
    y0 = yC;
    x1 = xC + xS;
    y1 = yC + yS;
    toggle = t;
    text = txt;
  }
  public void setAlpha(float f) {
  alpha = f;
  }
  
  public void update() {
  stroke(100, 100, 255, 170*alpha);
  if(toggle && mouseX>x0 && mouseY>y0 && mouseX<x1 && mouseY<y1 && mousePressed && !wasMousePressed) {
    isOn = !isOn;
  }
  if(toggle && !(mouseX>x0 && mouseY>y0 && mouseX<x1 && mouseY<y1) && mousePressed)
    isOn = false;
  if(!toggle)
    isOn = false;
  if(!toggle && mouseX>x0 && mouseY>y0 && mouseX<x1 && mouseY<y1 && !wasMousePressed)
    if(mousePressed && !wasMousePressed)
      isOn = true;
    else
      isOn = false;
   
  wasMousePressed = mousePressed;
  if(isOn)
    fill(100, 100, 255, alpha*255.f);
  else
    fill(0, 0, 0, alpha*100.f);
  rect(x0, y0, x1-x0, y1-y0, 7);
  if(isOn)
    fill(0, 0, 0, alpha*255.f);
  else
    fill(100, 100, 255, alpha*255.f);
  textAlign(CENTER, CENTER);
  text(text, (x0 + x1)/2.0f, (y0 + y1)/2.0f);
  fill(255);
  noFill();
  }

}

// LoadingBar
// Use:
// create the object before setup
// init() must becalled in setup, after size()
// update() must be called at the end of draw(), after everything you want it to blur out
// to set the percent, set LoadingBar.percent     For example, if your LoadingBar is called bob:
// bob.percent = 42;
// also to turn the bar on and off:
// bob.active = true;

public class LoadingBar {
  public int percent = 0;
  String title;
  String subtitle = "";
  public boolean active = false;
  int sx;
  int sy;
  int x;
  int y;
  
  public LoadingBar(String title){
    this.title = title;
  }
  
  public LoadingBar(String title, String subtitle){
    this.title = title;
    this.subtitle = subtitle;
  }
  
  public void init(){
    this.sx = 500;
    this.sy = 26;
    this.x = (width/2)-sx/2;
    this.y = (height/2)-sy/2;
  }
  
  public void update(){
    if(active == true){
      filter(BLUR,3);
      textAlign(CENTER);
      
      fill(0, 0, 0, 100);
      noStroke();
      rect(x, y, sx, sy, 7);
      
      fill(50, 50, 100, 200);
      rect(x, y, percent*5, sy, 7);
      
      noFill();
      stroke(100, 100, 255, 170);
      strokeWeight(2);
      rect(x, y, sx, sy, 7);
      
      textSize(20);
      textAlign(CENTER,CENTER);
      fill(#FF7852);
      text(str(percent)+"%",width/2,height/2-3);
      
      textSize(24);
      fill(100, 100, 255, 255);
      text(title,width/2,y-20);
      
      textSize(18);
      fill(128,245,94,255);
      text(subtitle,width/2, y+sy+10);
    }
  }
}


 public class ConfirmationDialog {
  int w;
  int h;
  String text;
  boolean active;
  boolean confirmed;
  Button b;
  int activeTime = 0;
  float alpha = 0.f;
  public ConfirmationDialog(int w, int h, String text) {
    this.w = w;
    this.h = h;
    this.text = new String(text);
    b = new Button(width/2-40, height/2-60+h/2, 80, 40, false, "OK");
  }
  public void update() {
    confirmed = false;
    if(active) {
      alpha = 200.f;
      activeTime++;
      if(activeTime > 10 && mousePressed && !(mouseX > width/2-w/2 && mouseX < width/2+w/2 && mouseY > height/2-h/2 && mouseY < height/2+h/2)) {
        active = false;
        activeTime = 0;
      }
      if(b.isOn||keyCode==ENTER) {
        active = false;
        confirmed = true;
        activeTime = 0;
      }
    }
    if(alpha > 10.f) {
      //println(alpha);
      fill(0, 0, 0, alpha);
      stroke(100, 100, 255, alpha*1.7f);
      rect(width/2-w/2, height/2-h/2, w, h, 7);
      textAlign(CENTER, TOP);
      fill(255, 120, 82, alpha*1.7f);
      text(text, width/2, height/2-h/2+20);
      b.setAlpha(alpha/100.f);
      b.update();
    }
    alpha /= 1.06f;
  }
}




