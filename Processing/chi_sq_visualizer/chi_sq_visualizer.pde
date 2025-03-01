PVector[] data = new PVector[]{
new PVector(4,35),
new PVector(11,68),
new PVector(14,102),
new PVector(19,130),
new PVector(26,171),
new PVector(32,200),
new PVector(37,230),
new PVector(42,259),
new PVector(43,298),
new PVector(48,325)};

PVector min = new PVector(0, 0);
PVector max = new PVector(60, 350);

PVector[] y1 = new PVector[data.length];
PVector[] y2 = new PVector[data.length];

void setup() {
  size(1600, 900);
  for(int i = 0; i < data.length; i++) {
    y1[i] = new PVector(data[i].x, 6.5*data[i].x + 3);
    y2[i] = new PVector(data[i].x, 4.5*data[i].x + 5);
  }
}

void keyPressed() {
  saveFrame(millis() + ".png");
}

void draw() {
  background(255);
  
  strokeWeight(1);
  drawGrid();
  
  fill(230, 20, 20, 100);
  for(int i = 0; i < data.length; i++) {
    noStroke();
    plotErrorRect(data[i], y2[i]);
    strokeWeight(15);
    plotPoint(data[i]);
  }
  strokeWeight(4);
  for(int i = 0; i < data.length-1; i++) {
    stroke(0, 150, 240);
    //plotLine(y1[i], y1[i+1]);
    plotLine(y2[i], y2[i+1]);
  }
  
  stroke(230, 20, 20);
  strokeWeight(15);
  for(PVector p : data) plotPoint(p);
}

float gridxmajor = 10;
float gridxminor = 2;

float gridymajor = 50;
float gridyminor = 10;
void drawGrid() {
  stroke(0, 100);
  textAlign(CENTER, TOP);
  fill(0, 200);
  textSize(24);
  for(float i = min.x; i < max.x; i += gridxmajor) {
    plotLine(new PVector(i, min.y), new PVector(i, max.y));
    plotText(int(i) + "", new PVector(i, min.y - 10));
  }
  textAlign(RIGHT, CENTER);
  for(float i = min.y; i < max.y; i += gridymajor) {
    plotLine(new PVector(min.x, i), new PVector(max.x, i));
    plotText(int(i) + "", new PVector(min.x - 1, i));
  }
  
  stroke(0, 30);
  for(float i = min.x; i < max.x; i += gridxminor) {
    plotLine(new PVector(i, min.y), new PVector(i, max.y));
  }
  for(float i = min.y; i < max.y; i += gridyminor) {
    plotLine(new PVector(min.x, i), new PVector(max.x, i));
  }
}

int padding = 100;

void plotErrorRect(PVector a, PVector b) {
  float x0 = map(a.x, min.x, max.x, padding, 1600 - padding);
  float y0 = map(a.y, min.y, max.y, 900 - padding, padding);
  float x1 = map(b.x, min.x, max.x, padding, 1600 - padding);
  float y1 = map(b.y, min.y, max.y, 900 - padding, padding);
  rect(x0, y0, (y0-y1), (y1-y0));
}

void plotPoint(PVector p) {
  point(map(p.x, min.x, max.x, padding, 1600 - padding),
        map(p.y, min.y, max.y, 900 - padding, padding));
}

void plotText(String s, PVector p) {
  text(s, map(p.x, min.x, max.x, padding, 1600 - padding),
          map(p.y, min.y, max.y, 900 - padding, padding));
}

void plotLine(PVector a, PVector b) {
  line(map(a.x, min.x, max.x, padding, 1600 - padding),
        map(a.y, min.y, max.y, 900 - padding, padding),
        map(b.x, min.x, max.x, padding, 1600 - padding),
        map(b.y, min.y, max.y, 900 - padding, padding));
}
