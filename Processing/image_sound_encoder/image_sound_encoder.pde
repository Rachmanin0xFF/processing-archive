import ddf.minim.*;
import ddf.minim.ugens.*;
 
Minim minim;
AudioOutput out;

float level_low = 1000.1f;
float level_high = 20000.f;
int resolution = 150;
float sending_speed = 0.45f;

ArrayList<Oscil> wave = new ArrayList<Oscil>();
float[] levels = new float[resolution]; //200-400//
Wavetable table;
PImage img;
PImage scale;
FourierTransformer fft = new FourierTransformer();
float pic_x = 0.f;

float loop_102152 = (level_high - level_low)/float(resolution);
float wv_mult_102152 = 0.5f/float(resolution);
float wave_len = 0.f;

void setup() {
  size(512, 200, P2D);
  img = loadImage("line.png");
  minim = new Minim(this);
  out = minim.getLineOut(Minim.MONO, 1024, 22010);
  int i = 0;
  for(float k = level_low; k <= level_high + 1.f; k += loop_102152) {
    wave.add(new Oscil(k, wv_mult_102152, Waves.SINE));
    wave.get(i).patch(out);
    wave_len++;
    i++;
  }
}

void draw() {
  int i = 0;
  for(float k = level_low; k <= level_high + 1.f; k += loop_102152) {
    float y = img.height - float(i)/wave_len*(float)img.height;
    
    //float y2 = scale.height - float(i)/wave_len*(float)scale.height;
    //color c_scale = scale.get(3, (int)y2);
    //float value2 = 1.f - ((float)b(c_scale))/255.f;
    
    color c = img.get(img.width - (int)pic_x, (int)y);
    float value = float(r(c) + g(c) + b(c))/255.f;
    
    wave.get(i).setAmplitude(wv_mult_102152*value);
    i++;
  }
  pic_x += sending_speed;
}
