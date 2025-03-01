// Hey, so remember how I useed to have a big "UTIL" file that housed a bajillion Processing functions
// That sure was an awful way to do things
// I made another with more stuff

// WHAT I'VE PUT IN HERE SO FAR:
//   - Scanline floodfill
//   - Some color space conversions
//   - Texture interpolation (nearest, bilinear, bicubic, and a variety of BC-spline interpolations)
//   - A couple other resampling/scaling algorithms (Lanczos, AdvMAME2x)
//   - A good medoid algorthm (trimed) (just in 3D for now)
//   - Poisson disk generation
//   - 1D and 2D FFTs
//   - Commonly-used math functions (sigmoid, smootherstep, etc.)
//   - A few fixed-size Matrix / Vector classes (i3, i3x3, d3, d4x4)
//   - Image convolution and adjustment
//   - Camzy (easy camera class)

// THINGS I'D LIKE TO ADD IN THE FUTURE:
//   - GLSL colorspace github code adaptation
//   - CCL/CCA algorithm from oceanography project (take out wrapping)
//   - Some actually decent general lin. alg. classes (I had implemented Cholesky decomposition in
//        "Polyharmonic_Spline_Test.pde", and LU decomposition/inversion somewhere else)
//        Maybe add eigenvector solver too?
//   - That RBF interpolation method from that .pde file (clean up maybe)
//   - An integrator / vectorized ODE solver class
//        Support arbitrary RK Butcher Tableaus!
//        Also linear multistep methods


//====================FLOOD FILL====================\\

// modified scanline floodfill method
// very fast, i think
import java.util.Stack;
boolean[][] flood_fill(boolean[][] arr, int x0, int y0) {

  int xres = arr.length;
  int yres = arr[0].length;
  if (!arr[x0][y0]) {
    println("spot not fillable!");
    return null;
  }

  boolean[][] in_sink = new boolean[xres][yres];
  Stack<ScanPT> pts = new Stack<ScanPT>();
  pts.push(new ScanPT(x0, x0, x0+1, x0-1, y0, (byte)1));
  pts.push(new ScanPT(x0, x0, x0+1, x0-1, y0, (byte)-1));

  int x = 0;
  int iter = 0;

  while (!pts.empty()) {
    ScanPT l = pts.pop();

    if (!in_sink[l.x0][l.y]) {

      // fill center region
      for (x = l.x0; x <= l.x1; x++) in_sink[x][l.y] = true;

      // fill right side
      for (; x < xres; x++)
        if (arr[x][l.y]) in_sink[x][l.y] = true;
        else break;

      l.x1 = x-1; // store right edge

      // fill left side
      for (x = l.x0; x >= 0; x--)
        if (arr[x][l.y]) in_sink[x][l.y] = true;
        else break;

      l.x0 = x+1; // store left edge

      int left_side = l.x0;
      boolean c_arr = false;
      boolean p_arr = false;

      // sweep whole range
      if (l.y + l.direction < yres && l.y + l.direction >= 0) {
        for (x = l.x0; x <= l.x1; x++) {
          c_arr = arr[x][l.y+l.direction];
          if (!p_arr && c_arr) // are we on a new fillable region?
            left_side = x;    // if so, mark the start of it
          else if (p_arr && !c_arr) // are we on a new unfillable region?
            pts.push(new ScanPT(left_side, x-1, l.x0, l.x1, l.y + l.direction, l.direction)); // if so, add the old fillable region to the stack
          p_arr = c_arr;
        }
        if (p_arr) pts.push(new ScanPT(left_side, x-1, l.x0, l.x1, l.y + l.direction, l.direction)); // if we reached the end in a fillable space, dump the region to the stack
      }

      if (l.y - l.direction < yres && l.y - l.direction >= 0) {
        if (l.x1 > l.px1) { // is the new right bound bigger than the old one?
          left_side = l.px1;
          c_arr = false;
          p_arr = false;
          for (x = l.px1; x <= l.x1; x++) {
            c_arr = arr[x][l.y-l.direction]; // negative direction!
            if (!p_arr && c_arr) left_side = x;
            else if (p_arr && !c_arr) pts.push(new ScanPT(left_side, x-1, l.x0, l.x1, l.y - l.direction, (byte)-l.direction));
            p_arr = c_arr;
          }
          if (p_arr) pts.push(new ScanPT(left_side, x-1, l.x0, l.x1, l.y - l.direction, (byte)-l.direction));
        }

        if (l.x0 < l.px0) { // is the new left bound smaller than the old one?
          left_side = l.px0;
          c_arr = false;
          p_arr = false;
          for (x = l.px0; x >= l.x0; x--) {
            c_arr = arr[x][l.y-l.direction]; // negative direction!
            if (!p_arr && c_arr) left_side = x;
            else if (p_arr && !c_arr) pts.push(new ScanPT(x+1, left_side, l.x0, l.x1, l.y - l.direction, (byte)-l.direction));
            p_arr = c_arr;
          }
          if (p_arr) pts.push(new ScanPT(x+1, left_side, l.x0, l.x1, l.y - l.direction, (byte)-l.direction));
        }
      }
    }
    iter++;
  }
  return in_sink;
}
final class ScanPT {
  public int x0;
  public int x1;
  public byte direction;
  public int px0;
  public int px1;
  public int y;
  public ScanPT(int x0, int x1, int px0, int px1, int y, byte direction) {
    this.x0 = x0;
    this.x1 = x1;
    this.px0 = px0;
    this.px1 = px1;
    this.y = y;
    this.direction = direction;
  }
}

//====================CAMZY====================\\

// TODO: Update this

// Camzy is a camera control application used for making things look cooler and spinning and stuff.
// Usage is pretty simple and should be self-explanatory.

class Camzy {
  float rotHorizontial = PI*0.25f;
  float rotVertical = PI*0.75f;
  float zoom = 1.f;
  float vv = 0.f;
  float vh = 0.f;
  float vz = 0.f;
  boolean pmousePressed = false;
  void applyRotations() {
    translate(width/2, height/2);
    scale(zoom);
    rotateX(rotVertical);
    rotateY(rotHorizontial);
  }
  void drawThing() {
    strokeWeight(1.5f/zoom);
    stroke(255, 0, 0);
    line(0, 0, 0, 1, 0, 0);
    stroke(0, 255, 0);
    line(0, 0, 0, 0, 1, 0);
    stroke(0, 0, 255);
    line(0, 0, 0, 0, 0, 1);
  }
  void update() {
    zoom = CAMZY_GLOBALZOOM;
    if(keyPressed) if(key == '+') CAMZY_GLOBALZOOM *= 1.05f; else if(key == '-') CAMZY_GLOBALZOOM /= 1.05f;
    if(mousePressed && pmousePressed && mouseButton == RIGHT) {
      vh = float(pmouseX - mouseX)/300.f;
      vv = float(pmouseY - mouseY)/300.f;
    }
    rotHorizontial += vh;
    rotVertical += vv;
    vh /= 1.0f;
    vv /= 1.1f;
    pmousePressed = mousePressed;
  }
}
float CAMZY_GLOBALZOOM = 50.f;
// PUT THIS IN UR CODE!!!!
// Thnx ;)
// -Adam
void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  if(e < 0.f) CAMZY_GLOBALZOOM *= 1.05f;
  else CAMZY_GLOBALZOOM /= 1.05f;
}

//====================CONSTANTS====================\\

final float RAD_TO_DEG = 57.2957795131;
final float DEG_TO_RAD = 0.01745329251;

//====================COLOR OPERATIONS====================\\

// Descriptions of the color spaces listed here:
// NAME    sRGB GAMUT RANGE                 PRECISION
// sRGB:   0 to 255                         int
// RGB:    0 to 1                           float
// XYZ:    0 to (95, 100, 108)              float
// L*a*b*: (0, -86, -108) to 100            float
// LCH_ab: (0, 0, -180) to (100, 134, 180)  float
// LCH_uv: (0, 0, -180) to (100, 179, 180)  float
// ΔE2000: 0 to 162                         float

// All conversions use the CIE D65 Standard Illuminant unless specified otherwise
final PVector ref_white = new PVector(95.047, 100.0, 108.883);

float lightnessFP(color c) {
  return lightnessFP(LAB_to_LCH(XYZ_to_LAB(RGB_to_XYZ(sRGB_to_RGB(c)))));
}

PVector sRGB_to_LCH(color c) {
  return LAB_to_LCH(XYZ_to_LAB(RGB_to_XYZ(sRGB_to_RGB(c))));
}

// fairchild pirrotta lightness (helmholtz-kohlrausch compensation)
// thanks to https://stackoverflow.com/questions/596216/formula-to-determine-brightness-of-rgb-color/59602392#59602392
float lightnessFP(PVector lch) {
  return lch.x +(2.5 - 0.025*lch.x)
               *(0.116*abs(sin(DEG_TO_RAD*((lch.z-90.0)/2.0))) + 0.085)
               *lch.y;
}

PVector LAB_to_LCH(PVector c) {
  return new PVector(c.x, sqrt(c.y*c.y + c.z*c.z), atan2(c.z, c.y)*RAD_TO_DEG);
}
PVector LUV_to_LCH(PVector c) {
  return LAB_to_LCH(c);
}

// LAB is L*a*b*
PVector XYZ_to_LAB(PVector c) {
  PVector v = cpv(c);
  
  // D65 white point
  v.x /= ref_white.x;
  v.y /= ref_white.y;
  v.z /= ref_white.z;
  
  v.x = v.x > 0.008856 ? pow(v.x, 1.0/3.0) : v.x*7.787 + 16.0/116.0;
  v.y = v.y > 0.008856 ? pow(v.y, 1.0/3.0) : v.y*7.787 + 16.0/116.0;
  v.z = v.z > 0.008856 ? pow(v.z, 1.0/3.0) : v.z*7.787 + 16.0/116.0;
  
  return new PVector(116.0*v.y - 16.0, 500.0*(v.x - v.y), 200.0*(v.y - v.z));
}

// LUV is L*u*v*
PVector XYZ_to_LUV(PVector c) {
  float v_rp = 9.0*ref_white.y/(ref_white.x + 15.0*ref_white.y + 3.0*ref_white.z);
  float u_rp = 4.0*ref_white.x/(ref_white.x + 15.0*ref_white.y + 3.0*ref_white.z);
  
  float vp =  9.0*c.y/(c.x + 15.0*c.y + 3.0*c.z);
  float up =  4.0*c.x/(c.x + 15.0*c.y + 3.0*c.z);
  
  float y_r =  c.y/ref_white.y;
  float L = y_r > 0.008856 ? 116.0*pow(y_r, 1.0/3.0) - 16.0 : 903.3*y_r;
  
  float u = 13.0*L*(up - u_rp);
  float v = 13.0*L*(vp - v_rp);
  
  return new PVector(L, u, v);
}

PVector RGB_to_XYZ(PVector c) {
  return new PVector(41.24 * c.x + 35.76 * c.y + 18.05 * c.z,
                     21.26 * c.x + 71.52 * c.y + 07.22 * c.z,
                     01.93 * c.x + 11.92 * c.y + 95.05 * c.z);
}

PVector sRGB_to_RGB(color c) {
  return new PVector(sX_to_X(r(c)/255.0),
                     sX_to_X(g(c)/255.0),
                     sX_to_X(b(c)/255.0));
}

PVector sRGB_to_RGB(color c, boolean random_dithering) {
  if(random_dithering)
  return new PVector(sX_to_X(int_to_float_dither_255(r(c))/255.0),
                     sX_to_X(int_to_float_dither_255(g(c))/255.0),
                     sX_to_X(int_to_float_dither_255(b(c))/255.0));
  else
  return new PVector(sX_to_X(r(c)/255.0),
                     sX_to_X(g(c)/255.0),
                     sX_to_X(b(c)/255.0));
}

// sRGB to RGB gamma transformation
float sX_to_X(float x) {
  if(x <= 0.04045) return x/12.92;
  else return pow((x + 0.055)/1.055, 2.4);
}

// clamped to the 0-255 range for 8-bit colors
float int_to_float_dither_255(int x) {
  return max(0, min(255, (float)x + random(-0.5, 0.5)));
}

float DELTA_E_2000(color a, color b) {
  return DELTA_E_2000(XYZ_to_LAB(RGB_to_XYZ(sRGB_to_RGB(a))), XYZ_to_LAB(RGB_to_XYZ(sRGB_to_RGB(b))));
}

// this was a pain
// math from:
// http://www2.ece.rochester.edu/~gsharma/ciede2000/ciede2000noteCRNA.pdf
// http://zschuessler.github.io/DeltaE/learn/

float DELTA_E_2000(PVector lab1, PVector lab2) {
  float C_ab = (sqrt(lab1.y*lab1.y + lab1.z*lab1.z) + sqrt(lab2.y*lab2.y + lab2.z*lab2.z))/2.0;
  float G = 0.5*(1-sqrt(pow(C_ab, 7.0)/(pow(C_ab, 7) + 6103515625.0)));
  float ap1 = (1+G)*lab1.y;
  float ap2 = (1+G)*lab2.y;
  float Cp1 = sqrt(ap1*ap1 + lab1.z*lab1.z);
  float Cp2 = sqrt(ap2*ap2 + lab2.z*lab2.z);
  
  float h1 = atan2(lab1.z, ap1)*RAD_TO_DEG;
  float h2 = atan2(lab2.z, ap2)*RAD_TO_DEG;
  
  float del_Lp = lab2.x - lab1.x;
  float del_Cp = Cp2 - Cp1;
  
  float del_hp = 0;
  if(Cp1*Cp2 != 0.0) {
    if(abs(h2 - h1) <= 180) del_hp = h2-h1;
    else if(h2 - h1 > 180)  del_hp = h2-h1 - 360;
    else if(h2 - h1 < -180) del_hp = h2-h1 + 360;
  }
  
  float del_H = 2*sqrt(Cp1*Cp2)*sin(DEG_TO_RAD*(del_hp/2.0));
  
  float Hp = abs(h1-h2) > 180 ? (h1 + h2 + 360.0)/2.0 :
                                (h1 + h2)/2.0;
  float T = 1 - 0.17*cos(DEG_TO_RAD*(Hp - 30.0))
              + 0.24*cos(DEG_TO_RAD*(2.0*Hp))
              + 0.32*cos(DEG_TO_RAD*(3.0*Hp + 6.0))
              - 0.2*cos(DEG_TO_RAD*(4*Hp - 63.0));
  
  float Lb = (lab1.y+lab2.y)/2.0;
  float Cp = (Cp1 + Cp2)/2.0;
  
  float S_L = 1 + 0.015*(Lb-50.0)*(Lb-50.0)/sqrt(20.0 + (Lb-50.0)*(Lb-50.0));
  float S_C = 1 + 0.045*Cp;
  float S_H = 1 + 0.015*Cp*T;
  
  float RT = -2*sqrt(pow(Cp, 7)/(pow(Cp, 7) + 6103515625.0)*sin(DEG_TO_RAD*60.0*exp(-((Hp - 275.0)*(Hp - 275.0)/625.0))));
  
  float E00 = sqrt(sq(del_Lp/S_L) + sq(del_Cp/S_C) + sq(del_H)/S_H + RT*del_Cp*del_H/(S_C*S_H));
  
  return E00;
}


//====================IMAGE OPERATIONS====================\\

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

int IMAGE_FILTER_MODE = 0;

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

//====================IMAGE OPERATIONS: SAMPLING & ANALYSIS====================\\

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

PVector cpv(PVector p) {
  return new PVector(p.x, p.y, p.z);
}

//====================MATH AND BITWISE OPERATIONS====================\\

float sigmoid(float x) {
  return 1/(1+exp(-x));
}

float sigmoid_prime(float x) {
  return sigmoid(x)*(1 - sigmoid(x));
}

int saw(int a, int b) {
  return (b-1)-abs(rmod(a, (2*(b-1)))-(b-1));
}

int rmod(int a, int b) {
  return (a % b + b)%b;
}

float lanczos(float x, float a) {
  if(x < -a || x > a) return 0;
  if(x == 0.0) return 1;
  return a*sin(PI*x)*sin(PI*x/a)/(PI*PI*x*x);
}

float smoothstep(float x) {
  return 3*x*x - 2*x*x*x;
}

float smootherstep(float x) {
  return x * x * x * (x * (x * 6.0 - 15.0) + 10.0);
}

float inverse_smoothstep(float x) {
  return 0.5 - sin(asin(1.0 - 2.0*x) / 3.0);
}

int mod(int x, int n) {
  return ((x >> 31) & (n - 1)) + (x % n);
}

int clamp_inclusive(int x, int low, int high) {
  if(x <= low) return low;
  if(x >= high) return high;
  return x;
}

long hammingDistance(long a, long b) {  
    return Long.bitCount(a^b); 
}

int a(color c) {return (c >> 24) & 255; }
int r(color c) {return (c >> 16) & 255; }
int g(color c) {return (c >> 8) & 255;}
int b(color c) {return c & 255; }

public float sinh(float x) {
  return (exp(x) - exp(-x))/2.f;
}

public float cosh(float x) {
  return (exp(x) + exp(-x))/2.f;
}

public long factorial(int x) {
  long product = 1;
  int i = x;
  while(i > 0) {
    product *= i;
    i--;
  }
  return product;
}

//====================GUI TOOLS====================\\

boolean is_in_bounds_exclusive(float x, float y, float x0, float y0, float w, float h) {
  return (x > x0) && (x < x0+w) && (y > y0) && (y < y0+h);
}

boolean is_in_bounds_inclusive(float x, float y, float x0, float y0, float w, float h) {
  return (x >= x0) && (x <= x0+w) && (y >= y0) && (y <= y0+h);
}

void drawAxes(float size){
  stroke(255,0,0);
  line(0,0,0,size,0,0);
  stroke(0,255,0);
  line(0,0,0,0,size,0);
  stroke(0,0,255);
  line(0,0,0,0,0,size);
}

//====================INTEGER-PRECISION TOOLS====================\\

/**
 * A simple class to represent integer 3x3 matrices
 * requires iVec3
 */
class iMat3 {
  int[][] a;
  int unique_code;
  iMat3() {
    set_identity();
  }
  void zero() {
    a = new int[3][3];
  }
  iMat3(int[][] vals) {
    a = new int[3][3];
    if(vals.length == 3 && vals[0].length == 3) {
      for(int row = 0; row < 3; row++) for(int col = 0; col < 3; col++) {
        a[row][col] = vals[row][col];
      }
    }
  }
  @Override
  public boolean equals(Object obj) {
    return this.hashCode() == ((iMat3)obj).hashCode();
  }
  @Override
  public int hashCode() {
    int w = 0;
    int k = 1;
    for(int row = 0; row < 3; row++) for(int col = 0; col < 3; col++) {
      if(a[row][col] < 0) w += k;
      else if(a[row][col] > 0) w += k*2;
      k *= 3;
    }
    return w;
  }
  void set_identity() {
    a = new int[3][3];
    a[0][0] = 1;
    a[1][1] = 1;
    a[2][2] = 1;
  }
  iVec3 mult(iVec3 x) {
    iVec3 y = new iVec3();
    y.x = x.x*a[0][0] + x.y*a[0][1] + x.z*a[0][2];
    y.y = x.x*a[1][0] + x.y*a[1][1] + x.z*a[1][2];
    y.z = x.x*a[2][0] + x.y*a[2][1] + x.z*a[2][2];
    return y;
  }
  void mult(iMat3 B) {
    iMat3 C = new iMat3();
    for(int row = 0; row < 3; row++) for(int col = 0; col < 3; col++) {
      C.a[row][col] = a[row][0]*B.a[0][col] +
                      a[row][1]*B.a[1][col] +
                      a[row][2]*B.a[2][col];
    }
    this.a = C.a;
  }
  void scale(int t) {
    iMat3 m = new iMat3();
    m.a[0][0] = t;
    m.a[1][1] = t;
    m.a[2][2] = t;
    mult(m);
  }
  void print_nice() {
    println("[[ " + a[0][0] + ", " + a[0][1] + ", " + a[0][2] + "],");
    println(" [ " + a[1][0] + ", " + a[1][1] + ", " + a[1][2] + "],");
    println(" [ " + a[2][0] + ", " + a[2][1] + ", " + a[2][2] + "]]");
  }
}

iMat3 mult(iMat3 A, iMat3 B) {
  iMat3 C = new iMat3(A.a);
  C.mult(B);
  return C;
}

iVec3 mult(iMat3 A, iVec3 x) {
  return A.mult(x);
}

/**
 * A simple class to represent 3-component integer vectors
 */
class iVec3 {
  int x, y, z;
  iVec3() {
    x = 0;
    y = 0;
    z = 0;
  }
  iVec3(int s) {
    x = s;
    y = s;
    z = s;
  }
  iVec3(int x, int y, int z) {
    this.x = x; this.y = y; this.z = z;
  }
  iVec3(iVec3 v) {
    this.x = v.x; this.y = v.y; this.z = v.z;
  }
  void add(iVec3 v) {
    x += v.x; y += v.y; z += v.z;
  }
  void sub(iVec3 v) {
    x -= v.x; y -= v.y; z -= v.z;
  }
  void mult(int w) {
    x *= w; y *= w; z *= w;
  }
  PVector toPVector() {
    return new PVector((float)x, (float)y, (float)z);
  }
  int dot(iVec3 a) {
    return a.x*x + a.y*y + a.z*z;
  }
  int max_component() {
    return x > y && x > z ? x : (y > z ? y : z);
  }
  int min_component() {
    return x < y && x < z ? x : (y < z ? y : z);
  }
  @Override
  public boolean equals(Object obj) {
    return x == ((iVec3)obj).x && y ==((iVec3)obj).y && z == ((iVec3)obj).z;
  }
  // note: hashCode() and euqals() may not agree for large corrdinates (diff>=1024)
  // HashSet calls equals() though, so it shouldn't be a problem in this project
  @Override
  public int hashCode() {
    return (x<<20)+(y<<10)+z;
  }
  void print_nice() {
    println("[ " + x + ", " + y + ", " + z + " ]");
  }
  iVec3 clone() {
    return new iVec3(x, y, z);
  }
}
iVec3 add(iVec3 a, iVec3 b) {
  return new iVec3(a.x + b.x, a.y + b.y, a.z + b.z);
}
iVec3 sub(iVec3 a, iVec3 b) {
  return new iVec3(a.x - b.x, a.y - b.y, a.z - b.z);
}
iVec3 cross(iVec3 a, iVec3 b) {
  return new iVec3(a.y*b.z - a.z*b.y, a.z*b.x - a.x*b.z, a.x*b.y - a.y*b.x);
}
iVec3 min(iVec3 a, iVec3 b) {
  return new iVec3(a.x<b.x?a.x:b.x, a.y<b.y?a.y:b.y, a.z<b.z?a.z:b.z);
}
iVec3 max(iVec3 a, iVec3 b) {
  return new iVec3(a.x>b.x?a.x:b.x, a.y>b.y?a.y:b.y, a.z>b.z?a.z:b.z);
}
int dot(iVec3 a, iVec3 b) {
  return a.dot(b);
}

//====================DIMAGE====================\\

class dImage {
  int w;
  int h;
  dVec3[][] px;
  dVec3 mean_col;
  dVec3 min_col;
  dVec3 max_col;
  dVec3 std_dev_col;
  dVec3 dev_col_0;
  int count = 0;
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

//====================DOUBLE-PRECISION TOOLS====================\\

double map(double value, double min1, double max1, double min2, double max2) {
  return min2 + (value - min1) * (max2 - min2) / (max1 - min1);
}

color to_color(dVec3 a, dVec3 a_min, dVec3 a_max) {
  int r = round((float)map(a.x, a_min.x, a_max.x, 0, 255));
  int g = round((float)map(a.y, a_min.y, a_max.y, 0, 255));
  int b = round((float)map(a.z, a_min.z, a_max.z, 0, 255));
  return color(r, g, b, 255);
}

class dMat4 {
  double[][] a;
  dMat4() {
    set_identity();
  }
  dMat4(double[][] vals) {
    a = new double[4][4];
    if(vals.length == 4 && vals[0].length == 4) {
      for(int row = 0; row < 4; row++) for(int col = 0; col < 4; col++) {
        a[row][col] = vals[row][col];
      }
    }
  }
  void set_identity() {
    a = new double[4][4];
    a[0][0] = 1.0;
    a[1][1] = 1.0;
    a[2][2] = 1.0;
    a[3][3] = 1.0;
  }
  dVec3 mult(dVec3 x) {
    dVec3 y = new dVec3();
    y.x = x.x*a[0][0] + x.y*a[0][1] + x.z*a[0][2] + a[0][3];
    y.y = x.x*a[1][0] + x.y*a[1][1] + x.z*a[1][2] + a[1][3];
    y.z = x.x*a[2][0] + x.y*a[2][1] + x.z*a[2][2] + a[2][3];
    return y;
  }
  void mult(dMat4 B) {
    dMat4 C = new dMat4();
    for(int row = 0; row < 4; row++) for(int col = 0; col < 4; col++) {
      C.a[row][col] = a[row][0]*B.a[0][col] +
                      a[row][1]*B.a[1][col] +
                      a[row][2]*B.a[2][col] +
                      a[row][3]*B.a[3][col];
    }
    this.a = C.a;
  }
  double mult_get_w(dVec3 x) {
    return x.x*a[3][0] + x.y*a[3][1] + x.z*a[3][2] + a[3][3];
  }
  void translate(double x, double y, double z) {
    dMat4 m = new dMat4();
    m.a[0][3] = x;
    m.a[1][3] = y;
    m.a[2][3] = z;
    mult(m);
  }
  void translate(dVec3 r) {
    dMat4 m = new dMat4();
    m.a[0][3] = r.x;
    m.a[1][3] = r.y;
    m.a[2][3] = r.z;
    mult(m);
  }
  void rotateX(double t) {
    dMat4 m = new dMat4();
    m.a[1][1] = cos(t); m.a[1][2] = -sin(t);
    m.a[2][1] = sin(t); m.a[2][2] = cos(t);
    mult(m);
  }
  void rotateY(double t) {
    dMat4 m = new dMat4();
    m.a[0][0] = cos(t); m.a[0][2] = sin(t);
    m.a[2][0] = -sin(t); m.a[2][2] = cos(t);
    mult(m);
  }
  void rotateZ(double t) {
    dMat4 m = new dMat4();
    m.a[0][0] = cos(t); m.a[0][1] = -sin(t);
    m.a[1][0] = sin(t); m.a[1][1] = cos(t);
    mult(m);
  }
  void scale(double t) {
    dMat4 m = new dMat4();
    m.a[0][0] = t;
    m.a[1][1] = t;
    m.a[2][2] = t;
    mult(m);
  }
}

dMat4 perspective_mat(double near, double far, double fov, double aspect) {
  dMat4 m = new dMat4();
  double tanfov = tan(fov/2.0);
  m.a[0][0] = 1.0/(tanfov*aspect);
  m.a[1][1] = 1.0/(tanfov);
  m.a[2][2] = (near+far)/(far-near);
  m.a[2][3] = (2*far*near)/(near-far);
  m.a[3][2] = 1.0;
  return m;
}

dMat4 mult(dMat4 A, dMat4 B) {
  dMat4 C = new dMat4(A.a);
  C.mult(B);
  return C;
}

dVec3 mult(dMat4 A, dVec3 x) {
  return A.mult(x);
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

class dVec3 {
  double x, y, z;
  dVec3() {
    x = 0;
    y = 0;
    z = 0;
  }
  dVec3(double s) {
    x = s;
    y = s;
    z = s;
  }
  dVec3(double x, double y, double z) {
    this.x = x; this.y = y; this.z = z;
  }
  dVec3(dVec3 v) {
    this.x = v.x; this.y = v.y; this.z = v.z;
  }
  void add(dVec3 v) {
    x += v.x; y += v.y; z += v.z;
  }
  void sub(dVec3 v) {
    x -= v.x; y -= v.y; z -= v.z;
  }
  void mult(double w) {
    x *= w; y *= w; z *= w;
  }
  void div(double w) {
    if(w == 0.0) {
      print("Division by zero detected; setting vector to zero.");
      x = 0.0; y = 0.0; z = 0.0;
      return;
    }
    x /= w; y /= w; z /= w;
  }
  void rotateX(double theta) {
    double ty = cos(theta)*y - sin(theta)*z;
            z = sin(theta)*y + cos(theta)*z;
    y = ty;
  }
  void rotateY(double theta) {
    double tx = cos(theta)*x - sin(theta)*z;
            z = sin(theta)*x + cos(theta)*z;
    x = tx;
  }
  void rotateZ(double theta) {
    double tx = cos(theta)*x - sin(theta)*y;
            y = sin(theta)*x + cos(theta)*y;
    x = tx;
  }
  PVector toPVector() {
    return new PVector((float)x, (float)y, (float)z);
  }
  double mag() {
    return sqrt(x*x + y*y + z*z);
  }
  double mag2() {
    return x*x + y*y + z*z;
  }
  double dist(dVec3 a) {
    return sqrt((x-a.x)*(x-a.x) + (y-a.y)*(y-a.y) + (z-a.z)*(z-a.z));
  }
  double dist2(dVec3 a) {
    return (x-a.x)*(x-a.x) + (y-a.y)*(y-a.y) + (z-a.z)*(z-a.z);
  }
  double dot(dVec3 a) {
    return a.x*x + a.y*y + a.z*z;
  }
  double max_component() {
    return x > y && x > z ? x : (y > z ? y : z);
  }
  double min_component() {
    return x < y && x < z ? x : (y < z ? y : z);
  }
  void normalize() {
    double m = mag();
    x /= m;
    y /= m;
    z /= m;
  }
}
dVec3 add(dVec3 a, dVec3 b) {
  return new dVec3(a.x + b.x, a.y + b.y, a.z + b.z);
}
dVec3 sub(dVec3 a, dVec3 b) {
  return new dVec3(a.x - b.x, a.y - b.y, a.z - b.z);
}
dVec3 cross(dVec3 a, dVec3 b) {
  return new dVec3(a.y*b.z - a.z*b.y, a.z*b.x - a.x*b.z, a.x*b.y - a.y*b.x);
}
dVec3 lerp(dVec3 a, dVec3 b, double x) {
  return new dVec3(lerp(a.x, b.x, x), lerp(a.y, b.y, x), lerp(a.z, b.z, x));
}
dVec3 min(dVec3 a, dVec3 b) {
  return new dVec3(a.x<b.x?a.x:b.x, a.y<b.y?a.y:b.y, a.z<b.z?a.z:b.z);
}
dVec3 max(dVec3 a, dVec3 b) {
  return new dVec3(a.x>b.x?a.x:b.x, a.y>b.y?a.y:b.y, a.z>b.z?a.z:b.z);
}
dVec3 square_components(dVec3 a) {
  return new dVec3(a.x*a.x, a.y*a.y, a.z*a.z);
}
dVec3 sqrt_components(dVec3 a) {
  return new dVec3(sqrt(a.x), sqrt(a.y), sqrt(a.z));
}
dVec3 log_components(dVec3 a) {
  return new dVec3(Math.log(a.x), Math.log(a.y), Math.log(a.z));
}
double lerp(double a, double b, double x) {
  return a*(1.0-x) + b*x;
}
double dot(dVec3 a, dVec3 b) {
  return a.dot(b);
}
double mag(dVec3 a) {
  return a.mag();
}
double mag2(dVec3 a) {
  return a.mag2();
}
double dist(dVec3 a, dVec3 b) {
  return a.dist(b);
}
double dist2(dVec3 a, dVec3 b) {
  return a.dist2(b);
}

double sqrt(double x) {
  return Math.sqrt(x);
}
double sin(double x) {
  return Math.sin(x);
}
double cos(double x) {
  return Math.cos(x);
}
double tan(double x) {
  return Math.cos(x);
}
double atan2(double y, double x) {
  return Math.atan2(y, x);
}


//====================IMAGE AND 2D ARRAY OPERATIONS====================\\

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

// NOTE: INCLUDES WHITE NOISE DITHER!!!!!
float[][] toArray(PImage p) {
  float[][] dat = new float[p.width][p.height];
  for(int x = 0; x < p.width; x++)
  for(int y = 0; y < p.height; y++) {
    color q = p.get(x, y);
    dat[x][y] = r(q) + random(-0.5, 0.5); // dither
  }
  return dat;
}

// Mode 0 : simple min/max
// Mode 1 : +/-4 sigma centered on mean
// Mode 2 : centered on zero, makes positives red and negatives cyan
// Mode 3 : centered on zero, same colors, +/-4 sigma
PImage toPic(float[][] dat, int mode) {
  PImage p = createImage(dat.length, dat[0].length, ARGB);
  
  float min = Float.MAX_VALUE;
  float max = -Float.MAX_VALUE;
  if(mode==0) {
    for(int x = 0; x < p.width; x++)
    for(int y = 0; y < p.height; y++) {
      if((x - p.width/2)*(x-p.width/2) + (y-p.height/2)*(y-p.height/2) > 25) {
        if(abs(dat[x][y]) < min) min = abs(dat[x][y]);
        if(abs(dat[x][y]) > max) max = abs(dat[x][y]);
      }
    }
  } else if(mode == 1 || mode == 3) {
    float mean = 0.f;
    for(int x = 0; x < p.width; x++)
    for(int y = 0; y < p.height; y++) {
      mean += dat[x][y];
    }
    mean /= (float)p.width*(float)p.height;
    float varr = 0.f;
    for(int x = 0; x < p.width; x++)
    for(int y = 0; y < p.height; y++) {
      varr += abs(mean - dat[x][y]);
    }
    varr /= (float)p.width*(float)p.height - 1;
    min = mean - 4.0*varr;
    max = mean + 4.0*varr;
  } else if(mode == 2) {
    for(int x = 0; x < p.width; x++)
    for(int y = 0; y < p.height; y++) {
      if(abs(dat[x][y]) > max) {
        max = abs(dat[x][y]);
      }
    }
    min = -max;
  }
  for(int x = 0; x < p.width; x++)
  for(int y = 0; y < p.height; y++) {
    if(mode < 2) {
      p.set(x, y, color(map(dat[x][y], min, max, 0, 255), 255));
    } else {
      float pos = map(dat[x][y], 0, max, 0, 255);
      float neg = map(dat[x][y], 0, min, 0, 255);
      p.set(x, y, color(pos + neg*0.2, pos*0.4 + neg*0.6, pos*0.4 + neg, 255));
    }
  }
  return p;
}

float[][] toFloatArray(PImage p) {
  float[][] f = new float[p.width][p.height];
  for(int x = 0; x < p.width; x++) for(int y = 0; y < p.height; y++) {
    f[x][y] = brightness(p.get(x,y));
  }
  return f;
}


PImage gamma(PImage p, float value) {
  PImage o = createImage(p.width, p.height, RGB);
  for(int x = 0; x < p.width; x++) for(int y = 0; y < p.height; y++) {
    color c = p.get(x, y);
    o.set(x, y, color(pow((float)r(c)/255.f, value)*255.f, pow((float)g(c)/255.f, value)*255.f, pow((float)b(c)/255.f, value)*255.f));
  }
  return o;
}

PImage bw(PImage p, float cutoff) {
  PImage o = createImage(p.width, p.height, RGB);
  for(int x = 0; x < p.width; x++) for(int y = 0; y < p.height; y++) {
    color c = p.get(x, y);
    float b = brightness(c);
    color q = color(255, 255);
    if(b < cutoff) q = color(0, 255);
    o.set(x, y, q);
  }
  return o;
}

PImage contrast(PImage p, float value, float center) {
  PImage o = createImage(p.width, p.height, RGB);
  for(int x = 0; x < p.width; x++) for(int y = 0; y < p.height; y++) {
    color c = p.get(x, y);
    o.set(x, y, color(value*(r(c)-255*center)+255*center, value*(g(c)-255*center)+255*center, value*(b(c)-255*center)+255*center));
  }
  return o;
}

PImage desaturate(PImage p) {
  PImage o = createImage(p.width, p.height, RGB);
  for(int x = 0; x < p.width; x++) for(int y = 0; y < p.height; y++) {
    color c = p.get(x, y);
    float l = brightness(c);
    o.set(x, y, color(l, l, l));
  }
  return o;
}

float[][] simpleLaplacian = new float[][]{{0, -1, 0}, {-1, 4, -1}, {0, -1, 0}};
float[][] simpleLaplacianDiagonals = new float[][]{{-1, -1, -1}, {-1, 8, -1}, {-1, -1, -1}};

// math source: https://homepages.inf.ed.ac.uk/rbf/HIPR2/log.htm
float LoG(float x, float y, float stdev) {
  float xp = -(x*x+y*y)/(2*stdev*stdev);
  return -(1+xp)*exp(xp)/(PI*stdev*stdev); // NOT NORMALIZED PROPERLY FOR CONSTANT EDGE DETECTION VALUES WITH VARYING DEVIATIONS!!!
}

float[][] normalize(float[][] m) {
  if(m.length > 0) {
    float[][] o = new float[m.length][m[0].length];
    float sum = 0.f;
    for(int x = 0; x < m.length; x++) for(int y = 0; y < m[0].length; y++) {
      sum += m[x][y];
      o[x][y] = m[x][y];
    }
    if(sum != 0.f) {
      for(int x = 0; x < m.length; x++) for(int y = 0; y < m[0].length; y++) {
        o[x][y] = m[x][y]/sum;
      }
    } else println("I think your input array is empty; there's nothing to normalize!");
    return o;
  }
  return m;
}

float[][] DoG(float stdeva, float stdevb) {
  int r = ceil(max(stdeva, stdevb)*3.f);
  float[][] kernela = new float[r*2+1][r*2+1];
  float[][] kernelb = new float[r*2+1][r*2+1];
  float[][] kernelc = new float[r*2+1][r*2+1];
  for(int x = -r; x <= r; x++) {
    for(int y = -r; y <= r; y++) {
      kernela[x+r][y+r] = gaussian(x*x+y*y, stdeva);
      kernelb[x+r][y+r] = gaussian(x*x+y*y, stdevb);
    }
  }
  normalize(kernela);
  normalize(kernelb);
  for(int x = -r; x <= r; x++) {
    for(int y = -r; y <= r; y++) {
      kernelc[x+r][y+r] = kernelb[x+r][y+r] - kernela[x+r][y+r];
    }
  }
  return kernelc;
}

float[][] gaussian(float stdev) {
  int r = ceil(stdev*3.f);
  float[][] kernel = new float[r*2+1][r*2+1];
  float sum = 0.f;
  for(int x = -r; x <= r; x++) {
    for(int y = -r; y <= r; y++) {
      float k = gaussian(x*x+y*y, stdev);
      kernel[x+r][y+r] = k;
      sum += k;
    }
  }
  kernel = normalize(kernel);
  println("Gaussian kernel generated. Array size: " + kernel.length + "^2");
  return kernel;
}

float[][] gaussianX(float stdev) {
  int r = ceil(stdev*1.25f);
  float[][] kernel = new float[r*2+1][r*2+1];
  float sum = 0.f;
  for(int x = -r; x <= r; x++) {
    float k = gaussian(x*x, stdev);
    kernel[x+r][r] = k;
    sum += k;
  }
  kernel = normalize(kernel);
  println("Gaussian kernel generated. Array size: " + kernel.length + "^2");
  return kernel;
}

float[][] gaussianY(float stdev) {
  int r = ceil(stdev*1.25f);
  float[][] kernel = new float[r*2+1][r*2+1];
  float sum = 0.f;
  for(int y = -r; y <= r; y++) {
    float k = gaussian(y*y, stdev);
    kernel[r][y+r] = k;
    sum += k;
  }
  kernel = normalize(kernel);
  println("Gaussian kernel generated. Array size: " + kernel.length + "^2");
  return kernel;
}

float[][] LoG(float stdev) {
  int r = ceil(stdev*3.f);
  float[][] kernel = new float[r*2+1][r*2+1];
  for(int x = -r; x <= r; x++) {
    for(int y = -r; y <= r; y++) {
      float k = LoG(x, y, stdev);
      kernel[x+r][y+r] = k;
    }
  }
  println("Lagrangian of Gaussian kernel generated. Array size: " + kernel.length + "^2");
  return kernel;
}

float luma255(color c) {
  return 0.2126*(float)r(c) + 0.7152*g(c) + 0.0722*b(c);
}

float luma255(PVector c255) {
  return 0.2126*c255.x + 0.7152*c255.y + 0.0722*c255.z;
}

float gaussian(float r2, float stdev) {
  return exp(-r2/(stdev*stdev*2.f))/(stdev*SQRT_TWO_PI);
}

PImage exposure(PImage p, float value) {
  PImage o = createImage(p.width, p.height, RGB);
  if(value < 1.f) println("Warning! Exposure multiplier < 1.f!");
  for(int x = 0; x < p.width; x++) for(int y = 0; y < p.height; y++) {
    color c = p.get(x, y);
    o.set(x, y, color(value*(float)r(c), value*(float)g(c), value*(float)b(c)));
  }
  return o;
}

PImage invert(PImage p) {
  PImage o = createImage(p.width, p.height, RGB);
  for(int x = 0; x < p.width; x++) for(int y = 0; y < p.height; y++) {
    color c = p.get(x, y);
    o.set(x, y, color(255-r(c), 255-g(c), 255-b(c)));
  }
  return o;
}

PImage linComb(PImage a, PImage b, float amult, float bmult) {
  if(a.width != b.width || a.height != b.height) {
    println("Images not same size! Returning image a!");
    return a;
  }
  PImage o = createImage(a.width, a.height, RGB);
  for(int x = 0; x < a.width; x++) for(int y = 0; y < a.height; y++) {
    color ca = a.get(x, y);
    color cb = b.get(x, y);
    o.set(x, y, color(amult*(float)r(ca) + bmult*(float)r(cb), amult*(float)g(ca) + bmult*(float)g(cb), amult*(float)b(ca) + bmult*(float)b(cb)));
  }
  return o;
}

PImage lensBlur(PImage p, PImage lensMask) {
  float[][] kernel = new float[lensMask.width][lensMask.height];
  if(lensMask.width%2 == 0 || lensMask.width != lensMask.height) {
    println("Lens mask does not meet requirements (width/height must be equal and odd)!");
    return p;
  }
  for(int x = 0; x < lensMask.width; x++) {
    for(int y = 0; y < lensMask.height; y++) {
      kernel[x][lensMask.height - y - 1] = ((float)g(lensMask.get(x, y)))/255.f;
    }
  }
  return lensBlur(p, kernel);
}

PImage lensBlur(PImage p, int r) {
  float[][] kernel = new float[r*2+1][r*2+1];
  for(int x = -r; x <= r; x++) {
    for(int y = -r; y <= r; y++) {
      float a = (x*x+y*y < r*r)?1:0;
      kernel[x+r][y+r] = a;
    }
  }
  println("Circular kernel generated. Array size: " + kernel.length + "^2");
  return lensBlur(p, kernel);
}

PImage lensBlur(PImage p, float[][] kernel) {
  PImage img = createImage(p.width, p.height, RGB);
  for(int xc = 0; xc < p.width; xc++) for(int yc = 0; yc < p.height; yc++) {
  PVector sumvec = new PVector(0.f, 0.f, 0.f);
  float sumscalar = 0.f;
  for(int x = 0; x < kernel.length; x++) {
    for(int y = 0; y < kernel.length; y++) {
      if(kernel[x][y] > 0) {
        PVector v = getVector255(p, xc + x - kernel.length/2, yc + y - kernel.length/2);
        v = new PVector(v.x*kernel[x][y], v.y*kernel[x][y], v.z*kernel[x][y]);
        float lum = luma255(v);
        sumvec.add(PVector.mult(v, lum));
        sumscalar += lum*kernel[x][y];
      }
    }
  }
  sumvec.mult(1.f/sumscalar);
  img.set(xc, yc, color(sumvec.x, sumvec.y, sumvec.z));
  }
  println("Blur done.");
  return img;
}

float SQRT_TWO_PI = 2.50662827463f;
PImage gaussianBlur(PImage p, float stdev) {
  PGraphics pg = createGraphics(p.width, p.height);
  pg.beginDraw();
  int r = ceil(stdev*3.f);
  float[][] kernel = new float[r*2+1][r*2+1];
  float sum = 0.f;
  for(int x = -r; x <= r; x++) {
    for(int y = -r; y <= r; y++) {
      float a = gaussian(x*x + y*y, stdev);
      kernel[x+r][y+r] = a;
      sum += a;
    }
  }
  println("Kernel generated. Array size: " + kernel.length + "^2");
  PImage img = createImage(p.width, p.height, RGB);
  for(int x = 0; x < p.width; x++) for(int y = 0; y < p.height; y++) {
    PVector v = convolve(p, x, y, kernel).mult(1.f/sum);
    img.set(x, y, color(v.x, v.y, v.z));
  }
  println("Blur done.");
  return img;
}

PVector abs(PVector p) {
  return new PVector(abs(p.x), abs(p.y), abs(p.z));
}

//color() but scaled by 255.0
color color255(float x, float y, float z) {
  return color(x*255.f, y*255.f, z*255.f);
}

//color() but scaled by 255.0*w
color color255(float x, float y, float z, float w) {
  return color(x*255.f*w, y*255.f*w, z*255.f*w);
}

PVector getVector(float x, float y) {
  color c = get(max(0, min(width-1, round(x))), max(0, min(height-1, round(y))));
  return new PVector((float)r(c)/255.f, (float)g(c)/255.f, (float)b(c)/255.f);
}
PVector getVector(PImage p, float x, float y) {
  color c = p.get(max(0, min(p.width-1, round(x))), max(0, min(p.height-1, round(y))));
  return new PVector((float)r(c)/255.f, (float)g(c)/255.f, (float)b(c)/255.f);
}
color getColor(float x, float y) { return get(max(0, min(width-1, round(x))), max(0, min(height-1, round(y)))); }
color getColor(PImage p, float x, float y) { return p.get(max(0, min(p.width-1, round(x))), max(0, min(p.height-1, round(y)))); }

PImage convolve(PImage p, float[][] conv) {
  PImage o = createImage(p.width, p.height, RGB);
  for(int xc = 0; xc < p.width; xc++) { print(xc); for(int yc = 0; yc < p.height; yc++) {
    PVector v = convolve(p, xc, yc, conv);
    o.set(xc, yc, color(v.x, v.y, v.z));
  }}
  return o;
}

PVector convolve(PImage p, float xc, float yc, float[][] conv) {
  PVector sum = new PVector(0.f, 0.f, 0.f);
  for(int x = 0; x < conv.length; x++) {
    for(int y = 0; y < conv.length; y++) {
      PVector v = getVector255(p, xc + x - conv.length/2, yc + y - conv.length/2);
      v = new PVector(v.x*conv[x][y], v.y*conv[x][y], v.z*conv[x][y]);
      sum.add(v);
    }
  }
  return sum;
}

//Radial blur
PVector getRadial(PImage p, float xc, float yc, int r) {
  PVector sum = new PVector(0.f, 0.f, 0.f);
  float total_pixels = 0.f;
  for(int x = -r; x <= r; x++) {
    for(int y = -r; y <= r; y++) {
      if(x*x + y*y <= r*r) {
        sum.add(getVector(p, xc + x, yc + y));
        total_pixels++;
      }
    }
  }
  sum.mult(1.f/total_pixels);
  return sum;
}

//Compares two radial blurs to one another (r2 blur - r1 blur)
PVector getRadialDiff(PImage p, float xc, float yc, int r1, int r2) {
  PVector a = getRadial(p, xc, yc, r2);
  a.sub(getRadial(p, xc, yc, r1));
  return a;
}

//Returns the average of the specified channels at the specified coordinates
float getValue(PImage p, float xc, float yc, boolean re, boolean ge, boolean bu) {
  int x = 0;
  int y = 0;
  color c = getColor(p, xc, yc);
  return (float)((re?r(c):0)+(ge?g(c):0)+(bu?b(c):0))/((re?1:0)+(ge?1:0)+(bu?1:0));
}
