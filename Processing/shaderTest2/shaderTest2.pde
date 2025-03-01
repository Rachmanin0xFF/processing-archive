PShader s;
void setup() {
  size(512, 128, P2D);
  println("Program Start");
  s = loadShader("woop.glsl");
  s.set("resXY", float(width), float(height));
  for(int x = 0; x < width; x++)
   for(int y = 0; y < height; y++) {
     color c = color(random(255), random(255), random(255));
     set(x, y, c);
   }
 frameRate(1000000);
}
void draw() {
 filter(s);
}

//MAX INT RANGE - 2,000,000
//So basically 1,000,000 signed possible values.
int[] ftoi(float x) {
  if(x>2000000)
    println("Major data loss! " + x + " is out of range!");
  int a = int(x%200f);
  int b = int(x%20000f)/200;
  int c = int(x%2000000f)/20000;
  return new int[]{a, b, c};
}
float itof(int a, int b, int c) {
  return float(a) + float(b)*200f + float(c)*20000f;
}
