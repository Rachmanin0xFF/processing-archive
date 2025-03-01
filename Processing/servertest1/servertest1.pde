  

import processing.net.*;
Server myServer;
int val = 12;

void setup() {
  size(200, 200);
  myServer = new Server(this, 25564); 
}

void draw() {
  delay(30);
  val = mouseX;
  val = val/2;
  myServer.write(val);
  println(val);
}


