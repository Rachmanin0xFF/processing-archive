int[] palette = new int[0];
int s = 1;
float mlt = 70.f;
float div = 350.f;
void setup() {
  size(1280*s, 720*s, P2D);
  frameRate(10000000);
  rectMode(CENTER);
  noSmooth();
  //stroke(255);
  //smooth(4);
  background(255);
  palette = colorPick();
}
float t = 0.f;
void draw() {
  //noFill();
  //fill(255, 40);
  //rect(0, 0, width*2, height*2);
  //palette = colorPick();
  drawStuff();
  //saveFrame(get_time() + "output.jpg");
}

void drawStuff() {
  randomSeed(4);
  background(palette[(int)random(palette.length)]);
  //background(255);
  for(int i = 0; i < 10000; i++) {
    fill(palette[(int)random(palette.length)]);
    //noStroke();
    stroke(palette[(int)random(palette.length)]);
    //stroke(0);
    float x = random(width);
    float y = random(height);
    float r = (float)ridged_noise(x/div+1251251, y/div, t)*mlt;
    float r2 = (float)ridged_noise(y/div+215125, x/div, t)*mlt;
    pushMatrix();
    translate(x*s, y*s);
    rotate((float)ridged_noise(x/div+1251251, y/div, t));
    rect(0, 0, r2*s, r*s);
    popMatrix();
  }
  t += 0.01f;
}

import java.util.Random;
int[] colorPick() {
  randomSeed(millis());
  Random r = new Random();
  ArrayList<PVector> c = new ArrayList<PVector>();
  colorMode(HSB);
  PVector base = new PVector(random(255), random(255), random(100, 255));
  //c.add(base);
  int count = (int)(2 + abs(4.f*(float)r.nextGaussian()));
  println(count);
  println(base.x + " " + base.y + "' " + base.z);
  for(int i = 0; i < count; i++) {
    c.add(new PVector((float)(r.nextGaussian()*30.f + base.x)%255, (float)(base.y + r.nextGaussian()*30.f), (float)(base.z + r.nextGaussian()*30.f)));
    //if(random(10)>9)
    //  c.add(new PVector((float)(255/2 + base.x)%255, (float)(base.y + r.nextGaussian()*40.f), (float)(base.z + r.nextGaussian()*40.f)));
    c.add(new PVector(random(255), random(255), random(255)));
  }
  int[] z = new int[c.size()];
  for(int i = 0; i < c.size(); i++)
    z[i] = color(clamp(c.get(i).x, 0, 255), clamp(c.get(i).y, 0, 255), clamp(c.get(i).z, 0, 255));
  colorMode(RGB);
  return z;
}

void keyPressed() {
  if(key == 'p' || key == 'P')
    saveFrame(get_time() + "output.png");
  if(key == 'c' || key == 'C') {
    palette = colorPick();
    drawStuff();
  }
}
