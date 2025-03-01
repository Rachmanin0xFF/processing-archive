
//============================================= IMAGES =====================================================//

// Edge handling
// 0 - clamp edges
// 1 - wrap edges (torus)
// 2 - black edges (0)
// 3 - white edges (255)

int EDGE_MODE = 0;

// Texture mag filtering
// 0 - nearest
// 1 - bilinear
// 2 - bicubic
// 3 - Mitchell-Netravali filters / BC-splines
//       Hermite              B=0   C=0
//       B-Spline             B=1   C=0    (smoothest)
//       Sharp Bicubic        B=0   C=1
//       Mitchell-Netravali   B=1/3 C=1/3  (recommended)
//       Catmull-Rom          B=0   C=0.5
//       Photoshop Cubic      B=0   C=0.75
//       (B+2C = 1 are considered visually satisfactory)

int IMAGE_FILTER_MODE = 2;

float BC_SPLINE_B = 0.333333;
float BC_SPLINE_C = 0.333333;

PVector getVector255(PImage p, float x, float y) {
  color c = p.get(max(0, min(p.width-1, round(x))), max(0, min(p.height-1, round(y))));
  return new PVector((float)r(c), (float)g(c), (float)b(c));
}

PVector[][] toVectors(PImage p) {
  PVector[][] o = new PVector[p.width][p.height];
  color c = 0;
  for(int x = 0; x < p.width; x++) for(int y = 0; y < p.height; y++) {
    c = p.pixels[x + y*p.width];
    o[x][y] = new PVector(r(c), g(c), b(c));
  }
  return o;
}

PVector getVecFiltered(PVector[][] img, float x, float y) {
  switch(IMAGE_FILTER_MODE) {
    case 0: // nearest
      return getVec(img, round(x), round(y));
    case 1: // bilinear
      float dx = x%1;
      float dy = y%1;
      
      return PVector.add(PVector.add(PVector.mult(getVec(img, floor(x), floor(y)), (1-dx)*(1-dy)),
                                     PVector.mult(getVec(img, floor(x+1), floor(y)),  dx*(1-dy))),
                         PVector.add(PVector.mult(getVec(img, floor(x), floor(y+1)),   (1-dx)*dy),
                                     PVector.mult(getVec(img, floor(x+1), floor(y+1)),   dx*dy)));
    case 2:
      return getVecCubicX(img, x, y);
    case 3:
      return getVecMitchellNetravaliX(img, x, y, BC_SPLINE_B, BC_SPLINE_C);
    default:
      println("Unsupported filter mode!");
      break;
  }
  return null;
}

// these next two functions are helpers for cubic interpolation during image upscaling
PVector getVecCubicX(PVector[][] img, float x, float y) {
  PVector _p0 = getVecCubicY(img, floor(x)-1, y);
  PVector _p1 = getVecCubicY(img, floor(x), y);
  PVector _p2 = getVecCubicY(img, ceil(x), y);
  PVector _p3 = getVecCubicY(img, ceil(x)+1, y);

  float _x = x - floor(x);

  // credit to https://www.paulinternet.nl/?page=bicubic for crunching the algebra here

  return PVector.add(_p1, PVector.mult(PVector.add(PVector.sub(_p2, _p0), PVector.mult((PVector.add(PVector.add(PVector.sub(PVector.mult(_p0, 2.0), PVector.mult(_p1, 5.0)), PVector.sub(PVector.mult(_p2, 4.0), _p3)), 
                          PVector.mult(PVector.add(PVector.mult(PVector.sub(_p1, _p2), 3.0), PVector.sub(_p3, _p0)), _x))), _x)), 0.5*_x));
}
PVector getVecCubicY(PVector[][] img, int x, float y) {
  PVector _p0 = getVec(img, x, floor(y)-1);
  PVector _p1 = getVec(img, x, floor(y));
  PVector _p2 = getVec(img, x, ceil(y));
  PVector _p3 = getVec(img, x, ceil(y)+1);

  float _x = y - floor(y);

  // credit to https://www.paulinternet.nl/?page=bicubic for crunching the algebra here

  return PVector.add(_p1, PVector.mult(PVector.add(PVector.sub(_p2, _p0), PVector.mult((PVector.add(PVector.add(PVector.sub(PVector.mult(_p0, 2.0), PVector.mult(_p1, 5.0)), PVector.sub(PVector.mult(_p2, 4.0), _p3)), 
                          PVector.mult(PVector.add(PVector.mult(PVector.sub(_p1, _p2), 3.0), PVector.sub(_p3, _p0)), _x))), _x)), 0.5*_x));
}

PVector getVecMitchellNetravaliX(PVector[][] img, float x, float y, float B, float C) {
  PVector p0, p1, p2, p3;
  float d = x - floor(x);
  
  if(d == 0.0) {
    p0 = getVecMitchellNetravaliY(img, floor(x)-1, y, B, C);
    p1 = getVecMitchellNetravaliY(img, floor(x), y, B, C);
    p2 = getVecMitchellNetravaliY(img, floor(x)+1, y, B, C);
    p3 = getVecMitchellNetravaliY(img, floor(x)+2, y, B, C);
  } else {
    p0 = getVecMitchellNetravaliY(img, floor(x)-1, y, B, C);
    p1 = getVecMitchellNetravaliY(img, floor(x), y, B, C);
    p2 = getVecMitchellNetravaliY(img, ceil(x), y, B, C);
    p3 = getVecMitchellNetravaliY(img, ceil(x)+1, y, B, C);
  }
  return PVector.add(PVector.add(PVector.mult(PVector.add(PVector.add(PVector.mult(p0,-B/6.0-C),
           PVector.mult(p1,-1.5*B-C+2.0)),PVector.add(PVector.mult(p2,1.5*B+C-2.0),PVector.mult(p3,
           B/6.0+C))),d*d*d),PVector.mult(PVector.add(PVector.add(PVector.mult(p0,0.5*B+2.0*C),
           PVector.mult(p1,2.0*B+C-3.0)),PVector.add(PVector.mult(p2,-2.5*B-2.0*C+3.0),
           PVector.mult(p3,-C))),d*d)),PVector.add(PVector.mult(PVector.add(PVector.mult(p0,-0.5*B-C),
           PVector.mult(p2,0.5*B+C)),d),PVector.add(PVector.mult(p0,B/6.0),PVector.add(
           PVector.mult(p1,-B/3.0+1.0),PVector.mult(p2,B/6.0)))));
}

PVector getVecMitchellNetravaliY(PVector[][] img, int x, float y, float B, float C) {
  PVector p0, p1, p2, p3;
  float d = y - floor(y);
  
  if(d == 0.0) {
    p0 = getVec(img, x, floor(y)-1);
    p1 = getVec(img, x, floor(y));
    p2 = getVec(img, x, floor(y)+1);
    p3 = getVec(img, x, floor(y)+2);
  } else {
    p0 = getVec(img, x, floor(y)-1);
    p1 = getVec(img, x, floor(y));
    p2 = getVec(img, x, ceil(y));
    p3 = getVec(img, x, ceil(y)+1);
  }
  return PVector.add(PVector.add(PVector.mult(PVector.add(PVector.add(PVector.mult(p0,-B/6.0-C),
           PVector.mult(p1,-1.5*B-C+2.0)),PVector.add(PVector.mult(p2,1.5*B+C-2.0),PVector.mult(p3,
           B/6.0+C))),d*d*d),PVector.mult(PVector.add(PVector.add(PVector.mult(p0,0.5*B+2.0*C),
           PVector.mult(p1,2.0*B+C-3.0)),PVector.add(PVector.mult(p2,-2.5*B-2.0*C+3.0),
           PVector.mult(p3,-C))),d*d)),PVector.add(PVector.mult(PVector.add(PVector.mult(p0,-0.5*B-C),
           PVector.mult(p2,0.5*B+C)),d),PVector.add(PVector.mult(p0,B/6.0),PVector.add(
           PVector.mult(p1,-B/3.0+1.0),PVector.mult(p2,B/6.0)))));
}

PVector getVec(PVector[][] img, int x, int y) {
  switch(EDGE_MODE) {
    case 0: // clamp
      x = clamp_inclusive(x, 0, img.length-1);
      y = clamp_inclusive(y, 0, img[0].length-1);
      break;
    case 1: // wrap (torus)
      x = mod(x, img.length);
      y = mod(y, img[0].length);
      break;
    case 2: // black
      if(x >= img.length || x < 0 || y >= img[0].length || y < 0)
        return new PVector(0, 0, 0);
      break;
    case 3: // white
      if(x >= img.length || x < 0 || y >= img[0].length || y < 0)
        return new PVector(255, 255, 255);
      break;
    default:
      println("Unsupported edge mode!");
      break;
  }
  return img[x][y];
}

// resizes the input array to (w, h)
PVector[][] resample_lanczos(PVector[][] img, int w, int h, int lanczos_k) {
  float w0 = img.length;
  float h0 = img[0].length;
  
  PVector[][] o = new PVector[w][h];
  
  float factor_x = w0/(float)w;
  float factor_y = h0/(float)h;
  
  for(int x = 0; x < w; x++) {
    for(int y = 0; y < h; y++) {
      
      o[x][y] = new PVector();
      
      int min_x = floor(factor_x*(float)(x - lanczos_k));
      int min_y = floor(factor_y*(float)(y - lanczos_k));
      
      int max_x = ceil(factor_x*(float)(x + lanczos_k));
      int max_y = ceil(factor_y*(float)(y + lanczos_k));
      
      float c_x = factor_x*(float)x;
      float c_y = factor_y*(float)y;
      
      float norm = 0.f;
      
      for(int xo = min_x; xo <= max_x; xo++) {
        for(int yo = min_y; yo <= max_y; yo++) {
          float fac = lanczos((xo - c_x)/factor_x, lanczos_k)*lanczos((yo - c_y)/factor_y, lanczos_k);
          norm += fac;
          if(Float.isNaN(fac)) println(xo, (xo - c_x), factor_x, yo, (yo - c_y), factor_y);
          o[x][y].add(PVector.mult(getVec(img, xo, yo), fac));
        }
      }
      o[x][y] = PVector.mult(o[x][y], 1.0/norm);
    }
  }
  return o;
}

// AdvMAME2x pixel art scaling algorithm
// uses
PVector[][] EPX2(PVector[][] img) {
  PVector[][] o = new PVector[img.length*2][img[0].length*2];
  for(int x = 0; x < img.length; x++) {
    for(int y = 0; y < img[x].length; y++) {
      PVector P = img[x][y];
      PVector A = getVec(img, x, y-1);
      PVector B = getVec(img, x+1, y);
      PVector C = getVec(img, x-1, y);
      PVector D = getVec(img, x, y+1);
      
      PVector V1 = cpv(P);
      PVector V2 = cpv(P);
      PVector V3 = cpv(P);
      PVector V4 = cpv(P);
      
      if(vec_eq(C, A) && !vec_eq(C, D) && !vec_eq(A, B)) V1 = A;
      if(vec_eq(A, B) && !vec_eq(A, C) && !vec_eq(B, D)) V2 = B;
      if(vec_eq(D, C) && !vec_eq(D, B) && !vec_eq(C, A)) V3 = C;
      if(vec_eq(B, D) && !vec_eq(B, A) && !vec_eq(D, C)) V4 = D;
      
      o[x*2][y*2] = V1;
      o[x*2+1][y*2] = V2;
      o[x*2][y*2+1] = V3;
      o[x*2+1][y*2+1] = V4;
    }
  }
  return o;
}

PVector[][] ln(PVector[][] img) {
  PVector[][] o = new PVector[img.length][img[0].length];
  for(int x = 0; x < img.length; x++) {
    for(int y = 0; y < img[x].length; y++) {
      o[x][y] = new PVector(log(img[x][y].x), log(img[x][y].y), log(img[x][y].z));
    }
  }
  return o;
}

PVector[][] mult(PVector[][] img, float a) {
  PVector[][] o = new PVector[img.length][img[0].length];
  for(int x = 0; x < img.length; x++) {
    for(int y = 0; y < img[x].length; y++) {
      o[x][y] = PVector.mult(img[x][y], a);
    }
  }
  return o;
}

PVector[][] add(PVector[][] img, PVector p) {
  PVector[][] o = new PVector[img.length][img[0].length];
  for(int x = 0; x < img.length; x++) {
    for(int y = 0; y < img[x].length; y++) {
      o[x][y] = PVector.add(img[x][y], p);
    }
  }
  return o;
}

PVector[][] min(PVector[][] img, PVector p) {
  PVector[][] o = new PVector[img.length][img[0].length];
  for(int x = 0; x < img.length; x++) {
    for(int y = 0; y < img[x].length; y++) {
      o[x][y] = o[x][y] = new PVector(min(p.x, img[x][y].x), min(p.y, img[x][y].y), min(p.z, img[x][y].z));
    }
  }
  return o;
}

PVector[][] max(PVector[][] img, PVector p) {
  PVector[][] o = new PVector[img.length][img[0].length];
  for(int x = 0; x < img.length; x++) {
    for(int y = 0; y < img[x].length; y++) {
      o[x][y] = o[x][y] = new PVector(max(p.x, img[x][y].x), max(p.y, img[x][y].y), max(p.z, img[x][y].z));
    }
  }
  return o;
}

// TODO: implement more optimized mediod algorithm
PVector[][] medoid(PVector[][] img, int rad) {
  PVector[][] o = new PVector[img.length][img[0].length];
  boolean[][] kernel = new boolean[rad*2+1][rad*2+1];
  int samp_count = 0;
  for(int x = -rad; x <= rad; x++) {
    for(int y = -rad; y <= rad; y++) {
      kernel[x+rad][y+rad] = x*x+y*y <= rad*rad;
      if(kernel[x+rad][y+rad]) samp_count++;
    }
  }
  PVector[] samples = new PVector[samp_count];
  int[][] coords = new int[samp_count][2];
  int i = 0;
  for(int x = -rad; x <= rad; x++) {
    for(int y = -rad; y <= rad; y++) {
      if(kernel[x+rad][y+rad]) {
        coords[i][0] = x;
        coords[i][1] = y;
        i++;
      }
    }
  }
  for(int x = 0; x < img.length; x++) {
    for(int y = 0; y < img[x].length; y++) {
      for(i = 0; i < coords.length; i++) {
        samples[i] = getVec(img, coords[i][0] + x, coords[i][1] + y);
      }
      o[x][y] = medoid(samples);
    }
  }
  return o;
}

// This function selects the PVector in the input array that best
// represents the dataset as a whole (minimizing absolute error)
//   This function uses the "trimed" algorithm:
//   http://proceedings.mlr.press/v54/newling17a/newling17a.pdf
// TODO: implement a more efficient mediod algorithm
PVector medoid(PVector[] data) {
  // lower bound on the energy of each entry
  float[] lowers = new float[data.length];
  // used in loop
  float[] distances = new float[data.length];
  
  // minimum energy value and index
  float min_E = Float.MAX_VALUE;
  int min_E_i = 0;
  println("");
  for(int i = 0; i < data.length; i++) {
    if(lowers[i] < min_E) {
      // compute distances
      float E_i = 0.0;
      for(int j = 0; j < data.length; j++) {
        if(i != j) {
          distances[j] = L2(data[i], data[j]);
          E_i += distances[j];
        }
      }
      
      if(E_i < min_E) {
        // update medoid
        min_E = E_i;
        min_E_i = i;
      }
      
      // update lower bounds
      for(int j = i+1; j < data.length; j++) {
        // multiply distances[j] by length since we don't normalize error
        lowers[j] = max(lowers[j], abs(data.length*distances[j] - E_i));
      }
    }
  }
  
  return data[min_E_i];
}

//============================================= SAMPLING & ANALYSIS =====================================================//

// modified sunflower function
// https://stackoverflow.com/a/28572551
PVector[] sunflower(int n) {
  return sunflower(n, 0.75);
}
// higher alpha = more constant edge, default is 0.75
PVector[] sunflower(int n, float alpha) {
  PVector[] o = new PVector[n];
  int b = round(alpha*sqrt(n));
  float phi = (1.0+sqrt(5))/2.0;
  for(int i = 0; i < n; i++) {
    float r = 1.0;
    if(i < n-b) r = sqrt((float)i - 0.5)/sqrt(n - (b+1.0)*0.5);
    float theta = 2.0*PI*(float)i/(phi*phi);
    o[i] = new PVector(r*cos(theta), r*sin(theta));
  }
  return o;
}

import java.util.HashSet;
import java.util.Iterator;

// this function will give you a poisson distribution with ROUGHLY n samples
// accuracy decreases with smaller n, the function generally will overshoot n
PVector[] poisson(int n) {
  // the value 2.706 was found experimentally, averaging over ~50 runs with r = 500, k=20
  return poisson(max(1, round(sqrt((float)n/2.706))), 20);
}

// r - grid radius, k - sample attempts (default 20)
// returns a disc
PVector[] poisson(int r, int k) {
  ArrayList<PVector> dead = new ArrayList<PVector>();
  HashSet<PVector> active = new HashSet<PVector>(); // O(1) removal time
  boolean[][] occupied = new boolean[r*2+1][r*2+1];
  PVector[][] coord_grid = new PVector[occupied.length][occupied[0].length];
  
  float x0 = random(-r/2, r/2);
  float y0 = random(-r/2, r/2);
  
  active.add(new PVector(x0, y0));
  occupied[round(x0 + r)][round(y0 + r)] = true;
  coord_grid[round(x0 + r)][round(y0 + r)] = new PVector(x0, y0);
  
  ArrayList<PVector> new_active = new ArrayList<PVector>();
  Iterator<PVector> it = active.iterator();
  while(!(active.isEmpty() && new_active.isEmpty())) {
    while(it.hasNext()) {
      PVector p = it.next();
      
      int i;
      float sd = random(TWO_PI);
      for(i = 0; i < k; i++) {
        float theta = sd + TWO_PI*((float)i/(float)k);
        
        // the "maximal poisson sampling" algorithm described here:
        // http://extremelearning.com.au/an-improved-version-of-bridsons-algorithm-n-for-poisson-disc-sampling/
        // produces veeeery minor rivers in the points if theta is non-uniformly distributed (and maybe if it is, still?)
        // I counteract this by adding a small random value to the radius. There's still some anisotropy, but it looks better, I think.
        float rd = 1.41421356237 + random(0.15);
        float x = p.x + cos(theta)*rd;
        float y = p.y + sin(theta)*rd;
        int xc = round(x + r);
        int yc = round(y + r);
        
        if(xc > 0 && yc > 0 && xc < occupied.length - 1 && yc < occupied.length - 1) {
          boolean tooClose = false;
          
          if(x*x + y*y > r*r) tooClose = true;
          
          if(!tooClose)
          for(int xf = -1; xf <= 1; xf++) {
            for(int yf = -1; yf <= 1; yf++) {
              if(occupied[xc+xf][yc+yf]) {
                PVector s = coord_grid[xc+xf][yc+yf];
                if((s.x - x)*(s.x - x) + (s.y - y)*(s.y - y) <= 2.0) {
                  tooClose = true;
                  xf = 2;
                  break;
                }
              }
            }
          }
          if(!tooClose) {
            new_active.add(new PVector(x, y));
            dead.add(new PVector(x, y));
            
            occupied[xc][yc] = true;
            coord_grid[xc][yc] = new PVector(x, y);
            
            break;
          }
        }
      }
      if(i == k) {
        it.remove();
        dead.add(p);
      }
    }
    active.addAll(new_active);
    it = active.iterator();
    new_active.clear();
  }
  
  PVector[] o = new PVector[dead.size()];
  for(int i = 0; i < o.length; i++) {
    o[i] = PVector.mult(dead.get(i), 1.0/(float)r);
  }
  
  return o;
}

PVector[][][] fft(PVector[][] img) {
  return fft(img, newVecMatrix(img.length, img[0].length));
}

PVector[][][] fft(PVector[][] img, PVector[][] img_im) {
  PVector[][][] o = new PVector[2][img.length][img[0].length];
  
  // fft on cols
  for(int i = 0; i < img.length; i++) {
    PVector[][] op = fft(img[i], img_im[i], false);
    for(int j = 0; j < img[0].length; j++) {
      o[0][i][j] = op[0][j];
      o[1][i][j] = op[1][j];
    }
  }
  
  // Transpose the image
  PVector[][][] ot = new PVector[2][img[0].length][img.length];
  for(int i = 0; i < img.length; i++) {
    for(int j = 0; j < img[0].length; j++) {
      ot[0][j][i] = cpv(o[0][i][j]);
      ot[1][j][i] = cpv(o[1][i][j]);
    }
  }
  
  // fft on cols
  for(int i = 0; i < img[0].length; i++) {
    PVector[][] op = fft(ot[0][i], ot[1][i], false);
    for(int j = 0; j < img.length; j++) {
      ot[0][i][j] = op[0][j];
      ot[1][i][j] = op[1][j];
    }
  }
  
  // Transpose again
  for(int i = 0; i < img.length; i++) {
    for(int j = 0; j < img[0].length; j++) {
      o[0][i][j] = ot[0][j][i];
      o[1][i][j] = ot[1][j][i];
    }
  }
  
  PVector[][][] o2 = new PVector[2][img.length][img[0].length];
  for(int i = 0; i < img.length; i++) {
    for(int j = 0; j < img[0].length; j++) {
      o2[0][i][j] = o[0][(i+img.length/2)%img.length][(j+img[0].length/2)%img[0].length];
      o2[1][i][j] = o[1][(i+img.length/2)%img.length][(j+img[0].length/2)%img[0].length];
    }
  }
  
  return o2;
}

PVector[][] fft_inv(PVector[][] img_re0, PVector[][] img_im0) {
  
  PVector[][] img_re = new PVector[img_re0.length][img_re0[0].length];
  PVector[][] img_im = new PVector[img_im0.length][img_im0[0].length];
  
  PVector[][][] o = new PVector[2][img_re.length][img_re[0].length];
  PVector[][][] o2 = new PVector[2][img_re.length][img_re[0].length];
  
  for(int i = 0; i < img_re.length; i++) {
    for(int j = 0; j < img_re[0].length; j++) {
      img_re[i][j] = img_re0[(i+img_re.length/2)%img_re.length][(j+img_re[0].length/2)%img_re[0].length];
      img_im[i][j] = img_im0[(i+img_re.length/2)%img_re.length][(j+img_re[0].length/2)%img_re[0].length];
    }
  }
  
  // fft on cols
  for(int i = 0; i < img_re.length; i++) {
    PVector[][] op = fft(img_re[i], img_im[i], true);
    for(int j = 0; j < img_re[0].length; j++) {
      o[0][i][j] = op[0][j];
      o[1][i][j] = op[1][j];
    }
  }
  
  // Transpose the image
  PVector[][][] ot = new PVector[2][img_re[0].length][img_re.length];
  for(int i = 0; i < img_re.length; i++) {
    for(int j = 0; j < img_re[0].length; j++) {
      ot[0][j][i] = cpv(o[0][i][j]);
      ot[1][j][i] = cpv(o[1][i][j]);
    }
  }
  
  // fft on cols
  for(int i = 0; i < img_re[0].length; i++) {
    PVector[][] op = fft(ot[0][i], ot[1][i], true);
    for(int j = 0; j < img_re.length; j++) {
      ot[0][i][j] = op[0][j];
      ot[1][i][j] = op[1][j];
    }
  }
  
  // Transpose again
  for(int i = 0; i < img_re.length; i++) {
    for(int j = 0; j < img_re[0].length; j++) {
      o[0][i][j] = ot[0][j][i];
      o[1][i][j] = ot[1][j][i];
    }
  }
  
  return o[0];
}

PVector[] newVecArray(int size) {
  PVector[] v = new PVector[size];
  for(int i = 0; i < v.length; i++) v[i] = new PVector(0, 0, 0);
  return v;
}

PVector[][] newVecMatrix(int w, int h) {
  PVector[][] v = new PVector[w][h];
  for(int i = 0; i < w; i++) for(int j = 0; j < h; j++) v[i][j] = new PVector(0, 0, 0);
  return v;
}

// Radix-2 Cooley-Tukey
// Applied to each component individually
// outputs PVector[0/1][x] where 0 gives real and 1 gives imaginary
public PVector[][] fft(final PVector[] inputReal, PVector[] inputImag, boolean INVERSE) {
    int n = inputReal.length;
    double ld = Math.log(n) / Math.log(2.0);
    if(((int) ld) - ld != 0) {
      System.out.println("The number of elements is not a power of 2.");
      return null;
    }
    
    int nu = (int) ld; // no information lost here if ld is a power of 2
    int n2 = n / 2;
    int nu1 = nu - 1;
    PVector[] xReal = new PVector[n];
    PVector[] xImag = new PVector[n];
    PVector tReal = new PVector();
    PVector tImag = new PVector();
    double p, arg, c, s;
    
    double constant = INVERSE?-TWO_PI:TWO_PI;
    // copy source arrays
    for(int i = 0; i < n; i++) {
        xReal[i] = cpv(inputReal[i]);
        xImag[i] = cpv(inputImag[i]);
    }
    
    int k = 0;
    for(int l = 1; l <= nu; l++) {
        while(k < n) {
            for(int i = 1; i <= n2; i++) {
                p = bitReverseFFT(k >> nu1, nu);
                arg = constant * p / n;
                c = Math.cos(arg);
                s = Math.sin(arg);
                tReal = PVector.add(PVector.mult(xReal[k + n2], (float)c), PVector.mult(xImag[k + n2], (float)s));
                tImag = PVector.sub(PVector.mult(xImag[k + n2], (float)c), PVector.mult(xReal[k + n2], (float)s));
                xReal[k + n2] = PVector.sub(xReal[k], tReal);
                xImag[k + n2] = PVector.sub(xImag[k], tImag);
                xReal[k] = PVector.add(xReal[k], tReal);
                xImag[k] = PVector.add(xImag[k], tImag);
                k++;
            }
            k += n2;
        }
        k = 0;
        nu1--;
        n2 /= 2;
    }

    // recombination
    k = 0;
    int r;
    while(k < n) {
        r = bitReverseFFT(k, nu);
        if(r > k) {
            tReal = cpv(xReal[k]);
            tImag = cpv(xImag[k]);
            xReal[k] = cpv(xReal[r]);
            xImag[k] = cpv(xImag[r]);
            xReal[r] = cpv(tReal);
            xImag[r] = cpv(tImag);
        }
        k++;
    }
    
    // create output arrays and normalize
    PVector[][] newArray = new PVector[2][xReal.length];
    float radice = 1.0 / sqrt(n);
    for(int i = 0; i < newArray[0].length; i++) {
        newArray[0][i] = PVector.mult(xReal[i], radice);
        newArray[1][i] = PVector.mult(xImag[i], radice);
    }
    return newArray;
}

int bitReverseFFT(int j, int nu) {
  int j2;
  int j1 = j;
  int k = 0;
  for (int i = 1; i <= nu; i++) {
      j2 = j1 / 2;
      k = 2 * k + j1 - 2 * j2;
      j1 = j2;
  }
  return k;
}

PVector mean(PVector... data) {
  PVector sum = new PVector();
  for(PVector p : data) {
    sum.add(p);
  }
  return PVector.mult(sum, 1.0/data.length);
}

float L2(PVector a, PVector b) {
  return sqrt((a.x - b.x)*(a.x - b.x) + (a.y - b.y)*(a.y - b.y) + (a.z - b.z)*(a.z - b.z));
}

boolean vec_eq(PVector a, PVector b) {
  return a.x == b.x && a.y == b.y && a.z == b.z;
}

float lanczos(float x, float a) {
  if(x < -a || x > a) return 0;
  if(x == 0.0) return 1;
  return a*sin(PI*x)*sin(PI*x/a)/(PI*PI*x*x);
}

float smoothstep(float x) {
  return 3*x*x - 2*x*x*x;
}

int mod(int x, int n) {
  return ((x >> 31) & (n - 1)) + (x % n);
}

int clamp_inclusive(int x, int low, int high) {
  if(x <= low) return low;
  if(x >= high) return high;
  return x;
}

int a(color c) {return (c >> 24) & 255; }
int r(color c) {return (c >> 16) & 255; }
int g(color c) {return (c >> 8) & 255;}
int b(color c) {return c & 255; }

PVector cpv(PVector p) {
  return new PVector(p.x, p.y, p.z);
}
