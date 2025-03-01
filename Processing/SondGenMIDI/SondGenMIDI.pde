
import ddf.minim.*;
import ddf.minim.signals.*;
Minim minim;
AudioOutput out;
Resonator signalGen;
FourierTransformer fastMath;

float[] waveVals;
void setup() {
  size(800, 800, P2D);
  frameRate(60);
  minim = new Minim(this);
  out = minim.getLineOut(Minim.MONO);
  signalGen = new Resonator();
  out.addSignal(signalGen);
  waveVals = new float[width];
  blendMode(ADD);
  noSmooth();
  fastMath = new FourierTransformer();
  setUpMIDI();
}

void draw() {
  background(0);
  displayWave();
}

void displayWave() {
  stroke(255, 0, 0);
  for(int i = 1; i < waveVals.length; i++) {
    line(i-1, waveVals[i-1]*float(height/2)+height/2, i, waveVals[i]*float(height/2)+height/2);
  }
}

int sampleRate = 44100;

double tick = 0.d;
double tick2 = 0.d;
float update() {
  tick += 1.d/((double)sampleRate);
  float output = 0.f;
  for(int i = 0; i < noteVels.length; i++) {
    if(noteVels[i] > 0.f) {
      output += (float)fastMath.getSine(((float)(tick*PI*note_to_freq(i)%(TWO_PI))))*noteVels[i]/512.f;
    }
  }
  output = (round(output*(float)(mouseX/30.f)))/(float)(mouseX/30.f);
  return clamp(output, -1.f, 1.f);
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