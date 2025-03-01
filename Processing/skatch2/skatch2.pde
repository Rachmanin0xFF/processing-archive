void setup() {
  size(1600, 900, P3D);
  background(255);
  smooth(8);
  frameRate(10000000);
}

boolean drawning = true;

float s = 500;
float iter = 1000;
void draw() {
  if(drawning) {
    //stroke(0, 0, 0, 50);
    noStroke();
    PVector col = mix(sin(iter/200.f), new PVector(255, 255, 255), new PVector(0, 0, 0));
    //fill(col.x, col.y, col.z, 255);
    float li = 2.f;
    lights();
    translate(width/2, height/2);
    rotateX(iter/1000.f);
    rotateY(iter/1000.f);
    rotateZ(iter/1000.f);
    
    box(s, s, s);
    //scale(3);
    //sphereDetail(3); sphere(s);
    s *= 0.999f;
    iter++;
    if(s <= 1.f) { saveFrame("output.png"); drawning = false; }
  }
}
