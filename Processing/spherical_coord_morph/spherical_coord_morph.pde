void setup() {
  size(1600, 900, P3D);
  background(0);
  smooth(16);
}

float refl(float z) {
  return z > 1.0 ? 2.0-z : z;
}
float saw(float z) {
  return refl(z%2);
}
float clmpsaw(float z) {
  return max(0.0, min(1.0, saw(z)*3.0-1.0));
}

float smootherstep(float z) {
  float x = max(0.0, min(1.0, z));
  return x * x * x * (x * (x * 6. - 15.) + 10.);
}
void draw() {
  background(0);
  translate(width/2, height/2);
  rotateX(-0.5);
  rotateY(frameCount/200.0);
  strokeWeight(1);
  float fac = smootherstep(clmpsaw(frameCount/200.0));
  
  float r = 3;
  float dz = 0.1;
  float s = 200.0;
  for(float xi = -r; xi <= r; xi++) {
    for(float yi = -r; yi <= r; yi++) {
      float xn = xi/r;
      float yn = yi/r;
      for(float zi = -r; zi < r; zi+=dz) {
        float zn = zi/r;
        
        PVector v1 = new PVector(xn, yn, zn);
        PVector v2 = new PVector(xn, yn, zn+dz/r);
        
        v1 = morph(v1, fac);
        v2 = morph(v2, fac);
        
        PVector v1s = PVector.mult(v1, s);
        PVector v2s = PVector.mult(v2, s);
        stroke(227, 70, 59);
        line(v1s.x, v1s.y, v1s.z, v2s.x, v2s.y, v2s.z);
        
        //
        
        zn = zi/r;
        
        v1 = new PVector(xn, zn, yn);
        v2 = new PVector(xn, zn+dz/r, yn);
        
        v1 = morph(v1, fac);
        v2 = morph(v2, fac);
        
        v1s = PVector.mult(v1, s);
        v2s = PVector.mult(v2, s);
        stroke(84, 184, 86);
        line(v1s.x, v1s.y, v1s.z, v2s.x, v2s.y, v2s.z);
        
        //
        
        zn = zi/r;
        
        v1 = new PVector(zn, xn, yn);
        v2 = new PVector(zn+dz/r, xn, yn);
        
        v1 = morph(v1, fac);
        v2 = morph(v2, fac);
        
        v1s = PVector.mult(v1, s);
        v2s = PVector.mult(v2, s);
        stroke(98, 87, 247);
        line(v1s.x, v1s.y, v1s.z, v2s.x, v2s.y, v2s.z);
        
      }
      
    }
  }
}

PVector lerp(PVector a, PVector b, float fac) {
  return new PVector((1.0-fac)*a.x + b.x*fac, (1.0-fac)*a.y + b.y*fac, (1.0-fac)*a.z + b.z*fac);
}

PVector morph(PVector v, float fac) {
  float r = 0.7*(v.x+1.0);
  float p = (v.y+1.0)*PI*0.5;
  float t = v.z*PI;
  PVector sph = new PVector(r*cos(t)*sin(p), r*sin(t)*sin(p), r*cos(p));
  return lerp(v, sph, fac);
}
