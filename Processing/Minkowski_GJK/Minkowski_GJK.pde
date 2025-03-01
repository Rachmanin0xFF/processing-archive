
ArrayList<PVector> A = new ArrayList<PVector>();
ArrayList<PVector> B = new ArrayList<PVector>();
ArrayList<PVector> C = new ArrayList<PVector>();

void setup() {
  size(1280, 720, P2D);
  stroke(255);
  background(0);
  noSmooth();
  strokeCap(SQUARE);
  blendMode(ADD);
  frameRate(1000);
}

void draw() {
  background(0);
  
  stroke(255, 100);
  line(0, height/2, width, height/2);
  line(width/2, 0, width/2, height);
  
  getKeyMoveInput();
  //C = minkowskiDiff(A, B);
  stroke(255);
  noFill();
  rect(8, 8, 24, 24);
  if(A.size() > 2 && B.size() > 2) {
    boolean b = GJK(A, B);
    fill(255, 255);
    if(b) rect(10, 10, 20, 20);
  }
  fill(255, 255, 255, 255);
  text("Frame Rate: " + frameRate, 10, 55);
  text("Iterations: " + dfkdsa1259012800o6543, 10, 70);
  drawPolygons();
}

//For visual purposes
public ArrayList<PVector> minkowskiSum(ArrayList<PVector> x, ArrayList<PVector> y) {
  ArrayList<PVector> z = new ArrayList<PVector>();
  for(PVector p : x) {
    for(PVector q : y) {
      z.add(PVector.add(p, q));
    }
  }
  return z;
}
public ArrayList<PVector> minkowskiDiff(ArrayList<PVector> x, ArrayList<PVector> y) {
  ArrayList<PVector> z = new ArrayList<PVector>();
  for(PVector p : x) {
    for(PVector q : y) {
      z.add(PVector.sub(p, q));
    }
  }
  return z;
}

int dfkdsa1259012800o6543 = 0;

//   _______      ___  ___   _  _______  ______  
//  |       |    |   ||   | | ||       ||      | 
//  |    ___|    |   ||   |_| ||____   ||  _    |
//  |   | __     |   ||      _| ____|  || | |   |
//  |   ||  | ___|   ||     |_ | ______|| |_|   |
//  |   |_| ||       ||    _  || |_____ |       |
//  |_______||_______||___| |_||_______||______| 

//@author Adam Lastowka

//----------------------------------------------------------------------------------//

/**
Given two 2D convex polygons in the form of a rotation-ordered arraylist of PVectors, GJK will return a boolean that is set to true if the two polygons intersect.
@param x The first polygon
@param y The second polygon
*/
public boolean GJK(ArrayList<PVector> x, ArrayList<PVector> y) {
  int i = 0;
  Triangle simplex = new Triangle();
  //Start things up with simplex vertices at the far left and right
  PVector d = new PVector(1.f, 0.f);
  simplex.addPoint(support(x, y, d));
  d.mult(-1.f);
  while(true) {
    //Pick our new vertex
    simplex.addPoint(support(x, y, d));
    
    //-------------------------------------//
    //program-specific (remove for other uses)
    //Drawing stuff (not working for some mysterious reason)
    dfkdsa1259012800o6543 = i;
    simplex.display();
    //-------------------------------------//
    
    //If the point added last was not past the origin in the direction of d then there is no way that the Minkowski sum contains the origin
    if(simplex.last.dot(d) <= 0.f) return false;
    if(simplex.containsOrigin()) return true;
    //Let the simplex pick out its normal vector which faces the origin.
    d = simplex.chooseDirection();
    if(i > 100) break; //We've gone too far.
    i++;
  }
  return false;
}

public PVector support(ArrayList<PVector> x, ArrayList<PVector> y, PVector d) {
  PVector p1 = x.get(farthestInDirection(x, d));
  PVector p2 = y.get(farthestInDirection(y, PVector.mult(d, -1.f)));
  return PVector.sub(p1, p2);
}

int farthestInDirection(ArrayList<PVector> x, PVector d) {
  int index = -1;
  float top = -Float.MAX_VALUE;
  for(int i = 0; i < x.size(); i++) {
    float r = x.get(i).dot(d);
    if(r > top) {
      top = r;
      index = i;
    }
  }
  return index;
}

//Note-- This is the vector triple product, the cross product one (optimized)
public PVector tripleProduct(PVector x, PVector y, PVector z) {
  return PVector.sub(PVector.mult(y, PVector.dot(z, x)), PVector.mult(x, PVector.dot(z, y)));
}

//Used for holding simplex
public class Triangle {
  ArrayList<PVector> points = new ArrayList<PVector>();
  PVector last = new PVector();
  public Triangle() {}
  public void addPoint(PVector p) {
    points.add(p);
    last = new PVector(p.x, p.y);
    if(points.size() == 4)
      points.remove(0);
  }
  public boolean containsOrigin() {
    //Taken from some forum thread, supposedly runs fast.
    if(points.size() != 3) return false;
    boolean b1 = false, b2 = false, b3 = false;
    PVector p1 = points.get(0);
    PVector p2 = points.get(1);
    PVector p3 = points.get(2);
    b1 = -p2.x*(p1.y - p2.y) - (p1.x - p2.x)*-p2.y < 0.f;
    b2 = -p3.x*(p2.y - p3.y) - (p2.x - p3.x)*-p3.y < 0.f;
    b3 = -p1.x*(p3.y - p1.y) - (p3.x - p1.x)*-p1.y < 0.f;
    return (b1==b2)&&(b2==b3);
  }
  public PVector chooseDirection() {
    PVector d = new PVector();
    if(points.size() == 2) {
      d = new PVector(points.get(1).y-points.get(0).y, points.get(0).x-points.get(1).x);
      if(PVector.dot(d, points.get(0)) >= 0.f) d.mult(-1.f);
    }
    if(points.size() == 3) {
      PVector ab = PVector.sub(points.get(1), points.get(0));
      PVector ac = PVector.sub(points.get(2), points.get(0));
      //Magical triple product calculates normals
      PVector abp = tripleProduct(ac, ab, ab);
      if(abp.dot(points.get(0)) <= 0.f) {
        //If AB's normals points to the origin, get rid of the old C.
        points.remove(2);
        //Set our new direction to the normal if it worked.
        d = abp;
      } else {
        //Same for AC and BC.
        PVector acp = tripleProduct(ab, ac, ac);
        if(acp.dot(points.get(0)) <= 0.f) {
          points.remove(1);
          d = acp;
        } else {
          //Triple products are wonky
          PVector bc = PVector.sub(points.get(1), points.get(2));
          PVector bcp = PVector.mult(tripleProduct(ab, bc, bc), -1.f);
          points.remove(0);
          d = bcp;
        }
      }
    }
    return d;
  }
  public void display() {
    pushMatrix();
    translate(width/2, height/2);
    strokeWeight(1);
    beginShape();
    for(PVector p : points) {
      vertex(p.x, p.y);
    }
    endShape(CLOSE);
    popMatrix();
  }
}

//----------------------------------------------------------------------------------//
  
void keyPressed() {
  if(key == 'c') {
    A = new ArrayList<PVector>();
    B = new ArrayList<PVector>();
    C = new ArrayList<PVector>();
  }
}

void mousePressed() {
  if(mouseButton == LEFT)
    A.add(new PVector(mouseX - width/2, mouseY - height/2));
  else
    B.add(new PVector(mouseX - width/2, mouseY - height/2));
}

void getKeyMoveInput() {
  float moveSpeed = 0.1f;
  if(keyPressed) {
    if(key == 'w') for(PVector p : A) p.add(new PVector(0.f, -moveSpeed));
    if(key == 'a') for(PVector p : A) p.add(new PVector(-moveSpeed, 0.f));
    if(key == 's') for(PVector p : A) p.add(new PVector(0.f, moveSpeed));
    if(key == 'd') for(PVector p : A) p.add(new PVector(moveSpeed, 0.f));
    
    if(keyCode == UP) for(PVector p : B) p.add(new PVector(0.f, -moveSpeed));
    if(keyCode == LEFT) for(PVector p : B) p.add(new PVector(-moveSpeed, 0.f));
    if(keyCode == DOWN) for(PVector p : B) p.add(new PVector(0.f, moveSpeed));
    if(keyCode == RIGHT) for(PVector p : B) p.add(new PVector(moveSpeed, 0.f));
  }
}

void drawPolygons() {
  pushMatrix();
  translate(width/2, height/2);
  strokeWeight(6);
  stroke(255, 255/2, 0, 150);
  for(PVector p : A) {
    point(p.x, p.y);
  }
  stroke(0, 255/2, 255, 150);
  for(PVector p : B) {
    point(p.x, p.y);
  }
  stroke(255/4, 255, 255/4, 150);
  for(PVector p : C) {
    //point(p.x, p.y);
  }
  
  noStroke();
  strokeWeight(1);
  beginShape();
  fill(255, 255/2, 0, 150);
  for(PVector p : A) {
    vertex(p.x, p.y);
  }
  endShape();
  beginShape();
  fill(0, 255/2, 255, 150);
  for(PVector p : B) {
    vertex(p.x, p.y);
  }
  endShape();
  /*
  beginShape();
  stroke(255/4, 255, 255/4, 150);
  for(PVector p : C) {
    vertex(p.x, p.y);
  }
  endShape();
  */
  popMatrix();
}