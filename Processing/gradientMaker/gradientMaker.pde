color start = color(255, 0, 0, 255);
color stop = color(0, 255, 0, 255);
void setup() {
  size(800, 50, P2D);
  for(float x = 0.f; x <= width; x++) {
    stroke(mix(stop, start, x/float(width)));
    line(x, 0, x, height);
  }
  saveFrame("output.png");
}

color mix(color x, color y, float a) {
  return color(r(x)*(1.f - a) + r(y)*a, g(x)*(1.f - a) + g(y)*a, b(x)*(1.f - a) + b(y)*a);
}

int r(color c) {return (c >> 16) & 255; }
int g(color c) {return (c >> 8) & 255;}
int b(color c) {return c & 255; }
