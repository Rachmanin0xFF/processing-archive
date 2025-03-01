//Reference- Matrix setup:
/*////
  L, M, and N are the 3 directions of the propeller axes.
   [[Lx  Mx  Nx]
    [Ly  My  Ny]
    [Lz  Mz  Nz]]
  D is the direction we want to push in.
   [[Dx]
    [Dy]
    [Dz]]
  These are the weights for motors L, M, and N. L->a, M->b, N->c.
    [[a]
     [b]
     [c]]
    
    Lx*a + Mx*b + Nx*c = Dx
    Ly*a + My*b + Ny*c = Dy
    Lz*a + Mz*b + Nz*c = Dz
////*/
import processing.opengl.*;
float camRotX = PI*2/3;
float camRotY = PI/3;
float tmouseX;
float tmouseY;
float addrx;
float addry;
boolean wmousePressed;
float zoom = 200;
PImage groundTex;
int framesPassed;
TetracopterX tet = new TetracopterX(5, 5, 5); //Tetracopter <------------ (((2)))
public PGraphics cubeView;
public PGraphics textPack;
ArrayList<vec3> dats = new ArrayList<vec3>();
void setup() {
  int horizontalDimension = 1920; //Edit window size here
  int verticalDimension = 1080;
  groundTex = loadImage("tiles2.jpg");
  size(horizontalDimension, verticalDimension, P2D);
  frameRate(5000000);
  cubeView = createGraphics(horizontalDimension, verticalDimension, OPENGL);//Graphics dimensions
  textPack = createGraphics(300, 210, JAVA2D); //console dimensions
  textureWrap(REPEAT);
  PFont font = createFont("LucidaConsole", 16, true);
  //textPack.textFont(font);
}
void draw() {
  if(keyPressed&&key=='r') {
    //IMPORTANT!! IF YOU WANT TO BE ABLE TO TRY OUT THE REGULAR TETRACOPTER CLASS, FIND+REPLACE "TetracopterX" WITH "Tetracopter". IN THE TETRACOPTERSIM FILE. THAT IS ALL.
    tet = new TetracopterX(5, 5, 5); //Tetracopter <------------
    framesPassed=0;
  }
  /////////CAMERA_OPERATIONS//////////
  cubeView.beginDraw();
  cubeView.background(0);
  cubeView.scale(zoom);
  cubeView.translate(width/2/zoom, height/2/zoom);
  cubeView.perspective(PI/3.0,(float)width/height,1,100000);
  if(!mousePressed&&wmousePressed) {
    camRotX += addrx;
    camRotY += addry;
  }
  if(mousePressed) {
    addry = (tmouseX-mouseX)/300.0f;
    addrx = (tmouseY-mouseY)/200.0f;
    wmousePressed = true;
    cubeView.rotateX(camRotX+addrx);
    cubeView.rotateY(camRotY+addry);
  } else {
    tmouseX = mouseX;
    tmouseY = mouseY;
    cubeView.rotateX(camRotX);
    cubeView.rotateY(camRotY);
    wmousePressed = false;
  }
   if(keyPressed&&key=='1') {
     zoom = 50;
     cubeView.scale(zoom);
   }
   if(keyPressed&&key=='2') {
     zoom = 100;
     cubeView.scale(zoom);
   }
   if(keyPressed&&key=='3') {
     zoom = 150;
     cubeView.scale(zoom);
   }
   if(keyPressed&&key=='4') {
     zoom = 200;
     cubeView.scale(zoom);
   }
  ////////////////////////////////////
  cubeView.translate(-tet.x, -tet.y, -tet.z);
  doLines();
  cubeView.fill(100); stroke(0);
  cubeView.noStroke();
  cubeView.pushMatrix();
  cubeView.lights();
  cubeView.translate(0, 0, 0);
  drawGround();
  cubeView.popMatrix();
  cubeView.stroke(0, 200, 0);
  cubeView.strokeWeight(.02*50);//ADJUST STROKEWEIGHT
  cubeView.line(0, 0, 0, 0, 100, 0);
  cubeView.stroke(200, 0, 0);
  cubeView.line(0, 0, 0, 100, 0, 0);
  cubeView.stroke(0, 0, 200);
  cubeView.line(0, 0, 0, 0, 0, 100);
  cubeView.strokeWeight(.02*50);//ADJUST STROKEWEIGHT
  tet.update();
  cubeView.endDraw();
  
  framesPassed++;
  image(cubeView, 0, 0);
  textPack.beginDraw();
  textPack.background(0);
  textPack.stroke(255);
  textPack.noFill();
  textPack.strokeWeight(.04*50);//ADJUST STROKEWEIGHT 2
  textPack.rect(-2, -2, textPack.width, textPack.height);
  tet.printStatusReport2();
  textPack.endDraw();
  image(textPack, 0, 0);
}
public void doLines() {
  //println(framesPassed);
  cubeView.stroke(255);
  cubeView.strokeWeight(.02*50);//ADJUST STROKEWEIGHT
  if(!tet.inBox)
    dats.add(new vec3(tet.x, tet.y, tet.z));
  cubeView.beginShape(LINES);
  cubeView.colorMode(HSB);
  for(int i = max(1, dats.size()-1000); i < dats.size(); i++) {
    cubeView.stroke(float(i-dats.size()+1000)/1000f*255f, 255, 255);
    cubeView.vertex(dats.get(i).x, dats.get(i).y, dats.get(i).z);
    cubeView.vertex(dats.get(i-1).x, dats.get(i-1).y, dats.get(i-1).z);
  }
  cubeView.colorMode(RGB);
  cubeView.endShape();
  cubeView.strokeWeight(.02*50);//ADJUST STROKEWEIGHT
  if(framesPassed==0)
    dats.clear();
}
public void keyReleased() {
    println("bye");
    if(key=='k')
      tet.targetDir.z=-1.0;
    if(key=='l')
      tet.targetDir.x=1.0;
    if(key=='i')
      tet.targetDir.z=1.0/1;
    if(key=='j')
      tet.targetDir.x=-1.0/1;}
      
    void keyPressed() {
    println("hi");
    if(key=='k')
      tet.targetDir.z=1.0/1;
    if(key=='l')
      tet.targetDir.x=-1.0/1;
    if(key=='i')
      tet.targetDir.z=-1.0/1;
    if(key=='j')
      tet.targetDir.x=1.0/1;}
public void drawGround() {
  float s = 500;
  float h = 0f;
  cubeView.textureMode(NORMAL);
  cubeView.textureWrap(REPEAT);
  cubeView.beginShape();
  cubeView.texture(groundTex);
  cubeView.vertex(-s, h, -s, 0, 0);
  cubeView.vertex(-s, h, s, 0, 12.5*s/50);
  cubeView.vertex(s, h, s, 12.5*s/50, 12.5*s/50);
  cubeView.vertex(s, h, -s, 12.5*s/50, 0);
  cubeView.vertex(-s, h, -s, 0, 0);
  cubeView.endShape();
  int k = 10;
  cubeView.stroke(0);
  strokeWeight(.02*50);//ADJUST STROKEWEIGHT 1
  randomSeed(225); // WORLD SEED
  cubeView.lights();
  boolean inBox = false;
  cubeView.strokeWeight(.02*50);//ADJUST STROKEWEIGHT 2 //building lines
  vec3 tetPos = new vec3(tet.x, tet.y, tet.z);
  for(int x = -k; x < k; x++)
    for(int z = -k; z < k; z++) {
      cubeView.pushMatrix();
      int xPos = x*10+(int)random(-6, 6);
      int zPos = z*10+(int)random(-6, 6);
      cubeView.translate(xPos, 0, zPos);
      int yDim = (int)random(1, 30);
      cubeView.box(4, yDim*2, 4);
      cubeView.popMatrix();
      float bnd = 2.25;
      if((tetPos.x>xPos-bnd&&tetPos.x<xPos+bnd)&&(tetPos.z>zPos-bnd&&tetPos.z<zPos+bnd)&&(tetPos.y<yDim+.25))
        inBox = true;
    }
  cubeView.strokeWeight(.02*50);//ADJUST STROKEWEIGHT
  if(tet.inBox!=true)
    tet.setInBox(inBox);
}
/////////////////////////////////////////////MATRIX//////////////////////////////////////////////
public vec3 solveAxB3x3(vec3 a, float[][] b) {
  float[][] c = invert3x3(b);
  return vectorMul3x3(c, a);
}
public vec3 vectorMul3x3 (float[][] matrix, vec3 a) {
  vec3 b = new vec3();
  b.x = matrix[0][0]*a.x + matrix[0][1]*a.y + matrix[0][2]*a.z;
  b.y = matrix[1][0]*a.x + matrix[1][1]*a.y + matrix[1][2]*a.z;
  b.z = matrix[2][0]*a.x + matrix[2][1]*a.y + matrix[2][2]*a.z;
  return b;
}
public float[][] invert3x3(float[][] toInv) {
  float[][] output = new float[3][3];
  
  float a = toInv[0][0];
  float b = toInv[0][1];
  float c = toInv[0][2];
  
  float l = toInv[1][0];
  float m = toInv[1][1];
  float n = toInv[1][2];
  
  float q = toInv[2][0];
  float r = toInv[2][1];
  float s = toInv[2][2];
  
  output[0][0] = m*s-n*r; output[0][1] = c*r-b*s; output[0][2] = b*n-c*m;
  output[1][0] = n*q-l*s; output[1][1] = a*s-c*q; output[1][2] = c*l-a*n;
  output[2][0] = l*r-m*q; output[2][1] = b*q-a*r; output[2][2] = a*m-b*l;
  
  float determinantInverse = 1f/(a*m*s-a*n*r-b*l*s+b*n*q+c*l*r-c*m*q);
  
  for(int i = 0; i < 3; i++)
    for(int j = 0; j < 3; j++)
      output[i][j] *= determinantInverse;
  
  return output;
}
void print3x3(float[][] matrix) {
  println("\nPRINTINTG 3x3 MATRIX--");
  for(int i = 0; i < 3; i++) {
    println("\n");
    for(int j = 0; j < 3; j++)
      print(matrix[i][j] + "  ");
  }
}
public class vec3 {
  public float x;
  public float y;
  public float z;
  String name = "";
  public vec3() {}
  public vec3(float x, float y, float z) {
    this.x = x;
    this.y = y; 
    this.z = z;
  }
  public vec3(String name, float x, float y, float z) {
    this.name = name;
    this.x = x;
    this.y = y; 
    this.z = z;
  }
  public void print() {
    if(name == "")
      println("x " + x + " y " + y + " z " + z);
    else
      println("Vector " + name + ": x " + x + " y " + y + " z " + z);
  }
  public void displayCol() {
    vec3 temp = new vec3(x, y, z);
    temp.normalize();
    cubeView.stroke(temp.x*255, temp.y*255, temp.z*255);
    display();
  }
  public void displayCol(float s) {
    vec3 temp = new vec3(x, y, z);
    temp.normalize();
    cubeView.stroke(temp.x*255, temp.y*255, temp.z*255);
    display(s);
  }
  public void displayCol(float a, float b, float c) {
    vec3 temp = new vec3(x, y, z);
    temp.normalize();
    cubeView.stroke(temp.x*255, temp.y*255, temp.z*255);
    display(a, b, c);
  }
  public void displayCol(float a, float b, float c, float s) {
    vec3 temp = new vec3(x, y, z);
    temp.normalize();
    cubeView.stroke(temp.x*255, temp.y*255, temp.z*255);
    display(a, b, c, s);
  }
  public void display() {
    cubeView.line(0, 0, 0, x, y, z);
  }
  public void display(float s) {
    cubeView.line(0, 0, 0, x*s, y*s, z*s);
  }
  public void display(float a, float b, float c) {
    cubeView.line(a, b, c, x+a, y+b, z+c);
  }
  public void display(float a, float b, float c, float s) {
    cubeView.line(a, b, c, x*s+a, y*s+b, z*s+c);
  }
  public void normalize() {
    float d = 1f/sqrt(x*x+y*y+z*z);
    x = d*x;
    y = d*y;
    z = d*z;
  }
  public void add(vec3 a) {
    x += a.x;
    y += a.y;
    z += a.z;
  }
  public void add(vec3 a, float scalar) {
    x += a.x*scalar;
    y += a.y*scalar;
    z += a.z*scalar;
  }
  public float dot(vec3 a) {
    return x*a.x+y*a.y+z*a.z;
  }
  public void mul(float scalar) {
    x *= scalar;
    y *= scalar;
    z *= scalar;
  }
  public float mag() {
    return sqrt(x*x+y*y+z*z);
  }
  public float[] getArr() {
    float[] f = {x, y, z};
    return f;
  }
}
public vec3 rotateZ2(vec3 in, float a) {
  vec3 b = new vec3();
  b.x = in.x*cos(a)-in.y*sin(a);
  b.y = in.x*sin(a)+in.y*cos(a);
  b.z = in.z;
  return b;
}
public vec3 rotateY2(vec3 in, float a) {
  vec3 b = new vec3();
  b.x = in.x*cos(a)-in.z*sin(a);
  b.z = in.x*sin(a)+in.z*cos(a);
  b.y = in.y;
  return b;
}
public vec3 rotateX2(vec3 in, float a) {
  vec3 b = new vec3();
  b.y = in.y*cos(a)-in.z*sin(a);
  b.z = in.y*sin(a)+in.z*cos(a);
  b.x = in.x;
  return b;
}
public vec3 rollPitchYaw(vec3 v, float c, float b, float a) {
  float[][] matrix = {{cos(a)*cos(b), cos(a)*sin(b)*sin(c)-sin(a)*cos(c), cos(a)*sin(b)*cos(c)+sin(a)*sin(c)},
                      {sin(a)*cos(b), sin(a)*sin(b)*sin(c)+cos(a)*cos(c), sin(a)*sin(b)*cos(c)-cos(a)*sin(c)},
                      {-sin(b),       cos(b)*sin(c),                      cos(b)*cos(c)                     }};
  vec3 d = vectorMul3x3(matrix, v);
  return d;
}
