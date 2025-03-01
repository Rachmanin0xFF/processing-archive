import megamu.mesh.*;
import java.util.*;

void setup() {
  size(2000, 2000);
  background(255);
  smooth(16);
  doTriangles();
}

void draw() {
}

void keyPressed() {
  if(key == 'p') saveFrame("picture.png"); else {
    //background(255);
    fill(255, 50);
    rect(-1, -1, width+2, height+2);
    doTriangles();
  }
}

void doTriangles() {
  fill(0, 30);
  noStroke();
  float[][] pts = new float[802][2];
  for(int i = 0; i < pts.length; i++) {
    pts[i] = new float[]{random(-200, width + 200), random(-200, height + 200)};
  }
  //push apart
  for(int x = 0; x < 200; x++)
  for(int i = 0; i < pts.length; i++) {
    int j = (int)random(pts.length);
    for(j = 0; j < pts.length; j++) {
      if(i != j) {
        float x1 = pts[i][0]; float y1 = pts[i][1];
        float x2 = pts[j][0]; float y2 = pts[j][1];
        if((x2-x1)*(x2-x1) + (y2-y1)*(y2-y1) < 300*300) {
          PVector awayFrom2 = new PVector(x1 - x2, y1 - y2);
          float len = awayFrom2.mag();
          awayFrom2.normalize();
          awayFrom2.mult(20f/(len + 0.1f));
          pts[i][0] += awayFrom2.x; pts[i][1] += awayFrom2.y;
        }
      }
    }
  }
  
  pts[0][0] = -10000; pts[0][1] = -10000;
  
  Delaunay triangles = new Delaunay(pts);
  int[][] links = triangles.getLinks();
  for(int i = 0; i < pts.length; i++) {
    
    int[] localLinks = triangles.getLinked(i);
    List<LinkA> linkList = new ArrayList();
    for(int j = 0; j < localLinks.length; j++) {
      if(localLinks[j] != 0) { //delaunay library is broken and puts zeroes everywhere which is why the code is weird -_-
        float angle = atan2(pts[i][0] - pts[localLinks[j]][0], pts[i][1] - pts[localLinks[j]][1]);
        linkList.add(new LinkA(localLinks[j], angle));
      }
    }
    
    //println("\nPART 1:");
    //for(LinkA l : linkList) println(l.linkNum);
    //println("PART 2:");
    Collections.sort(linkList);
    //for(LinkA l : linkList) println(l.linkNum);
    fill(248, 230, 66);
    if(random(1) > 0.5f) fill(255, 238, 68);
    fill(248 + random(-10, 10), 230 + random(-10, 10), 66 + random(-10, 10));
    colorMode(HSB);
    fill(36, 200 + random(-90, 90), 255);
    if(pts[i][0] < width && pts[i][0] > 0 && pts[i][1] < height && pts[i][1] > 0) {
      vertex(pts[i][0], pts[i][1]);
      for(int j = 1; j < linkList.size(); j++) {
        int i2 = linkList.get(j).linkNum;
        int i3 = linkList.get(j-1).linkNum;
        
        if(0.4 + random(-0.05, 0.05) > noise(pts[i][0]/200.f+27.3, pts[i][1]/200.f+34.8, millis()/1000.f/6.f)/* || pts[i][0] < 200*/) {
          fill(36 + random(-5, 5), 180 + random(-40, 35), 255);
          beginShape(TRIANGLES);
          vertex(pts[i3][0], pts[i3][1]);
          vertex(pts[i2][0], pts[i2][1]);
          vertex(pts[i][0], pts[i][1]);
          endShape(CLOSE);
        }
      }
    }
  }
  stroke(0, 100);
  for(int i = 0; i < links.length; i++) {
    int start = links[i][0];
    int end = links[i][1];
    float sx = pts[start][0];
    float sy = pts[start][1];
    float ex = pts[end][0];
    float ey = pts[end][1];
    //line(sx, sy, ex, ey);
  }
  
}

class LinkA implements Comparable<LinkA> {
  int linkNum;
  Float angle;
  public LinkA(int l, float a) {
    this.linkNum = l;
    this.angle = a;
  }
  
  public int compareTo(LinkA a) {
    return this.angle.compareTo(a.angle);
  }
}
