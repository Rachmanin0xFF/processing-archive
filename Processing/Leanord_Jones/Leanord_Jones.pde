
ArrayList<Par> pars = new ArrayList<Par>();

void setup() {
  size(512, 512, P2D);
  for(int i = 0; i < 100; i++) {
    pars.add(new Par((i*40)%width, ((int)(i*40/width))*40, 10.0));
  }
  strokeWeight(3);
  background(0);
  stroke(255);
}

void draw() {
  background(0);
  for(int i = 0; i < pars.size(); i++) {
    for(int j = 0; j < pars.size(); j++) {
      if(i != j) {
        pars.get(i).force_to(pars.get(j));
      }
    }
  }
  for(int i = 0; i < pars.size(); i++) {
    pars.get(i).update();
    point(pars.get(i).r.x, pars.get(i).r.y);
  }
}
void mousePressed() {
  //pars.add(new Par(mouseX, mouseY, 0.0));
  sigma*=1.05;
}
float sigma = 50.0;
float epsilon = 50.0;

float dt = 0.0001;


class Par {
  PVector r;
  PVector v;
  public Par(float x, float y, float mag) {
    r = new PVector(x, y);
    float theta = random(TWO_PI);
    v = new PVector(mag*cos(theta), mag*sin(theta));
  }
  
  public void update() {
    r.add(PVector.mult(v, dt));
    v.mult(0.999);
    
    if(r.x < 0) {
      r.x = 0; v.x = 0;
    }
    if(r.x > width) {
      r.x = width; v.x = 0;
    }
    if(r.y < 0) {
      r.y = 0; v.y = 0;
    }
    if(r.y > height) {
      r.y = height; v.y = 0;
    }
    
  }
  
  public void force_to(Par p2) {
    PVector dst = PVector.sub(p2.r, r);
    float rad = dst.mag();
    float force = 48*epsilon*(pow(sigma, 12)/pow(rad, 13) - 24*epsilon*pow(sigma, 6)/pow(rad, 7));
    dst.mult(dt*force/rad);
    v.add(dst);
  }
}
