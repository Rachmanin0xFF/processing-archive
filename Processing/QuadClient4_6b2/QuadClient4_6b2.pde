import processing.net.*; 
import java.net.*;


Client myClient; 
Client myClientR;
int dataIn; 
Slider throt = new Slider(100, 100, 900, 100, 100, "Throttle");
Slider corr = new Slider(100, 250, 900, 100, 100, "Correction");
Slider varA = new Slider(100, 400, 500, 50, 50, "Kp");
Slider varB = new Slider(100, 480, 500, 50, 50, "Ki");
Slider varC = new Slider(100, 560, 500, 50, 50, "Kd");
Slider varD = new Slider(100, 640, 500, 50, 50, "Desired Angle");
AngleReadout quadRotation = new AngleReadout(700, 400, 400, 300);
AngleVisuals navSphere = new AngleVisuals(1150, 250, 200);
Button scan = new Button(1150, 100, 180, 100, false, "Scan For\nQuadcopter");
Button dirCon = new Button(1080, 40, 250, 40, false, "Direct Connect");
LoadingBar scanProgress = new LoadingBar("Scanning network for Quadcopter...", "Initializing..");
ConfirmationDialog confirm; //I’m leaving the choice of putting in the test confirmation slider up to you
textDialog ipIn;
Menu menu = new Menu(100, 40, 150, 400);
String lastCMD = "";
boolean connected = false;
boolean recvReady = false;
int mode = 0;
boolean lightTheme = false;
boolean posterTheme = false;
boolean curse = true;
float killcol = 0.f;
float throtErrorFade = 0.f;
float credAlpha = 0.f;
String fadeError = "";
PImage bkg;
float deltaCube = 0.f;
boolean useCursor = false;
boolean disableSliders = false;
boolean verbose = false;
boolean averager = false;
double basetime = 0f;
double baseTick = -0f;
double tickRate = 0f;

boolean rxing = false;
boolean scanning = false;
boolean foundQuad = false;
boolean wasConnected = false;
String quadIP = "";
int scanIndex = 5;
int portNum = 0;

long frames = 0;
PVector quadcopter_latest_angle = new PVector(0.f, 0.f, 0.f);

PFont font;
PFont script;
PFont roboto;
color statusC=color(128, 245, 94);
color boxC=color(100, 100, 255);
color infoC=color(255, 120, 82);
color warnC=#FF3232;

int quadPort = 42042;

//String[] rxVals = new String[5];
String[] rxVals= {
  "0.0", "0.0", "0.0", "0.0", "0.0"
};
String[] emptyParts = {
  "0", "0", "0", "0", "0"
};
int rxReset = 3;

copterIcon copter;
////////////////
////////////////
////////////////
int rxPacketParts= 5;
////////////////
////////////////
////////////////

void setup() {
  size(1425, 830, P3D);
  font = createFont("Ubuntu-R.ttf", 24, true);
  script = createFont("segoesc.ttf", 36, true);
  roboto = createFont("Cellblock NBP", 24, true);
  textFont(font);
  //textFont(script);
  textAlign(CENTER, CENTER);
  bkg = loadImage("bkg.png");
  bkg.filter(BLUR, 3);
  confirm = new ConfirmationDialog(300, 200, "Are you sure you\nwant to do a thing\nor something?");
  ipIn = new textDialog(300, 190, "Enter target ip:");
  copter = new copterIcon(width-150, height-150, 75);
  scanProgress.init();
  scanProgress.active = false;
  frameRate(200);
  noSmooth();
  noCursor();
  rxVals=expand(rxVals, rxPacketParts);
  varD.value = 0.5f;
}

void draw() {
  //println("\n\n",mouseX, mouseY,"\n");
  if (useCursor)
    noCursor();
  else
    cursor(ARROW);
    
  if(!connected && wasConnected) {
    println("saving...");
    quadRotation.saveData();
  }
  wasConnected = connected;

  //println("BREAKPOINT_1");
  image(bkg, 0, 0);
  fill(0, 100);
  rect(0, 0, width, height);

  //println("BREAKPOINT_2");
  textAlign(LEFT, BOTTOM);
  textFont(roboto);
  fill(100, 100, 255, 130);
  text("You say 'bug', we say 'Feature'.", 20, height-20);
  textFont(font);

  //println("BREAKPOINT_3");
  if (averager=true&&baseTick!=float(rxVals[0])) {
    tickRate=(float(rxVals[0])-baseTick)/(millis()-basetime);
  }

  //println("BREAKPOINT_4");
  if (float(rxVals[0])>0.0&&baseTick==-2) {
    averager=true;
    basetime=millis();

    baseTick=float(rxVals[0]);
  }

  //println("BREAKPOINT_5");
  textSize(18);
  //if(menu.mFont.isOn)textFont(roboto);
  textAlign(LEFT, TOP);
  fill(statusC);
  if (menu.mVLite.isOn) {
    text("FPS: "+str(int(frameRate)), 0, 0);
    text("Q TickRate: "+round((float)tickRate*1000), 100, 0);
    text("Q Ticks: "+rxVals[0], 250, 0);
    text("Roll: "+rxVals[1], 450, 0);
    text("Pitch: "+rxVals[2], 700, 0);
    text("Yaw: "+rxVals[3], 950, 0);
  }
  textSize(24);
  textAlign(CENTER, CENTER);
  textFont(font);

  //println("BREAKPOINT_6");
  disableSliders = confirm.alpha > 1.f || scanProgress.active || ipIn.alpha>1.f||menu.active;
  throt.takeInput = !disableSliders;
  corr.takeInput = !disableSliders;
  varA.takeInput = !disableSliders;
  varB.takeInput = !disableSliders;
  varC.takeInput = !disableSliders;
  varD.takeInput = !disableSliders;


  //button and slider updates
  //println("BREAKPOINT_7");
  dirCon.update();
  throt.update();
  corr.update();
  varA.update();
  varB.update();
  varC.update();
  varD.update();
  scan.update();
  if(connected)
    scan.isOn = false;
  // Scanning
  scanProgress.active = scanning;

  //println("BREAKPOINT_8");
  quadRotation.display();
  navSphere.display(quadcopter_latest_angle.x, quadcopter_latest_angle.y);
  //navSphere.display(mouseX-width/2, mouseY-height/2);

  //println("BREAKPOINT_9");
  if (connected && !scanning) {
    fill(100, 100, 255, 170);
    textAlign(LEFT, LEFT);
    String t;
    if (rxing) t = "  Running"; 
    else t = "  Starting...";
    text("Linked to " + quadIP + " on port " + quadPort+"..."+t, 180, 80);
  }
  textAlign(CENTER, CENTER);

  if (scanning) {

    /// Send stuff to scanning bar
    scanProgress.percent = int(min(30.0f, scanIndex)*100.0f/30.0f);
    scanProgress.subtitle = "ip: 192.168.1."+scanIndex+"      port: "+quadPort;
    // //print("6");

    if (foundQuad) {
      scanIndex++;
    } else {
      if (isServerUp("192.168.1." + scanIndex, portNum)) {
        //println("Found Quadcopter at 192.168.1." + scanIndex + "!");
        quadIP = "192.168.1." + scanIndex;
        foundQuad = true;
        connect();
      }
    }
    scanIndex++;
    if (scanIndex >= 30) foundQuad = true;
    if (scanIndex >= 40) {
      scanIndex = 2;
      scanning = false;
      foundQuad = false;
      scanProgress.percent = 0;
      // //print("7");
    }
  } else { // This else is so the custom cursor disappears while scanning
    //println("BREAKPOINT_10");
    if (useCursor) {
      curse = true;
    } else {
      curse=false;
    }
    //PORT TX //PORT TX //PORT TX //PORT TX //PORT TX //PORT TX //PORT TX //PORT TX //PORT TX //PORT TX //PORT TX //PORT TX //PORT TX //PORT TX //PORT TX //PORT TX //PORT TX //
    //PORT TX //PORT TX //PORT TX //PORT TX //PORT TX //PORT TX //PORT TX //PORT TX //PORT TX //PORT TX //PORT TX //PORT TX //PORT TX //PORT TX //PORT TX //PORT TX //PORT TX //
    //println("BREAKPOINT_11");
    if (connected) {
      //   //print("8");
      if (recieve())rxing=true;
      //    //print("9");
      String packet = throt.value + "~" + corr.value*varA.value + "~" + corr.value*varB.value + "~" + corr.value*varC.value + "~" + (varD.value*2.0-1.0)*45.0f + "%";
      //println("\tR correction: ", varA.value*5f);
      myClient.write(packet);
      if (frameCount%30==0) println(packet, "  ");
      //reciever
      //print(rxVals[5]);
    }
  }
  //println("BREAKPOINT_12");
  if (dirCon.isOn==true && !connected) {
    //println("ison");
    ipIn.active = true;
  }
  //println("BREAKPOINT_13");
  if (ipIn.done) {
    if (isIPV4(ipIn.input)) {
      quadIP = ipIn.input;
      //println(quadIP.equals("192.168.7.2"));
      if (isServerUp(quadIP, quadPort)) {
        connect();
        //delay(1000);
      }
    }
    ipIn.done=false;
  }
  //println("BREAKPOINT_14");
  fill(255, 120, 82, min(170.0f, throtErrorFade));
  textAlign(LEFT, TOP);
  text(fadeError, 100, 360);
  textAlign(CENTER, CENTER);

  // Draw copter

  //  //print("1");
  copter.update();
  //  //print("2");    

  //Update bars and dialogs
  hint(DISABLE_DEPTH_TEST);

  //println("BREAKPOINT_15");
  //MENU STUUF
  menu.update();
  posterTheme = menu.mPost.isOn;
  useCursor = menu.mPointer.isOn;
  if (menu.mDisCon.isOn) {
    disCon();
  }
  //END MENU STUUF
  // //print("a");
  ipIn.update();
  //  //print("B");

  //println("BREAKPOINT_16");
  scanProgress.update();
  confirm.update();
  hint(ENABLE_DEPTH_TEST);

  //println("BREAKPOINT_17");
  if (millis()<8000) {
    credAlpha+=.3;
    credAlpha = min(150f, credAlpha);
  }
  if (millis()<18000&&millis()>12000) {
    credAlpha-=.6;
    credAlpha = max(0f, credAlpha);
  }
  textAlign(LEFT, BASELINE);
  textFont(roboto);
  textSize(20);
  fill(100, 100, 255, credAlpha);
  text("qClient Version 4.6b developed for the Quadcopter Project by Benjamin and Adam.", 120, 230);
  textFont(font);
  noStroke();
  //println(credAlpha,millis());
  fill(255, 120, 82, killcol);
  rect(0, 0, width, height);
  killcol /= 1.02f;
  throtErrorFade /= 1.02f; 

  //println("BREAKPOINT_18");
  if (scan.isOn)
    if ((throt.value <= 0.f && corr.value <= 0.f)) {
      quadIP="192.168.1.41"; //STATIC IP CHECK
      if (isServerUp(quadIP, quadPort)) {
        connect();
      } else {
        scanForQuad(quadPort);
      }
    } else {
      throtErrorFade = 1000.f;
      fadeError="Can't scan while throttled up!";
    }
  //  //print("3");    

  //println("BREAKPOINT_19");
  if (curse) {
    drawCursor();
  }
  //Apply Themes
  if (lightTheme) filter(INVERT);
  if (posterTheme) filter(POSTERIZE, 16);
  frames++;
}







public void connect() {
  //println("Connecting to quadcopter...");
  delay(500);
  myClient = new Client(this, quadIP, quadPort);//(this, quadIP, portNum);
  //println("Connected!");
  connected = true;
  recvReady = true;
  rxReset = 360;
  myClientR = new Client(this, quadIP, 42043);
  //println(myClientR.ip());
}


void scanForQuad(int port) { 
  filter(BLUR, 1);
  stroke(255, 0, 0);
  quadIP = "";
  scanning = true;
  connected = false;
  myClient = null;
  portNum = port;
}

boolean recieve() {
  boolean worked = false;
  if (myClientR.available() > 0) { 
    String dataIn = myClientR.readString();
    if (dataIn.length()>0) {
      String[] packets = dataIn.split("%");
      if (packets.length>0) {
        //if (packets[0].length() > 0)
        if (packets[0].substring(0, 1).equals("$")) {
          println('A');
          packets[0] = packets[0].substring(1);
          println('B');
          String[] chunks = packets[0].split("~");
          if (chunks.length==rxPacketParts) {
            rxVals=chunks;
            worked = true;
            //print("\nrecieved data: ");
            //print(rxVals);
            quadRotation.addAngle(new PVector(Float.parseFloat(rxVals[1]), Float.parseFloat(rxVals[2]), Float.parseFloat(rxVals[3])));
            quadcopter_latest_angle = new PVector(Float.parseFloat(rxVals[1]), Float.parseFloat(rxVals[2]), Float.parseFloat(rxVals[3]));
            //print("  ###   ");
          }
        }
      }
    }
  }
  return worked;
}

public boolean isServerUp(String ip, int port) { 
  //print("Checking with ip " + ip + " on port " + port + "... ");
  try {
    Socket s = new Socket();
    s.connect(new InetSocketAddress(ip, port), 100); //Server check delay
    return true;
  } 
  catch(IOException ex) {
  }
  //println("nothing found.");
  return false;
}

void disCon() {
  throt.value = 0.f;
  corr.value = 0.f;
  killcol = 100;
  
//  draw();
//  draw();
//  draw();
//  draw();
//  draw();
//  draw();
  print("killing...  ");
  String packet = throt.value + "~" + corr.value + "%";
  myClient.write(packet);
  delay(50);
  for (int a=0; a<20000; a++) {
    packet = throt.value + "~" + corr.value + "%";
    myClient.write(packet);
    //delay(50);
  }
  //print("  Sent Pakets... ");
  delay(1000);
  //println("Closing links....");
  myClient.stop();
  myClientR.stop();
  connected=false;
  rxing = false;
}

public boolean isIPV4(String adr) {
  String[] d = adr.split("\\.");
  if (d.length != 4) return false;
  for (String s : d)
    for (char c : s.toCharArray ())
      if (c!='0'&&c!='1'&&c!='2'&&c!='3'&&c!='4'&&c!='5'&&c!='6'&&c!='7'&&c!='8'&&c!='9') {
        throtErrorFade = 1000.f;
        fadeError="Not a valid IP!";
        return false;
      }
  return true;
}


float places3(float in) {
  return float(int(in*1000))/1000;
}
float places3(double in) {
  return float(int((float)in*1000f))/1000;
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

void drawMotor(float x, float y, int r, float power, String label) {
  stroke(statusC);
  noFill();
  ellipse(x, y, r*2, r*2);
  noStroke();
  if (power<0f||power>1f) {
    fill(255, 50, 50, 150);
    power=1;
  } else {
    fill(boxC, 120);
  }
  if (!menu.mAltIcon.isOn) {
    float powerR=map(power, 0f, 1f, -PI-HALF_PI, PI-HALF_PI);
    arc(x, y, r*2, r*2, -PI-HALF_PI, powerR, PIE);
  } else {
    float powerR=map(power, 0f, 1f, 0, r);
    ellipse(x, y, powerR*1.5+r/2, powerR*1.5+r/2);
    fill(0);
    noStroke();
    ellipse(x, y, r/2, r/2);
  }
  fill(infoC, 255);
  textSize(19);
  text(str(float(int(power*1000))/1000), x, y);
  text(label, x-r, y-r);
}

void drawCursor() {
  //hint(DISABLE_DEPTH_TEST);
  pushMatrix();
  translate(0, 0, 1);
  noFill();
  stroke(boxC, 255);
  ellipse(mouseX, mouseY, 15, 15);
  stroke(infoC, 255);
  strokeWeight(8);
  point(mouseX, mouseY);
  strokeWeight(2);
  popMatrix();
}

void drawWork(int x, int y) {
  pushMatrix();
  translate(x, y);
  rotateZ(((millis()%3000f)/3000f)*TWO_PI);
  noFill();
  stroke(100, 100, 255, 255.f);
  ellipse(0, 0, 30, 30);
  triangle(0, -15, 13, 7.5, -13, 7.5);
  popMatrix();
}
//hint(ENABLE_DEPTH_TEST);


void keyPressed() {
  if (key!=CODED) {
    switch(key) {
    case '*':
      myClient.stop();
      myClientR.stop();
      //println("Closing links....");
      connected=false;
    case '!':

      break;
    case '@':
      lightTheme= !lightTheme;
      break;
    case '#':
      useCursor = !useCursor;
      break;
    case '%':
      ipIn.active = true;
      break;
    case '^':
      String bob = "HELLO";
      //println(bob.split("q"));
      myClientR = new Client(this, quadIP, portNum+1);
      break;
    case BACKSPACE: //BACKSPACE
      //println("backspace: ", millis());
      ipIn.backspace();
      break;
    case ENTER:
      break;
    default:
      ipIn.chr(key);
    }
  } else {
    switch(keyCode) {

    case 114: //F3
      menu.mVLite.isOn=!menu.mVLite.isOn;
      break;
    case 115: // F4
      copter.show = !copter.show;
      break;
    case 121:
      if (connected) {
        disCon();
      }
      break;
    case 123:
      throt.value = 0.f;
      corr.value = 0.f;
      killcol = 100;
      break;
    }
  }
}

void mouseWheel(MouseEvent event) {
  throt.scroll(event.getCount());
  corr.scroll(event.getCount());
  varA.scroll(event.getCount());
  varB.scroll(event.getCount());
  varC.scroll(event.getCount());
  varD.scroll(event.getCount());
  //println("scroll: ",event.getCount());
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


public class copterIcon {
  PVector a;
  PVector b;
  PVector c;
  PVector d;
  float r;
  int mr;
  float x;
  float y;
  boolean show = true;

  public copterIcon(float x, float y, float r) {
    this.x = x;
    this.y = y;
    this.r = r;
    this.mr=int(r/2);
    this.a = new PVector(x, y-r, 0f);
    this.b = new PVector(x+r, y, 0f);
    this.c = new PVector(x, y+r, 0f);
    this.d = new PVector(x-r, y, 0f);
  }

  public void update() {


    stroke(statusC);
    if (show) {
      line(x-r+mr, y, x+r-mr, y);
      line(x, y-r+mr, x, y+r-mr);
      drawMotor(a.x, a.y, mr, a.z, "A");
      drawMotor(b.x, b.y, mr, b.z, "B");
      drawMotor(c.x, c.y, mr, c.z, "C");
      drawMotor(d.x, d.y, mr, d.z, "D");
      noFill();
      stroke(infoC);
      strokeWeight(4);
      float xDiff = 0, yDiff =0;
      if (clamp(a.z)==0&&0==clamp(c.z)) {
        yDiff=0;
      } else {
        yDiff=r*(c.z-a.z);
      }
      //println(xDiff,yDiff);
      ellipse(x-xDiff, y+yDiff, 20, 20);
      strokeWeight(2);
    }
  }
  float clamp(float a) {
    return min(max(a, 0f), 1f);
  }
  public void setSpeeds(String a, String b, String c, String d) {
    this.a.z = float(a);
    this.b.z = float(b);
    this.c.z = float(c);
    this.d.z = float(d);
  }
}





public class Slider {
  float value;
  float x;
  float y;
  float len; //length
  float hit; //height
  float slen; //slider length
  String name = "";
  boolean takeInput;
  boolean wasPressed = false;
  int corMouse=0;



  public Slider(float x, float y, float len, float hit, float slen, String name) {
    this.x = x;
    this.y = y;
    this.len = len;
    this.hit = hit;
    this.slen = slen;
    this.name = name;
    takeInput = true;
  }

  public void scroll(int direction) {
    if (direction==-1&& mouseX < x+len+slen && mouseX > x && mouseY < y+hit && mouseY > y)value=min(value+0.003f, 1.0f);
    if (direction==1&& mouseX < x+len+slen && mouseX > x && mouseY < y+hit && mouseY > y)value=max(value-0.003f, 0.0f);
  }
  public void update() {
    textAlign(CENTER);
    textFont(font);
    fill(0, 0, 0, 150);
    stroke(100, 100, 255, 170);
    strokeWeight(2);
    rect(x, y, len+slen, hit, 7);

    fill(50, 50, 100, 150);
    rect(x + value*(len), y, slen, hit, 7);
    fill(#FF7852);
    //println(value);
    String pval = str(round(value*1000)/1000.0);
    if (hit < 60) textSize(16);
    text(pval, x + value*len + slen/2, y + hit/4);

    fill(100, 100, 255, 255);
    text(name, x+len/2+slen/2, y+hit/2);

    if (mousePressed && mouseX > x && mouseY > y && mouseX < x + len + slen && mouseY < y + hit)
      value = (float(mouseX) - x - slen/2)/(len);

    value = min(1.0, max(0.0, value));

    textAlign(LEFT);
    wasPressed = mousePressed;
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
  boolean active = true;
  color outC = color(100, 100, 255);


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
  public Button(float xC, float yC, float xS, float yS, boolean t, String txt, color o) {
    x0 = xC;
    y0 = yC;
    x1 = xC + xS;
    y1 = yC + yS;
    toggle = t;
    text = txt;
    outC = o;
  }
  public void setAlpha(float f) {
    alpha = f;
  }

  public void update() {
    stroke(outC, 170*alpha);
    if (toggle && mouseX>x0 && mouseY>y0 && mouseX<x1 && mouseY<y1 && mousePressed && !wasMousePressed&&active) {
      isOn = !isOn;
    }
    if (!toggle && !(mouseX>x0 && mouseY>y0 && mouseX<x1 && mouseY<y1) && mousePressed&&active)
      isOn = false;
    if (!toggle)
      isOn = false;
    if (!toggle && mouseX>x0 && mouseY>y0 && mouseX<x1 && mouseY<y1 && !wasMousePressed&&active)
      if (mousePressed && !wasMousePressed)
        isOn = true;
      else
        isOn = false;

    wasMousePressed = mousePressed;

    if (isOn)
      fill(100, 100, 255, alpha*255.f);
    else
      fill(0, 0, 0, alpha*100.f);
    rect(x0, y0, x1-x0, y1-y0, 7);
    if (isOn)
      fill(0, 0, 0, alpha*255.f);
    else
      fill(100, 100, 255, alpha*255.f);
    textAlign(CENTER, CENTER);
    text(text, (x0 + x1)/2.0f, (y0 + y1)/2.0f);
    fill(255);
    noFill();
  }
}

class AngleVisuals {
  PVector angle = new PVector(0.f, 0.f, 0.f);
  float x = 0.f;
  float y = 0.f;
  float s = 0.f;
  float navR = 15.f;
  public AngleVisuals(float x, float y, float size) {
    this.x = x;
    this.y = y;
    this.s = size;
  }
  public void display(float degrees_x, float degrees_y) {
    noFill();
    ellipse(x + s/2, y + s/2, s, s);
    stroke(statusC);
    ellipse(x + s/2, y + s/2, s-navR*2.f, s-navR*2.f);
    stroke(255, 120, 82, 170);
    ellipse(x + cos(degrees_y/57.2957795f)*sin(degrees_x/57.2957795f)*(s/2.f-navR) + s/2.f, y + sin(-degrees_y/57.2957795)*(s/2.f-navR) + s/2.f, navR, navR);
    pushMatrix();
    translate(x + s/2.f, y + s/2.f);
    rotateY(degrees_x/57.2957795f);
    rotateX(degrees_y/57.2957795f);
    rotateX(PI/2);
    ortho();
    sphereDetail(16);
    stroke(100, 100, 255, 50);
    sphere(s/2.f-navR);
    popMatrix();
    fill(0, 150);
    stroke(100, 100, 255, 170);
    rect(x, y, s, s, 7);
  }
}

class AngleReadout {
  ArrayList<PVector> angles = new ArrayList<PVector>();
  ArrayList<PVector> backupAngleData = new ArrayList<PVector>();
  float aree_x = 0.f;
  float aree_y = 0.f;
  float aree_w = 0.f;
  float aree_h = 0.f;
  public AngleReadout(float x, float y, float w, float h) {
    aree_x = x;
    aree_y = y;
    aree_w = w;
    aree_h = h;
  }
  public void display() {
    fill(0, 150);
    stroke(100, 100, 255, 170);
    rect(aree_x, aree_y, aree_w, aree_h, 7);
    float min = -90.f;
    float max = 90.f;

    stroke(255, 0, 0, 150);
    for (float i = 1.0f; i < angles.size (); i += 1.0f) {
      float thisVal = angles.get((int)i).x;
      float prevVal = angles.get((int)(i-1)).x;
      thisVal = map(thisVal, min, max, aree_y+aree_h, aree_y);
      prevVal = map(prevVal, min, max, aree_y+aree_h, aree_y);
      line((i-1.0f)*aree_w/float(angles.size()-1) + aree_x, prevVal, i*aree_w/float(angles.size()-1) + aree_x, thisVal);
    }

    stroke(0, 255, 0, 150);
    for (float i = 1.0f; i < angles.size (); i += 1.0f) {
      float thisVal = angles.get((int)i).y;
      float prevVal = angles.get((int)(i-1)).y;
      thisVal = map(thisVal, min, max, aree_y+aree_h, aree_y);
      prevVal = map(prevVal, min, max, aree_y+aree_h, aree_y);
      line((i-1.0f)*aree_w/float(angles.size()-1) + aree_x, prevVal, i*aree_w/float(angles.size()-1) + aree_x, thisVal);
    }

    stroke(0, 0, 255, 150);
    for (float i = 1.0f; i < angles.size (); i += 1.0f) {
      float thisVal = angles.get((int)i).z;
      float prevVal = angles.get((int)(i-1)).z;
      thisVal = map(thisVal, min, max, aree_y+aree_h, aree_y);
      prevVal = map(prevVal, min, max, aree_y+aree_h, aree_y);
      line((i-1.0f)*aree_w/float(angles.size()-1) + aree_x, prevVal, i*aree_w/float(angles.size()-1) + aree_x, thisVal);
    }

    stroke(100, 100, 255, 170);
    line(aree_x, aree_y + aree_h/2.f, aree_x + aree_w, aree_y + aree_h/2.f);
    line(aree_x, aree_y + aree_h/4.f, aree_x + aree_w, aree_y + aree_h/4.f);
    line(aree_x, aree_y + aree_h/4.f*3.f, aree_x + aree_w, aree_y + aree_h/4.f*3.f);
    textFont(font);
    textSize(16);
    textAlign(LEFT, TOP);
    fill(100, 100, 255, 170);
    text(" 90\u00b0", aree_x, aree_y);
    text(" 45\u00b0", aree_x, aree_y + aree_h/4.f);
    textAlign(LEFT, BOTTOM);
    text(" -45\u00b0", aree_x, aree_y + aree_h/4.f*3.f);
    text(" -90\u00b0", aree_x, aree_y + aree_h);
    text(" 0\u00b0", aree_x, aree_y + aree_h/2.f);
    //addAngle(new PVector(random(-10, 10), sin((float)frames/11.f)*20.f, sin((float)frames/20.f)*40.f));
  }
  public void addAngle(PVector p) {
    angles.add(copyVec(p));
    backupAngleData.add(copyVec(p));
    if (angles.size() > 300)
      angles.remove(0);
  }
  public void saveData() {
    String[] oData = new String[backupAngleData.size()+1];
    for(int i = 0; i < oData.length-1; i++)
      oData[i+1] = backupAngleData.get(i).x + ", " + backupAngleData.get(i).y + ", " + backupAngleData.get(i).z;
    oData[0] = "x_roll, y_pitch, z_yaw";
    saveStrings("data_out/Quadcopter_Angle_Data" + "_" + quadIP + "_" + getTime() + ".csv", oData);
    backupAngleData = new ArrayList<PVector>();
  }
}

public String getTime() {
  return year() + "-" + month() + "-" + day() + "-" + hour() + "-" + minute() + "-" + second() + "-" + millis();
}

public PVector copyVec(PVector p) {
  return new PVector(p.x, p.y, p.z);
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

  public LoadingBar(String title) {
    this.title = title;
  }

  public LoadingBar(String title, String subtitle) {
    this.title = title;
    this.subtitle = subtitle;
  }

  public void init() {
    this.sx = 500;
    this.sy = 26;
    this.x = (width/2)-sx/2;
    this.y = (height/2)-sy/2;
  }

  public void update() {
    if (active == true) {
      filter(BLUR, 3);
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
      textAlign(CENTER, CENTER);
      fill(#FF7852);
      text(str(percent)+"%", width/2, height/2-3);

      textSize(24);
      fill(100, 100, 255, 255);
      text(title, width/2, y-20);

      textSize(18);
      fill(128, 245, 94, 255);
      text(subtitle, width/2, y+sy+10);
      drawWork(x-22, y+13);
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
  }
  public void update() {
    b = new Button(width/2-40, height/2-60+h/2, 80, 40, false, "OK");
    confirmed = false;
    if (active) {
      alpha = 200.f;
      activeTime++;
      if (activeTime > 10 && mousePressed && !(mouseX > width/2-w/2 && mouseX < width/2+w/2 && mouseY > height/2-h/2 && mouseY < height/2+h/2)) {
        active = false;
        activeTime = 0;
      }
      if (b.isOn||keyCode==ENTER) {
        active = false;
        confirmed = true;
        activeTime = 0;
      }
    }
    if (alpha > 1.f) {
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


public class textDialog {
  int w;
  int h;
  char cursor;
  int cycles;
  String text;
  boolean active;
  boolean done = false;
  String input = "192.168.1.";
  Button b;
  int activeTime = 0;
  float alpha = 0.f;
  public textDialog(int w, int h, String text) {
    this.w = w;
    this.h = h;
    this.text = new String(text);
  }
  public void chr(char l) {
    if (active)input=input+l;
  }
  public void backspace() {
    if (active) {
      input = input.substring(0, max(0, input.length()-1));
      //println(input.substring(0,max(0,input.length())),max(0,input.length()));
    }
  }
  public void update() {
    b = new Button(width/2-40, height/2-60+h/2, 80, 40, false, "OK");
    cycles++;
    if ((cycles/60)%2==0) {
      cursor='|';
    } else {
      cursor=' ';
    };
    done = false;
    if (active) {
      alpha = 200.f;
      activeTime++;
      //print(keyPressed, keyCode, '\n');
      if (activeTime > 30 && mousePressed && !(mouseX > width/2-w/2 && mouseX < width/2+w/2 && mouseY > height/2-h/2 && mouseY < height/2+h/2)) {
        //print("mouseTrig");
        active = false;
        activeTime = 0;
      }
      if (b.isOn||(keyPressed&&key=='\n')) {
        //print("enterTrig");
        active = false;
        done = true;
        activeTime = 0;
      }
    }
    if (alpha > 1.f) {
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
    if (active) {
      noFill();
      textAlign(LEFT, TOP);
      stroke(100, 100, 255, 170);
      strokeWeight(2);
      rect((width/2)-130, (height/2)-15, 260, 30, 7);
      fill(statusC);
      text(input+cursor, (width/2)-128, (height/2)-13);
    }
    alpha /= 1.06f;
  }
}

public class Menu {
  Button b;
  Button mPost;
  Button mPointer;
  Button mDisCon;
  Button mVLite;
  Button mAltIcon;
  int winX;
  int winY;
  int xDim;
  int yDim;
  float fadeSpeed = 6f;
  float alpha = 0f;

  boolean active =false;

  public Menu(int winX, int winY, int xDim, int yDim) {
    this.winX = winX;
    this.winY = winY;
    this.xDim = xDim;
    this.yDim = yDim;
    this.b = new Button(winX, winY, 40, 40, true);
    //print(winX, winY, xDim, yDim, dist(winX, winY, xDim, yDim));

    this.mPost = new Button(10+winX+(150*0), 50+winY+(50*0), 130, 40, true, "Posterize");
    this.mPointer = new Button(10+winX+(150*0), 50+winY+(50*1), 130, 40, true, "Pointer");
    this.mVLite = new Button(10+winX+(150*0), 50+winY+(50*2), 130, 40, true, "Data Monitor");
    this.mAltIcon = new Button(10+winX+(150*0), 50+winY+(50*3), 130, 40, true, "Motor Display");
    this.mDisCon = new Button(10+winX+(150*0), 50+winY+(50*6), 130, 40, false, "Disconnect", #FF3232);
  }


  public void update() {
    active=b.isOn;
    if (b.isOn||alpha>2f) {
      fill(0, 0, 0, alpha);
      stroke(100, 100, 255, alpha*1.7f);
      rect(winX, winY, xDim, yDim, 7);
    }
    if (b.isOn)alpha = min(alpha+fadeSpeed, 200f); 
    else alpha = max(alpha-fadeSpeed, 0f);
    b.update();
    pushMatrix();
    translate(winX+20, winY+20);
    rotateZ(((millis()%3000f)/3000f)*TWO_PI);
    if (!b.isOn) {
      noFill();
      stroke(100, 100, 255, 255.f);
      ellipse(0, 0, 30, 30);
    } else {
      stroke(0, 0, 0, 255.f);
      noFill();
      ellipse(0, 0, 30, 30);
      fill(0, 0, 0, 255.f);
    }
    textSize(15);
    //text("Q",0,0);
    triangle(0, -15, 13, 7.5, -13, 7.5);
    popMatrix();


    textFont(roboto);
    textSize(24);
    textAlign(LEFT, CENTER);
    fill(boxC, alpha);
    text("Q Client\n V. 4.6", winX+50, winY+20);

    textFont(font);
    textSize(20);

    mPost.active=active;
    mPointer.active=active;
    mVLite.active=active;
    mAltIcon.active=active;
    mDisCon.active=(active&&connected);

    mPost.alpha=alpha/200f;
    mPointer.alpha=alpha/200f;
    mVLite.alpha=alpha/200f;
    mAltIcon.alpha=alpha/200f;
    if (connected) {
      mDisCon.alpha=alpha/200f;
    } else {
      mDisCon.alpha=0f;
    }

    mPost.update();
    mPointer.update();
    mDisCon.update();
    mVLite.update();
    mAltIcon.update();
    //println(xDim, mouseX, yDim, mouseY);
    if (mousePressed && !(mouseX > winX && mouseX < winX+xDim && mouseY > winY && mouseY < winY+yDim)) {
      b.isOn=false;
    }
  }
}

// GLOWING
 
// Martin Schneider
// October 14th, 2009
// k2g2.org
 
 
// use the glow function to add radiosity to your animation :)
 
// r (blur radius) : 1 (1px)  2 (3px) 3 (7px) 4 (15px) ... 8  (255px)
// b (blur amount) : 1 (100%) 2 (75%) 3 (62.5%)        ... 8  (50%)
   
void glow(int r, int b) {
  loadPixels();
  blur(1); // just adding a little smoothness ...
  int[] px = new int[pixels.length];
  arrayCopy(pixels, px);
  blur(r);
  mix(px, b);
  updatePixels();
}
 
void blur(int dd) {
   int[] px = new int[pixels.length];
   for(int d=1<<--dd; d>0; d>>=1) { 
      for(int x=0;x<width;x++) for(int y=0;y<height;y++) {
        int p = y*width + x;
        int e = x >= width-d ? 0 : d;
        int w = x >= d ? -d : 0;
        int n = y >= d ? -width*d : 0;
        int s = y >= (height-d) ? 0 : width*d;
        int r = ( r(pixels[p+w]) + r(pixels[p+e]) + r(pixels[p+n]) + r(pixels[p+s]) ) >> 2;
        int g = ( g(pixels[p+w]) + g(pixels[p+e]) + g(pixels[p+n]) + g(pixels[p+s]) ) >> 2;
        int b = ( b(pixels[p+w]) + b(pixels[p+e]) + b(pixels[p+n]) + b(pixels[p+s]) ) >> 2;
        px[p] = 0xff000000 + (r<<16) | (g<<8) | b;
      }
      arrayCopy(px,pixels);
   }
}
 
void mix(int[] px, int n) {
  for(int i=0; i< pixels.length; i++) {
    int r = (r(pixels[i]) >> 1)  + (r(px[i]) >> 1) + (r(pixels[i]) >> n)  - (r(px[i]) >> n) ;
    int g = (g(pixels[i]) >> 1)  + (g(px[i]) >> 1) + (g(pixels[i]) >> n)  - (g(px[i]) >> n) ;
    int b = (b(pixels[i]) >> 1)  + (b(px[i]) >> 1) + (b(pixels[i]) >> n)  - (b(px[i]) >> n) ;
    pixels[i] =  0xff000000 | (r<<16) | (g<<8) | b;
  }
}
 
int r(color c) {return (c >> 16) & 255; }
int g(color c) {return (c >> 8) & 255;}
int b(color c) {return c & 255; }
