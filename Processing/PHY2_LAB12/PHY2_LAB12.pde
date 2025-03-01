
Run[] runz;

float[] final_vals;
float[] double_corr;

float zum = 20.0;

void setup() {
  size(1600, 900, P2D);
  runz = new Run[12];
  for(int i = 0; i < runz.length; i++) {
    runz[i] = new Run("data/run" + (i+1) + ".csv");
  }
  calc_phase_runs();
  final_vals = new float[runz[0].x.length];
  for(int i = 0; i < runz[0].x.length; i++) {
    for(int k = 0; k < runz.length; k++) {
      int i2 = i + runz[k].phase_offset;
      if(i2 >= 0 && i2 < runz[k].x.length-1) {
        final_vals[i] += runz[k].y[i2];
      }
    }
    final_vals[i] = abs(final_vals[i]);
  }
  
  double_corr = new float[runz[0].x.length];
  background(0);
  
  for(int i = 0; i < double_corr.length; i++) {
    double_corr[i] = corr_2(new Run(final_vals), new Run(final_vals), i, false);
  }
  
  saveFloats(runz[0].x, double_corr, "autocorrelation.txt");
}

void saveFloats(float[] x, float[] y, String fname) {
  String[] arr = new String[x.length];
  for(int i = 0; i < arr.length; i++) {
    arr[i] = x[i] + " " + y[i];
  }
  saveStrings(fname, arr);
}

void draw() {
  //background(0);
  fill(0, 100);
  noStroke();
  rect(0, 0, width, height/2);
  /*
  for(int i = 0; i < runz.length; i++) {
    runz[i].plot(50, i*100 + 50, 500);
  }
  float qq = (float)mouseX/507.f;
  ellipse(100, (runz[0].get_at(qq))*100.f + height/2, 50, 50);
  */
  stroke(255);
  plot(final_vals, 0, height/4, width, 0.5);
  plot(double_corr, 0, height/4*3, width, 1.0);
  /*
  plot(corr_vals, width/2, 100, 500, 50);
  stroke(255, 0, 0, 100);
  runz[4].plot(10, 300, width - 20);
  stroke(100, 255, 0, 100);
  runz[kkkk].plot(10, 300, width - 20, moff);
  colorMode(HSB);
  fill((frameCount%20)*1.5, 255, 255);
  colorMode(RGB);
  text(corr_2(runz[4], runz[kkkk], moff) + " " + moff, 10, 10);
  noStroke();
  ellipse(width/2 + moff*2, height/3*2 - 1000*corr_vals[min(500, max(0, moff+corr_vals.length/2))] + 300, 2, 2);
  */
}

int kkkk = 0;
void mousePressed() {
  kkkk++;
  background(0);
}

void calc_phase_runs() {
  for(int kkkk = 0; kkkk < runz.length; kkkk++) {
  float max_val = 0.f;
  int max_moff = 0;
  float[] corr_vals = new float[runz[0].x.length];
  for(int i = 0; i < corr_vals.length; i++) {
    corr_vals[i] = corr_2(runz[4], runz[kkkk], i - corr_vals.length/2, false);
    if(corr_vals[i] > max_val) {
      max_val = corr_vals[i];
      max_moff = i-corr_vals.length/2;
    }
  }
  int moff = max_moff;//(int)(mouseX - width/2)/3;
  runz[kkkk].phase_offset = moff;
  println(kkkk + " " + moff*0.1f);
  }
}

/*
void phase_plot(Run r) {
  float period_range = 100.f;
  float period_step = 1.f;
  float phase_step = TWO_PI/100.f;
  float xp = 0;
  float yp = 0;
  for(float T = 0; T < period_range; T += period_step) {
    for(float w = 0; w < TWO_PI; w += phase_step) {
      
      float f = 1/T;
      float phase_offset = (w/TWO_PI)*T;
      for(float x = 0; x < 50.0; x+=0.1) {
        float y = r.get_at(x);
        for(float j = 0; j < T; j
        float y2 = r.get_at(x%T + T);
      }
    }
  }
}
*/

float cross_corr(Run r1, Run r2, float offset_s) {
  return cross_correlation(r1, r2, round(offset_s*100.0));
}

float corr_2(Run r1, Run r2, int offset, boolean subb) {
  float sum = 0.0;
  for(int i = 0; i < r1.y.length; i++) {
    int i2 = i+offset;
    if(i2 >= 0 && i2 < r1.y.length) {
      //sum += 0.01/(0.015+abs(r1.y[i] - r2.y[i2]));
      //if(r1.y[i]*r2.y[i2] > 0)
      //sum+=0.01f/(0.01f+(r1.y[i] - r2.y[i2])*(r1.y[i] - r2.y[i2]));
      sum+=1-(r1.y[i] - r2.y[i2])*(r1.y[i] - r2.y[i2]);
    }
  }
  sum /= (r1.y.length - (subb?abs(offset):0))*1.f;
  return sum;
}

float cross_correlation(Run r1, Run r2, int offset) {
  float mean_1 = 0.f;
  float mean_2 = 0.f;
  for(int i = 0; i < r1.y.length; i++) {
    mean_1 += r1.y[i];
    mean_2 += r2.y[i];
  }
  mean_1 /= 1.0*r1.y.length;
  mean_2 /= 1.0*r1.y.length;
  float num = 0.f;
  float dv1 = 0.f;
  float dv2 = 0.f;
  for(int i = 0; i < r1.y.length; i++) {
    int i2 = i-offset;
    if(i2 >= 0 && i2 < r1.y.length) {
      num += (r1.y[i] - mean_1)*(r2.y[i2] - mean_2);
      dv1 += (r1.y[i] - mean_1)*(r1.y[i] - mean_1);
      dv2 += (r1.y[i2] - mean_2)*(r1.y[i2] - mean_2);
    }
  }
  dv1 = sqrt(dv1);
  dv2 = sqrt(dv2);
  return num/(dv1*dv2);
}

class Run {
  float[] x;
  float[] y;
  float[] tsf_y;
  float max_x = 0;
  float samp_count = 0;
  int phase_offset = 0;
  Run(float[] yy) {
    this.x = yy;
    this.y = yy;
  }
  Run(String loc) {
    String[] dat = loadStrings(loc);
    ArrayList<PVector> poopers = new ArrayList<PVector>();
    for(int i = 1; i < dat.length; i++) {
      String[] qual = dat[i].split(",");
      if(qual.length > 1 && (i-1)%5==0) {
        float xp = float(qual[0]);
        float yp = float(qual[2]);
        poopers.add(new PVector(xp, yp));
      }
    }
    x = new float[poopers.size()];
    y = new float[poopers.size()];
    for(int i = 0; i < poopers.size(); i++) {
      x[i] = poopers.get(i).x;
      if(x[i] > max_x) max_x = x[i];
      y[i] = poopers.get(i).y;
    }
    samp_count = x.length;
    println("Max X: " + max_x);
    println("Samples: " + samp_count);
    filterY(0.1);
  }
  float get_at(float xval) {
    if(xval < 0 || ceil(xval*10.0) > y.length-1) return 0;
    float intrp = xval*10.0 - floor(xval*10.0);
    return y[floor(xval*10.0)]*(1.0 - intrp) + y[ceil(xval*10.0)]*intrp;
  }
  void filterY(float val) {
    for(int i = 0; i < x.length; i++) {
      y[i] = max(abs(y[i]) - val, 0)*(y[i]<0?-1:1);
    }
  }
  void plot(float xx, float yy, float ww) {
    for(int i = 1; i < x.length; i++) {
      line(x[i]*ww/max_x + xx, y[i]*zum + yy, x[i-1]*ww/max_x + xx, y[i-1]*zum + yy);
    }
  }
  void plot(float xx, float yy, float ww, int moff) {
    for(int i = 1; i < x.length; i++) {
      int y2 = min(x.length-1, max(1, i+moff));
      line(x[i]*ww/max_x + xx, y[y2]*zum + yy, x[i-1]*ww/max_x + xx, y[y2-1]*zum + yy);
    }
  }
}

void plot(float[] y, float xx, float yy, float ww, float ymult) {
  stroke(255, 0, 255);
  float max_x = y.length;
  for(int i = 1; i < y.length; i++) {
    line(i*ww/max_x + xx, 10*y[i]*ymult + yy, (i-1)*ww/max_x + xx, 10*y[i-1]*ymult + yy);
  }
}
