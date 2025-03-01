
// TODO: Dithering, color spaces

class dImage {
  int w;
  int h;
  dVec3[][] px;
  dVec3 mean_col;
  dVec3 min_col;
  dVec3 max_col;
  dVec3 std_dev_col;
  dVec3 dev_col_0;
  long count = 0;
  boolean z_test = true;
  double[][] z;
  dImage(int w, int h) {
    this.w = w;
    this.h = h;
    px = new dVec3[w][h];
    z = new double[w][h];
    for(int x = 0; x < w; x++) {
      for(int y = 0; y < h; y++) {
        px[x][y] = new dVec3();
        z[x][y] = Double.MAX_VALUE;
      }
    }
  }
  void clear() {
    for(int x = 0; x < w; x++) {
      for(int y = 0; y < h; y++) {
        px[x][y].x = 0;
        px[x][y].y = 0;
        px[x][y].z = 0;
        z[x][y] = Double.MAX_VALUE;
      }
    }
    count = 0;
  }
  void hit_photon(int x, int y, double r, double g, double b) {
    count++;
    if(y > h-1 || y < 0 || x > w-1 || x < 0) return;
    px[x][y].add(new dVec3(r, g, b));
  }
  double get_z(double x, double y) {
    int xc = round((float)x);
    int yc = round((float)y);
    if(yc > h-1 || yc < 0 || xc > w-1 || xc < 0) return -10000000000.0;
    return z[xc][yc];
  }
  void hit_photon(double x, double y, double r, double g, double b) {
    count++;
    int xc = round((float)x);
    int yc = round((float)y);
    if(yc > h-1 || yc < 0 || xc > w-1 || xc < 0) return;
    px[xc][yc].add(new dVec3(r, g, b));
  }
  void hit_photon_z(double x, double y, double depth, double r, double g, double b) {
    count++;
    int xc = round((float)x);
    int yc = round((float)y);
    if(yc > h-1 || yc < 0 || xc > w-1 || xc < 0) return;
    if(depth < z[xc][yc]) {
      px[xc][yc] = lerp(px[xc][yc], new dVec3(r, g, b), Math.max(0.2, Math.min(1.0, Math.abs(depth - z[xc][yc]))));
      z[xc][yc] = depth;
    }
  }
  void hit_photon_01(double x, double y, double r, double g, double b) {
    hit_photon((x+1.0)*w/2.0, (y+1.0)*h/2.0, r, g, b);
  }
  void hit_photon_z_01(double x, double y, double z, double r, double g, double b) {
    hit_photon_z((x+1.0)*w/2.0, (y+1.0)*h/2.0, z, r, g, b);
  }
  void hit_photon_linear_01(double x, double y, double r, double g, double b) {
    hit_photon_linear((x+1.0)*w/2.0, (y+1.0)*h/2.0, r, g, b);
  }
  void hit_photon_DoF(double x, double y, double r, double g, double b, double CoC) {
    double im = 1.f/(CoC*CoC);
    double a = (double)w/(double)h;
    int n = 0;
    for(double xc = -CoC*a; xc <= CoC*a; xc+=1/(double)w) {
      for(double yc = -CoC; yc <= CoC; yc+=1.0/(double)h) {
        if(xc*xc*a*a+yc*yc <= CoC*CoC) {
          hit_photon_01(x+xc, y+yc, r*im, g*im, b*im);
          n++;
        }
      }
    }
    if(n == 0) hit_photon_linear_01(x, y, r, g, b);
  }
  void calc_stats() {
    dVec3[] mmx = mean_min_max(px);
    mean_col = mmx[0];
    min_col = mmx[1];
    max_col = mmx[2];
    std_dev_col = std_dev(px, mean_col);
    dev_col_0 = std_dev(px, new dVec3(0.0));
  }
  PImage to_image_simple(boolean SSAO) {
    calc_stats();
    PImage pic = createImage(w, h, RGB);
    pic.loadPixels();
    dVec3 top = new dVec3(dev_col_0.max_component()*6.0);
    dVec3 bot = new dVec3(0.0);
    for(int x = 0; x < w; x++) {
      for(int y = 0; y < h; y++) {
        dVec3 q = new dVec3(px[x][y]);
        if(SSAO && z[x][y] != Double.MAX_VALUE) {
          double frac = 0.0;
          float samps = 400;
          for(int i = 0; i < samps; i++) {
            float r = random(100);
            float t = random(TWO_PI);
            frac -= (get_z(x + r*cos(t), y+r*sin(t)) <= z[x][y])?1:0;
          }
          frac = frac/samps + 1.0;
          q = new dVec3(px[x][y]);
          q.mult(frac*3.0);
        }
        pic.pixels[y*px.length + x] = to_color(q, bot, top);
      }
    }
    pic.updatePixels();
    return pic;
  }
  
  // warning: only accurate to bin resolution!!! (lerping in bins doesn't help much in relevant edge cases)
  // higher percentile = dimmer image
  PImage to_image_percentile(double white_percentile) {
    calc_stats();
    
    double[] q = min_max(px);
    double min = q[0];
    double max = q[1];
    int[] pic_hist = mag_histo(px, 10000, 16);
    long histo_sum = 0;
    for(int i : pic_hist) {
      histo_sum += i;
    }
    long ticker = 0;
    long cutoff = (long)((double)(histo_sum) * white_percentile);
    int i = 0;
    for(; i < pic_hist.length; i++) {
      ticker += pic_hist[i];
      if(ticker > cutoff) {
        break;
      }
    }
    i = max(i, 1);
    dVec3 bot = new dVec3(0.0);
    dVec3 top = new dVec3((i)/((pic_hist.length-1)/(max-min)) + min);
    
    PImage pic = createImage(w, h, RGB);
    pic.loadPixels();
    for(int x = 0; x < w; x++) {
      for(int y = 0; y < h; y++) {
        dVec3 w = new dVec3(px[x][y]);
        pic.pixels[y*px.length + x] = to_color(w, bot, top);
      }
    }
        
    pic.updatePixels();
    return pic;
  }
  PImage to_image_MAX() {
    calc_stats();
    PImage pic = createImage(w, h, RGB);
    pic.loadPixels();
    dVec3 top = new dVec3(1.0);
    dVec3 bot = new dVec3(0.0);
    for(int x = 0; x < w; x++) {
      for(int y = 0; y < h; y++) {
        pic.pixels[y*px.length + x] = to_color(px[x][y], bot, top);
      }
    }
    pic.updatePixels();
    return pic;
  }
  void hit_photon_linear(double x, double y, double r, double g, double b) {
    count++;
    int xmin = floor((float)x+0.5);
    int ymin = floor((float)y+0.5);
    int xmax = ceil((float)x+0.5);
    int ymax = ceil((float)y+0.5);
    if(ymin > h-1 || ymax < 0 || xmin > w-1 || xmax < 0) return;
    
    float hix = (float)(x+0.5) - xmin;
    float lox = xmax - (float)(x+0.5);
    
    float loy = ymax - (float)(y+0.5);
    float hiy = (float)(y+0.5) - ymin;
    
    if(ymin >= 0) {
      if(xmin >= 0)
      px[xmin][ymin].add(new dVec3(lox*loy*r, lox*loy*g, lox*loy*b));
      if(xmax <= w-1)
      px[xmax][ymin].add(new dVec3(hix*loy*r, hix*loy*g, hix*loy*b));
    }
    if(ymax <= h-1) {
      if(xmin >= 0)
      px[xmin][ymax].add(new dVec3(lox*hiy*r, lox*hiy*g, lox*hiy*b));
      if(xmax <= w-1)
      px[xmax][ymax].add(new dVec3(hix*hiy*r, hix*hiy*g, hix*hiy*b));
    }
  }
}
dVec3 mean(dVec3[][] a) {
  dVec3 sum = new dVec3();
  for(int x = 0; x < a.length; x++) {
    for(int y = 0; y < a[0].length; y++) {
      sum.add(a[x][y]);
    }
  }
  sum.mult(1.0/(a.length*a[0].length));
  return sum;
}

color to_color(dVec3 a, dVec3 a_min, dVec3 a_max) {
  int r = round((float)map(a.x, a_min.x, a_max.x, 0, 255));
  int g = round((float)map(a.y, a_min.y, a_max.y, 0, 255));
  int b = round((float)map(a.z, a_min.z, a_max.z, 0, 255));
  return color(r, g, b, 255);
}

double map(double value, double min1, double max1, double min2, double max2) {
  return min2 + (value - min1) * (max2 - min2) / (max1 - min1);
}

int[][] histo(dVec3[][] a, int bin_count, int skip) {
  double[] q = min_max(a);
  double min = q[0];
  double max = q[1];
  int[][] bins = new int[bin_count][3];
  double temp_mult = (bin_count-1)/(max-min);
  for(int x = 0; x < a.length; x+=skip) for(int y = 0; y < a[0].length; y+=skip) {
    if(a[x][y].x > 0 || a[x][y].y > 0 || a[x][y].z > 0) {
      bins[(int)((a[x][y].x - min)*temp_mult)][0]++;
      bins[(int)((a[x][y].y - min)*temp_mult)][1]++;
      bins[(int)((a[x][y].z - min)*temp_mult)][2]++;
    }
  }
  return bins;
}

int[] mag_histo(dVec3[][] a, int bin_count, int skip) {
  double[] q = min_max(a);
  double min = q[0];
  double max = q[1];
  int[] bins = new int[bin_count];
  double temp_mult = (bin_count-1)/(max-min);
  for(int x = 0; x < a.length; x+=skip) for(int y = 0; y < a[0].length; y+=skip) {
    if(a[x][y].x > 0 || a[x][y].y > 0 || a[x][y].z > 0) {
      bins[(int)(((a[x][y].x + a[x][y].y + a[x][y].z)/3.0 - min)*temp_mult)]++;
    }
  }
  return bins;
}

double[] min_max(dVec3[][] a) {
  double mn = Double.MAX_VALUE;
  double mx = -Double.MAX_VALUE;
  for(int x = 0; x < a.length; x++) for(int y = 0; y < a[0].length; y++) {
    double k = a[x][y].max_component();
    mn = Math.min(k, mn);
    mx = Math.max(k, mx);
  }
  return new double[]{mn, mx};
}

dVec3[] mean_min_max(dVec3[][] a) {
  dVec3 sum = new dVec3();
  dVec3 mn = new dVec3(Double.MAX_VALUE);
  dVec3 mx = new dVec3(-Double.MAX_VALUE);
  for(int x = 0; x < a.length; x++) for(int y = 0; y < a[0].length; y++) {
    sum.add(a[x][y]);
    mn = min(mn, a[x][y]);
    mx = max(mx, a[x][y]);
  }
  sum.mult(1.0/(a.length*a[0].length));
  return new dVec3[]{sum, mn, mx};
}

dVec3 std_dev(dVec3[][] a, dVec3 mean_vec) {
  dVec3 sum = new dVec3();
  for(int x = 0; x < a.length; x++) {
    for(int y = 0; y < a[0].length; y++) {
      sum.add(square_components(sub(a[x][y], mean_vec)));
    }
  }
  sum.mult(1.0/(a.length*a[0].length));
  return sqrt_components(sum);
}
