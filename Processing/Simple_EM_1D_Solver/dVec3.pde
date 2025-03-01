
public class dVec3 {
  double x, y, z;
  dVec3() {
    x = 0;
    y = 0;
    z = 0;
  }
  dVec3(double s) {
    x = s;
    y = s;
    z = s;
  }
  dVec3(double x, double y, double z) {
    this.x = x; this.y = y; this.z = z;
  }
  dVec3(dVec3 v) {
    this.x = v.x; this.y = v.y; this.z = v.z;
  }
  void add(dVec3 v) {
    x += v.x; y += v.y; z += v.z;
  }
  void sub(dVec3 v) {
    x -= v.x; y -= v.y; z -= v.z;
  }
  void mult(double w) {
    x *= w; y *= w; z *= w;
  }
  void div(double w) {
    if(w == 0.0) {
      print("Division by zero detected; setting vector to zero.");
      x = 0.0; y = 0.0; z = 0.0;
      return;
    }
    x /= w; y /= w; z /= w;
  }
  void rotateX(double theta) {
    double ty = cos(theta)*y - sin(theta)*z;
            z = sin(theta)*y + cos(theta)*z;
    y = ty;
  }
  void rotateY(double theta) {
    double tx = cos(theta)*x - sin(theta)*z;
            z = sin(theta)*x + cos(theta)*z;
    x = tx;
  }
  void rotateZ(double theta) {
    double tx = cos(theta)*x - sin(theta)*y;
            y = sin(theta)*x + cos(theta)*y;
    x = tx;
  }
  dVec3 copy() {
    return new dVec3(x, y, z);
  }
  PVector toPVector() {
    return new PVector((float)x, (float)y, (float)z);
  }
  double mag() {
    return sqrt(x*x + y*y + z*z);
  }
  double mag2() {
    return x*x + y*y + z*z;
  }
  double dist(dVec3 a) {
    return sqrt((x-a.x)*(x-a.x) + (y-a.y)*(y-a.y) + (z-a.z)*(z-a.z));
  }
  double dist2(dVec3 a) {
    return (x-a.x)*(x-a.x) + (y-a.y)*(y-a.y) + (z-a.z)*(z-a.z);
  }
  double dot(dVec3 a) {
    return a.x*x + a.y*y + a.z*z;
  }
  double max_component() {
    return x > y && x > z ? x : (y > z ? y : z);
  }
  double min_component() {
    return x < y && x < z ? x : (y < z ? y : z);
  }
  void normalize() {
    double m = mag();
    x /= m;
    y /= m;
    z /= m;
  }
  boolean equals(dVec3 v) {
    return (v.x == x && v.y == y && v.z == z);
  }
}
dVec3 mult(dVec3 a, double b) {
  return new dVec3(a.x*b, a.y*b, a.z*b);
}
dVec3 add(dVec3 a, dVec3 b) {
  return new dVec3(a.x + b.x, a.y + b.y, a.z + b.z);
}
dVec3 sub(dVec3 a, dVec3 b) {
  return new dVec3(a.x - b.x, a.y - b.y, a.z - b.z);
}
dVec3 cross(dVec3 a, dVec3 b) {
  return new dVec3(a.y*b.z - a.z*b.y, a.z*b.x - a.x*b.z, a.x*b.y - a.y*b.x);
}
dVec3 lerp(dVec3 a, dVec3 b, double x) {
  return new dVec3(lerp(a.x, b.x, x), lerp(a.y, b.y, x), lerp(a.z, b.z, x));
}
dVec3 min(dVec3 a, dVec3 b) {
  return new dVec3(a.x<b.x?a.x:b.x, a.y<b.y?a.y:b.y, a.z<b.z?a.z:b.z);
}
dVec3 max(dVec3 a, dVec3 b) {
  return new dVec3(a.x>b.x?a.x:b.x, a.y>b.y?a.y:b.y, a.z>b.z?a.z:b.z);
}
dVec3 square_components(dVec3 a) {
  return new dVec3(a.x*a.x, a.y*a.y, a.z*a.z);
}
dVec3 sqrt_components(dVec3 a) {
  return new dVec3(sqrt(a.x), sqrt(a.y), sqrt(a.z));
}
dVec3 log_components(dVec3 a) {
  return new dVec3(Math.log(a.x), Math.log(a.y), Math.log(a.z));
}
double lerp(double a, double b, double x) {
  return a*(1.0-x) + b*x;
}
double dot(dVec3 a, dVec3 b) {
  return a.dot(b);
}
double mag(dVec3 a) {
  return a.mag();
}
double mag2(dVec3 a) {
  return a.mag2();
}
double dist(dVec3 a, dVec3 b) {
  return a.dist(b);
}
double dist2(dVec3 a, dVec3 b) {
  return a.dist2(b);
}

double sqrt(double x) {
  return Math.sqrt(x);
}
double sin(double x) {
  return Math.sin(x);
}
double cos(double x) {
  return Math.cos(x);
}
double tan(double x) {
  return Math.cos(x);
}
double atan2(double y, double x) {
  return Math.atan2(y, x);
}
