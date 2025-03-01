
import java.util.*;

float value;
ArrayList<Float> recorded_values = new ArrayList<Float>();
ArrayList<Float> measured_values = new ArrayList<Float>();
ArrayList<Float> understood_values = new ArrayList<Float>();

void setup() {
  size(1600, 900, P2D);
  background(255);
  frameRate(100);
  strokeCap(SQUARE);
  //noSmooth();
  blendMode(ADD);
}

//1 frame = 1/100th of a second

float tnkVal1 = 0.f;
float smt = 0.f;

void draw() {
  background(0);
  value = sin((float)frameCount/100.f*PI)*45.f*0.f;
  
  value = (mouseX - width/2.f)/10.f;
  
  recorded_values.add(value);
  if(frameCount % 2 == 0) {
    measured_values.add(value + randomGaussian()*1.5f);
  }
  
  if(frameCount > 100) {
    float trgm1 = measured_values.get(measured_values.size()-2);
    float trg = measured_values.get(measured_values.size()-1);
    
    int iter = 0;
    int len = 20;
    float[] vals = new float[len];
    float[] vals2 = new float[len];
    int dex = measured_values.size() - 1;
    int dex2 = vals.length - 1;
    for(int i = 0; i < vals.length; i++) {
      vals[dex2] = measured_values.get(dex);
      dex--;
      dex2--;
    }
    for(int k = 0; k < iter; k++) {
      for(int i = 1; i < vals.length; i++) {
        if(i == vals.length - 1)
          vals2[i] = (vals[i-1] + vals[i]*40.f)/41.f;
        else
          vals2[i] = (vals[i+1] + vals[i] + vals[i-1])/3.f;
      }
      for(int i = 0; i < vals.length; i++) vals[i] = vals2[i];
    }
    stroke(255, 255);
    for(int i = 0; i < vals.length; i++) {
      point(i*10 + 20, height/3 - vals[i]/2.f);
    }
    
    float sm0 = vals[vals.length-1];
    float sm1 = vals[vals.length-2];
    float sm2 = vals[vals.length-3];
    float sm3 = vals[vals.length-4];
    
    float d1 = sm0 - sm1;
    float d2 = (d1 - (sm1 - sm2))/2.f;
    float d3 = (d2 - ((sm1 - sm2) - (sm2 - sm3))/2.f);
    
    float taylor = d1 + d2/2.f + d3/6.f;
    
    smt += 0.4f*(taylor - smt);
    
    tnkVal1 += smt;
    tnkVal1 += 0.2*((sm0 + sm1)/2.f - tnkVal1);
  }
  understood_values.add(tnkVal1);
  
  if(recorded_values.size() > 100) {
    recorded_values.remove(0);
    understood_values.remove(0);
  }
  if(measured_values.size() > 50) {
    measured_values.remove(0);
  }
  plotData(20, 20, width - 40, height - 40, recorded_values, measured_values, understood_values);
  if(mousePressed) {
    blendMode(SUBTRACT);
    fill(255, 0, 0);
    rect(-10, -10, width + 20, height + 20);
    blendMode(ADD);
  }
  pushMatrix();
  translate(width/2, height/2);
  rotate(tnkVal1/57.f);
  stroke(255, 0, 255);
  line(-500, 0, 500, 0);
  popMatrix();
  translate(width/2, height/2);
  stroke(255, 255);
  rotate(value/57.f);
  line(-500, 0, 500, 0);
}

void plotData(float x, float y, float w, float h, ArrayList<Float>... input) {
  //stroke(0, 255, 0, 255);
  //line(x, y + h/2.f, x + w, y + h/2.f);
  noFill();
  stroke(255, 255, 255, 255);
  rect(x, y, w, h);
  color[] dataColors = new color[]{color(200, 0, 0), color(50, 200, 50), color(50, 50, 200)};
  int k = 0;
  //blendMode(ADD);
  float ramng = 90.f;
  for(ArrayList<Float> data : input) {
    if(k == 1) strokeWeight(3); else strokeWeight(1);
    stroke(dataColors[k%dataColors.length]);
    for(float i = 0.f; i < data.size()-1.f; i++) {
      float x0 = map(i, 0.f, data.size(), x, x + w);
      float y0 = clamp(map(data.get(int(i)), -ramng, ramng, y + h, y), y, y + h);
      float x1 = map(i + 1.f, 0.f, data.size(), x, x + w);
      float y1 = clamp(map(data.get(int(i + 1.f)), -ramng, ramng, y + h, y), y, y + h);
      if(k == 1)
        point(x0, y0);
      else
        line(x0, y0, x1, y1);
      if(k == 2) {
        strokeWeight(3);
        point(x0, y0);
        strokeWeight(1);
      }
        
    }
    k++;
  }
  blendMode(BLEND);
}

boolean bog = true;
void keyPressed() {
  bog = !bog;
  if(bog) loop(); else noLoop();
}

float clamp(float a, float x, float y) {
  if(x > y) return -1.f;
  if(a < x) return x;
  if(a > y) return y;
  return a;
}
