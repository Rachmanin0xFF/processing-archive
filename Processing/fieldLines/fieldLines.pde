ArrayList<Charge> pointCharges = new ArrayList<Charge>();
void setup() {
  size(1024, 1024, P2D);
  smooth(8);
  stroke(0);
  background(255);
  fill(255);
}
void draw() {
  doLEeen();
  for(Charge c : pointCharges)
    c.display();
}
void keyPressed() {
  ArrayList<Charge> pointCharges = new ArrayList<Charge>();
}
void mousePressed() {
  background(255);
  int isdelet = -1;
  for(int i = 0; i < pointCharges.size(); i++) {
    if(dist(mouseX, mouseY, pointCharges.get(i).position.x, pointCharges.get(i).position.y) < 15)
      isdelet = i;
  }
  if(isdelet != -1) {
    pointCharges.remove(isdelet);
  } else {
    if(mouseButton == LEFT)
      pointCharges.add(new Charge(mouseX, mouseY, 1.f));
    else
      pointCharges.add(new Charge(mouseX, mouseY, -1.f));
  }
  doLEeen();
}
class Charge {
  PVector position;
  float q = 1.f;
  public Charge(float x, float y) {
    position = new PVector(x, y);
  }
  public Charge(PVector p) {
    position = new PVector(p.x, p.y);
  }
  public Charge(float x, float y, float q) {
    position = new PVector(x, y);
    this.q = q;
  }
  public Charge(PVector p, float q) {
    position = new PVector(p.x, p.y);
    this.q = q;
  }
  public void display() {
    //displayFieldLines();
    
    ellipse(position.x, position.y, 20, 20);
    line(position.x-7, position.y, position.x+7, position.y);
    if(q > 0) line(position.x, position.y-7, position.x, position.y+7);
    
  }
  public void displayFieldLines() {
    for(float theta = 0.f; theta < TWO_PI; theta += TWO_PI/50.f) {
      float uQ = -q;
      PVector uPosition = new PVector(position.x + cos(theta)*100f, position.y + sin(theta)*100f);
      PVector previousUPosition = new PVector(position.x, position.y);
      for(int i = 0; i < 1000; i++) {
        PVector uDelta = new PVector();
        for(Charge c : pointCharges) {
          PVector dir = PVector.sub(c.position, uPosition);
          float r = dir.mag();
          dir.normalize();
          dir.mult(1000.f/(r*r));
          dir.mult(c.q*uQ);
          uDelta.add(dir);
        }
        uPosition.add(uDelta);
        
        
        strokeWeight(1);
        //line(uPosition.x, uPosition.y, previousUPosition.x, previousUPosition.y);
        //strokeWeight(2);
        point(uPosition.x, uPosition.y);
        previousUPosition = new PVector(uPosition.x, uPosition.y);
      }
      strokeWeight(1);
    }
  }
}

public void doLEeen() {
  for(float x = 0.f; x < width; x += 20.f) {
    for(float y = 0.f; y < height; y += 20.f) {
      for(int j = -1; j <= 1; j += 2) {
        float uQ = j + random(-0.1f, 0.1f);
        
        PVector uPosition = new PVector(x, y);
        PVector previousUPosition = new PVector(uPosition.x, uPosition.y);
        for(int i = 0; i < 20; i++) {
          PVector uDelta = new PVector();
          for(Charge c : pointCharges) {
            PVector dir = PVector.sub(c.position, uPosition);
            float r = dir.mag();
            dir.normalize();
            dir.mult(20000.f/(r*r));
            dir.mult(c.q*uQ);
            uDelta.add(dir);
          }
          uPosition.add(uDelta);
          
          
          strokeWeight(1);
          //line(uPosition.x, uPosition.y, previousUPosition.x, previousUPosition.y);
          //strokeWeight(2);
          point(uPosition.x, uPosition.y);
          previousUPosition = new PVector(uPosition.x, uPosition.y);
        }
        strokeWeight(1);
      }
    }
  }
}
public void doLEeen2() {
  for(float y = 0; y < 100; y++) {
    for(int j = -1; j <= 1; j += 2) {
      float uQ = j + random(-0.1f, 0.1f);
      
      PVector uPosition = new PVector(random(width), random(height));
      PVector previousUPosition = new PVector(uPosition.x, uPosition.y);
      for(int i = 0; i < 20; i++) {
        PVector uDelta = new PVector();
        for(Charge c : pointCharges) {
          PVector dir = PVector.sub(c.position, uPosition);
          float r = dir.mag();
          dir.normalize();
          dir.mult(20000.f/(r*r));
          dir.mult(c.q*uQ);
          uDelta.add(dir);
        }
        uPosition.add(uDelta);
        
        
        strokeWeight(1);
        //line(uPosition.x, uPosition.y, previousUPosition.x, previousUPosition.y);
        //strokeWeight(2);
        point(uPosition.x, uPosition.y);
        previousUPosition = new PVector(uPosition.x, uPosition.y);
      }
      strokeWeight(1);
    }
  }
}
