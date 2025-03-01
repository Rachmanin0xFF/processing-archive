import ddf.minim.*;
import ddf.minim.ugens.*;

AudioCommTX actx;
void setup() {
  size(400, 400, P2D);
  frameRate(0.5f);
  background(0);
  actx = new AudioCommTX();
}

void draw() {
  background(0);
  actx.update();
}

class AudioCommTX {
  Minim minim;
  AudioOutput out;
  
  final int bufferSize = 1024;
  final int sampleRate = 22010;
  
  //Number of data transmission channels
  final int channels = 4;
  //Frequency range of data transmission (inclusive)
  final float dataLowFreq = 1713.f;
  final float dataHighFreq = 10000.f;
  //Signal generators
  Oscil[] dataGen = new Oscil[channels];
  
  public AudioCommTX() {
    //Minim customs
    minim = new Minim(this);
    out = minim.getLineOut(Minim.MONO, bufferSize, sampleRate);
    
    //Setup Oscils for wave generation
    println("Transmission Frequencies:");
    for(int i = 0; i < channels; i++) {
      float frequency = map((float)i, 0.f, (float)(channels - 1), dataLowFreq, dataHighFreq);
      //Freq, amp, waveform
      dataGen[i] = new Oscil(frequency, 1, Waves.SQUARE);
      dataGen[i].patch(out);
      println("\t"+frequency);
    }
  }
  
  public void update() {
    fill(255);
    noStroke();
    colorMode(HSB);
    int inUse = 0;
    for(int i = 0; i < channels; i++) {
      int g = (int)random(1.5);
      dataGen[i].setAmplitude(g);
      inUse += g;
      fill(i*255/8, 255, 255);
      rect(i*20, height, 20, -g*100.f);
    }
    text(inUse, 100, 100);
  }
}
