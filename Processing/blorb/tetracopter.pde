public class Tetracopter {
  float x;
  float y;
  float z;
  float roll;
  float pitch;
  float yaw;
  boolean inBox;
  vec3 pAlpha = new vec3(1, 1, 1);
  vec3 pBeta = new vec3(1, -1, -1);
  vec3 pGamma = new vec3(-1, 1, -1);
  vec3 pDelta = new vec3(-1, -1, 1);
  vec3 p0 = new vec3();
  vec3 p1 = new vec3();
  vec3 p2 = new vec3();
  vec3 p3 = new vec3();
  vec3 targetDir = new vec3();
  vec3 motorWeights = new vec3();
  int[] motorsInUse = new int[3];
  String[] codenames = {"Alpha", "Beta ", "Gamma", "Delta"};
  float efficiency;
  public Tetracopter(float x, float y, float z) {
    this.x = x;
    this.y = y;
    this.z = z;
  }
  public void update() {
    if(keyPressed&&key=='i')
      roll+=0.01;
    if(keyPressed&&key=='o')
      pitch+=0.01;
    if(keyPressed&&key=='p')
      yaw+=0.01;
    applyRotations();
    normalize();
    drawCube();
    cubeView.hint(DISABLE_DEPTH_TEST);
    display();
    physics();
    cubeView.hint(ENABLE_DEPTH_TEST);
    printStatusReport();
  }
  public void physics() {
    targetDir = new vec3(0, 1, 0);
    targetDir.normalize();
    
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
    cubeView.strokeWeight(6);
    motorWeights.x = max(0.0, motorWeights.x);
    motorWeights.y = max(0.0, motorWeights.y);
    ((vec3)vals.get(0)).displayCol(x, y, z, motorWeights.x);
    ((vec3)vals.get(1)).displayCol(x, y, z, motorWeights.y);
    ((vec3)vals.get(2)).displayCol(x, y, z, motorWeights.z);
    vec3 sum = new vec3(0, 0, 0);
    sum.add((vec3)vals.get(0), motorWeights.x);
    sum.add((vec3)vals.get(1), motorWeights.y);
    sum.add((vec3)vals.get(2), motorWeights.z);
    sum.displayCol(x, y, z, 1);
    efficiency = ((motorWeights.x + motorWeights.y + motorWeights.z)-1f)/2f/targetDir.mag();
    cubeView.strokeWeight(1);
  }
  public void setInBox(boolean b){}
  public void printStatusReport2(){}
  public void display() {
    cubeView.strokeWeight(1);
    p0.displayCol(x, y, z, 1);
    p1.displayCol(x, y, z, 1);
    p2.displayCol(x, y, z, 1);
    p3.displayCol(x, y, z, 1);
    cubeView.strokeWeight(1);
  }
  public void normalize() {
    p0.normalize();
    p1.normalize();
    p2.normalize();
    p3.normalize();
  }
  public void applyRotations() {
    p0 = rollPitchYaw(pAlpha, roll, yaw, pitch);
    p1 = rollPitchYaw(pBeta,  roll, yaw, pitch);
    p2 = rollPitchYaw(pGamma, roll, yaw, pitch);
    p3 = rollPitchYaw(pDelta, roll, yaw, pitch);
  }
  public void printStatusReport() {
    println("\n\n\n\n\nRoll: " + (roll%TWO_PI)/TWO_PI*360 + " Pitch: " + (pitch%TWO_PI)/TWO_PI*360 + " Yaw: " + (yaw%TWO_PI)/TWO_PI*360);
    println("Motors In Use: " + codenames[motorsInUse[0]] + " " + codenames[motorsInUse[1]] + " " + codenames[motorsInUse[2]]);
    println("               " + float(int(motorWeights.x*1000))/1000 + " " + float(int(motorWeights.y*1000))/1000 + " " + float(int(motorWeights.z*1000))/1000);
    println("Efficiency " + (int)((1.0-efficiency)*100) + "%");
    println("Current maximum motor work: " + max(max(motorWeights.x, motorWeights.y), motorWeights.z));
  }
  public void drawCube() {
    cubeView.strokeWeight(1);
    cubeView.stroke(0);
    cubeView.lights();
    cubeView.pushMatrix();
    cubeView.translate(x, y, z);
    cubeView.rotateZ(pitch);
    cubeView.rotateY(yaw);
    cubeView.rotateX(roll);
    cubeView.box(0.5, 0.5, 0.5);
    cubeView.popMatrix();
    cubeView.noLights();
  }
}
