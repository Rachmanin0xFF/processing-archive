class dMat4 {
  double[][] a;
  dMat4() {
    set_identity();
  }
  dMat4(double[][] vals) {
    a = new double[4][4];
    if(vals.length == 4 && vals[0].length == 4) {
      for(int row = 0; row < 4; row++) for(int col = 0; col < 4; col++) {
        a[row][col] = vals[row][col];
      }
    }
  }
  void set_identity() {
    a = new double[4][4];
    a[0][0] = 1.0;
    a[1][1] = 1.0;
    a[2][2] = 1.0;
    a[3][3] = 1.0;
  }
  dVec3 mult(dVec3 x) {
    dVec3 y = new dVec3();
    y.x = x.x*a[0][0] + x.y*a[0][1] + x.z*a[0][2] + a[0][3];
    y.y = x.x*a[1][0] + x.y*a[1][1] + x.z*a[1][2] + a[1][3];
    y.z = x.x*a[2][0] + x.y*a[2][1] + x.z*a[2][2] + a[2][3];
    return y;
  }
  void mult(dMat4 B) {
    dMat4 C = new dMat4();
    for(int row = 0; row < 4; row++) for(int col = 0; col < 4; col++) {
      C.a[row][col] = a[row][0]*B.a[0][col] +
                      a[row][1]*B.a[1][col] +
                      a[row][2]*B.a[2][col] +
                      a[row][3]*B.a[3][col];
    }
    this.a = C.a;
  }
  double mult_get_w(dVec3 x) {
    return x.x*a[3][0] + x.y*a[3][1] + x.z*a[3][2] + a[3][3];
  }
  void translate(double x, double y, double z) {
    dMat4 m = new dMat4();
    m.a[0][3] = x;
    m.a[1][3] = y;
    m.a[2][3] = z;
    mult(m);
  }
  void translate(dVec3 r) {
    dMat4 m = new dMat4();
    m.a[0][3] = r.x;
    m.a[1][3] = r.y;
    m.a[2][3] = r.z;
    mult(m);
  }
  void rotateX(double t) {
    dMat4 m = new dMat4();
    m.a[1][1] = cos(t); m.a[1][2] = -sin(t);
    m.a[2][1] = sin(t); m.a[2][2] = cos(t);
    mult(m);
  }
  void rotateY(double t) {
    dMat4 m = new dMat4();
    m.a[0][0] = cos(t); m.a[0][2] = sin(t);
    m.a[2][0] = -sin(t); m.a[2][2] = cos(t);
    mult(m);
  }
  void rotateZ(double t) {
    dMat4 m = new dMat4();
    m.a[0][0] = cos(t); m.a[0][1] = -sin(t);
    m.a[1][0] = sin(t); m.a[1][1] = cos(t);
    mult(m);
  }
  void scale(double t) {
    dMat4 m = new dMat4();
    m.a[0][0] = t;
    m.a[1][1] = t;
    m.a[2][2] = t;
    mult(m);
  }
}

dMat4 perspective_mat(double near, double far, double fov, double aspect) {
  dMat4 m = new dMat4();
  double tanfov = tan(fov/2.0);
  m.a[0][0] = 1.0/(tanfov*aspect);
  m.a[1][1] = 1.0/(tanfov);
  m.a[2][2] = (near+far)/(far-near);
  m.a[2][3] = (2*far*near)/(near-far);
  m.a[3][2] = 1.0;
  return m;
}

dMat4 mult(dMat4 A, dMat4 B) {
  dMat4 C = new dMat4(A.a);
  C.mult(B);
  return C;
}

dVec3 mult(dMat4 A, dVec3 x) {
  return A.mult(x);
}
