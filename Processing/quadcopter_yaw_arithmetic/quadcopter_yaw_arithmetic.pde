void setup() {
  size(512, 512, P2D);
  background(255);
  frameRate(1000);
}
float theta1 = 0.f;
float theta2 = 0.f;
void draw() {
  background(255);
  stroke(0, 255);
  if(mousePressed) {
    if(mouseButton == LEFT) theta1 = (float(mouseX)/100.f)%TWO_PI;
    if(mouseButton == RIGHT) theta2 = (float(mouseX)/100.f)%TWO_PI;
  }
  noFill();
  ellipse(width/2, height/2, 400, 400);
  stroke(200, 0, 0);
  fill(200, 0, 0);
  text("θ1: " + theta1, 10, 20);
  line(width/2, height/2, width/2 + cos(theta1)*200, height/2 + sin(theta1)*200);
  stroke(0, 200, 0);
  fill(0, 200, 0);
  text("θ2: " + theta2, 10, 40);
  line(width/2, height/2, width/2 + cos(theta2)*200, height/2 + sin(theta2)*200);
  
  //IMPORTANT LINES//
  float k0 = theta2 - theta1 - TWO_PI;
  float k1 = theta2 - theta1;
  float k2 = theta2 - theta1 + TWO_PI;
  float thetaDelta = k0;
  if(abs(k1) < abs(thetaDelta)) thetaDelta = k1;
  if(abs(k2) < abs(thetaDelta)) thetaDelta = k2;
  //IMPORTANT LINES OVER//
  
  stroke(0, 0, 200);
  fill(0, 0, 200);
  text("Δθ: " + thetaDelta, 10, 60);
}