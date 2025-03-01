import peasy.*;
PeasyCam cam;

int arr_vals = 500;
double dt = 0.00001;
double dx = 0.01;

double mu_zero = 1.0;
double epsilon_zero = 1.0;

dVec3[] E = new dVec3[arr_vals];
dVec3[] B = new dVec3[arr_vals];

void setup() {
  size(1280, 720, P3D);
  cam = new PeasyCam(this, 100);
  cam.setMinimumDistance(50);
  cam.setMaximumDistance(3000);
  for(int i = 0; i < arr_vals; i++) {
    float mlt = 50.0*exp(-pow((i-arr_vals/2.0)/30.0, 2.0));
    E[i] = new dVec3(0, sin(i*dx*20.0)*mlt + 0.5*cos(i*dx*20.0)*mlt, cos(i*dx*20.0)*mlt + 0.5*sin(i*dx*20.0)*mlt);
    B[i] = new dVec3(0, -cos(i*dx*20.0)*mlt - 0.5*sin(i*dx*20.0)*mlt, sin(i*dx*20.0)*mlt + 0.5*cos(i*dx*20.0)*mlt);
  }
}

void draw() {
  background(0);
  for(int i = 0; i < 1000; i++) {
  updateEB();
  }
  drawEB();
  stroke(255, 0, 0);
  line(0, 0, 0, 100, 0, 0);
  stroke(0, 255, 0);
  line(0, 0, 0, 0, 100, 0);
  stroke(0, 0, 255);
  line(0, 0, 0, 0, 0, 100);
}

void drawEB() {
  stroke(255, 230, 30);
  for(int i = 0; i < arr_vals; i++) {
    line(i-arr_vals/2, 0, 0, i-arr_vals/2, (float)E[i].y, (float)E[i].z);
  }
  stroke(60, 100, 255);
  for(int i = 0; i < arr_vals; i++) {
    line(i-arr_vals/2, 0, 0, i-arr_vals/2, (float)B[i].y, (float)B[i].z);
  }
}

void updateEB() {
  dVec3[] E_temp = new dVec3[E.length];
  dVec3[] B_temp = new dVec3[B.length];
  for(int i = 1; i < arr_vals-1; i++) {
    dVec3 dEdx = mult(sub(E[i+1], E[i]), 1.0/dx);
    dVec3 dBdx = mult(sub(B[i], B[i-1]), 1.0/dx);
    
    E_temp[i] = add(E[i], mult(new dVec3(0.0, dBdx.z, -dBdx.y), dt*mu_zero*epsilon_zero));
    B_temp[i] = add(B[i], mult(new dVec3(0.0, -dEdx.z, dEdx.y), dt));
  }
  for(int i = 1; i < arr_vals-1; i++) {
    E[i] = E_temp[i];
    B[i] = B_temp[i];
  }
}
