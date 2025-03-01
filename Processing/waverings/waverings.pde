ArrayList<Resonator> waves = new ArrayList<Resonator>();

Slider amp = new Slider(10, 10, 300, 40, "Amplitude");
Slider freq = new Slider(10, 60, 300, 40, "Frequency");
Slider phas = new Slider(10, 110, 300, 40, "Phase");

void setup() {
  size(800, 600, P2D);
  frameRate(1000);
  amp.display_value = true;
  freq.display_value = true;
  phas.display_value = true;
  dispWaves();
}

void draw() {
  waves.clear();
  float f = 0.15f;
  float z = 3.173f;
  float theta = (mouseX - width/2)/100.f;
  println(theta*57.f);
  randomSeed(4);
  for(float i = -9.f; i < 9.f; i+=1.f) {
    float xpos = width/4*3 + i*z;
    float ypos = height;
    //xpos = random(-50, 50) + width/2;
    //ypos = random(-50, 50) + height/2;
    //xpos = cos(i)*50.f + width/2;
    //ypos = sin(i)*50.f + height/2;
    //float phase = TWO_PI*i*z*sin(theta)*f/WAVE_SPEED_CONST;
    float phase = TWO_PI*dist(xpos, ypos, mouseX, mouseY)*f/WAVE_SPEED_CONST;
    waves.add(new Resonator(xpos, ypos, f, 10.f, phase));
  }
  for(float i = -9.f; i < 9.f; i+=1.f) {
    float xpos = width/2 + i*z;
    float ypos = height;
    //xpos = random(-50, 50) + width/2;
    //ypos = random(-50, 50) + height/2;
    //xpos = cos(i)*50.f + width/2;
    //ypos = sin(i)*50.f + height/2;
    //float phase = TWO_PI*i*z*sin(theta)*f/WAVE_SPEED_CONST;
    float phase = TWO_PI*dist(xpos, ypos, mouseX, mouseY)*f/WAVE_SPEED_CONST;
    waves.add(new Resonator(xpos, ypos, f, 10.f, phase));
  }
  for(float i = -9.f; i < 9.f; i+=1.f) {
    float xpos = width/4 + i*z;
    float ypos = height;
    //xpos = random(-50, 50) + width/2;
    //ypos = random(-50, 50) + height/2;
    //xpos = cos(i)*50.f + width/2;
    //ypos = sin(i)*50.f + height/2;
    //float phase = TWO_PI*i*z*sin(theta)*f/WAVE_SPEED_CONST;
    float phase = TWO_PI*dist(xpos, ypos, mouseX, mouseY)*f/WAVE_SPEED_CONST;
    waves.add(new Resonator(xpos, ypos, f, 10.f, phase));
  }
  for(float i = -9.f; i < 9.f; i+=1.f) {
    float xpos = 0 + i*z;
    float ypos = height;
    //xpos = random(-50, 50) + width/2;
    //ypos = random(-50, 50) + height/2;
    //xpos = cos(i)*50.f + width/2;
    //ypos = sin(i)*50.f + height/2;
    //float phase = TWO_PI*i*z*sin(theta)*f/WAVE_SPEED_CONST;
    float phase = TWO_PI*dist(xpos, ypos, mouseX, mouseY)*f/WAVE_SPEED_CONST;
    waves.add(new Resonator(xpos, ypos, f, 10.f, phase));
  }
  for(float i = -9.f; i < 9.f; i+=1.f) {
    float xpos = width + i*z;
    float ypos = height;
    //xpos = random(-50, 50) + width/2;
    //ypos = random(-50, 50) + height/2;
    //xpos = cos(i)*50.f + width/2;
    //ypos = sin(i)*50.f + height/2;
    //float phase = TWO_PI*i*z*sin(theta)*f/WAVE_SPEED_CONST;
    float phase = TWO_PI*dist(xpos, ypos, mouseX, mouseY)*f/WAVE_SPEED_CONST;
    waves.add(new Resonator(xpos, ypos, f, 10.f, phase));
  }
  dispWaves();
  dispGUI();
  stroke(255, 255);
  line(0, height/2, width, height/2);
  line(width/2, 0, width/2, height);
  line(width/2, height/2, width/2 - 1000, height/2 - 1000);
}

void dispGUI() {
  amp.update();
  freq.update();
  phas.update();
  amp.display();
  freq.display();
  phas.display();
}

void dispPix() {
  float i = 3.f;
  strokeWeight(4);
  for(float x = 0.f; x < width; x+=i) {
    for(float y = 0.f; y < height; y+=i) {
      float sum = 0.f;
      for(Resonator r : waves) {
        sum += r.f(x, y, 0.f, 0.f);
      }
      sum = 0.f;
      float min = 100000.f;
      float max = -100000.f;
      float n = 0.f;
      for(float k = 0.f; k <= 2*PI; k += PI/20.f) {
        float q = 0.f;
        for(Resonator r : waves) {
          float m = max(0.0, r.f(x, y, 0.f, k));
          q += m;
        }
        if(q < min)
          min = q;
        if(q > max)
          max = q;
        n++;
        sum = abs(max-min)/float(waves.size());
      }
      stroke(sum*10.f, 255);
      point(x, y);

    }
  }
  strokeWeight(1);
}

void dispWaves() {
  background(0);
  colorMode(HSB);
  noFill();
  blendMode(ADD);
  for(Resonator r : waves) {
    for(float i = 0.f; i < 20.f; i++) {
      stroke(i/7.f*255.f, 255, 255, 255.f-i/10.f*255.f);
      float w = r.wavelength*(i + (r.phase/TWO_PI)%1.f);
      ellipse(r.position.x, r.position.y, w*2.f, w*2.f);
    }
  }
  blendMode(BLEND);
  colorMode(RGB);
  if(keyPressed) {
    dispPix();
  }
}

void mousePressed() {
  if(mouseButton == RIGHT) {
    waves.add(new Resonator(mouseX, mouseY, 1.f/100.f, amp.value, phas.value));
    dispWaves();
    dispGUI();
  }
}

final float WAVE_SPEED_CONST = 1.f;
class Resonator {
  PVector position;
  float frequency;
  float amplitude;
  float phase;
  float wavelength;
  float period;
  float angular_frequency;
  public Resonator(PVector position, float frequency, float amplitude, float phase) {
    this.position = copy_vec(position);
    this.frequency = frequency;
    this.amplitude = amplitude;
    this.phase = phase;
    period = 1.f/frequency;
    wavelength = WAVE_SPEED_CONST/frequency;
    angular_frequency = 2.f*PI/period;
  }
  public Resonator(float x, float y, float frequency, float amplitude, float phase) {
    this.position = new PVector(x, y);
    this.frequency = frequency;
    this.amplitude = amplitude;
    this.phase = phase;
    period = 1.f/frequency;
    wavelength = WAVE_SPEED_CONST/frequency;
    angular_frequency = 2.f*PI/period;
  }
  float f(float x, float y, float z, float t) {
    float d = dist(position, new PVector(x, y, z));
    //float s = 0.f;
    //for(float w = 0.f; w < TWO_PI; w += TWO_PI/20.f)
    //  s += amplitude*sin(-angular_frequency*d/WAVE_SPEED_CONST + phase + w);
    //return s;
    return amplitude*sin(-angular_frequency*d/WAVE_SPEED_CONST + phase + t);///(d/100.f);
  }
  float f(PVector p, float t) {
    float d = dist(position, copy_vec(p));
    return amplitude*sin(-angular_frequency*d/WAVE_SPEED_CONST + phase + t);///(d/100.f);
  }
}