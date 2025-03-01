int r(color c) {return (c >> 16) & 255; }
int g(color c) {return (c >> 8) & 255;}
int b(color c) {return c & 255; }

void strokea(color c, int alpha) {
  stroke(r(c), g(c), b(c), alpha);
}

void filla(color c, int alpha) {
  fill(r(c), g(c), b(c), alpha);
}

float coslerp(float x) {
  if(x >= 1) return 1;
  return -cos(x*PI)*0.5f+0.5f;
}
float SQRT_2 = 1.41421356237f;