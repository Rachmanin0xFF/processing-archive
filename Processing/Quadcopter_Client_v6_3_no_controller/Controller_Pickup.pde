
// Game controller (xbox, steam controller, joystick, etc.) in this file.
// Using the Game Control Plus library for processing by user quark on the processing forums (http://www.lagers.org.uk/)

final float IGNORE_LOW_INPUTS = 0.05f;

import org.gamecontrolplus.gui.*;
import org.gamecontrolplus.*;
import net.java.games.input.*;
ControlIO control;
ControlDevice stick;
void initControl() {
  // Initialise the ControlIO
  control = ControlIO.getInstance(this);
  // Find a device that matches the configuration file
  stick = control.getMatchedDevice("xbox");
  if (stick == null) {
    println2("No suitable device configured");
    System.exit(-1); // End the program NOW!
  } else {
    println2("Controller online.");
  }
}

// Values are in range -1.f to 1.f
float CONTROL_X = 0.f;
float CONTROL_Y = 0.f;
float CONTROL_THROTTLE = 0.f;
float CONTROL_THROTTLE_GLOBAL = 0.f;

float THROTTLE = 0.f;
float THROTTLE_GLOBAL = 0.f;

float CONTROL_X_EASED = 0.f;
float CONTROL_Y_EASED = 0.f;
float CONTROL_THROTTLE_EASED = 0.f;

boolean CONTROL_SCAN = false;
boolean CONTROL_DISCON = false;
boolean CONTROL_LOADPID = false;
boolean CONTROL_ZERO = false;

float CONTROL_X0 = 0.f;
float CONTROL_Y0 = 0.f;

float CTRLXYSCL = 0.1f;

void updateControl() {
  /*
  CONTROL_X = stick.getSlider("XPOS").getValue();
  CONTROL_Y = stick.getSlider("YPOS").getValue();
  */
  if(abs(CONTROL_X) < IGNORE_LOW_INPUTS) CONTROL_X = 0.f;
  else CONTROL_X = signum(CONTROL_X)*(abs(CONTROL_X) - IGNORE_LOW_INPUTS)*(1.f/(1.f-IGNORE_LOW_INPUTS));
  if(abs(CONTROL_Y) < IGNORE_LOW_INPUTS) CONTROL_Y = 0.f;
  else CONTROL_Y = signum(CONTROL_Y)*(abs(CONTROL_Y) - IGNORE_LOW_INPUTS)*(1.f/(1.f-IGNORE_LOW_INPUTS));
 // CONTROL_THROTTLE = -stick.getSlider("THROT").getValue();
  
  // Commenting out for now because it looks sort of jerk-y on the screen.
  //if(CONTROL_X*CONTROL_X + CONTROL_Y*CONTROL_Y < 0.01) {
  //  CONTROL_X = 0.f;
  //  CONTROL_Y = 0.f;
  //}
  /*
  CONTROL_SCAN = stick.getButton("SCAN").pressed();
  CONTROL_DISCON = stick.getButton("DISCON").pressed();
  CONTROL_LOADPID = stick.getButton("LOADPID").pressed();
  CONTROL_ZERO = stick.getButton("ZERO").pressed();
  float hatx = stick.getHat("ZERO_CONTROL").getX();
  float haty = stick.getHat("ZERO_CONTROL").getY();
  CONTROL_X0 += CTRLXYSCL*hatx/400.f;
  CONTROL_Y0 -= CTRLXYSCL*haty/400.f;
  */
  float mx = CTRLXYSCL*0.5f;
  if(CONTROL_X0 > mx) CONTROL_X0 = mx;
  if(CONTROL_Y0 > mx) CONTROL_Y0 = mx;
  if(CONTROL_X0 < -mx) CONTROL_X0 = -mx;
  if(CONTROL_Y0 < -mx) CONTROL_Y0 = -mx;
  
  
  //CONTROL_THROTTLE_GLOBAL = 0.f - stick.getSlider("ZPOS").getValue();
  if(abs(CONTROL_THROTTLE_GLOBAL) < 0.2f)
    CONTROL_THROTTLE_GLOBAL = 0.f;
  else
    CONTROL_THROTTLE_GLOBAL = signum(CONTROL_THROTTLE_GLOBAL)*(abs(CONTROL_THROTTLE_GLOBAL) - 0.2f)*1.25f;
  
  CONTROL_X_EASED += (CONTROL_X - CONTROL_X_EASED)*0.3f;
  CONTROL_Y_EASED += (CONTROL_Y - CONTROL_Y_EASED)*0.3f;
  CONTROL_THROTTLE_EASED += (CONTROL_THROTTLE - CONTROL_THROTTLE_EASED)*0.3f;
  
  THROTTLE_GLOBAL += CONTROL_THROTTLE_GLOBAL*0.002f;
  if(THROTTLE_GLOBAL > 1.f) THROTTLE_GLOBAL = 1.f;
  if(THROTTLE_GLOBAL < 0.f) THROTTLE_GLOBAL = 0.f;
  
  THROTTLE = THROTTLE_GLOBAL + CONTROL_THROTTLE*0.1f;
  THROTTLE = throddle.value;
  
  if(THROTTLE > 1.f) THROTTLE = 1.f;
  if(THROTTLE < 0.f) THROTTLE = 0.f;
  
  if(CONTROL_ZERO) {
    THROTTLE = 0.f;
    THROTTLE_GLOBAL = 0.f;
    CONTROL_X = 0.f;
    CONTROL_X_EASED = 0.f;
    CONTROL_Y = 0.f;
    CONTROL_Y_EASED = 0.f;
    CONTROL_THROTTLE = 0.f;
    CONTROL_THROTTLE_EASED = 0.f;
    CONTROL_THROTTLE_GLOBAL = 0.f;
  }
}