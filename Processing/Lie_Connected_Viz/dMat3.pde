class dMat3 {
  double[][] a;
  dMat3() {
    set_identity();
  }
  dMat3(double[][] vals) {
    a = new double[3][3];
    if(vals.length == 3 && vals[0].length == 3) {
      for(int row = 0; row < 3; row++) for(int col = 0; col < 3; col++) {
        a[row][col] = vals[row][col];
      }
    }
  }
  void set_identity() {
    a = new double[3][3];
    a[0][0] = 1.0;
    a[1][1] = 1.0;
    a[2][2] = 1.0;
  }
  dVec3 mult(dVec3 x) {
    dVec3 y = new dVec3();
    y.x = x.x*a[0][0] + x.y*a[0][1] + x.z*a[0][2];
    y.y = x.x*a[1][0] + x.y*a[1][1] + x.z*a[1][2];
    y.z = x.x*a[2][0] + x.y*a[2][1] + x.z*a[2][2];
    return y;
  }
  void mult(dMat3 B) {
    dMat3 C = new dMat3();
    for(int row = 0; row < 3; row++) for(int col = 0; col < 3; col++) {
      C.a[row][col] = a[row][0]*B.a[0][col] +
                      a[row][1]*B.a[1][col] +
                      a[row][2]*B.a[2][col];
    }
    this.a = C.a;
  }
  void rotateX(double t) {
    dMat3 m = new dMat3();
    m.a[1][1] = cos(t); m.a[1][2] = -sin(t);
    m.a[2][1] = sin(t); m.a[2][2] = cos(t);
    mult(m);
  }
  void rotateY(double t) {
    dMat3 m = new dMat3();
    m.a[0][0] = cos(t); m.a[0][2] = sin(t);
    m.a[2][0] = -sin(t); m.a[2][2] = cos(t);
    mult(m);
  }
  void rotateZ(double t) {
    dMat3 m = new dMat3();
    m.a[0][0] = cos(t); m.a[0][1] = -sin(t);
    m.a[1][0] = sin(t); m.a[1][1] = cos(t);
    mult(m);
  }
  void scale(double t) {
    dMat3 m = new dMat3();
    m.a[0][0] = t;
    m.a[1][1] = t;
    m.a[2][2] = t;
    mult(m);
  }
}

// Explicit inverse formula for 3x3 matrices
dMat3 inverse(dMat3 A) {
  double a = A.a[0][0]; double b = A.a[0][1]; double c = A.a[0][2];
  double d = A.a[1][0]; double e = A.a[1][1]; double f = A.a[1][2];
  double g = A.a[2][0]; double h = A.a[2][1]; double i = A.a[2][2];
  dMat3 m = new dMat3();
  m.a[0][0] = e*i - f*h; m.a[0][1] = c*h - b*i; m.a[0][2] = b*f - c*e;
  m.a[1][0] = f*g - d*i; m.a[1][1] = a*i - c*g; m.a[1][2] = c*d - a*f;
  m.a[2][0] = d*h - e*g; m.a[2][1] = b*g - a*h; m.a[2][2] = a*c - b*d;
  m.scale(1.0 / (a*e*i - a*f*h - b*d*i + b*f*g + c*d*h - c*e*g));
  return m;
}

dMat3 mult(dMat3 A, dMat3 B) {
  dMat3 C = new dMat3(A.a);
  C.mult(B);
  return C;
}

dVec3 mult(dMat3 A, dVec3 x) {
  return A.mult(x);
}
