PImage gain;
PImage phase;

PVector[] gv;
PVector[] pv;

void setup() {
  gain = loadImage("gain.png");
  phase = loadImage("phase.png");
  ArrayList<PVector> lerp_gain = new ArrayList<PVector>();
  ArrayList<PVector> lerp_phase = new ArrayList<PVector>();
  String ostring = "";
  for(int i = 0; i < gain.width; i+=10) {
    int k = 0;
    for(k = 0; k < gain.height; k++) {
      if(brightness(gain.get(i, k)) > 100) break;
    }
    if(k != gain.height) {
      PVector vo = to_gain_vec(i, k);
      lerp_gain.add(vo);
      ostring += vo.x + " " + vo.y + "\n";
    }
  }
  saveStrings("gain.txt", new String[]{ostring});
  ostring = "";
  for(int i = 0; i < phase.width; i+=10) {
    int k = 0;
    for(k = 0; k < phase.height; k++) {
      if(brightness(phase.get(i, k)) > 100) break;
    }
    if(k != phase.height) {
      PVector vo = to_phase_vec(i, k);
      println(vo.x, vo.y);
      ostring += vo.x + " " + vo.y + "\n";
    }
  }
  saveStrings("phase.txt", new String[]{ostring});
}

PVector to_gain_vec(float x, float y) {
  float expt = map(x, 0, gain.width, -4, 4);
  float x_o = pow(10, expt);
  float y_o = map(y, 0, gain.height, 100, -80);
  return new PVector(x_o, y_o);
}

PVector to_phase_vec(float x, float y) {
  float expt = map(x, 0, phase.width, -4, 4);
  float x_o = pow(10, expt);
  float y_o = map(y, 0, phase.height, 0, -180);
  return new PVector(x_o, y_o);
}
