
AudioCommRX acrx;

void setup() {
  size(400, 400, P2D);
  acrx = new AudioCommRX();
  frameRate(500);
}

void draw() {
  background(0);
  acrx.update();
  acrx.display();
}

import ddf.minim.*;

class AudioCommRX {
  Minim minim;
  AudioInput in;
  
  //Minim line in values
  final int bufferSize = 1024;
  final int sampleRate = 22010;
  //Calculate dt between datapoints in signal in
  final float dt = 1.0f/sampleRate*bufferSize;
  
  float[] signal = new float[bufferSize - 1];
  
  //Number of data transmission channels
  final int channels = 4;
  //Frequency range of data transmission (inclusive)
  final float dataLowFreq = 1713.f;
  final float dataHighFreq = 10000.f;
  
  FourierTransformer fft = new FourierTransformer();
  
  //An array for containing the energy levels at each transmission frequency
  float[] energyLevels = new float[channels];
  
  public AudioCommRX() {
    //Minim customs
    minim = new Minim(this);
    in = minim.getLineIn(Minim.MONO, bufferSize, sampleRate);
  }
  
  public void update() {
    //Copy mic in to signal[]
    for(int i = 0; i < in.bufferSize() - 1; i++) {
      signal[i] = in.mix.get(i);
    }
    //Scan transmission frequencies
    float sum = 0.f;
    for(int i = 0; i < channels; i++) {
      float frequency = map((float)i, 0.f, (float)(channels - 1), dataLowFreq, dataHighFreq);
      float d = max(0.f, fft.discrete_fourier_transform(frequency, dt, signal));
      energyLevels[i] = d*1000.f;
      sum += d;
    }
    //Normalize energy levels
    //for(int i = 0; i < channels; i++) energyLevels[i] /= sum;
  }
  
  public void display() {
    fill(255);
    noStroke();
    colorMode(HSB);
    for(int i = 0; i < channels; i++) {
      fill(i*255/8, 255, 255);
      rect(i*20, height, 20, -energyLevels[i]*100.f);
    }
  }
}