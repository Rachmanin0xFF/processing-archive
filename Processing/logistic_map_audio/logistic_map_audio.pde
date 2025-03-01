import ddf.minim.*;
import ddf.minim.signals.*;

Minim minim;
AudioOutput out;
Resonator signalGen;

void initMinim() {
  //Git minim starhted.
  minim = new Minim(this);
  out = minim.getLineOut(Minim.MONO);
  
  //Boot up our link to minim and patch it into the output signal.
  signalGen = new Resonator();
  out.addSignal(signalGen);
}

void stop() {
  out.close();
  minim.stop();
  super.stop();
}

void setup() {
  size(800, 200, P2D);
  frameRate(60);
  initMinim();
}

float[] recvals = new float[1000];
int recid = 0;

void draw() {
  background(0);
  stroke(255);
  r += 0.01*((mouseX + width)/400.f + 0.1f - r);
  for(float i = 0; i < recvals.length; i++) {
    point(width*i/recvals.length, -(height/2.f)*recvals[(int)i]+height/2);
  }
  recid = 0;
}

void mousePressed() {
  x = 0.1f;
  sma = 0.1f;
  LP = 0.0f;
}

float x = 0.1f;
float r = 0.1f;

float sma = 0.f;

float LP = 0.f;

int wavIndex = 0;
float update() {
  float wavSample = 0.f;
  
  if(wavIndex%1==0) {
    x = r*x*(1.f-x);
    sma -= 0.01*(sma - x);
  }
  wavSample = x - sma;
  LP += 0.1*(wavSample - LP);
  
  //Clamp the signal between -1.0 and 1.0 (this almost certainly happens later down the line, but I'm just bein' safe).
  wavIndex++;
  if(recid < recvals.length) recvals[recid] = LP;
  recid++;
  return clamp(LP, -1.f, 1.f);
}

class Resonator implements AudioSignal {
  void generate(float[] samp) {
    for(int i = 0; i < samp.length; i++) {
      samp[i] = update();
    }
  }
  void generate(float[] left, float[] right) {
    //Mono sound output :P
  }
}

float clamp(float a, float x, float y) {
  if(x > y) return -1.f;
  if(a < x) return x;
  if(a > y) return y;
  return a;
}
