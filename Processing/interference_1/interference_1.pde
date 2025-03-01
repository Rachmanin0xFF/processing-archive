

ArrayList<Resonator> sources = new ArrayList<Resonator>();
int pixelSize = 4;

float xMin = -1.f;
float xMax = 1.f;
float yMin = -1.f;
float yMax = 1.f;

FourierTransformer ft = new FourierTransformer();

Slider amp = new Slider(10, 10, 300, 40, "Amplitude");
Slider freq = new Slider(10, 60, 300, 40, "Frequency");
Slider phas = new Slider(10, 110, 300, 40, "Phase");
Slider zaxis = new Slider(10, 160, 300, 40, "z-Axis");
Slider time = new Slider(10, 210, 300, 40, "Time (Net Phase)");
Button butt = new Button(10, 260, 100, 55, "Show\nInterference");
Button butt2 = new Button(10, 335, 100, 55, "Show Rings");
GoPad gdp = new GoPad(320, 10, 300, 300);

boolean showInterference = false;


void setup() {
  size(800, 800, P2D);
  background(0);
  amp.display_value = true;
  freq.display_value = true;
  phas.display_value = true;
  amp.set_value(0.75f);
  freq.set_value(0.05f);
  freq.set_range(0.f, 10.f);
  zaxis.value = 0.5f;
  //butt.toggle = true;
  //butt2.toggle = true;
  gdp.radius = 0;
  gdp.sticky = false;
  gdp.display_values = true;
  smooth(8);
  
  for(float i = 0.f; i < 40.f; i+=1.f) {
    sources.add(new Resonator(i*0.1f, 0.f, 1.f, 0.5f, TWO_PI*i*0.1f*sin(10.f)));
  }
  drawWave();
  if (frame != null) {
    frame.setResizable(true);
  }
}

void dispGUI() {
  amp.display();
  freq.display();
  phas.display();
  zaxis.display();
  time.display();
  butt.display();
  gdp.display();
  butt2.display();
}

void keyPressed() {
  if(key == 'c' || key == 'C') {
    sources.clear();
    drawWave();
    dispGUI();
  }
}

float prevZ = 0.f;
float prevT = 0.f;
void draw() {
  amp.update();
  freq.update();
  phas.update();
  zaxis.update();
  time.update();
  butt.update();
  butt2.update();
  gdp.update();
  if(butt.changed || didZoom) {
    drawWave();
  }
  if(didZoom) didZoom = false;
  if(mousePressed && mouseButton == CENTER) {
    PVector dF = new PVector(float(pmouseX - mouseX)/float(width)*(xMax-xMin), float(pmouseY - mouseY)/float(height)*(yMax-yMin));
    xMin += dF.x;
    xMax += dF.x;
    yMin += dF.y;
    yMax += dF.y;
    drawWave();
  }
  if(butt2.changed || prevZ != zaxis.value || prevT != time.value)
    drawWave();
  prevZ = zaxis.value;
  prevT = time.value;
  dispGUI();
}

boolean didZoom = false;
void mouseWheel(MouseEvent me) {
  float e = me.getCount();
  if(e > 0.f)
    e = 1.25f;
  if(e < 0.f)
    e = 0.8f;
  float cx = (xMax + xMin)/2.f;
  float cy = (yMax + yMin)/2.f;
  float rx = (xMax - xMin)/2.f;
  float ry = (yMax - yMin)/2.f;
  xMin = cx - rx*e;
  xMax = cx + rx*e;
  yMin = cy - ry*e;
  yMax = cy + ry*e;
  didZoom = true;
}

void mousePressed() {
  if(mouseButton == RIGHT) {
    PVector p = screenToWorld(mouseX, mouseY);
    p.z = (zaxis.value-0.5f)*20.f;
    sources.add(new Resonator(p, freq.value*5.f, amp.value*1.f, phas.value*2.f*PI));
    drawWave();
    dispGUI();
  }
}

void drawWave2() {
  background(0);
  noFill();
  colorMode(HSB);
  for(Resonator r : sources) {
    PVector p = worldToScreen(r.position.x, r.position.y);
    for(float i = -0.f; i < 15.f; i++) {
      stroke(i/15.f*255.f, 100, 255.f-i/10.f*255.f);
      float w = (i - r.phase%1.f/TWO_PI)/(yMax-yMin)*float(height)/r.frequency;
      ellipse(p.x, p.y, w, w);
    }
  }
  colorMode(RGB);
}

void drawWave() {
  if(butt2.is_on) {
    drawWave2();
  } else {
    strokeWeight(pixelSize);
    strokeCap(SQUARE);
    for(int x = 0; x < width + pixelSize; x += pixelSize)
      for(int y = 0; y < height + pixelSize; y += pixelSize) {
        PVector p = screenToWorld(x, y);
        p.z = (zaxis.value-0.5f)*20.f;
        
        float sum = 0.f;
        if(butt.is_on) {
          float min = 100000.f;
          float max = -100000.f;
          float n = 0.f;
          for(float k = 0.f; k <= 2*PI; k += PI/20.f) {
            float q = 0.f;
            for(Resonator r : sources) {
              float m = max(0.0, r.f(p, k));
              q += m;
            }
            if(q < min)
              min = q;
            if(q > max)
              max = q;
            n++;
          }
          sum = abs(max-min)/float(sources.size());
        } else {
          for(Resonator r : sources)
            sum += r.f(p, -time.value*30.f);
        }
        float u = sum*200.f;
        stroke(u*1.5f, u*1.f, u*2.f, 255);
        //stroke(sum*200.f, 255);
        point(x, y);
      }
    strokeWeight(1);
    stroke(0, 255, 0);
    noFill();
    for(Resonator r : sources) {
      PVector p = worldToScreen(r.position.x, r.position.y);
      ellipse(p.x, p.y, 16, 16);
    }
  }
}

PVector screenToWorld(PVector screenPos) {
  return new PVector(map(screenPos.x, 0, width, xMin, xMax), map(screenPos.y, 0, height, yMin, yMax));
}

PVector screenToWorld(float x, float y) {
  return new PVector(map(x, 0, width, xMin, xMax), map(y, 0, height, yMin, yMax));
}

PVector worldToScreen(float x, float y) {
  return new PVector(map(x, xMin, xMax, 0, width), map(y, yMin, yMax, 0, height));
}

class Resonator {
  PVector position;
  float frequency;
  float amplitude;
  float phase;
  public Resonator(PVector position, float frequency, float amplitude, float phase) {
    this.position = copy_vec(position);
    this.frequency = frequency;
    this.amplitude = amplitude;
    this.phase = phase;
  }
  public Resonator(float x, float y, float frequency, float amplitude, float phase) {
    this.position = new PVector(x, y);
    this.frequency = frequency;
    this.amplitude = amplitude;
    this.phase = phase;
  }
  float f(float x, float y, float z, float t) {
    float d = dist(position, new PVector(x, y, z));
    return amplitude*ft.getSine(2*PI*frequency*d + phase + t)/2.f/d;
  }
  float f(PVector p, float t) {
    float d = dist(position, copy_vec(p));
    return amplitude*ft.getSine(2*PI*frequency*d + phase + t)/2.f/d;
  }
}
