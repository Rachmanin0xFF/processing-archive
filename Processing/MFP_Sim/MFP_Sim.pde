
void setup() {
  size(1900, 1000, P2D);
  n = new Navigator(768+4, 4, 760, 760);
  //noSmooth();
  smooth(16);
  frameRate(1000);
  OVERRIDE_VECTOR_ERRORS = true;
}

import java.util.Random;

boolean cls = true;
boolean pcls = true;
void draw() {
  pcls = cls;
  cls = !(keyPressed && key == 'l');
  CURSOR_MODE = ARROW;if(cls)background(bkgcol);
  
  stroke(255);n.update(pcls);
  textAlign(LEFT);
  noFill();
  
  if(mousePressed && mouseButton == RIGHT && is_in_bounds_exclusive(mouseX, mouseY, n.screenX, n.screenY, n.screenW, n.screenH)) draggy = true;
  if(!mousePressed) draggy = false;
  
  String poppo = "";
  if(draggy) {
    float dx = mouseX - mx0;
    float dy = mouseY - my0;
    line(mx0, my0, mouseX, mouseY);
    if(sources.size() > 0) {
      PVector scal = n.screenToSpaceScale(dx, -dy);
      sources.get(sources.size()-1).moment = new VecN(scal.x, scal.y, 0.0);
      poppo = "Magnitude: " + sqrt(scal.x*scal.x + scal.y*scal.y) + "Nm/T";
    }
  } else {
    mx0 = mouseX;
    my0 = mouseY;
  }
  
  PVector circrad = n.spaceToScreenScale(0.06, 0.06);
  PVector circpos = n.spaceToScreen(0.0, 0.0);
  stroke(255);
  ellipse(circpos.x, circpos.y, circrad.x*2.0, circrad.y*2.0);
  for(Dipole d : sources) {
    PVector rectrad = n.spaceToScreenScale(0.01, 0.01);
    PVector rectpos = n.spaceToScreen(d.position.x, d.position.y);
    pushMatrix();
    translate(rectpos.x, rectpos.y);
    rotate(atan2(-(float)d.moment.y, (float)d.moment.x));
    rect(-rectrad.x/2.0, -rectrad.y/2.0, rectrad.x, rectrad.y);
    popMatrix();
  }
  
  blendMode(ADD);
  if(keyPressed && key == 'l') {
    for(int i = 0; i < 80; i++) {
      float m = random(-10, 10);
      if(m < 0) m = -1;
      if(m >= 0) m = 1;
      double x = random((float)n.minX, (float)n.maxX);
      double y = random((float)n.minY, (float)n.maxY);
      double d = Math.sqrt(x*x + y*y);
      if(!mousePressed || (d > 0.06 - 0.005 && d < 0.06 + 0.005)) {
        double px = x;
        double py = y;
        for(int j = 0; j < 200; j++) {
          VecN v2 = BField(x, y);
          VecN v = normalize(v2);
          x += v.x * 0.0015 * m;
          y += v.y * 0.0015 * m;
          //float col = (float)Math.atan2(v.y, v.x)/3.141593*2.0;
          //stroke((float)v.x*127.0 + 127, 100, (float)v.y*127.0 + 127, 50);
          //stroke(col*255.f, 100, 255.f - col*255.f, 5);
          stroke(60, 255, 255, 10);
          n.drawLine(x, y, px, py);
          px = x;
          py = y;
        }
      }
    }
  }
  blendMode(BLEND);
  colorMode(RGB);
  
  stroke(255);fill(0);n.drawMaskInverse();
  
  fill(255);
  text(poppo, 10, 10);
  if(is_in_bounds_exclusive(mouseX, mouseY, n.screenX, n.screenY, n.screenW, n.screenH)) {
    double[] v = n.screenToSpace(mouseX, mouseY);
    VecN q = BField(v[0], v[1]);
    VecN q2 = magPath.getBField_FGens(new VecN(v[0], v[1], 0.0));
    text("Field strength: " + magnitude(q) + "T", 10, 24);
    text("Field strength approx: " + magnitude(q2) + "T", 10, 34);
  }
  noFill();
  
  if(keyPressed && key == 'e') drawFVSApprox(10, 760, 40, 0.5f);
  
  MFPFuncs();
}

void drawFVSApprox(float xc, float yc, int displaySize, float rad) {
  float w = displaySize;
  float h = displaySize;
  
  double[] v = n.screenToSpace(mouseX, mouseY);
  VecN q = BField(v[0], v[1]);
  double scale = 1.f/magnitude(q);
  
  int scl = 10;
  strokeWeight(scl);
  strokeCap(SQUARE);
  for(float x = 0; x < w; x++) {
    for(float y = 0; y < h; y++) {
      VecN mapped = new VecN((x/w-0.5)*rad*2.0, (y/h-0.5)*rad*2.0, 0.0);
      VecN realField = BField(mapped.x, mapped.y);
      VecN approxField = magPath.getBField_FGens(new VecN(mapped.x, mapped.y, 0.0));
      stroke((float)(realField.x*scale*255.), (float)(realField.y*scale*255.), 0.0);
      if(mousePressed) stroke((float)(approxField.x*scale*255.), (float)(approxField.y*scale*255.), 0.0);
      point(xc + x*scl, yc + y*scl);
    }
  }
  strokeWeight(1);
}

////////////////////////////////////////////////////////////////////////////////////
//                                  SIMULATOR                                     //
////////////////////////////////////////////////////////////////////////////////////

import java.util.Random;
Random randNG = new Random();

Button addSamps = new Button(10, 100, 100, 50, "Add Samples");
Button clearSamps = new Button(120, 100, 100, 50, "Clear data");
Button calcDerivs = new Button(230, 100, 100, 50, "Calculate\nDerivatives");
Ring magPath = new Ring(0.06, 128);

void MFPFuncs() {
  randomSeed(millis());
  addSamps.update();
  addSamps.display();
  if(addSamps.is_on && addSamps.changed) {
    for(int i = 0; i < 500000; i++) {
      double theta = randNG.nextDouble()*Math.PI*2.0;
      VecN pos = magPath.thetaToCoords(theta);
      VecN field = BField(pos.x, pos.y);
      //field.add(new VecN(randNG.nextDouble()*Math.pow(10, -8), randNG.nextDouble()*Math.pow(10, -8)));
      magPath.magSample(theta, field);
    }
  }
  clearSamps.update();
  clearSamps.display();
  if(clearSamps.is_on && clearSamps.changed) {
    magPath.clearData();
  }
  calcDerivs.update();
  calcDerivs.display();
  if(calcDerivs.is_on && calcDerivs.changed) {
    magPath.calcDerivatives(20);
  }
  magPath.display(300, 400, 200, 30000000.0);
}

////////////////////////////////////////////////////////////////////////////////////
//                                  RING CODE                                     //
////////////////////////////////////////////////////////////////////////////////////

class FGen {
  VecN position;
  VecN direction; //norm(v) in math
  int n = -1; //nth derivative
  VecN s; //∂ in math (derivative value) (field x and y)
  double factorial = -1.0; //n! in math
  public FGen(VecN position, VecN direction, int nthDeriv, VecN derivValues) {
    this.position = copy_vec(position);
    this.direction = normalize(direction);
    n = nthDeriv;
    s = copy_vec(derivValues);
  }
  public VecN getF(VecN x) {
    double l = dot(sub(x, position), direction);
    if(factorial == -1.0) factorial = (double)factorialLong(n);
    double sMult = Math.pow(l, (double)n)/factorial;
    return mult(s, sMult);
  }
}

class Ring {
  double radius = 0.0;
  int resolution = 0;
  VecN[] collectors;
  int[] collectorsTick;
  ArrayList<ArrayList<FGen>> seriesStorage;
  public Ring(double radius, int resolution) {
    this.radius = radius;
    this.resolution = resolution;
    collectors = new VecN[resolution];
    collectorsTick = new int[resolution];
    for(int i = 0; i < collectors.length; i++) {
      collectors[i] = new VecN(0.0, 0.0, 0.0);
    }
    seriesStorage = new ArrayList<ArrayList<FGen>>();
  }
  void magSample(double theta, VecN field) {
    int id = thetaToID(theta);
    collectors[id].add(field);
    collectorsTick[id]++;
  }
  void clearData() {
    collectors = new VecN[resolution];
    collectorsTick = new int[resolution];
    for(int i = 0; i < collectors.length; i++) {
      collectors[i] = new VecN(0.0, 0.0, 0.0);
    }
    seriesStorage = new ArrayList<ArrayList<FGen>>();
  }
  public VecN getBField_FGens(VecN x) {
    VecN sum = new VecN(0.0, 0.0, 0.0);
    if(seriesStorage.size() > 0)
    for(int i = 0; i < seriesStorage.size(); i++) 
    for(int j = 0; j < seriesStorage.get(0).size(); j++)
    sum.add(seriesStorage.get(i).get(j).getF(x));
    return sum;
  }
  void calcDerivatives(int level) {
    seriesStorage.add(new ArrayList<FGen>());
    for(int i = 0; i < resolution; i++) {
      VecN u = thetaToCoords(i);
      VecN q = thetaToCoords(i+1);
      VecN position = mult(add(u, q), 0.5);
      VecN direction = sub(q, u);
      VecN s = mult(sub(getAt(i+1), getAt(i)), 1.0/length(sub(q, u)));
      seriesStorage.get(0).add(new FGen(position, direction, 0, s));
    }
    
    for(int i = 0; i < level; i++) {
      seriesStorage.add(new ArrayList<FGen>());
      for(int j = 0; j < resolution; j++) {
        int id0 = j%resolution;
        int id1 = (j + 1)%resolution;
        VecN u = copy_vec(seriesStorage.get(i).get(id0).position);
        VecN q = copy_vec(seriesStorage.get(i).get(id1).position);
        VecN position = mult(add(u, q), 0.5);
        VecN direction = sub(q, u);
        VecN s  = mult(sub(seriesStorage.get(i).get(id1).s, seriesStorage.get(i).get(id0).s), 1.0/length(sub(q, u)));
        seriesStorage.get(i+1).add(new FGen(position, direction, 0, s));
      }
    }
  }
  VecN getAt(int id) {
    VecN out = copy_vec(collectors[id%resolution]);
    out.mult(1.0/((double)collectorsTick[id%resolution]));
    return out;
  }
  int thetaToID(double theta) {
    double x = (theta/(2.0*Math.PI))%1.0;
    int id = (int)Math.round(x*((double)resolution));
    if(id > collectors.length - 1) id = 0;
    if(id < 0) id = collectors.length - 1;
    return id;
  }
  double IDToTheta(int id) {
    double x = (2.0*Math.PI)*(((double)id)/((double)resolution));
    return x;
  }
  void display(float x, float y, float dispRadius, double scale) {
    stroke(255, 255);
    noFill();
    ellipse(x, y, dispRadius*2.f, dispRadius*2.f);
    line(x, y + 10, x, y - dispRadius - 10);
    line(x - 10, y, x + 10, y);
    line(x - dispRadius - 10, y, x - dispRadius + 10, y);
    line(x + dispRadius - 10, y, x + dispRadius + 10, y);
    line(x, y + dispRadius - 10, x, y + dispRadius + 10);
    colorMode(HSB);
    blendMode(ADD);
    for(int i = 0; i < collectors.length; i++) {
      double theta = IDToTheta(i);
      double x0 = Math.cos(theta)*dispRadius;
      double y0 = -Math.sin(theta)*dispRadius;
      double scale2 = scale/((double)collectorsTick[i]);
      double xoff = collectors[i].x*scale2;
      double yoff = collectors[i].y*scale2;
      xoff = getAt(i).x*scale;
      yoff = getAt(i).y*scale;
      if(keyPressed && key == 'i') {
        int dispID = floor(mouseX/100);
        xoff = seriesStorage.get(dispID).get(i).s.x*scale;
        yoff = seriesStorage.get(dispID).get(i).s.y*scale;
      }
      stroke((float)(255.0*theta/Math.PI/2.0), 255, 120, 80);
      line(x + (float)x0, y + (float)y0, x + (float)(x0 - xoff), y + (float)(y0 + yoff));
    }
    colorMode(RGB);
    blendMode(BLEND);
  }
  VecN thetaToCoords(double theta) {
    return new VecN(radius*Math.cos(theta), radius*Math.sin(theta), 0.0);
  }
}

////////////////////////////////////////////////////////////////////////////////////
//                                 MAG SIM CODE                                   //
////////////////////////////////////////////////////////////////////////////////////

VecN BField(double x, double y) {
  VecN field = new VecN(0.0, 0.0, 0.0);
  for(Dipole d : sources) {
    field.add(d.get_B_field(new VecN(x, y, 0.0)));
  }
  return field;
}

ArrayList<Dipole> sources = new ArrayList<Dipole>();

class Dipole {
  VecN position;
  VecN moment;
  public Dipole(PVector position, PVector moment) {
    this.position = new VecN(position.x, position.y, position.z);
    this.moment = new VecN(moment.x, moment.y, moment.z);
  }
  VecN get_B_field(VecN x) {
    return dipole_B(position, moment, x);
  }
}

//Significant figures used here
//Ring radius = 6cm
//1 millitesla = 0.001T
//1 microtesla = 0.000001T
//Average bar magnet dipole moment = 1-10 Nm/T (Am^2)

//For speed/readability
VecN moment(double theta, double magnitude) {
  return moment(new VecN(Math.cos(theta), Math.sin(theta), 0.0), magnitude);
}
VecN moment(VecN orientation, double magnitude) {
  return mult(normalize(orientation), magnitude);
}
//Returns B field vector of a static magnetic dipole
final double free_space_permeability = 1.25663706e-6;//=pi/2500000(N/A^2)
VecN dipole_B(VecN source, VecN moment, VecN x) {
  VecN r = sub(x, source);
  VecN rnorm = normalize(r);
  VecN dividend = sub(mult(rnorm, 3.0*dot(moment, rnorm)), moment);
  double divisor = length(r);
  divisor = divisor*divisor*divisor;
  VecN quotient = mult(dividend, 1.0/divisor);
  quotient.mult(free_space_permeability/(4.0*Math.PI));
  //Ignoring exact Dirac delta form
  return quotient;
}

////////////////////////////////////////////////////////////////////////////////////
//                                  VISUALS                                       //
////////////////////////////////////////////////////////////////////////////////////

boolean draggy = false;
int mx0;
int my0;

void mousePressed() {
  if(mouseButton == RIGHT && is_in_bounds_exclusive(mouseX, mouseY, n.screenX, n.screenY, n.screenW, n.screenH)) {
    double[] mp = n.screenToSpace(mouseX, mouseY);
    sources.add(new Dipole(new PVector((float)mp[0], (float)mp[1], 0), new PVector(6, 0, 0)));
  }
}

void keyPressed() {
  if(key == 'c') if(sources.size() > 0) sources.remove(sources.size()-1);
}

color bkgcol = color(0, 0, 10, 255);
int CURSOR_MODE = ARROW;
Navigator n;
class Navigator {
  double minX = -1.f;
  double minY = -1.f;
  double maxX = 1.f;
  double maxY = 1.f;
  int screenX = 0;
  int screenY = 0;
  int screenW = 0;
  int screenH = 0;
  boolean dispGrid = true;
  double gridInterval = 10.0;
  boolean squareLock = true;
  boolean clearRestOfScreen = true;
  
  color fill_color = color(0, 0, 0, 0);
  color border_color = color(255, 255, 255, 255);
  
  public Navigator(int x, int y, int w, int h) {
    screenX = x;
    screenY = y;
    screenW = w;
    screenH = h;
    if(squareLock) {
      double aspect = (double)screenW/(double)screenH;
      minX *= aspect;
      maxX *= aspect;
    }
  }
  public void drawLine(double x0, double y0, double x1, double y1) {
    PVector start = spaceToScreen(x0, y0);
    PVector end = spaceToScreen(x1, y1);
    line(start.x, start.y, end.x, end.y);
  }
  public PVector spaceToScreen(double x, double y) {
    if(!clearRestOfScreen) {
      return new PVector(clamp((float)map(x, minX, maxX, (double)screenX, (double)(screenX + screenW)), screenX, screenX + screenW),
                         clamp((float)map(y, minY, maxY, (double)(screenY + screenH), (double)screenY), screenY, screenY + screenH));
    }
    return new PVector((float)map(x, minX, maxX, (double)screenX, (double)(screenX + screenW)),
                       (float)map(y, minY, maxY, (double)(screenY + screenH), (double)screenY));
  }
  public PVector spaceToScreenScale(double x, double y) {
    return new PVector((float)(x/(maxX - minX)*(double)(screenW)), (float)(y/(maxY - minY)*(double)(screenH)));
  }
  public PVector screenToSpaceScale(double x, double y) {
    return new PVector((float)(x/(double)(screenW)*(maxX - minX)), (float)(y/(double)(screenH)*(maxY - minY)));
  }
  public double[] screenToSpace(double x, double y) {
    return new double[]{map(x, (double)screenX, (double)(screenX + screenW), minX, maxX), map(y, (double)(screenY + screenH), (double)screenY, minY, maxY)};
  }
  boolean dragging = false;
  boolean pmousePressed = false;
  public void update(boolean shouldDraw) {
    if(!pmousePressed && mousePressed && mouseButton == LEFT && is_in_bounds_inclusive(mouseX, mouseY, screenX, screenY, screenW, screenH)) dragging = true;
    if(!mousePressed) dragging = false;
    if(dragging) {
      double xoff = ((double)(pmouseX - mouseX)/(double)(screenW))*(maxX - minX);
      double yoff = ((double)(mouseY - pmouseY)/(double)(screenH))*(maxY - minY);
      minX += xoff; maxX += xoff;
      minY += yoff; maxY += yoff;
      CURSOR_MODE = MOVE;
    }
    
    if(shouldDraw) {
      displayGrid(0, 100, false);
      displayGrid(1, 50, true);
      displayGrid(2, 10, false);
      
      PVector zero = spaceToScreen(0.0, 0.0);
      if(0.0 > minX && 0.0 < maxX) {
        stroke(0, 255, 0, 255);
        line(zero.x, screenY, zero.x, screenY + screenH);
      }
      if(0.0 > minY && 0.0 < maxY) {
        stroke(255, 0, 0, 255);
        line(screenX, zero.y, screenX + screenW, zero.y);
      }
      
      noFill();
      stroke(border_color);
      rect(screenX, screenY, screenW, screenH);
      
      if(clearRestOfScreen) {
        noStroke();
        fill(bkgcol);
        rect(0, 0, screenX, screenY);
        rect(0, screenY, screenX, screenH);
        rect(screenX, 0, screenW, screenY);
        rect(0, screenY + screenH, screenX, height - (screenY + screenH));
        rect(screenX + screenW, 0, width - (screenX + screenW), screenY);
        rect(screenX + screenW + 1, screenY, width - (screenX + screenW), screenH);
        rect(screenX, screenY + screenH + 1, screenW, height - (screenY + screenH));
        rect(screenX + screenW + 1, screenY + screenH + 1, width - (screenX + screenW), height - (screenY + screenH));
      }
    }
    
    pmousePressed = mousePressed && mouseButton == LEFT;
  }
  
  void drawMaskInverse() {
    noStroke();
    fill(bkgcol);
    rect(0, 0, screenX, screenY);
    rect(0, screenY, screenX, screenH);
    rect(screenX, 0, screenW, screenY);
    rect(0, screenY + screenH, screenX, height - (screenY + screenH));
    rect(screenX + screenW, 0, width - (screenX + screenW), screenY);
    rect(screenX + screenW + 1, screenY, width - (screenX + screenW), screenH);
    rect(screenX, screenY + screenH + 1, screenW, height - (screenY + screenH));
    rect(screenX + screenW + 1, screenY + screenH + 1, width - (screenX + screenW), height - (screenY + screenH));
  }
  
  void displayGrid(int powOffset, int alpha, boolean text) {
    stroke(r(border_color), g(border_color), b(border_color), alpha);
    if(dispGrid) {
      long xpow = Math.round(Math.log(maxX - minX)/Math.log(gridInterval))-powOffset;
      long ypow = Math.round(Math.log(maxY - minY)/Math.log(gridInterval))-powOffset;
      if(squareLock)  ypow = xpow;
      double xincr = Math.pow(gridInterval, xpow);
      double yincr = Math.pow(gridInterval, ypow);
      
      double startingPointX = roundTo(minX - (maxX - minX)/4.0, xincr);
      for(double x = startingPointX; x < maxX + (maxX - minX)/4.0; x += xincr) {
        if(x > minX && x < maxX || clearRestOfScreen) {
          PVector s = spaceToScreen(x, 0.0);
          line(s.x, screenY, s.x, screenY + screenH);
          if(text) {
            fill(border_color);
            String dispText = (float)roundTo(x, xincr) + "";
            double tw = (xincr/(maxX - minX))*(double)screenW;
            boolean workaround = false;
            if(tw < (double)textWidth(dispText + " ")) workaround = true;
            boolean skip = false;
            if(workaround) {
              if(Math.abs(x)%(2*xincr) > xincr) skip = true;
            }
            if(!skip) {
              if(x > 5.0e37 || x < -5.0e37) dispText = roundTo(x, xincr) + "";
              if(Math.abs(x) < xincr/10.0) dispText = "0.0";
              if(s.y > screenY + 100) textAlign(LEFT, BOTTOM); else textAlign(LEFT, TOP);
              if(s.x + textWidth(dispText) < screenX + screenW || clearRestOfScreen) text("" + dispText, s.x, s.y);
            }
          }
        }
      }
      
      double startingPointY = roundTo(minY - (maxY - minY)/4.0, yincr);
      for(double y = startingPointY; y < maxY + (maxY - minY)/4.0; y += yincr) {
        if(y > minY && y < maxY || (clearRestOfScreen && y > minY - yincr/2.0 && y < maxY + yincr/2.0)) {
          PVector s = spaceToScreen(0.0, y);
          line(screenX, s.y, screenX + screenW, s.y);
          if(text && s.y - (clearRestOfScreen?-12:12) > screenY) {
            fill(border_color);
            String dispText = (float)roundTo(y, yincr) + "";
            if(y > 5.0e37 || y < -5.0e37) dispText = roundTo(y, yincr) + "";
            if(Math.abs(y) < yincr/10.0) dispText = "";
            if(s.x > screenX + screenW - 100) textAlign(RIGHT); else textAlign(LEFT);
            text("" + dispText, s.x, s.y);
          }
        }
      }
    }
  }
  
  void MW(float count) {
    double z = 1.1;
    if(count < 0.f) z = 1.0/1.1;
    double focusX = (minX + maxX)/2.0;
    double focusY = (minY + maxY)/2.0;
    double radX = (maxX - minX)/2.0;
    double radY = (maxY - minY)/2.0;
    radX *= z;
    radY *= z;
    minX = focusX - radX;
    maxX = focusX + radX;
    minY = focusY - radY;
    maxY = focusY + radY;
  }
  
  public void set_theme(Theme t) {
    this.fill_color = t.fill_color;
    this.border_color = t.border_color;
  }
}
double roundTo(double x, double f) {
  return f * Math.round(x / f);
}
void mouseWheel(MouseEvent me) {
  float e = me.getCount();
  n.MW(e);
}

/*
strokeCap(SQUARE);
if(keyPressed && key == 'f') {
  int cnt = 100;
  float radius = (float)(n.maxX - n.minX);
  int px = 5;
  strokeWeight(px);
  for(int x = 0; x < cnt; x++) {
    for(int y = 0; y < cnt; y++) {
      double mapx = ((float)x/(float)cnt)*radius*2.f - radius;
      double mapy = ((float)y/(float)cnt)*radius*2.f - radius;
      VecN field = BField(mapx, mapy);
      
      stroke((float)field.x*10000.0, (float)field.y*10000.0, 0);
      point(x * px, y * px);
    }
  }
}
strokeWeight(1);
*/