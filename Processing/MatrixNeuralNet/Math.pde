public float sigmoid(float x) {
  return 1/(1+exp(-x));
}

Vector sigmoid(Vector a) {
  Vector b = new Vector(a.v.length);
  for(int i = 0; i < a.v.length; i++) {
    b.v[i] = sigmoid(a.v[i]);
  }
  return b;
}

public float sigmoid_prime(float x) {
  return sigmoid(x)*(1 - sigmoid(x));
}

Vector sigmoid_prime(Vector a) {
  Vector b = new Vector(a.v.length);
  for(int i = 0; i < a.v.length; i++) {
    b.v[i] = sigmoid_prime(a.v[i]);
  }
  return b;
}

class Vector {
  float[] v;
  public Vector(int len) {
    v = new float[len];
  }
  public Vector(float... elems) {
    v = new float[elems.length];
    for(int i = 0; i < elems.length; i++) {
      v[i] = elems[i];
    }
  }
  public void print_info() {
    print("[ ");
    for(float a : v) {
      print(a + " ");
    }
    print("]\n");
  }
  public String get_info() {
    String s = "[ ";
    for(float a : v) {
      s += a + " ";
    }
    s += "]";
    return s;
  }
}

class Matrix {
  Vector[] v;
  public Matrix(int rows, int columns) {
    v = new Vector[rows];
    for(int i = 0; i < v.length; i++) {
      v[i] = new Vector(columns);
    }
  }
  public Matrix(Vector... elems) {
    v = new Vector[elems.length];
    for(int i = 0; i < elems.length; i++) {
      v[i] = cp(elems[i]);
    }
  }
  public void print_info() {
    println("[");
    for(Vector a : v) {
      a.print_info();
    }
    println("]");
  }
}

//Vector to (2) matrix
Matrix v2m(Vector a, boolean transpose) {
  if(transpose) {
    return new Matrix(a);
  }
  Matrix m = new Matrix(a.v.length, 1);
  for(int i = 0; i < a.v.length; i++) {
    m.v[i].v[0] = a.v[i];
  }
  return m;
}

Vector cp(Vector a) {
  Vector b = new Vector(a.v.length);
  for(int i = 0; i < a.v.length; i++) {
    b.v[i] = a.v[i];
  }
  return b;
}

Matrix cp(Matrix a) {
  Matrix b = new Matrix(a.v.length, a.v[0].v.length);
  for(int i = 0; i < a.v.length; i++) {
    b.v[i] = cp(a.v[i]);
  }
  return b;
}

Vector neg(Vector a) {
  Vector b = new Vector(a.v.length);
  for(int i = 0; i < a.v.length; i++) {
    b.v[i] = -a.v[i];
  }
  return b;
}

Matrix neg(Matrix a) {
  Matrix b = new Matrix(a.v.length, a.v[0].v.length);
  for(int i = 0; i < a.v.length; i++) {
    b.v[i] = neg(a.v[i]);
  }
  return b;
}

float dot(Vector a, Vector b) {
  float sum = 0.f;
  for(int i = 0; i < a.v.length; i++) {
    sum += a.v[i]*b.v[i];
  }
  return sum;
}

Vector add(Vector a, Vector b) {
  Vector c = new Vector(a.v.length);
  for(int i = 0; i < a.v.length; i++) {
    c.v[i] = a.v[i] + b.v[i];
  }
  return c;
}

Matrix add(Matrix a, Matrix b) {
  Matrix c = new Matrix(a.v.length, a.v[0].v.length);
  for(int i = 0; i < a.v.length; i++) {
    c.v[i] = add(a.v[i], b.v[i]);
  }
  return c;
}

Vector sub(Vector a, Vector b) {
  Vector c = new Vector(a.v.length);
  for(int i = 0; i < a.v.length; i++) {
    c.v[i] = a.v[i] - b.v[i];
  }
  return c;
}

Matrix sub(Matrix a, Matrix b) {
  Matrix c = new Matrix(a.v.length, a.v[0].v.length);
  for(int i = 0; i < a.v.length; i++) {
    c.v[i] = sub(a.v[i], b.v[i]);
  }
  return c;
}

Vector mult(Vector a, float b) {
  Vector c = new Vector(a.v.length);
  for(int i = 0; i < a.v.length; i++) {
    c.v[i] = a.v[i]*b;
  }
  return c;
}

Matrix mult(Matrix a, float b) {
  Matrix c = new Matrix(a.v.length, a.v[0].v.length);
  for(int i = 0; i < a.v.length; i++) {
    c.v[i] = mult(a.v[i], b);
  }
  return c;
}

Vector hadamard(Vector a, Vector b) {
  Vector c = new Vector(a.v.length);
  for(int i = 0; i < a.v.length; i++) {
    c.v[i] = a.v[i]*b.v[i];
  }
  return c;
}

Matrix hadamard(Matrix a, Matrix b) {
  Matrix c = new Matrix(a.v.length, a.v[0].v.length);
  for(int i = 0; i < a.v.length; i++) {
    c.v[i] = hadamard(a.v[i], b.v[i]);
  }
  return c;
}

Vector mult(Matrix a, Vector b) {
  Vector c = new Vector(a.v.length);
  for(int i = 0; i < a.v.length; i++) {
    c.v[i] = dot(a.v[i], b);
  }
  return c;
}

Matrix transpose(Matrix a) {
  Matrix b = new Matrix(a.v[0].v.length, a.v.length);
  for(int r = 0; r < a.v.length; r++) {
    for(int c = 0; c < a.v[0].v.length; c++) {
      b.v[c].v[r] = a.v[r].v[c];
    }
  }
  return b;
}

//Could be optimized (see https://en.wikipedia.org/wiki/Matrix_multiplication_algorithm)
Matrix mult(Matrix a, Matrix b) {
  Matrix c = new Matrix(a.v.length, b.v[0].v.length);
  Matrix bt = transpose(b);
  for(int r = 0; r < a.v.length; r++) {
    c.v[r] = mult(bt, a.v[r]);
  }
  return c;
}