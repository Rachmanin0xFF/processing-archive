
//Alright here's how it is
//This code is filled with some stuff from where I was taking the fourier transform of the derivative of the fourier transform of the microphone input
//I was doing this for some fancy reasons involving piano note recognition (top secret (not really))
//So a lot of stuff here isn't even used in the program
//Also there aren't many comments
//The comments that exist are just me commenting out stuff I don't want to use
//This whole .pde is pretty much just getting mic input and making things look fancy
//Also I use the font I do so I can get those nice sharp/flat signs.

import ddf.minim.*;

int tick = 0;

Minim minim;
AudioInput in;
//AudioPlayer in;

ArrayList<Float> signal = new ArrayList<Float>();
ArrayList<Float> fft = new ArrayList<Float>();
ArrayList<Float> fft_2 = new ArrayList<Float>();
FourierTransformer fourier = new FourierTransformer();

float range = 2000.f; // 'default' 1000.0
float range_2 = 5000.f; //ignoramus thisus


float bufferSize = 1024*4;
float sampleRate = 22010*2;

float dt = 1.0f/sampleRate*bufferSize;
float spectrograph_freq_scale = 0.f;
float spectrograph_freq_scale_2 = 0.f;
 
float[] q;
float[] q_2;
float[][] key_relations = new float[1][1];

float most_prominent_frequency = 0.f;
float max_power = 0.f;

boolean do_piano_fft = true;
float[] pkey_2 = new float[12];
String interp_note = "";
int fftsamps = 500;
int fftsamps_2 = 500;
float dt_2 = 1.0f*range;

Slider gain = new Slider(10, 110, 400, 40, "Gain");

void setup() {
  size(1000, 900, P2D);
  PFont font = createFont("Arial Unicode MS", 12);
  //PFont font = createFont("Lucide Sans Unicode", 24);
  textFont(font);
  textSize(12);
  minim = new Minim(this);
  in = minim.getLineIn(Minim.MONO, (int)bufferSize, (int)sampleRate);
  //in = minim.loadFile("Tristam - My Friend.mp3", (int)bufferSize); in.play();
  background(0);
  strokeWeight(2);
  frameRate(100);
  println("MINIMUM Hz: " + 4.f/dt);
  spectrograph_freq_scale = range;
  spectrograph_freq_scale_2 = range_2;
}

void draw() {
  most_prominent_frequency = 0.f;
  get_audio();
  
  calc_fft();
  most_prominent_frequency = fourier.inspect(most_prominent_frequency, 20.f, 1.f, dt, q);
  most_prominent_frequency = fourier.inspect(most_prominent_frequency, 1.f, 0.1f, dt, q);
  most_prominent_frequency = fourier.inspect(most_prominent_frequency, 0.1f, 0.01f, dt, q);
 // calc_double_fft();
  if(fft.size() != key_relations.length) recalculate_key_relations();
  if(!mousePressed)
    frequency = most_prominent_frequency;
  draw_spectrogram(width/2, 0, width/2, height/2);
  draw_spin(0, height/2, width/2);
  draw_sideways_bars(0, 0, width/2, height/2);
  draw_wave(width/2, height/2, width/2, height/2);
  //draw_piano(10, 10, 30);
  //draw_bars(0, 0, width/2, height/2, fft_2);
  gain.update();
  gain.display();
  gain.fill_color = color(15, 30, 100, 100);
  gain.border_color = color(255, 255);
  
  textAlign(LEFT, TOP);
  //outlined_text("Targeted Frequency: " + frequency + "Hz", 10, 10, color(0, 255), color(255, 255));
  outlined_text("Most Prominent Frequency: " + most_prominent_frequency + "Hz", width/2 + 10, height - 16 - 10, color(0, 255), color(100, 255, 200/3+255/3, 100));
  outlined_text("Interpreted Note: " + interp_note, 10, 160, color(0, 255), color(255, 255) );
  outlined_text("Targeted Frequency " + frequency + "Hz", 10, height/2 + 10, color(0, 255), color(100, 255, 200/3+255/3, 100));
  
  signal.clear();
  fft.clear();
  fft_2.clear();
  signal = new ArrayList<Float>();
  fft = new ArrayList<Float>();
  tick++;
}

void get_audio() {
  for(int i = 0; i < in.bufferSize() - 1; i++) {
    signal.add(in.mix.get(i)/2.0f);
  }
  q = toArray(signal);
}

float[] recorded_noise = new float[fftsamps];
float noise_avg_iter = 0.f;
void keyReleased() {
  if(key == 'N') {
    for(int i = 0; i < recorded_noise.length; i++)
      recorded_noise[i] /= noise_avg_iter;
    noise_avg_iter = 0.f;
  }
}

void calc_fft() {
  boolean zeta = false;
  if(keyPressed && key == 'N') {
    zeta = true;
    noise_avg_iter += 1.f;
  }
  max_power = 0.f;
  for(int i = 0; i < fftsamps; i+=1) {
    float r = max(0.f, fourier.discrete_fourier_transform(float(i)/float(fftsamps)*spectrograph_freq_scale, dt, q)*100000.f);
    if(!zeta)
      r -= recorded_noise[i];
    r = max(0.f, r);
    fft.add(r*gain.value*10.f);
    if(zeta) recorded_noise[i] += r;
    if(r > max_power && float(i)/float(fftsamps)*spectrograph_freq_scale > 2.f/dt) {
      max_power = r;
      most_prominent_frequency = float(i)/float(fftsamps)*spectrograph_freq_scale;
    }
  }
  q_2 = new float[fft.size()];
  for(int i = 0; i < fft.size() - 1; i++) {
    q_2[i] = (fft.get(i + 1) - fft.get(i));
  }
}

void calc_double_fft() {
  for(int i = 0; i < fftsamps_2; i+=1) {
    float r = fourier.discrete_fourier_transform(float(i)/float(fftsamps_2)*spectrograph_freq_scale_2, dt_2, q_2)*500.f;
    fft_2.add(r);
  }
  for(int i = 0; i < fftsamps_2 - 1; i+=1) {
    //fft_2.set(i, fft_2.get(i+1) - fft_2.get(i));
  }
}

void draw_spectrogram(float x, float y, float w, float h) {
  loadPixels();
  PImage p = get((int)x, (int)y, (int)w-1, (int)h);
  image(p, x + 1, y);
  updatePixels();
  noStroke();
  strokeWeight(4);
  for(int i = 0; i < h; i+=1) {
    float r = fft.get(i);
    //stroke(r, r*2.f, r*0.5f, 255);
    stroke(r*0.5f, r*1.f, r*2.f, 255);
    point(x+1, y*2 + h - i);
  }
  stroke(255, 255);
  point(x+1, y + h);
  if(mousePressed && is_in_bounds_exclusive(mouseX, mouseY, x, y, w, h)) {
    frequency = (h - (float(mouseY)-y))/h*spectrograph_freq_scale;
  }
}

void draw_spin(float x, float y, float r) {
  float w = r;
  float h = r;
  strokeWeight(1);
  fill(0, 150);
  noStroke();
  rect(x-1, y-1, w+1, h+1);
  blendMode(ADD);
  //stroke(100, 200/3+255/3, 255, 100);
  //stroke(100, 200/3+255/3, 255, 100);
  stroke(100, 255, 200/3+255/3, 100);
  float real = 0.f;
  float imag = 0.f;
  float mult = 2.f*PI*frequency*dt/(float)q.length;
  float k = 2048.f;
  float px = 0.f;
  float py = 0.f;
  for(float i = 0; i < k; i++) {
    int index = int(i/k*float(signal.size()-2));
    float Re = q[index]*fourier.getSine(index*mult-PI/2)*10.f*gain.value;
    float Im = q[index]*fourier.getSine(index*mult)*10.f*gain.value;
    real += Re;
    imag += Im;
    float p = max(1.f, sqrt(Re*Re+Im*Im)*h/25.f);
    strokeWeight(p);
    stroke(100, 255, 200/3+255/3, 100.f/p*p);
    //point(x + w/2.f + Re*w, y + h/2.f + Im*h);
    strokeWeight(1);
    if(i != 0)
      line(px, py, min(x + w, max(x, x + w/2.f + Re*w)), min(y + h, max(y, y + h/2.f + Im*h)));
    px = min(x + w, max(x, x + w/2.f + Re*w));
    py = min(y + h, max(y, y + h/2.f + Im*h));
  }
  strokeWeight(1);
  noFill();
  float intensity = min(h-4, sqrt(real*real + imag*imag)*h/200.f);
  stroke(255, 255);
  ellipse(x + w/2.f, y + h/2.f, intensity, intensity);
  blendMode(BLEND);
}

boolean orange = true;
void draw_piano(float x, float y, float r) {
  float[] pkey = new float[12];
  if(true || do_piano_fft) {
    //actually git our vals dood
    int i = 0;
    for(float f = 110.f; f < 5000.f; f *= 1.05946309436f) {
      float power = fourier.discrete_fourier_transform(f, dt, q);
      pkey[i%12] += power*((float)mouseX/(float)width)*10.f;
      i++;
    }
  } else {
    /**
    for(int i = 0; i < pkey.length; i++) {
      for(int j = 0; j < fft.size(); j++) {
        float h = key_relations[j][i]*fft.get(j);
        if(h > 0.f)
          pkey[i] += h*0.5f;
      }
    }**/
  }
  float maxp = 0.f;
  float minp = 100000000.f;
  for(int i = 0; i < pkey.length; i++) {
    if(pkey[i] > maxp) {
      maxp = pkey[i];
      interp_note = musical_notes_81bpqs01MA18YUB1a2[i%12];
    }
    if(pkey[i] < minp)
      minp = pkey[i];
  }
  for(int i = 0; i < pkey.length; i++) {
    pkey[i] = (pkey[i]-minp)/max(0.0000001f, maxp-minp)*maxp*16384;
  }
  for(int i = 0; i < pkey.length; i++) {
    pkey_2[i] += 0.3*(pkey[i] - pkey_2[i]);
  }
  stroke(255);
  int k = 0;
  for(int g = 0; g < pkey.length*2+1; g++) {
    int i = (g+12)%12;
    if(orange)
      fill(mix(pkey_2[(i+12)%12]/655.f, color(0, 15, 50, 255), color(255, 100, 10, 255)));
    else
      fill(mix_p_c(pkey_2[(i+12)%12]/2655.f, new PVector(0, 15, 50), new PVector(255, 255*2.f, 255*4.f)));
    if(i == 0 || i == 2 || i == 3 || i == 5 || i == 7 || i == 8 || i == 10 || i == 12) {
      rect(x + k*r, y, r, r*3);
      k++;
    }
  }
  k = 0;
  for(int g = 0; g < pkey.length*2+1; g++) {
    int i = (g+12)%12;
    if(orange)
      fill(mix(pkey_2[(i+12)%12]/655.f, color(0, 15, 50, 255), color(255, 100, 10, 255)));
    else
      fill(mix_p_c(pkey_2[(i+12)%12]/2655.f, new PVector(0, 15, 50), new PVector(255, 255*2.f, 255*4.f)));
    if(!(i == 0 || i == 2 || i == 3 || i == 5 || i == 7 || i == 8 || i == 10 || i == 12)) {
      rect(x + k*r-r*0.4f, y, r*0.8, r*1.5f);
    } else
      k++;
  }
  strokeWeight(1);
}

void recalculate_key_relations() {
  key_relations = new float[fft.size()][18];
  for(int i = 1; i < fft.size(); i++) {
    PVector v = closest_notes((float)i*spectrograph_freq_scale/float(fft.size()));
    key_relations[i][frequency_to_note_index(v.x)] += 1.0f - v.z;
    key_relations[i][frequency_to_note_index(v.y)] += v.z;
  }
}

void draw_bars(float x, float y, float w, float h, ArrayList<Float> z) {
  strokeWeight(1);
  fill(0, 255);
  noStroke();
  rect(x-1, y-1, w+1, h+1);
  fill(255, 255);
  noStroke();
  for(float i = 0.01f; i < 1.f - 0.011f; i += 0.001f) {
    float value = min(z.get(int(i*(float)z.size()))*100.f/h, h);
    rect(x + i*w, y + h, 2, -value);
  }
}

void draw_bars(float x, float y, float w, float h, float[] z) {
  strokeWeight(1);
  fill(0, 255);
  noStroke();
  rect(x-1, y-1, w+1, h+1);
  fill(255, 255);
  noStroke();
  for(float i = 0.01f; i < 1.f - 0.011f; i += 0.001f) {
    float value = min(z[int(i*(float)z.length)]*100.f/h, h);
    rect(x + i*w, y + h, 2, -value);
  }
}

void draw_sideways_bars(float x, float y, float w, float h) {
  strokeWeight(1);
  fill(0, 255);
  noStroke();
  rect(x-1, y-1, w+1, h+1);
  stroke(255, 255);
  for(float i = 0.01f; i < 1.f - 0.011f; i += 0.002f) {
    float value = min(fft.get(int(i*(float)fft.size()))*300.f/w, w);
    line(x + w - 1, y + h - i*h, x + w - value - 1, y + h - i*h);
  }
  if(mousePressed && is_in_bounds_exclusive(mouseX, mouseY, x, y, w, h)) {
    frequency = (h - (float(mouseY)-y))/h*spectrograph_freq_scale;
  }
  blendMode(BLEND);
  stroke(100, 255, 200/3+255/3, 100);
  line(x, h - (frequency/spectrograph_freq_scale)*h, x+w - 1, h - (frequency/spectrograph_freq_scale)*h);
}

void draw_wave(float x, float y, float w, float h) {
  strokeWeight(1);
  fill(0, 255);
  noStroke();
  rect(x-1, y-1, w+1, h+1);
  stroke(255, 255);
  for(float i = 0; i < w-1; i++) {
    int index = int(i/w*q.length);
    int index_2 = int((i+1)/w*q.length);
    line(x + i, y + q[index]*h*.75f*.5f + h/4.f, x + i + 1, y + q[index_2]*h*.75f*.5f + h/4.f);
  }
  float mpp = fourier.discrete_fourier_transform(frequency, dt, q);
  if(mousePressed) mpp = 0.1f;
  stroke(100, 255, 200/3+255/3, 100);
  for(float i = 0; i < w-1; i++) {
    float yc = max(-1.f, min(1.f, sin(i/w*dt*frequency*2.f*PI)*mpp*5.f))/2.f;
    float yc2 = max(-1.f, min(1.f, sin((i+1)/w*dt*frequency*2.f*PI)*mpp*5.f))/2.f;
    line(x + i, y + yc*h*.75f*.5f + h/4.f*3.f, x + i + 1, y + yc2*h*.75f*.5f + h/4.f*3.f);
  }
}

float frequency = 261.f;
boolean b = true;
void keyPressed() {
  if(key == ' ') {
    b = !b;
    if(b)
      loop();
    else
      noLoop();
  }
  if(key == 'c') {
    recorded_noise = new float[fftsamps];
  }
}

void mouseWheel(MouseEvent event) {
  frequency -= event.getCount();
}
