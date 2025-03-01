
float R = 1.5;
float C = 1;
float L = 1;
int n = 100;
float g = 10;

float[] values = new float[10000];
float[] values2 = new float[10000];

void setup() {
  size(512, 512, P2D);
  background(0);
}


float r_z = -1;
float v_z = 0;
float dt = 0.001;
float tt = 0.0;
float zm = 40.0;

int ii = 0;

float sgn(float w) {
  return w < 0.0 ? -1.0 : 1.0;
}
void draw() {
  background(0);
  float I = 0.0;
  for(int i = 0; i < 100; i++) {
    float target = -sgn(sin(tt)) - 2.4;
    if(r_z < target) I = 5.0 - v_z*0.2; else I = -0.4 - v_z*0.4;
    v_z += get_acc(r_z, I) * dt;
    r_z += v_z * dt;
    tt += dt;
    
    store_val(r_z);
    store_val2(target);
  }
  
  
  for(int i = 0; i < values.length-1; i++) {
    float xp = map(i, 0, values.length, 0, width);
    float xp2 = map(i+1, 0, values.length, 0, width);
    float yp = -zm * values[i];
    stroke(150);
    point(xp, yp);
    stroke(170, 80, 30);
    float yp2 = -zm * values2[i];
    float yp3 = -zm * values2[i+1];
    if(i != ii)
    line(xp, yp2, xp2, yp3);
  }
  rectMode(CENTER);
  noStroke();
  fill(255, 90, 90);
  rect(width/2, height/2 - 0.5*L*zm, 2.0*R*zm, L*zm);
  fill(90, 140, 255);
  rect(width/2, height/2 - 0.25*L*zm, 2.0*R*zm, 0.5*L*zm);
  fill(255);
  ellipse(width/2, height/2 - zm*r_z, 10, 10);
}

void store_val(float x) {
  values[ii] = x;
  ii++;
  ii = ii%values.length;
}

void store_val2(float x) {
  values2[ii] = x;
}

float get_acc(float z, float I) {
  return C * I * n * ( (z + L)/sqrt(R*R + (z + L)*(z + L)) - z / sqrt(R*R + z*z)) - g;
}
