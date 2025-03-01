
int RES = 38;
float[][] u = new float[RES][RES];
float[][] tu = new float[RES][RES];
float[][] ttu = new float[RES][RES];
float[][] cls = new float[RES][RES];

void setup() {
  size(900, 900, P3D);
  noiseDetail(1);
  for(int x = 0; x < RES; x++) {
    for(int y = 0; y < RES; y++) {
      u[x][y] = 0;
      tu[x][y] = u[x][y];
      ttu[x][y] = tu[x][y];
    }
  }
}


void draw() {
  background(0);
  plotFArr3D(u, cls, 200, 200, width-400);
  
  fill(255);
  for(int i = 0; i < 300 ;i++) {
      u[RES/3*2][RES/3*2] = -1;
      u[RES/3][RES/3*2] = 1;
      u[RES/3*2][RES/3] = 1;
      u[RES/3][RES/3] = -1;
     for(int x = 2; x < RES-2; x++) {
        for(int y = 2; y < RES-2; y++) {
          tu[x][y] = u[x][y] - getBiharmonic(u, x, y)*0.01;
          
          if((x == RES/3*2 && y == RES/3*2) || (x == RES/3 && y == RES/3*2) || (x == RES/3*2 && y == RES/3) || (x == RES/3 && y == RES/3))
          cls[x][y] = 0;
          else cls[x][y] = getBiharmonic(u, x, y);
          
        }
     }
     for(int x = 0; x < RES; x++) {
        for(int y = 0; y < RES; y++) {
          tu[x][y] = tu[min(max(x, 1), RES-2)][min(max(y, 1), RES-2)];
          ttu[x][y] = tu[x][y];
        }
     }
     if(mousePressed) {
     // sets laplace operator to 0
     float fac = 0.00001;
     for(int x = 1; x < RES-1; x++) {
        for(int y = 1; y < RES-1; y++) {
          if(x == 1 && y > 1 && y < RES-2) {
            ttu[x][y] = tu[x][y] +  fac*(-tu[x][y] + 4.0*tu[x+1][y] - tu[x+1][y+1] - tu[x+1][y-1] - tu[x+2][y]);
          }
          if(x == RES-2 && y != 1 && y > 1 && y < RES-2) {
            ttu[x][y] = tu[x][y] +  fac*(-tu[x][y] + 4.0*tu[x-1][y] - tu[x-1][y+1] - tu[x-1][y-1] - tu[x-2][y]);
          }
          if(y == RES-2 && x != 1 && x > 1 && x < RES-2) {
            ttu[x][y] = tu[x][y] +  fac*(-tu[x][y] + 4.0*tu[x][y-1] - tu[x-1][y-1] - tu[x+1][y-1] - tu[x][y-2]);
          }
          if(y == 1 && x != 1 && x > 1 && x < RES-2) {
            ttu[x][y] = tu[x][y] +  fac*(-tu[x][y] + 4.0*tu[x][y+1] - tu[x-1][y+1] - tu[x+1][y+1] - tu[x][y+2]);
          }
        }
     }
     
     
     //neumann
     
       for(int x = 1; x < RES-1; x++) {
          for(int y = 1; y < RES-1; y++) {
            if(x == 1 && y > 1 && y < RES-2) {
              ttu[x][y] = tu[x][y] + 0.01*(-tu[x][y] + tu[x+1][y])*mouseX/1000.f;
            }
            if(x == RES-2 && y != 1 && y > 1 && y < RES-2) {
              ttu[x][y] = tu[x][y] + 0.01*(-tu[x][y] + tu[x-1][y])*mouseX/1000.f;
            }
            if(y == RES-2 && x != 1 && x > 1 && x < RES-2) {
              ttu[x][y] = tu[x][y] + 0.01*(-tu[x][y] + tu[x][y-1])*mouseX/1000.f;
            }
            if(y == 1 && x != 1 && x > 1 && x < RES-2) {
              ttu[x][y] = tu[x][y] + 0.01*(-tu[x][y] + tu[x][y+1])*mouseX/1000.f;
            }
          }
       }
       for(int x = 0; x < RES; x++) {
        for(int y = 0; y < RES; y++) {
          tu[x][y] = ttu[x][y];
        }
       }
     }
     for(int x = 0; x < RES; x++) {
        for(int y = 0; y < RES; y++) {
          u[x][y] = tu[x][y];
        }
     }
  }
}

float[][] toBiharmonic(float[][] input) {
  float[][] output = new float[input.length][input[0].length];
  for(int x = 0; x < input.length; x++) {
    for(int y = 0; y < input[0].length; y++) {
      output[x][y] = getBiharmonic(input, x, y);
    }
  }
  return output;
}

//https://www.researchgate.net/figure/A-thirteen-point-scheme-used-for-the-approximation-of-the-biharmonic-equation-into-square_fig1_276082886
float getBiharmonic(float[][] input, int x, int y) {
  float a = getAt(input, x, y+2) + getAt(input, x, y-2) + getAt(input, x+2, y) + getAt(input, x-2, y);
  float b = getAt(input, x+1, y+1) + getAt(input, x-1, y+1) + getAt(input, x-1, y-1) + getAt(input, x+1, y-1);
  float c = getAt(input, x+1, y) + getAt(input, x, y+1) + getAt(input, x-1, y) + getAt(input, x, y-1);
  float d = getAt(input, x, y);
  
  return a + 2.f*b - 8.f*c + 20.f*d;
}

float getLaplace(float[][] input, int x, int y) {
  float a = getAt(input, x, y+1) + getAt(input, x, y-1) + getAt(input, x+1, y) + getAt(input, x-1, y);
  float d = getAt(input, x, y);
  
  return -a + d*4.f;
}

float getAt(float[][] vals, int x, int y) {
  if(x < 0) x = 0;
  if(x > vals.length-1) x = vals.length-1;
  if(y < 0) y = 0;
  if(y > vals.length-1) y = vals.length-1;
  return vals[x][y];
}

void plotFArr(float[][] vals, float x, float y, float wh) {
  strokeCap(SQUARE);
  strokeWeight(wh / vals.length);
  float min =  100000000.0;
  float max = -100000000.0;
  for(int xi = 0; xi < vals.length; xi++) {
    for(int yi = 0; yi < vals[xi].length; yi++) {
      if(vals[xi][yi] < min) min = vals[xi][yi];
      if(vals[xi][yi] > max) max = vals[xi][yi];
    }
  }
  for(int xi = 0; xi < vals.length; xi++) {
    for(int yi = 0; yi < vals[xi].length; yi++) {
      stroke(map(vals[xi][yi], min, max, 0, 255));
      point((xi/(float)vals.length)*wh + x, (yi/(float)vals[xi].length)*wh + y);
    }
  }
  strokeWeight(1);
}

void plotFArr3D(float[][] vals, float[][] cvals, float x, float y, float wh) {
  pushMatrix();
  camera(x + wh/2.0, y + wh/2.0, (height/2.0) / tan(PI*30.0 / 180.0), width/2, height/2, 0, 0, 1, 0);
  ortho();
  translate(x + wh/2, y + wh/2);
  rotateX(-0.5f);
  rotateY(mouseX/2000.f);
  float min =  100000000.0;
  float max = -100000000.0;
  float minc = min;
  float maxc = max;
  float avc = 0;
  for(int xi = 0; xi < vals.length; xi++) {
    for(int yi = 0; yi < vals[xi].length; yi++) {
      avc += cvals[xi][yi];
    }
  }
  float stdv = 0.0;
  avc /= vals.length*vals[0].length;
  for(int xi = 0; xi < vals.length; xi++) {
    for(int yi = 0; yi < vals[xi].length; yi++) {
      if(vals[xi][yi] < min) min = vals[xi][yi];
      if(vals[xi][yi] > max) max = vals[xi][yi];
      if(cvals[xi][yi] < minc) minc = cvals[xi][yi];
      if(cvals[xi][yi] > maxc) maxc = cvals[xi][yi];
      stdv += (cvals[xi][yi] - avc)*(cvals[xi][yi] - avc);
    }
  }
  stdv /= vals.length*vals[0].length;
  stdv = sqrt(stdv);
  fill(255, 255);
  
  noStroke();
  fill(255);
  if(min != max)
  for(int xi = 0; xi < vals.length-1; xi++) {
    for(int yi = 0; yi < vals[xi].length-1; yi++) {
      fill(map(vals[xi][yi], min, max, 0, 255));
      fill(0);
      boolean bar = false;
      if(xi < 1 || yi < 1 || xi > vals.length-3 || yi > vals[xi].length-3) bar = true;
      if(bar) fill(255, (xi*6475)%255, (yi*64375)%255);
      beginShape(QUADS);
      stroke(0);
      if(!bar) fill(0, map(cvals[xi][yi], avc - stdv*2.0, avc + stdv*2.0, 0, 255), 70);
      vertex((xi/(float)vals.length-0.5)*wh, map(-vals[xi][yi], min, max, -wh/4, wh/4), (yi/(float)vals.length-0.5)*wh);
      if(!bar) fill(0, map(cvals[xi+1][yi], avc - stdv*2.0, avc + stdv*2.0, 0, 255), 70);
      vertex(((xi+1)/(float)vals.length-0.5)*wh, map(-vals[xi+1][yi], min, max, -wh/4, wh/4), (yi/(float)vals.length-0.5)*wh);
      if(!bar) fill(0, map(cvals[xi+1][yi+1], avc - stdv*2.0, avc + stdv*2.0, 0, 255), 70);
      vertex(((xi+1)/(float)vals.length-0.5)*wh, map(-vals[xi+1][yi+1], min, max, -wh/4, wh/4), ((yi+1)/(float)vals.length-0.5)*wh);
      if(!bar) fill(0, map(cvals[xi][yi+1], avc - stdv*2.0, avc + stdv*2.0, 0, 255), 70);
      vertex((xi/(float)vals.length-0.5)*wh, map(-vals[xi][yi+1], min, max, -wh/4, wh/4), ((yi+1)/(float)vals.length-0.5)*wh);
      endShape(CLOSE);
    }
  }
  popMatrix();
  fill(255);
  text(stdv*10000.0, 30, 30);
}
