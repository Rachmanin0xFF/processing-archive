float[][] toArray(PImage p) {
  float[][] dat = new float[p.width][p.height];
  for(int x = 0; x < p.width; x++)
  for(int y = 0; y < p.height; y++) {
    color q = p.get(x, y);
    dat[x][y] = r(q) + random(-0.5, 0.5);
  }
  return dat;
}

PImage toPic(float[][] dat) {
  PImage p = createImage(dat.length, dat[0].length, ARGB);
  
  
  float mean = 0.f;
  for(int x = 0; x < p.width; x++)
  for(int y = 0; y < p.height; y++) {
    //dat[x][y] = abs(dat[x][y]);
    mean += dat[x][y];
  }
  mean /= (float)p.width*(float)p.height;
  float varr = 0.f;
  for(int x = 0; x < p.width; x++)
  for(int y = 0; y < p.height; y++) {
    varr += abs(mean - dat[x][y]);//*(mean - dat[x][y]);
  }
  varr /= (float)p.width*(float)p.height - 1;
  //varr = sqrt(varr);
  float min = mean - 1.0*varr;
  float max = mean + 1.0*varr;
  
  min = Float.MAX_VALUE;
  max = -Float.MAX_VALUE;
  
  for(int x = 0; x < p.width; x++)
  for(int y = 0; y < p.height; y++) {
    if((x - p.width/2)*(x-p.width/2) + (y-p.height/2)*(y-p.height/2) > 25) {
      if(abs(dat[x][y]) < min) min = abs(dat[x][y]);
      if(abs(dat[x][y]) > max) max = abs(dat[x][y]);
    }
  }
  
  for(int x = 0; x < p.width; x++)
  for(int y = 0; y < p.height; y++) {
    //p.set(x, y, grad.get((int)map(dat[x][y], min, max, grad.width, 0), 1));
    //p.set(x, y, color(max(0, dat[x][y]), 0, max(0, -dat[x][y])));
    //p.set(x, y, color(abs(dat[x][y])));
    p.set(x, y, color(map(dat[x][y], min, max, 0, 255), 255));
  }
  return p;
}

float[][] ft(float[][] p) {
  float[][] o = new float[p.length][p.length];
  for(int i = 0; i < p.length; i++) {
    float[] op = fft(p[i]);
    for(int j = 0; j < p.length; j++) {
      o[i][j] = op[j];
    }
  }
  o = transpose(o);
  float[][] o2 = new float[p.length][p.length];
  for(int i = 0; i < p.length; i++) {
    float[] op = fft(o[i]);
    for(int j = 0; j < p.length; j++) {
      o2[i][j] = op[j];
    }
  }
  float[][] o3 = new float[p.length][p.length];
  for(int i = 0; i < p.length; i++) {
    for(int j = 0; j < p.length; j++) {
      o3[i][j] = o2[(i+p.length/2)%p.length][(j+p.length/2)%p.length];
    }
  }
  return o3;
}

PImage reduce_img(PImage p) {
  PVector[][] px = new PVector[p.width][p.height];
  for(int x = 0; x < px.length; x++)
  for(int y = 0; y < px[0].length; y++) {
    px[x][y] = to_vec(p.get(x, y));
  }
  return reduce_img(px);
}

PImage reduce_img(PVector[][] px) {
  PImage o = createImage(px.length, px[0].length, RGB);
  
  PVector[][] px2 = new PVector[o.width][o.height];
  for(int x = 0; x < px.length; x++)
  for(int y = 0; y < px[0].length; y++) {
    px2[x][y] = cpv(px[x][y]);
  }
  
  for(int x = 0; x < px.length; x++) {
    float f = randomGaussian()*0;
    px[x][0] = px[x][0].add(new PVector(f, f, f));
  }
  
  //bidirectional (switches every scanline) minimized average error diffusion
  for(int y = 0; y < px[0].length; y++) {
    if(y%2==0) {
      for(int x = 0; x < px.length; x++) {
        PVector current = px[x][y];
        PVector nu = quantize(current);
        PVector err = error(current, nu);
        
        
        //PVector dvals = cpv(dither_diffusion_coeff[(int)min(255.5, max(0, (int)(px2[x][y].x) + random(-100, 100)))]);
        PVector dvals = new PVector(abs(randomGaussian()), abs(randomGaussian()), abs(randomGaussian()));
        //dvals.x *= dither_diffusion_coeff[(int)(px2[x][y].x)].x;
        //dvals.y *= dither_diffusion_coeff[(int)(px2[x][y].x)].y;
        //dvals.z *= dither_diffusion_coeff[(int)(px2[x][y].x)].z;
        float dvl = dvals.x + dvals.y + dvals.z;
        dvals = dvals.mult(1.f/dvl);
        
        /*
        add_to(px, x+1, y, cpv(err).mult(7.f/16.f));
        add_to(px, x-1, y+1, cpv(err).mult(3.f/16.f));
        add_to(px, x, y+1, cpv(err).mult(5.f/16.f));
        add_to(px, x+1, y+1, cpv(err).mult(1.f/16.f));
        */
        
        add_to(px, x+1, y, cpv(err).mult(dvals.x));
        add_to(px, x, y+1, cpv(err).mult(dvals.z));
        add_to(px, x-1, y+1, cpv(err).mult(dvals.y));
        
        
        //add_to(px, x+1, y, cpv(err).mult(dvals.x));
        //add_to(px, x, y+1, cpv(err).mult(dvals.z));
        //add_to(px, x-1, y+1, cpv(err).mult(dvals.y));
        //add_to(px, x-2, y+1, cpv(err).mult(1.f - (dvals.x + dvals.y + dvals.z)));
        
        px[x][y] = nu;
      }
    } else {
      for(int x = px.length-1; x >= 0; x--) {
        PVector current = px[x][y];
        PVector nu = quantize(current);
        PVector err = error(current, nu);
        
        
        //PVector dvals = cpv(dither_diffusion_coeff[(int)min(255.5, max(0, (int)(px2[x][y].x) + random(-100, 100)))]);
        PVector dvals = new PVector(abs(randomGaussian()), abs(randomGaussian()), abs(randomGaussian()));
        //dvals.x *= dither_diffusion_coeff[(int)(px2[x][y].x)].x;
        //dvals.y *= dither_diffusion_coeff[(int)(px2[x][y].x)].y;
        //dvals.z *= dither_diffusion_coeff[(int)(px2[x][y].x)].z;
        float dvl = dvals.x + dvals.y + dvals.z;
        dvals = dvals.mult(1.f/dvl);
        
        
        /*
        add_to(px, x-1, y, cpv(err).mult(7.f/16.f));
        add_to(px, x+1, y+1, cpv(err).mult(3.f/16.f));
        add_to(px, x, y+1, cpv(err).mult(5.f/16.f));
        add_to(px, x-1, y+1, cpv(err).mult(1.f/16.f));
        */
        
        add_to(px, x-1, y, cpv(err).mult(dvals.x));
        add_to(px, x, y+1, cpv(err).mult(dvals.z));
        add_to(px, x+1, y+1, cpv(err).mult(dvals.y));
        
        
        //add_to(px, x-1, y, cpv(err).mult(dvals.x));
        //add_to(px, x, y+1, cpv(err).mult(dvals.z));
        //add_to(px, x+1, y+1, cpv(err).mult(dvals.y));
        //add_to(px, x+2, y+1, cpv(err).mult(1.f - (dvals.x + dvals.y + dvals.z)));
        
        px[x][y] = nu;
      }
    }
  }
  
  for(int x = 0; x < px.length; x++)
  for(int y = 0; y < px[0].length; y++) {
    o.set(x, y, to_col(px[x][y]));
  }
  
  
  return o;
}

boolean BW = false;

PVector error(PVector a, PVector b) {
  return cpv(cpv(a).sub(b));
}

PVector quantize(PVector v) {
  return new PVector(f(v.x), f(v.y), f(v.z));
}

float f(float x) {
  return x > 127 ? 255 : 0;
  //return round(x/255.f*5.f)*255.f/5.f;
}

PVector cpv(PVector p) {
  return new PVector(p.x, p.y, p.z);
}

float luma(float r, float g, float b) {
  return 0.2126*r + 0.7152*g + 0.0722*b;
}

color to_col(PVector v) {
  //if(BW) return color(v.x, v.x, v.x);
  return color(v.x, v.y, v.z);
}

PVector to_vec(color c) {
  if(BW) return new PVector(luma(r(c), g(c), b(c)), luma(r(c), g(c), b(c)), luma(r(c), g(c), b(c)));
  return new PVector(r(c), g(c), b(c));
}

public static float[][] transpose(float[][] matrix){
    int m = matrix.length;
    int n = matrix[0].length;

    float[][] transposedMatrix = new float[n][m];

    for(int x = 0; x < n; x++) {
        for(int y = 0; y < m; y++) {
            transposedMatrix[x][y] = matrix[y][x];
        }
    }

    return transposedMatrix;
}

int r(color c) {return (c >> 16) & 255; }
int g(color c) {return (c >> 8) & 255;}
int b(color c) {return c & 255; }

void add_to(PVector[][] px, int x, int y, PVector c) {
  if(x >= 0 && y >= 0 && x < px.length && y < px[0].length) px[x][y].add(c);
}
