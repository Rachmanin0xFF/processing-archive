void setup() {
  size(512, 512, P2D);
  stroke(255);
  strokeWeight(5);
  smooth(16);
}
int Q = 2;
float wsin(float t) {
  return round(sin(t));
}
float wcos(float t) {
  return round(cos(t));
}
float t = 0;
void draw() {
  
  if(Q==1) {
  background(0);
  noFill();
  stroke(255);
  strokeWeight(1);
  ellipse(width/2, height/2, 300, 300);
  strokeWeight(5);
  fill(255);
  noStroke();
  ellipse(width/2 - sin(t)*150, height/2 - cos(t)*150, 40, 40);
  }
  if(Q==2) {
    background(0);
  noFill();
  stroke(255);
  strokeWeight(5);
  point(width/2 - 150, height/2 - 150);
  point(width/2 + 150, height/2 - 150);
  point(width/2 + 150, height/2 + 150);
  point(width/2 - 150, height/2 + 150);
  point(width/2 - 150, height/2);
  point(width/2 + 150, height/2);
  point(width/2, height/2 - 150);
  point(width/2, height/2 + 150);
  strokeWeight(8);
  
  fill(255);
  noStroke();
  ellipse(width/2 - wsin(t)*150, height/2 - wcos(t)*150, 40, 40);
  
    
}
strokeWeight(2);
  stroke(255, 50);
  line(width/2, 0, width/2, height);
  line(0, height/2, width, height/2);
if(t < TWO_PI) saveFrame(frameCount + ".png");
  println(t);
  t += TWO_PI/32.0;
  
  
}
