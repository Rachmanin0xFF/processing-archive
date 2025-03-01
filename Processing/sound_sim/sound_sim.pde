import ddf.minim.*;
import ddf.minim.signals.*;
Minim minim;
AudioOutput out;
Resonator signalGen;

float[] waveVals;
GoPad gop;
void setup() {
  size(800, 800, P2D);
  frameRate(60);
  minim = new Minim(this);
  out = minim.getLineOut(Minim.MONO);
  signalGen = new Resonator();
  out.addSignal(signalGen);
  waveVals = new float[width/2];
  gop = new GoPad(width/2+30, 30, width/2-60, height/2-60);
  gop.sticky = true;
  gop.display_values = true;
  gop.set_range(0.f, 1.f/1.f, 0.f, 1.f/70.f);
  gop.set_theme(new Theme(color(0, 255), color(0, 255, 0)));
  gop.var_x_name = "Firmness";
  gop.var_y_name = "Dampening";
  initialize();
  blendMode(ADD);
  noSmooth();
}

void draw() {
  background(0);
  displayWave();
  gop.update();
  gop.display();
  noiseDetail(mouseX/40, mouseY/(float)height/2);
  println(gop.x + " " + gop.y);
}

void displayWave() {
  stroke(255, 0, 0);
  for(int i = 1; i < waveVals.length; i++) {
    line(i-1, waveVals[i-1]*float(height/4)+height/4, i, waveVals[i]*float(height/4)+height/4);
  }
  strokeWeight(2);
  stroke(0, 100, 255);
  for(int i = 0; i < p.length; i++) {
    point(10 + i*20, height - height/4 + p[i]*2000);
  }
  strokeWeight(1);
  for(int i = 1; i < p.length; i++) {
    line(10 + i*20, height - height/4 + p[i]*2000, 10 + (i-1)*20, height - height/4 + p[i-1]*2000);
  }
}

void initialize() {
  
}

int wavIndex = 0;

float[] a = new float[28];
float[] v = new float[28];
float[] p = new float[28];
float[] pp = new float[28];
float firmness = 0.07f;
float dampening = 0.001f;

float pval = 0.f;
float tick = 0.f;
float update() {
  wavIndex++;
  for(int i = 1; i < v.length-1; i++) {
    a[i] = gop.value_x*((p[i-1]+p[i+1])/2.f - p[i]);
    v[i] *= 1.f - gop.value_y;
  }
  float avg = 0.f;
  for(int i = 1; i < v.length-1; i++) {
    //Euler Integration
    v[i] += a[i];
    p[i] += v[i];
    //Verlet Integration
    //p[i] = 2*p[i] - pp[i] + a[i]*10.f;
    //pp[i] = p[i];
    avg += p[i];
  }
  avg /= (float)p.length;
  tick += 0.02f;
  float output = avg;
  return clamp(output, -1.f, 1.f);
}

void mousePressed() {
  if(mouseButton == RIGHT) {
    int k = p.length/2 + (int)random(-3, 3);
    v[k] = -0.5f;
    p[k] = -0.5f;
  }
}

void keyPressed() {
  if(key == 'c') {
    v = new float[28];
    p = new float[28];
    pp = new float[28];
    a = new float[28];
  } else {
    int k = p.length/2 + (int)random(-9, 9);
    v[k] = -0.5f;
    p[k] = -0.5f;
  }
}

class Resonator implements AudioSignal {
  void generate(float[] samp) {
    for(int i = 0; i < samp.length; i++) {
      samp[i] = update();
    }
    for(int i = 0; i < waveVals.length; i++)
      waveVals[i] = samp[i];
  }
  void generate(float[] left, float[] right) {
    //Mono sound output :P
  }
}

//Close minim resources
void stop() {
  out.close();
  minim.stop();
  super.stop();
}