public class TetracopterR {
  float deltaT = 1.0f/200.0f;
  float x;
  float y;
  float z;
  vec3 d0 = new vec3(1, 1, 1);
  vec3 d1 = new vec3(1, -1, -1);
  vec3 d2 = new vec3(-1, 1, -1);
  vec3 d3 = new vec3(-1, -1, 1);
  boolean gravity = false;
  boolean groundCollision = true;
  boolean airResistance = true;
  boolean realTime = true;
  boolean rotationDrag = true;
  vec3 V = new vec3(0, 0, 0);
  vec3 A = new vec3(0, 0, 0);
  int stepsDone = 0;
  float easedMS = 0;
  vec3 angM = new vec3(0, 0, 0);
  public TetracopterR(float x, float y, float z) {
    this.x = x;
    this.y = y;
    this.z = z;
  }
  public void update(int ms) {
    
    if(realTime&&stepsDone>3) {
      easedMS += 0.1*(float(ms)-easedMS);
      deltaT = ms/1000.0f;
    } else {
      easedMS = ms;
    }
    if(stepsDone>20) {
      display();
      velocityUpdate();
    }
    stepsDone++;
  }
  
  void velocityUpdate() {
    A = new vec3(0, 0, 0);
    if(gravity) {
      A.add(new vec3(0.0f, -9.8f, 0));
    }
    V.add(A, deltaT);
    if(groundCollision&&y<0.035) {
        V = new vec3(V.x, abs(-V.y)/1.3f, V.z);
        V.x = V.x/1.1f;
        V.z = V.z/1.1f;
    }
    if(airResistance) {
      V.mul(1.0-0.2*deltaT);
    }
    doRotation();
    x += V.x*deltaT;
    y += V.y*deltaT;
    z += V.z*deltaT;
  }
  
  void doRotation() {
    vec3 toAdd = new vec3(0, 0, 0);
    toAdd.add(d0);
    toAdd.add(mul(d1, float(mouseX)/1600f).negate());
    toAdd.add(mul(d2, float(mouseX)/1600f).negate());
    toAdd.add(d3);
    toAdd.mul(0.004f);
    angM.add(toAdd);
    if(rotationDrag)
      angM.mul(0.995f);
    vec3 angDir = normalize(angM);
    
    //APPLY ANGULAR MOMENTUM VECTOR TO OBJECT//
    float w = 3;
    d0 = rAA(d0, angDir, angM.mag()/w);
    d1 = rAA(d1, angDir, angM.mag()/w);
    d2 = rAA(d2, angDir, angM.mag()/w);
    d3 = rAA(d3, angDir, angM.mag()/w);
    d0.normalize();
    d1.normalize();
    d2.normalize();
    d3.normalize();
  }
  
  void doRAll(vec3 a, float x) {
    d0 = rAA(d0, a, x);
    d1 = rAA(d1, a, x);
    d2 = rAA(d2, a, x);
    d3 = rAA(d3, a, x);
  }
  
  void display() {
    cubeView.stroke(255);
    cubeView.pushMatrix();
    cubeView.translate(x, y, z);
    cubeView.stroke(255);
    d0.display(0.25f);
    cubeView.stroke(255, 0, 0);
    d1.display(0.25f);
    cubeView.stroke(0, 255, 0);
    d2.display(0.25f);
    cubeView.stroke(0, 0, 255);
    d3.display(0.25f);
    cubeView.strokeWeight(0.01*1);
    cubeView.stroke(255, 255, 0);
    angM.display(0.15f);
    cubeView.stroke(0);
    cubeView.sphereDetail(15);
    cubeView.fill(208/2, 229/2, 19/2);
    cubeView.sphere(0.035f);
    
    cubeView.popMatrix();
  }
  
  void setInBox(boolean b) {}
  void printStatusReport() {}
  void printStatusReport2() {}
  boolean inBox;
}
