float x, y = 0;
float z = 300.0f;
float pf = 0.0f;
float br = 0.03f;
color col = color(80, 80, 255);
color col2 = color(255);
boolean add = true;
int localHold, apf = 0;
float[][] data;
int g = 0;
int[] rand;
float[] randW;

float a;
float b;
float c;
float d;
float e;
float f;

float juliaPower;
float juliaDist;

float varVals = 2.f;

void setup() {
  //size(1280, 720, P2D);
  fullScreen(P2D);
  data = new float[width][height];
  background(0);
  stroke(0, 0, 0, 5);
  frameRate(500);
  setVs();
}
void setVs() {
  a = random(-varVals, varVals);
  b = random(-varVals, varVals);
  c = random(-varVals, varVals);
  d = random(-varVals, varVals);
  e = random(-varVals, varVals);
  f = random(-varVals, varVals);
  juliaPower = float(int(random(2, 7)));
  juliaDist = random(1, 2);
  rand = new int[(int)random(3, 5)];
  randW = new float[rand.length];
  for (int i = 0; i < rand.length; i++) {
    rand[i] = (int)random(19);
    randW[i] = random(1.f);
    println(rand[i] + " " + randW[i]);
  }
  rand = new int[]{0, 1};
  randW = new float[]{1.f, 1.f};
}
void draw() {
  dispProgress(apf/3000.0f);
  x = random(-1, 1);
  y = random(-1, 1);
  if (apf<3000) {
    for (int i = 0; i < 10000; i++) {
      int k = (int)random(rand.length);
      int switchLight = rand[k];
      float tX = x;
      float tY = y;
      float qX = 0.f;
      float qY = 0.f;
      if (random(1.0f) < randW[k])
        switch(switchLight) {
        case 0:
          qX = sin(a*tY)-cos(b*tX);
          qY = sin(c*tX)-cos(d*tY);
          break;
        case 1:
          qX = sin(tX);
          qY = sin(tY);
          break;
        case 2:
          float r2 = tX*tX+tY*tY;
          qX = (1/r2)*tX;
          qY = (1/r2)*tY;
          break;
        case 3:
          float r20 = tX*tX+tY*tY;
          qX = tX*sin(r20)-tY*cos(r20);
          qY = tX*cos(r20)+tY*sin(r20);
          break;
        case 4:
          float r21 = tX*tX+tY*tY;
          float r = sqrt(r21);
          qX = (tX-tY)*(tX+tY)/r;
          qY = 2*tX*tY/r;
          break;
        case 5:
          float theta = atan2(tX, tY);
          float r0 = sqrt(tX*tX+tY*tY);
          qX = theta/PI;
          qY = r0-1;
        case 6:
          float theta0 = atan2(tX, tY);
          float r1 = sqrt(tX*tX+tY*tY);
          qX = r1*sin(theta0+r1);
          qY = r1*cos(theta0-r1);
        case 7:
          float r3 = sqrt(tX*tX+tY*tY);
          float theta1 = atan2(tX, tY);
          qX = r3*sin(theta1*r3);
          qY = r3*-cos(theta1*r3);
        case 8:
          float r4 = sqrt(tX*tX+tY*tY);
          float theta2 = atan2(tX, tY);
          qX = (theta2/PI)*sin(PI*r4);
          qY = (theta2/PI)*cos(PI*r4);
        case 9:
          float r5 = sqrt(tX*tX+tY*tY);
          float theta3 = atan2(tX, tY);
          qX = (cos(theta3)+sin(r5))/r5;
          qY = (sin(theta3)-cos(r5))/r5;
        case 10:
          float r6 = sqrt(tX*tX+tY*tY);
          float theta4 = atan2(tX, tY);
          qX = sin(theta4)/r6;
          qY = r6*cos(theta4);
        case 11:
          float r7 = sqrt(tX*tX+tY*tY);
          float theta5 = atan2(tX, tY);
          qX = r7-theta5;
          qY = cos(theta5)+r7;
        case 12:
          float r8 = sqrt(tX*tX+tY*tY);
          float theta6 = atan2(tX, tY);
          float p0 = sin(theta6+r8);
          float p1 = cos(theta6-r8);
          qX = r8*(p0*p0*p0+p1*p1*p1);
          qX = r8*(p0*p0*p0-p1*p1*p1);
        case 13:
          float omega = 0;
          if (random(10000)>5000)
            omega = PI;
          float r9 = sqrt(sqrt(tX*tX+tY*tY));
          float theta7 = atan2(tX, tY)/2;
          qX = r9*cos(theta7 + omega);
          qY = r9*sin(theta7 + omega);
          break;
        case 14:
          if (tX<0&&tY>=0)
            qX = 2*tX;
          if (tX>=0&&tY<0)
            qY = tY/2;
          if (tX<0&&tY<0) {
            qX = 2*tX;
            qY = tY/2;
          }
          break;
        case 15:
          qX = tX + b*sin(tY/(c*c));
          qY = tY + e*sin(tX/(f*f));
          break;
        case 16:
          float r10 = 2/(sqrt(tX*tX+tY*tY)+1);
          qX = tX*r10;
          qY = tY*r10;
          break;
        case 17:
          qX = tX + c*sin(tan(3*tY));
          qY = tY + f*sin(tan(3*tX));
          break;
        case 18:
          qX = exp(tX-1)*cos(PI*tY);
          qY = exp(tX-1)*sin(PI*tY);
          break;
        case 19:
          float ting = -1;
          if (random(10000)>5000)
            ting = 1;
          float p3 = (float)int(abs(juliaPower)*random(0, 1));
          float t0 = (ting*atan2(tY, tX) + 2*PI*p3)/juliaPower;
          float eimw = pow(sqrt(tY*tY+tX*tX), juliaDist/juliaPower);
          qX = eimw*cos(t0);
          qY = eimw*sin(t0);
          break;
        default:
          break;
        }
      x = qX;
      y = qY;
      PVector p = mapToScreen(x, y);
      //int md = add?ADD:BLEND;
      //color c4 = get((int)p.x, (int)p.y);
      //c4 = blendColor(color(r(col)*br, g(col)*br, b(col)*br), c4, md);
      //stroke(c4);
      //drawPoint(p);
      //set((int)p.x, (int)p.y, c4);
      if (p.x >= 0 && p.y >= 0 && p.x < width && p.y < height)
        data[(int)p.x][(int)p.y]++;
      updatePixels();
      //drawPoint2(p, col);
    }
    apf++;
  } else
    saveFrame("outie.png");
  pf++;
}
void mousePressed() {
  if (mouseButton == LEFT) {
    for (int x = 0; x < width; x++)
      for (int y = 0; y < height; y++)
        set(x, y, color(data[x][y]));
  } else if (mouseButton == RIGHT) {
    background(0);
    col = color(random(205)+50, random(205)+50, random(205)+50);
    data = new float[width][height];
    setVs();
    apf = 0;
  }
}
void keyPressed() {
  saveFrame("out.png");
}
void dispProgress(float amount) {
  int bars = int(amount*10.0f);
  noFill();
  stroke(255, 255, 255, 255);
  rect(5, 5, 300, 30);
  fill(255, 255, 255, 255);
  for (int i = 0; i < bars; i++)
    rect(i*30+10, 10, 20, 20);
}
void drawPoint(PVector p) {
  point(p.x, p.y);
}
void drawPoint2(PVector p, color c) {
  col2 = get((int)p.x, (int)p.y);
  set((int)p.x, (int)p.y, color(r(col2)+r(c)*br, g(col2)+g(c)*br, b(col2)+b(c)*br));
}
PVector mapToScreen(float x, float y) {
  return new PVector(x*z+width/2, y*z+height/2);
}
float rotX(float x, float y, float theta) {
  return x*cos(theta)-y*sin(theta);
}
float rotY(float x, float y, float theta) {
  return x*sin(theta)+y*cos(theta);
}

int r(color c) {
  return (c >> 16) & 255;
}
int g(color c) {
  return (c >> 8) & 255;
}
int b(color c) {
  return c & 255;
}
