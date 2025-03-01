void setup() {
  size(4000, 4000*9/16, P3D);
  background(255);
  smooth(8);
  frameRate(10000000);
  directionalLight(255, 0, 0, 0, 0.1f, -1);
  directionalLight(0, 255, 0, 0, 0, -1);
  directionalLight(0, 0, 255, 0, -0.1f, -1);
}

boolean drawning = true;

float s = 500;
float iter = 1000;
void draw() {
  if(drawning) {
    stroke(0, 0, 0, 50);
    //noStroke();
    PVector col = mix(sin(iter/200.f), new PVector(255, 255, 255), new PVector(0, 0, 0));
    //fill(col.x, col.y, col.z, 255);
    translate(width/2, height/2);
    rotateX(iter/1000.f);
    rotateY(iter/1000.f);
    rotateZ(iter/1000.f);
    
    //box(s, s, s);
    scale(3);
    sphereDetail(3); sphere(s);
    s *= 0.999f;
    iter++;
    if(s <= 1.f) drawning = false;
  }
}

void keyPressed() {
  saveFrame("output.png");
}
