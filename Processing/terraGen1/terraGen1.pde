  
PShader blur;
float d_P_0 = 0.05f;
PVector pos = new PVector();
float ang = 0.f;

void setup() {
  size(400, 400, P2D);
  noFill();
  blur = loadShader("px.glsl"); 
  rectMode(CENTER);
  frameRate(500);
  if (frame != null) {
    frame.setResizable(true);
  }
}

void draw() {
  getDeltaControl();
  frame.setTitle((int)frameRate + "fps");
  blur.set("rotX", ang);
  blur.set("userPosition", pos.x, pos.y, pos.z);
  filter(blur);
  ellipse(mouseX, mouseY, 10, 10);
}

void getDeltaControl() {
  ang = float(mouseX-width/2)/float(width)*PI;
  float delta_P = d_P_0*(mousePressed?0.2f:1.f);
  PVector directions = new PVector(1, 1, 1);
  PVector r_d = new PVector(cos(ang) - sin(ang), 1, sin(ang) + cos(ang));
  r_d = directions;
  if(keyPressed) {
    char k = key;
  if(k == 's')
    pos.z -= r_d.z*delta_P;
  if(k == 'w')
    pos.z += r_d.z*delta_P;
  if(k == 'a')
    pos.x -= r_d.x*delta_P;
  if(k == 'd')
    pos.x += r_d.x*delta_P;
  if(key == CODED && keyCode == SHIFT)
    pos.y -= delta_P;
  if(key == ' ')
    pos.y += delta_P;
  }
}