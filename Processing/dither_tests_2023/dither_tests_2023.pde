PImage input;
void setup() {
  size(512, 512, P2D);
  input = loadImage("gray.png");
  background(0);
  noSmooth();
  stroke(255);
}
void draw() {
  background(0);
   float[][] vals = toArray(input);
  //PImage qual = toPic(ft(vals));
  //image(qual, 0, 0);
  
  float[][] vals2 = quantize_dither(vals);
  
  loadPixels();
  for(int x = 0; x < width; x++) {
    for(int y = 0; y < height; y++) {
      //if(red(input.get(x, y)) + randomGaussian()*64 > 255/2) set(x, y, color(255));
      //set(x, y, color(red(input.get(x, y)) + random(-30, 30)));
      //set(x, y, color(random(255)));
      set(x, y, color(vals2[x][y]));
    }
  }
  updatePixels();
  saveFrame("output.png");
  noLoop();
  
  vals = new float[3][4];
  for(int x = 0; x < vals.length; x++) {
    for(int y = 0; y < vals[0].length; y++) {
      vals[x][y] = 0.3;
    }
  }
  vals = quantize_dither(vals);
  for(int x = 0; x < vals.length; x++) {
    for(int y = 0; y < vals[0].length; y++) {
      print(vals[x][y]);
      print(" ");
    }
    print("\n");
  }
}

float[][] quantize_dither(float[][] in) {
  float[][] out = new float[in.length][in[0].length];
  for(int x = 0; x < in.length; x++) {
    for(int y = 0; y < in[0].length; y++) {
      float this_p = quantize(in[x][y] + out[x][y]);
      
      float error = this_p - (in[x][y] + out[x][y]);
      out[x][y] = this_p;
      addv(out, x+1, y, -error*0.5);
      addv(out, x, y+1, -error*0.5);
      //addv(out, x+1, y+1, -error*0.3);
    }
  }
  
  return out;
}

float quantize(float f) {
  return f > (255/2)? 255 : 0;
  //return round(f);
}

void addv(float[][] arr, int x, int y, float val) {
  if(x > arr.length-1 || y > arr[0].length - 1 || x < 0 || y < 0) return;
  arr[min(max(x, 0), arr.length-1)][min(max(y, 0), arr[0].length-1)] += val;
}
