Subject subj;
void setup() {
  size(1024, 900, P2D);
  subj = new Subject();
  background(0);
}

void draw() {
  background(0);
  subj.display(100, 100, (float)mouseX/(float)width, 255.0);
  stroke(255);
  float[][] diffd = diffract(subj, frameCount/20.f);
  float[][] ftd = ft(squarify(diffd));
  draw_arr(diffd, 10, 10, 500);
  image(toPic(diffd, 3), 0, 0, 500, 500);
}

float[][] squarify(float[][] dat) {
  int diff = dat.length - dat[0].length;
  if(diff < 0) { println("Height must be < width"); return null; }
  int pad_top = round(diff/2);
  float[][] o = new float[dat.length][dat.length];
  for(int x = 0; x < dat.length; x++) {
    for(int y = 0; y < dat[x].length; y++) {
      o[x][y+pad_top] = dat[x][y];
    }
  }
  return o;
}

float[][] diffract(Subject s, float theta) {
  float[][] o = new float[image_xres][subject_res];
  float e1x = cos(theta);
  float e1y = sin(theta);
  float e2x = sin(theta);
  float e2y = -cos(theta);
  int xc, yc;
  for(int x = 0; x < subject_res; x++) {
    for(int y = 0; y < subject_res; y++) {
      float x0 = e1x*(x-subject_res/2) - e1y*(y-subject_res/2);
      float y0 = e2x*(x-subject_res/2) - e2y*(y-subject_res/2);
      xc = round(x0)+subject_res/2;
      yc = round(y0)+subject_res/2;
      if(xc >= 0 && yc >= 0 && xc < subject_res && yc < subject_res) {
        Spectrum spec = s.px[xc][yc];
        for(int j = 0; j < spectral_res; j++) {
          o[x+j][y] += spec.I[j];
        }
      }
    }
  }
  return o;
}

void draw_arr(float[][] dat, float xx, float yy, float w) {
  strokeWeight(w/(float)dat.length);
  strokeCap(SQUARE);
  float mlt = w/(float)dat.length;
  float vmin = 100000000.0;
  float vmax = -100000000.0;
  for(int x = 0; x < dat.length; x++) {
    for(int y = 0; y < dat[x].length; y++) {
      if(dat[x][y] < vmin) vmin = dat[x][y];
      if(dat[x][y] > vmax) vmax = dat[x][y];
    }
  }
  for(int x = 0; x < dat.length; x++) {
    for(int y = 0; y < dat[x].length; y++) {
      stroke(map(dat[x][y], vmin, vmax, 0, 255));
      point(xx + x*mlt, yy + y*mlt);
    }
  }
  strokeWeight(1);
  stroke(255);
  noFill();
  rect(xx, yy, dat.length*mlt, dat[0].length*mlt);
}

final int spectral_res = 300;
final int subject_res = 212;
final int image_xres = spectral_res+subject_res;
class Subject {
  Spectrum[][] px;
  
  Subject() {
    PImage p = loadImage("img1.png");
    px = from_photo_mono(material_1(), material_2(), p);
  }
  void display(int xx, int yy, float band, float mul) {
    for(int x = 0; x < subject_res; x++) {
      for(int y = 0; y < subject_res; y++) {
        set(xx + x, yy + y, color(px[x][y].I[(int)(band*spectral_res)]*mul));
      }
    }
  }
}

Spectrum[][] from_photo_mono(Spectrum mtl1, Spectrum mtl2, PImage p) {
  p.resize(subject_res, subject_res);
  noiseDetail(2, 0.5);
  Spectrum[][] o = new Spectrum[subject_res][subject_res];
  for(int x = 0; x < subject_res; x++) {
    for(int y = 0; y < subject_res; y++) {
      o[x][y] = mult(mtl1, brightness(p.get(x, y))/255.f);
      if(noise(x/10.0, y/10.0) > 0.5) o[x][y] = mult(mtl2, brightness(p.get(x, y))/255.f);
    }
  }
  return o;
}

class Spectrum {
  float[] I;
  Spectrum(float[] power_dist) {
    I = power_dist;
  }
}
Spectrum mult(Spectrum s, float x) {
  Spectrum o = new Spectrum(s.I.clone());
  for(int i = 0; i < o.I.length; i++) {
    o.I[i] *= x;
  }
  return o;
}

Spectrum material_1() {
  float[] o = new float[spectral_res];
  for(int i = 0; i < o.length; i++) {
    float x = (i/(float)spectral_res);
    o[i] = 0.9*exp(-pow(40*(x-0.7), 2)) + 0.2*exp(-pow(5*(x-0.45), 2)) + 0.2*exp(-pow(30*(x-0.77), 2));
  }
  return new Spectrum(o);
}

Spectrum material_2() {
  float[] o = new float[spectral_res];
  for(int i = 0; i < o.length; i++) {
    float x = (i/(float)spectral_res);
    o[i] = (0.2+0.5*pow(sin(30*x*x), 2.0))*exp(-pow(5*(x-0.4), 2));
  }
  return new Spectrum(o);
}
