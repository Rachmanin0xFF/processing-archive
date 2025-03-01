
class iMat3 {
  int[][] a;
  int unique_code;
  iMat3() {
    set_identity();
  }
  iMat3(int[][] vals) {
    a = new int[3][3];
    if(vals.length == 3 && vals[0].length == 3) {
      for(int row = 0; row < 3; row++) for(int col = 0; col < 3; col++) {
        a[row][col] = vals[row][col];
      }
    }
  }
  @Override
  public boolean equals(Object obj) {
    return this.hashCode() == ((iMat3)obj).hashCode();
  }
  @Override
  public int hashCode() {
    int w = 0;
    int k = 1;
    for(int row = 0; row < 3; row++) for(int col = 0; col < 3; col++) {
      if(a[row][col] < 0) w += k;
      else if(a[row][col] > 0) w += k*2;
      k *= 3;
    }
    return w;
  }
  void set_identity() {
    a = new int[3][3];
    a[0][0] = 1;
    a[1][1] = 1;
    a[2][2] = 1;
  }
  iVec3 mult(iVec3 x) {
    iVec3 y = new iVec3();
    y.x = x.x*a[0][0] + x.y*a[0][1] + x.z*a[0][2];
    y.y = x.x*a[1][0] + x.y*a[1][1] + x.z*a[1][2];
    y.z = x.x*a[2][0] + x.y*a[2][1] + x.z*a[2][2];
    return y;
  }
  void mult(iMat3 B) {
    iMat3 C = new iMat3();
    for(int row = 0; row < 3; row++) for(int col = 0; col < 3; col++) {
      C.a[row][col] = a[row][0]*B.a[0][col] +
                      a[row][1]*B.a[1][col] +
                      a[row][2]*B.a[2][col];
    }
    this.a = C.a;
  }
  void scale(int t) {
    iMat3 m = new iMat3();
    m.a[0][0] = t;
    m.a[1][1] = t;
    m.a[2][2] = t;
    mult(m);
  }
  void print_nice() {
    println("[");
    println("[ " + a[0][0] + ", " + a[0][1] + ", " + a[0][2] + "],");
    println("[ " + a[1][0] + ", " + a[1][1] + ", " + a[1][2] + "],");
    println("[ " + a[2][0] + ", " + a[2][1] + ", " + a[2][2] + "]");
    println("]");
  }
}


iMat3 mult(iMat3 A, iMat3 B) {
  iMat3 C = new iMat3(A.a);
  C.mult(B);
  return C;
}

iVec3 mult(iMat3 A, iVec3 x) {
  return A.mult(x);
}
