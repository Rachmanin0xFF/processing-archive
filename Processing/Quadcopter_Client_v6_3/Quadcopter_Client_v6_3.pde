
//Quadcopter Client v6.3

//v6.2 Updates/Changelog-
//Improved controller usability in various ways (more of the BEN updates)
//Added signum(x) function to UTIL.pde

//@author Adam Lastowka
//Created for the Quadcopter project in collaboration with Benjamin Welsh and Anthony Catalano-Johnson.

import org.gamecontrolplus.gui.*;

PShader shader;
PImage background_image;

public void setup() {
  size(1040, 570, P3D);
  initControl();
  initGUI();
  initNetworking();
  //noSmooth();
  smooth(8);
  frameRate(200);
  shader = loadShader("lmult.shader");
  background_image = loadImage("bkg.png");
  tint(0, 255, 80);
}

float bluriness = 1.f;
public void draw() {
  background(0);
  image(background_image, 0, 0, width, height);
  stroke(0, 255, 0);
  updateControl();
  updateGUI();
  
  if(bluriness > 0.00005f) {
    shader.set("RES", (float)width, (float)height);
    shader.set("amount", bluriness);
    filter(shader);
    bluriness /= 1.1f;
  }
  
  updateNetworking();
  
  if(loadPID.is_on && loadPID.changed) {
    String[] s = loadStrings("PID.txt");
    String[] vals = s[s.length-1].split(" ");
    P_COEFF.set_value(Float.parseFloat(vals[0]));
    I_COEFF.set_value(Float.parseFloat(vals[1]));
    D_COEFF.set_value(Float.parseFloat(vals[2]));
    println2("PID values loaded from time " + vals[3]);
  }
  if(savePID.is_on && savePID.changed) {
    String[] s = loadStrings("PID.txt");
    String toAdd = P_COEFF.value + " " + I_COEFF.value + " " + D_COEFF.value + " " + year() + "-" + month() + "-" + day() + "-" + hour() + ":" + minute() + ":" + second();
    String[] toSave = new String[s.length+1];
    for(int i = 0; i < s.length; i++) {
      toSave[i] = s[i];
    }
    toSave[s.length] = toAdd;
    saveStrings("data/PID.txt", toSave);
  }
}