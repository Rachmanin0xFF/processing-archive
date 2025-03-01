void setup() {
  size(512, 512, P2D);
}

float y1 = 4800;
float x1 = 7200;

float y2 = 2400;
float x2 = 5600;

void draw() {
  background(0);
  blendMode(ADD);
  //x2 = mouseX*30.f;
  //y2 = mouseY*30.f;
  float m1 = y1/x1;
  float m2 = y2/x2;
  stroke(255);
  stroke(255, 50, 50);
  line(0, height - y1*z, x1*z, height);
  if(m1 > m2)
    line(x2*z, height - y1*z, (x1+x2)*z, height);
  else
    line(0, height - (y2+y1)*z, x1*z, height - y2*z);
  stroke(50, 50, 255);
  line(0, height - y2*z, x2*z, height);
  if(m1 > m2)
    line(0, height - (y2+y1)*z, x2*z, height - y1*z);
  else
    line(x1*z, height - y2*z, (x1+x2)*z, height);
  stroke(255, 100, 255);
  //line(0, height - (y1 + y2)*z, (x1 + x2)*z, height);
  stroke(50, 50, 50);
  line(0, height, width, 0);
  
  float i1 = y1/(1.f+m1);
  float i2 = y2/(1.f+m2);
  println(i1 + " " + i2);
  float ic = (y1+y2)/(1.f+(y1+y2)/(x1+x2));
  noFill();
  ellipse(i1*z, height - i1*z, 10, 10);
  ellipse(i2*z, height - i2*z, 10, 10);
  ellipse((i1 + i2)*z, height - (i1 + i2)*z, 10, 10);
  //ellipse(ic*z, height - ic*z, 10, 10);
  //ellipse(ic*z/2.f, height - ic*z/2.f, 10, 10);
}
float z = 0.1f;
void mouseWheel(MouseEvent event) {
  if(event.getCount() < 0)
    z *= 1.05f;
  else
    z /= 1.05f;
}