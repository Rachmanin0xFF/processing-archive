

/*
Trying to better understand why decoherent light with the same frequency wouldn't just cancel itself out via destructive interference.
I was confused because when you just add a bunch of sine waves with random phases together, their sum stays at around zero.
I think I need to consider the average magnitude of the sum, though, not the sum itself. That's what this program computes.
It does it in 2D to represent adding together a bunch of E field vectors, but component-wise it works out to basically be the same.

Here is the notable empirical relationship:
The square of the "radius" of the blob (what is printed, sort of) is proportional to the square of the number of phasors.
I wonder if I could get an analytic formula for the avg. mag from the # of phasors...

All this is just fancy words for a 2D random walk where you can pick direction

*/

ArrayList<PVector> heads = new ArrayList<PVector>();

PVector[] phasors;
float[] phases;
float[] omegas;

float total = 0;
float sum = 0;
void setup() {
  size(512,512, P2D);
  phasors = new PVector[10000];
  phases = new float[phasors.length];
  omegas = new float[phasors.length];
  for(int i = 0; i < phases.length; i++) {
    phases[i] = random(TWO_PI);
    omegas[i] = 10.0 + random(-5,5);
  }
  heads.add(new PVector(0, 0));
  frameRate(1000);
}
void draw() {
  background(0);
  stroke(255, 20);
  PVector pos = new PVector(0, 0);
  translate(width/2, height/2);
  for(int k = 0; k < 100; k++) {
    float time = millis()/1000.0;
    for(int i = 0; i < phasors.length; i++) {
      phases[i] = random(TWO_PI);
      phasors[i] = new PVector(cos(phases[i] + time*omegas[i]), sin(phases[i] + time*omegas[i]));
    }
    
    pos = new PVector(0, 0);
    
    for(int i = 0; i < phasors.length; i++) {
      //line(pos.x, pos.y, phasors[i].x + pos.x, phasors[i].y + pos.y);
      pos.add(phasors[i]);
    }
    sum += pos.mag();
    total++;
  }
  
  stroke(255, 0, 0, 100);
  heads.add(pos);
  for(int i = 0; i < heads.size()-1; i++) {
    line(heads.get(i).x, heads.get(i).y, heads.get(i+1).x, heads.get(i+1).y);
  }
  
  println(sum / total);
}
