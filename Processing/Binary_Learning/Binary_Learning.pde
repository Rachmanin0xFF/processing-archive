
// 0 ~
// 1 >>
// 2 <<
// 3 <<<
// 4 >>>
// 5 |
// 6 ^
// 7 &

byte b = 0;

SGNN testN = new SGNN(200, 200, 1, 2);

void setup() {
  size(1024, 1024, P2D);
  background(0);
  stroke(255, 150);
  blendMode(ADD);
  
  testN.randomize();
  plot();
}
int len = 10024;
float[] data0 = new float[len];
float max0 = -10000000.f;
float min0 = 10000000.f;
float[] data1 = new float[len];
float max1 = -10000000.f;
float min1 = 10000000.f;
float[] datar = new float[len];
void draw() {
  colorMode(HSB);
  background(0);
  //for(int i = 0; i < len-1; i++) {
  //  line(i, map(data0[i], min0, max0, height, 0), i+1, map(data0[i+1], min0, max0, height, 0));
  //}
  for(int i = 0; i < len-1; i++) {
    stroke((datar[i] + 2147483647.f)/2147483647.f*2.f*255.f, 255.f, 255.f);
    point(map(data0[i], min0, max0, 0, width), map(data1[i], min1, max1, height, 0));
  }
}

void keyPressed() {
  plot();
}

void plot() {
  boolean bobo = true;
  while(bobo) {
    max0 = -10000000.f;
    min0 = 10000000.f;
    max1 = -10000000.f;
    min1 = 10000000.f;
    testN.randomize();
    for(int i = 0; i < len; i++) {
      float q = random(-2147483647, 2147483647);
      datar[i] = q;
      int[] z = testN.tsf((int)q);
      data0[i] = z[0];
      data1[i] = z[1];
      if(data0[i] < min0) min0 = data0[i];
      if(data0[i] > max0) max0 = data0[i];
      if(data1[i] < min1) min1 = data1[i];
      if(data1[i] > max1) max1 = data1[i];
    }
    if(min0 != max0 && min1 != max1) bobo = false;
  }
}


class SGNN {
  int inh;
  int ouh;
  int sgnw;
  int sgnh;
  
  SigN[][] sgns;
  SigN[] outputs;
  
  SGNN(int w, int h, int inputs, int outputs) {
    sgnw = w;
    sgnh = h;
    inh = inputs;
    ouh = outputs;
    sgns = new SigN[sgnw][sgnh];
    this.outputs = new SigN[ouh];
    for(int x = 0; x < w; x++) {
      for(int y = 0; y < h; y++) {
        sgns[x][y] = new SigN();
      }
    }
    for(int y = 0; y < ouh; y++) this.outputs[y] = new SigN();
  }
  
  void randomize() {
    for(int x = 0; x < sgnw; x++) {
      for(int y = 0; y < sgnh; y++) {
        if(x == 0)
          sgns[x][y] = new SigN((byte)(int)random(8), (int)random(inh), (int)random(inh));
        else
          sgns[x][y] = new SigN((byte)(int)random(8), (int)random(sgnh), (int)random(sgnh));
      }
    }
    for(int y = 0; y < ouh; y++) outputs[y] = new SigN((byte)(int)random(8), (int)random(sgnh), (int)random(sgnh));
  }
  
  int[] tsf(int... inputs) {
    for(int x = 0; x < sgnw; x++) {
      for(int y = 0; y < sgnh; y++) {
        if(x == 0) {
          sgns[x][y].process(inputs);
        } else {
          sgns[x][y].process(sgns[x-1]);
        }
      }
    }
    int[] outgoing = new int[ouh];
    for(int y = 0; y < ouh; y++) {
      outputs[y].process(sgns[sgnw-1]);
      outgoing[y] = outputs[y].result;
    }
    return outgoing;
  }
}
class SigN {
  // 0 ~
  // 1 >>
  // 2 <<
  // 3 <<<
  // 4 >>>
  // 5 |
  // 6 ^
  // 7 &
  int result = 0;
  byte type = 0;
  int fetch0 = -1;
  int fetch1 = -1;
  public SigN() {}
  public SigN(byte type, int fetch0, int fetch1) {
    this.type = type;
    this.fetch0 = fetch0;
    this.fetch1 = fetch1;
  }
  void process(SigN[] words) {
    switch(type) {
      case 0: result = ~words[fetch0].result; break;
      case 1: result = words[fetch0].result >> 1; break;
      case 2: result = words[fetch0].result << 1; break;
      case 3: result = words[fetch0].result + 1; break;
      case 4: result = words[fetch0].result - 1; break;
      case 5: result = words[fetch0].result | words[fetch1].result; break;
      case 6: result = words[fetch0].result ^ words[fetch1].result; break;
      case 7: result = words[fetch0].result & words[fetch1].result; break;
      default: break;
    }
  }
  void process(int[] words) {
    switch(type) {
      case 0: result = ~words[fetch0]; break;
      case 1: result = words[fetch0] >> 1; break;
      case 2: result = words[fetch0] << 1; break;
      case 3: result = words[fetch0] + 1; break;
      case 4: result = words[fetch0] - 1; break;
      case 5: result = words[fetch0] | words[fetch1]; break;
      case 6: result = words[fetch0] ^ words[fetch1]; break;
      case 7: result = words[fetch0] & words[fetch1]; break;
      default: break;
    }
  }
  boolean doubleInput() {
    return type > 4;
  }
}

void printBin(int x) {
  String s = Integer.toBinaryString(x);
  while(s.length() < 32) s = "0" + s;
  println(s);
}
