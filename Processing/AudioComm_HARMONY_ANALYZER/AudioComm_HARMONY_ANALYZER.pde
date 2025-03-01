
import java.util.Arrays; 

//Number of data transmission channels
final int channels = 4;
//Frequency range of data transmission (inclusive)
final float dataLowFreq = 1713.f;
final float dataHighFreq = 10000.f;
int startTime = 0;

AudioCommTX actx;
AudioCommRX acrx;
void setup() {
  size(400, 400, P2D);
  background(0);
  acrx = new AudioCommRX();
  actx = new AudioCommTX();
  startTime = millis();
  frameRate(1000);
}

void draw() {
  fill(0, 100);
  rect(0, 0, width, height);
  actx.update();
  acrx.update();
  acrx.display();
}

import ddf.minim.*;
import ddf.minim.ugens.*;

class AudioCommTX {
  Minim minim;
  AudioOutput out;
  
  final int bufferSize = 1024;
  final int sampleRate = 22010;
  
  int startTime = 0;
  int tock = 0;
  
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
    if((millis() - startTime)/5000 > tock) {
      tock++; 
    }
    //Convert tock to a binary number (in a string)
    String s = getBin(tock);
    //Turn on the frequencies for at '1' seen in the binary number
    for(int i = 0; i < channels; i++) {
      int g = (s.charAt(i)=='1'?1:0);
      dataGen[i].setAmplitude(g);
    }
    fill(255, 0, 255);
    text(s, 100, 100);
  }
}

class AudioCommRX {
  Minim minim;
  AudioInput in;
  
  //Minim line in values
  final int bufferSize = 1024;
  final int sampleRate = 22010;
  //Calculate dt between datapoints in signal in
  final float dt = 1.0f/sampleRate*bufferSize;
  
  float[] signal = new float[bufferSize - 1];
  
  FourierTransformer fft = new FourierTransformer();
  
  //An array for containing the energy levels at each transmission frequency
  float[] energyLevels = new float[channels];
  
  int tick = 0;
  int startTime = 0;
  int timeMark = 0;
  
  public AudioCommRX() {
    //Minim customs
    minim = new Minim(this);
    in = minim.getLineIn(Minim.MONO, bufferSize, sampleRate);
  }
  
  int prevTick = 0;
  public void update() {
    if((millis() - startTime)/5000 > tick) {
      tick++; 
    }
    //Copy mic in to signal[]
    for(int i = 0; i < in.bufferSize() - 1; i++) {
      signal[i] = in.mix.get(i);
    }
    //Scan transmission frequencies
    float sum = 0.f;
    if(millis() - timeMark > 1000) {
      for(int i = 0; i < channels; i++) {
        float frequency = map((float)i, 0.f, (float)(channels - 1), dataLowFreq, dataHighFreq);
        float d = max(0.f, fft.discrete_fourier_transform(frequency, dt, signal));
        energyLevels[i] += d*1000.f;
        sum += d;
      }
    }
    //Normalize energy levels
    //for(int i = 0; i < channels; i++) energyLevels[i] /= sum;
    if(prevTick != tick) {
      print((tick-1) + " " + getBin(tick-1) + " [");
      for(float x : energyLevels)
        print(" " + x);
      println(" ]");
      energyLevels = new float[channels];
      timeMark = millis();
    }
    prevTick = tick;
  }
  
  public void display() {
    fill(255);
    noStroke();
    colorMode(HSB);
    for(int i = 0; i < channels; i++) {
      fill(i*255/channels, 255, 255);
      rect(i*20, height, 20, -energyLevels[i]/200.f);
    }
  }
}

String getBin(int k) {
  String s = Integer.toString(k, 2);
  s = new StringBuilder(s).reverse().toString();
  while(s.length() < channels)
    s += "0";
  return s;
}
