public class TetracopterX {
  float x;
  float y;
  float z;
  float xv;
  float yv;
  float zv;
  float roll;
  float pitch;
  float yaw;
  float roll2;
  float pitch2;
  float yaw2;
  float brakeVx;
  float brakeVz;
  vec3 pAlpha = new vec3(1, 1, 1);
  vec3 pBeta = new vec3(1, -1, -1);
  vec3 pGamma = new vec3(-1, 1, -1);
  vec3 pDelta = new vec3(-1, -1, 1);
  vec3 p0 = new vec3();
  vec3 p1 = new vec3();
  vec3 p2 = new vec3();
  vec3 p3 = new vec3();
  Motor m0 = new Motor();
  Motor m1 = new Motor();
  Motor m2 = new Motor();
  Motor m3 = new Motor();
  vec3 targetDir = new vec3();
  vec3 motorWeights = new vec3();
  int[] motorsInUse = new int[3];
  String[] codenames = {"Alpha", "Beta ", "Gamma", "Delta"};
  float efficiency;
  float cThrust = 0.6;
  vec3 linA;
  vec3 linB;
  vec3 linC;
  vec3 weightSum;
  float tDy;
  boolean inBox;
  boolean redLight;
  public TetracopterX(float x, float y, float z) {
    this.x = x;
    this.y = y;
    this.z = z;
    m0.rotorV = 50;
    m2.rotorV = 50;
  }
  public void update() {
    if(!inBox) {
      getControls();
      applyRotations();
      normalize();
      physics();
      movement();
      if(!inBox) {
        //printStatusReport();
        drawSpeeds();
        drawCube();
        display();
      }
    } else
      drawSplosion();
  }
  boolean L = false;
  boolean keyR = false;
  void draw() {}
  
      
  public void getControls() {
    float eas = 1.0f;
    if(mousePressed&&mouseButton==RIGHT)
      eas = 0.2f;
    if(!keyPressed) {
      targetDir = new vec3(0, 1, 0);}
  
    
    

    
    
    if(keyPressed&&key=='q')
      roll2+=0.01;
    if(keyPressed&&key=='w')
      pitch2+=0.01;
    if(keyPressed&&key=='e')
      yaw2+=0.01;
    if(keyPressed&&key=='a')
      roll2-=0.01;
    if(keyPressed&&key=='s')
      pitch2-=0.01;
    if(keyPressed&&key=='d')
      yaw2-=0.01;
    
    if(keyPressed&&key==' ')
      tDy = 1.5;
    if(keyPressed&&keyCode==SHIFT)
      tDy = 0.5;
    if(!keyPressed) {
      tDy = 1.0;
      cThrust = 1.2;
    }
    
    if(keyPressed&&key=='z')
      cThrust = 0.12;
    if(keyPressed&&key=='c')
      cThrust = 0.0;
    if(keyPressed&&key=='x') {
      roll = 0.0;
      pitch = 0.0;
      yaw = 0.0;
    }
  }
  public void setInBox(boolean a) {
    inBox = a;
  }
  public void movement() {
    randomSeed(millis());
    float timeStep = 0.001;
    float[] powerVals = new float[4];
    powerVals[motorsInUse[0]] = motorWeights.x;
    powerVals[motorsInUse[1]] = motorWeights.y;
    powerVals[motorsInUse[2]] = motorWeights.z;
    m0.update(powerVals[0]*cThrust);
    m1.update(powerVals[1]*cThrust);
    m2.update(powerVals[2]*cThrust);
    m3.update(powerVals[3]*cThrust);
    xv += (m0.rotorV*p0.x + m1.rotorV*p1.x + m2.rotorV*p2.x + m3.rotorV*p3.x)/10.0f;
    yv += (m0.rotorV*p0.y + m1.rotorV*p1.y + m2.rotorV*p2.y + m3.rotorV*p3.y)/10.0f;
    zv += (m0.rotorV*p0.z + m1.rotorV*p1.z + m2.rotorV*p2.z + m3.rotorV*p3.z)/10.0f;
    if(y>0.25f)
      yv -= 6;
    if(y<0.25f) {
      //if(sqrt(xv*xv+yv*yv+zv*zv)>500)
      //  inBox = true;
      yv = -yv; //BOUNCE FACTOR!!!!!!!!!!!!!!!!!!!!!!!!
      y = 0.26f;
      if(sqrt(xv*xv+yv*yv+zv*zv)>50.2) {
        roll2 += random(-0.3, 0.3);
        pitch2 += random(-0.3, 0.3);
        yaw2 += random(-0.3, 0.3);
      }
    }
    xv /= 1.01; //Air
    yv /= 1.01;
    zv /= 1.01;
    x += xv*timeStep;
    y += yv*timeStep;
    z += zv*timeStep;
    vec3 realVel = new vec3((m0.rotorV*p0.x + m1.rotorV*p1.x + m2.rotorV*p2.x + m3.rotorV*p3.x)/60.0f, 
                            (m0.rotorV*p0.y + m1.rotorV*p1.y + m2.rotorV*p2.y + m3.rotorV*p3.y)/60.0f,
                            (m0.rotorV*p0.z + m1.rotorV*p1.z + m2.rotorV*p2.z + m3.rotorV*p3.z)/60.0f);
    strokeWeight(.04);//ADJUST STROKEWEIGHT 2
    realVel.displayCol(x, y, z);
    strokeWeight(.02);//ADJUST STROKEWEIGHT
  }
  float signum(float in) {
    int a = 0;
    if(in<0)
      a = -1;
    if(in>0)
      a = 1;
    return a;
  }
  public void physics() {
    targetDir.y = tDy;
    
    /////STABILIZER/////
   
    if((keyPressed&&key=='b')||!keyPressed) {
      targetDir.x = 4*min(3.0, (signum(-xv)*max(0.0, abs(xv)-299.5f*(abs(xv)/300)))/6.0);
      targetDir.z = 4*min(3.0, (signum(-zv)*max(0.0, abs(zv)-299.5f*(abs(zv)/300)))/6.0);
      targetDir.normalize();
      targetDir.mul(4.0f);
      targetDir.y = tDy;
    } else {
      brakeVx = xv;
      brakeVz = zv;
    }
   
    /////End STABILIZER/////
    
    vec3[] a = {p0, p1, p2, p3};
    int k = 0;
    float min = 1000.0;
    for(int i = 0; i < 4; i++)
      if(a[i].dot(targetDir)<min) {
        k = i;
        min = a[i].dot(targetDir);
      }
    ArrayList vals = new ArrayList<vec3>();
    ArrayList w = new ArrayList<Integer>();
    if(k!=0){ vals.add(p0); w.add(0);}
    if(k!=1){ vals.add(p1); w.add(1);}
    if(k!=2){ vals.add(p2); w.add(2);}
    if(k!=3){ vals.add(p3); w.add(3);}
    float[][] directions = {{((vec3)vals.get(0)).x, ((vec3)vals.get(1)).x, ((vec3)vals.get(2)).x},
                            {((vec3)vals.get(0)).y, ((vec3)vals.get(1)).y, ((vec3)vals.get(2)).y},
                            {((vec3)vals.get(0)).z, ((vec3)vals.get(1)).z, ((vec3)vals.get(2)).z}};
    motorWeights = solveAxB3x3(targetDir, directions);
    motorsInUse[0] = (Integer)w.get(0); motorsInUse[1] = (Integer)w.get(1); motorsInUse[2] = (Integer)w.get(2);
    cubeView.strokeWeight(.12); //ADJUST STROKEWEIGHT 6
    motorWeights.x = max(0.0, motorWeights.x);
    motorWeights.y = max(0.0, motorWeights.y);
    linA = ((vec3)vals.get(0));
    linB = ((vec3)vals.get(1));
    linC = ((vec3)vals.get(2));
    vec3 sum = new vec3(0, 0, 0);
    sum.add((vec3)vals.get(0), motorWeights.x);
    sum.add((vec3)vals.get(1), motorWeights.y);
    sum.add((vec3)vals.get(2), motorWeights.z);
    weightSum = sum;
    efficiency = ((motorWeights.x + motorWeights.y + motorWeights.z)-1f)/2f/targetDir.mag();
    cubeView.strokeWeight(.02);//ADJUST STROKEWEIGHT
  }
  public void display() {
    cubeView.strokeWeight(.02);//ADJUST STROKEWEIGHT
    p0.displayCol(1);
    p1.displayCol(1);
    p2.displayCol(1);
    p3.displayCol(1);
    cubeView.strokeWeight(.02);//ADJUST STROKEWEIGHT
  }
  public void normalize() {
    p0.normalize();
    p1.normalize();
    p2.normalize();
    p3.normalize();
  }
  public void applyRotations() {
    p0 = rollPitchYaw(pAlpha, roll2, yaw2, pitch2);
    p1 = rollPitchYaw(pBeta,  roll2, yaw2, pitch2);
    p2 = rollPitchYaw(pGamma, roll2, yaw2, pitch2);
    p3 = rollPitchYaw(pDelta, roll2, yaw2, pitch2);
  }
  public void drawSplosion() {
    cubeView.hint(DISABLE_DEPTH_TEST);
    cubeView.translate(x, y, z);
    cubeView.noStroke();
    for(int i = 0; i < 150; i++) {
      float f = random(255*2);
      cubeView.fill(255, f, f-255, 30);
      cubeView.rotateX(random(100));
      cubeView.rotateY(random(100));
      cubeView.rotateZ(random(100));
      float sz = random(1);
      cubeView.rect(-sz, -sz, sz, sz);
    }
    cubeView.hint(ENABLE_DEPTH_TEST);
  }
  /*public void printStatusReport() {
    println("\n\n\n\n\nRoll: " + (roll2%TWO_PI)/TWO_PI*360 + " Pitch: " + (pitch2%TWO_PI)/TWO_PI*360 + " Yaw: " + (yaw2%TWO_PI)/TWO_PI*360);
    println("Motors In Use: " + codenames[motorsInUse[0]] + " " + codenames[motorsInUse[1]] + " " + codenames[motorsInUse[2]]);
    println("               " + float(int(motorWeights.x*1000))/1000 + " " + float(int(motorWeights.y*1000))/1000 + " " + float(int(motorWeights.z*1000))/1000);
    println("Efficiency " + (int)((1.0-efficiency)*100) + "%");
    println("Current maximum motor work: " + max(max(motorWeights.x, motorWeights.y), motorWeights.z));
    println("Control Thrust: " + cThrust);
    println("Motor Speeds: " + round(m0.rotorV, 4) + " " + round(m1.rotorV, 4) + " " + round(m2.rotorV, 4) + " " + round(m3.rotorV, 4));
  }*/
  public void printStatusReport2() {
    textPack.fill(0, 255, 0);
    textPack.text("\n\n\n\n\nRoll: " + (roll2%TWO_PI)/TWO_PI*360 + " Pitch: " + (pitch2%TWO_PI)/TWO_PI*360 + key+" Yaw: " + (yaw2%TWO_PI)/TWO_PI*360, 10, -50);
    textPack.text("Motors In Use: " + codenames[motorsInUse[0]] + " " + codenames[motorsInUse[1]] + " " + codenames[motorsInUse[2]], 10, 40);
    textPack.text("                           " + float(int(motorWeights.x*1000))/1000 + " " + float(int(motorWeights.y*1000))/1000 + " " + float(int(motorWeights.z*1000))/1000, 10, 60);
    textPack.text("Efficiency " + (int)((1.0-efficiency)*100) + "%", 10, 80);
    textPack.text("Current maximum motor work: " + max(max(motorWeights.x, motorWeights.y), motorWeights.z), 10, 100);
    textPack.text("Control Thrust: " + cThrust, 10, 120);
    textPack.text("Motor Speeds: " + round(m0.rotorV, 4) + " " + round(m1.rotorV, 4) + " " + round(m2.rotorV, 4) + " " + round(m3.rotorV, 4), 10, 160);
    textPack.text("Power Used: " + (motorWeights.x+motorWeights.y+motorWeights.z)*cThrust, 10, 140);
    textPack.text("X: " + round(x, 3), 10, 180); textPack.text(" Y: " + round(y, 3), 70, 180); textPack.text(" Z: " + round(z, 3), 133, 180);
    textPack.text("Xv: " + round(xv, 3), 10, 200); textPack.text(" Yv: " + round(yv, 2), 70, 200); textPack.text(" Zv: " + round(zv, 3), 133, 200);
    textPack.fill(255, 0, 0);
    if(redLight) textPack.rect(260, 5, 30, 30);
    textPack.fill(255);
  }
  public void drawCube() {
    cubeView.strokeWeight(.02);//ADJUST STROKEWEIGHT
    cubeView.stroke(255);
    cubeView.noFill();
    cubeView.lights();
    cubeView.pushMatrix();
    cubeView.rotateZ(pitch2);
    cubeView.rotateY(yaw2);
    cubeView.rotateX(roll2);
    cubeView.box(0.5, 0.5, 0.5);
    cubeView.popMatrix();
    cubeView.noLights();
  }
  public void drawSpeeds() {
    cubeView.lights();
    float k = 300;
    cubeView.strokeWeight(.005);//ADJUST STROKEWEIGHT
    cubeView.stroke(0);
    cubeView.sphereDetail(15);
    p0.normalize();
    p1.normalize();
    p2.normalize();
    p3.normalize();
    cubeView.fill(100);
    //cubeView.noStroke();
    cubeView.translate(x, y, z);
    cubeView.sphere(0.15);
    cubeView.pushMatrix();
    cubeView.translate(p0.x, p0.y, p0.z);
    cubeView.sphere(m0.rotorV/k);
    cubeView.popMatrix();
    
    cubeView.pushMatrix();
    cubeView.translate(p1.x, p1.y, p1.z);
    cubeView.sphere(m1.rotorV/k);
    cubeView.popMatrix();
    
    cubeView.pushMatrix();
    cubeView.translate(p2.x, p2.y, p2.z);
    cubeView.sphere(m2.rotorV/k);
    cubeView.popMatrix();
    
    cubeView.pushMatrix();
    cubeView.translate(p3.x, p3.y, p3.z);
    cubeView.sphere(m3.rotorV/k);
    cubeView.popMatrix();
    cubeView.noLights();
    
    cubeView.strokeWeight(.10);//ADJUST STROKEWEIGHT 5
    linA.displayCol(motorWeights.x*1);
    linB.displayCol(motorWeights.y*1);
    linC.displayCol(motorWeights.z*1);
    cubeView.strokeWeight(.02);//ADJUST STROKEWEIGHT
    weightSum.displayCol();
  }
}
class Motor {
  float rotorV = 0.0f;
  float rotorR = 1.02f;
  boolean burnout;
  public Motor() {}
  public void update(float current) {
    if(burnout==false)
      rotorV += current;
    rotorV /= rotorR;
    if(rotorV>350)
      burnout = true;
    if(rotorV<0)
      rotorV = 0;
  }
}
float round(float a, int b) {
  return float(int(a*pow(10, b)))/pow(10, b);
}
