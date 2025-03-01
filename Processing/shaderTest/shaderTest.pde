PShader myShader;

void setup() {
  size(250, 250, P2D);
  noSmooth();
}

void draw() {

  // We reload the shader every frame so
  // you can see the changes applied in realtime 
  myShader = loadShader("shader.frag");
  myShader.set("resolution", float(width), float(height));
  shader(myShader);
  
  myShader.set("time", (float)(millis() / 1000.0));
  myShader.set("mouse", float(mouseX), float(mouseY));
  
  noStroke();
  fill(0);
  rect(0, 0, width, height);  
  
  resetShader();
}
