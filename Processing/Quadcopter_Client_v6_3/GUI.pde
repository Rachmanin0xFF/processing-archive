
//GUI management.

Theme wTheme = new Theme(color(0, 0, 0, 150), color(255, 255));
Theme rTheme = new Theme(color(0, 0, 0, 150), color(255, 80, 80, 255));
Theme gTheme = new Theme(color(0, 0, 0, 150), color(80, 255, 80, 255));
Theme bTheme = new Theme(color(0, 0, 0, 150), color(80, 80, 255, 255));

GoPad xyControllerPad;
Button lanScan;
Button dropConnection;
Button savePID;
Button loadPID;

Slider P_COEFF;
Slider I_COEFF;
Slider D_COEFF;

void initGUI() {
  xyControllerPad = new GoPad(width - 300 - 10, 10, 300, 300);
  xyControllerPad.set_theme(gTheme);
  xyControllerPad.var_x_name = "X Rot";
  xyControllerPad.var_y_name = "Y Rot";
  lanScan = new Button(10, 10, 80, 60, "Scan LAN\nNetwork");
  lanScan.set_theme(rTheme);
  dropConnection = new Button(10, 80, 80, 60, "Disconnect");
  dropConnection.set_theme(rTheme);
  savePID = new Button(10, 150, 80, 60, "Save PID");
  savePID.set_theme(rTheme);
  loadPID = new Button(10, 220, 80, 60, "Load PID");
  loadPID.set_theme(rTheme);
  
  P_COEFF = new Slider(100, 10, width - 400 - 20, 60, "P");
  P_COEFF.display_value = true;
  P_COEFF.set_theme(bTheme);
  I_COEFF = new Slider(100, 80, width - 400 - 20, 60, "I");
  I_COEFF.display_value = true;
  I_COEFF.set_theme(bTheme);
  D_COEFF = new Slider(100, 150, width - 400 - 20, 60, "D");
  D_COEFF.display_value = true;
  D_COEFF.set_theme(bTheme);
}

void updateGUI() {
  xyControllerPad.always_spin = true;
  xyControllerPad.display_values = true;
  xyControllerPad.set_value(CONTROL_X_EASED, CONTROL_Y_EASED);
  xyControllerPad.update();
  xyControllerPad.display();
  {
    float x = xyControllerPad.x;
    float y = xyControllerPad.y;
    float w = xyControllerPad.w;
    float h = xyControllerPad.h;
    text("Control X0: " + CONTROL_X0, x + 10, h - 30 - 12);
    text("Control Y0: " + CONTROL_Y0, x + 10, h - 10 - 12);
    fill(80, 255, 80, 255);
    String throttleText = round_to(THROTTLE*100, 2);
    if(throttleText.equals("1.52")) throttleText = "0.0";
    text("Throttle: " + throttleText + "%", x + w - 110, y + h - 24);
    stroke(80, 80, 255);
    line(x + CONTROL_X0*w/CTRLXYSCL - 10 + w/2.f, y - CONTROL_Y0*h/CTRLXYSCL + h/2.f, x + CONTROL_X0*w/CTRLXYSCL + 10 + w/2.f, y - CONTROL_Y0*h/CTRLXYSCL + h/2.f);
    line(x + CONTROL_X0*w/CTRLXYSCL + w/2.f, y - CONTROL_Y0*h/CTRLXYSCL - 10 + h/2.f, x + CONTROL_X0*w/CTRLXYSCL + w/2.f, y - CONTROL_Y0*h/CTRLXYSCL + 10 + h/2.f);
  }
  lanScan.update();
  if(CONTROL_SCAN) lanScan.is_on = true;
  lanScan.display();
  dropConnection.update();
  if(CONTROL_DISCON) { dropConnection.is_on = true; dropConnection.override_input = true; } else dropConnection.override_input = false;
  dropConnection.display();
  savePID.update();
  savePID.display();
  loadPID.update();
  if(CONTROL_LOADPID) { loadPID.is_on = true; loadPID.override_input = true; } else loadPID.override_input = false;
  loadPID.display();
  P_COEFF.update();
  P_COEFF.display();
  I_COEFF.update();
  I_COEFF.display();
  D_COEFF.update();
  D_COEFF.display();
  stroke(80, 255, 80);
  drawZ(width - 50 - 10, 320, 50, height - 320 - 10, CONTROL_THROTTLE_EASED, 1.f - THROTTLE);
  drawSphere(width - 50 - 20 - 240, 320, 240/2);
  
  drawSideQuad(width - 300 - 20 - 200, 220, 100, QUADCOPTER_RY, "Y Rotation");
  drawSideQuad(width - 300 - 20 - 410, 220, 100, QUADCOPTER_RX, "X Rotation");
  drawTopQuad(width - 300 - 20 - 620, 220, 100, QUADCOPTER_RZ, "Z Rotation");
  String toprintlowercorner = "Frame rate: " + round_to(frameRate, 2);
  fill(255, 80, 80, 255);
  if(connected) {
    toprintlowercorner += " Quadcopter ticks passed: " + QUADCOPTER_TICKS;
    text("Connected to " + connectionIP + ":" + QUAD_PORT, 10, height - 24);
  }
  text(toprintlowercorner, 10, height - 40);
  noFill();
  stroke(255, 80, 80);
  drawConsole(10, height - 130, 710, 90);
}

ArrayList<String> consoleOutput = new ArrayList<String>();
int currentConsole = 0;

void println2(String s) {
  println(s);
  consoleOutput.add(s);
  currentConsole++;
}

void drawConsole(float x, float y, float w, float h) {
  fill(0, 150);
  rect(x, y, w, h);
  fill(255, 80, 80, 255);
  float spacing = 11.8f;
  int numCanFit = (int)(h/spacing);
  line(x + 32, y, x + 32, y + h);
  while(consoleOutput.size() > numCanFit) consoleOutput.remove(0);
  for(int i = 0; i < consoleOutput.size(); i++) {
    textAlign(RIGHT, TOP);
    text(i - consoleOutput.size() + currentConsole, x + 30, y + spacing*i);
    textAlign(LEFT, TOP);
    text(consoleOutput.get(i), x + 34, y + spacing*i);
  }
}

void mouseWheel(MouseEvent me) {
  P_COEFF.update_scroll(me.getCount());
  I_COEFF.update_scroll(me.getCount());
  D_COEFF.update_scroll(me.getCount());
}

// Note: if a function accepts a parameter "r", the function will not center the display on (x,y).
// Treat "r" as more of a 'half-width'.
void drawSideQuad(float x, float y, float r, float rot, String axis) {
  fill(0, 150);
  rect(x, y, r*2, r*2);
  fill(0, 100);
  pushMatrix();
  translate(x + r, y + r);
  rotateZ(PI+rot);
  line(-r, 0, r, 0);
  rect(-15, -15, 30, 30);
  rect(-r, -10, 20, 20);
  rect(r-20, -10, 20, 20);
  line(0, 0, 0, 30);
  noFill();
  ellipse(0, 0, r*2, r*2);
  popMatrix();
  fill(80, 255, 80, 255);
  text(axis + ": " + round_to(rot*57.2957795131, 2) + "°", x, y + r*2 + 2);
}

void drawTopQuad(float x, float y, float r, float rot, String axis) {
  fill(0, 150);
  rect(x, y, r*2, r*2);
  fill(0, 100);
  pushMatrix();
  translate(x + r, y + r);
  rotateZ(PI/2 + rot);
  line(-r, 0, r, 0);
  line(0, -r, 0, r);
  rect(-15, -15, 30, 30);
  line(-r, 0, -r + 10, 10);
  line(-r, 0, -r + 10, -10);
  line(-r + 10, 0, -r + 20, 10);
  line(-r + 10, 0, -r + 20, -10);
  rect(r-20, -10, 20, 20);
  rect(-10, -r, 20, 20);
  rect(-10, r-20, 20, 20);
  noFill();
  ellipse(0, 0, r*2, r*2);
  popMatrix();
  fill(80, 255, 80, 255);
  text(axis + ": " + round_to(rot*57.2957795131, 2) + "°", x, y + r*2 + 2);
}

void drawSphere(float x, float y, float r) {
  noFill();
  rect(x, y, r*2, r*2);
  pushMatrix();
  ortho();
  translate(x + r, y + r);
  rotateX(PI/2);
  rotateX(QUADCOPTER_RX);
  rotateZ(QUADCOPTER_RY);
  
  sphereDetail(30, 10);
  sphere(r);
  
  popMatrix();
  stroke(80, 255, 80);
  fill(0, 150);
  rect(x, y, r*2, r*2);
}

void drawZ(float x, float y, float w, float h, float value1, float value2) {
  fill(0, 150);
  rect(x, y, w, h);
  noFill();
  line(x + w/2.f, y, x + w/2.f, y + h);
  line(x + w/5.f, y + h/2.f, x + w/5.f*4.f, y + h/2.f);
  for(float i = -5.f; i <= 5.f; i++) {
    line(x + w/5.f*2.f, y + h/10.f*i + h/2.f, x + w/5.f*3.f, y + h/10.f*i + h/2.f);
  }
  ellipse(x + w/2.f, y + h*(1.f - ((value1 + 0.5f/h)/2.f + 0.5f)), 10, 10);
  line(x, y + h*value2, x + w, y + h*value2);
}