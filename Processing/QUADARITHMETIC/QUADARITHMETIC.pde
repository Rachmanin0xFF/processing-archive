
//So simple!

float ms1 = 1.5f;
float ms2 = 1.0f;
float ms3 = 0.5f;
float ms4 = 1.0f;

void setup() {
  size(100, 100, P2D);
  frameRate(2147483647);
  
  float yo = 0.1f;
  
  ms1 += yo;
  ms2 -= yo;
  ms3 += yo;
  ms4 -= yo;
  
  printVals();
}

void printVals() {
  println("LIFT:  " + (ms1 + ms2 + ms3 + ms4));
  println("YAW:   " + (ms1 + ms3 - ms2 - ms4));
  println("Y-ROT: " + (ms1 - ms3));
  println("X-ROT: " + (ms2 - ms4));
}
