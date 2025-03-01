import controlP5.*;

import processing.video.*;

Capture cam;

boolean capturing = false;

ControlP5 cp5;
String textValue = "";

float num_secs = 60.0;

void setup() {
  size(640, 480);

  String[] cameras = Capture.list();
  
  int activeCam = int(loadStrings("CONFIG.txt")[0].split("=")[1]);
  println(activeCam);
  
  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    println("Available cameras:");
    for (int i = 0; i < cameras.length; i++) {
      println(cameras[i]);
    }
    
    // The camera can be initialized directly using an 
    // element from the array returned by list():
    cam = new Capture(this, cameras[activeCam]);
    cam.start();     
  }
  
  cp5 = new ControlP5(this);
  cp5.addTextfield("Delay (seconds):")
     .setPosition(20,20)
     .setSize(200,32)
     .setFont(createFont("arial",16))
     .setAutoClear(false)
     .setFocus(true)
     ;
}

int i = 0;
int last_pic = 0;

void draw() {
  
  if(!capturing) {
    background(0);
    if(cp5.getController("Delay (seconds):").getStringValue().length() > 0) {
      float q = float(cp5.getController("Delay (seconds):").getStringValue());
      if(!(new Float(q)).isNaN()) {
        num_secs = q;
      }
    }
    textSize(20);
    text(num_secs, 180, 76);
    
    fill(0, 255);
    stroke(255);
    rect(20, height - 100, 180, 80);
    fill(255, 255);
    if(mouseX > 20 && mouseX < 200 && mouseY > height - 100 && mouseY < height - 20) {
      fill(255, 255);
      rect(20, height - 100, 180, 80);
      fill(0, 255);
      
      if(mousePressed) capturing = true;
    }
    textAlign(CENTER, CENTER);
    text("Start Timelapse", 110, height - 60);
    textAlign(LEFT, TOP);
    fill(255, 255);
    
    if(frameCount%40==0)
    cam.read();
    image(cam, width/2, height/4, width/2, height/2);
    last_pic = 0;
  }
  
  if(capturing) {
    if(millis() - last_pic > num_secs*1000.0) {
      capture();
      background(0);
      image(cam, 0, 0, width, height);
      fill(255, 0, 0);
      text("Frame " + i, 15, 15+100);
      text("dt " + (millis() - last_pic)/1000.f + "s", 15, 35+100);
      last_pic = millis();
    }
  }
}

void capture() {
  if (cam.available() == true) {
      cam.read();
      cam.save("data/" + nf(i, 8) + "_" + year() + "-" + month() + "-" + day() + "-" + hour() + "-" + minute() + "-" + second() + ".png");
      cam.stop();
      delay(2000);
      cam.start();
      delay(4000);
      if(cam.available())
        cam.read();
      delay(2000);
      i++;
    }
}
