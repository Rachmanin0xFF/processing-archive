/**
 * A class to perform basic operations on arbitrary-length floating-point
 * vectors. Created because PVector can only store 3 components.
 */
public class Vecf {
  /*
   * RANT TIME: Deciding to avoid templates was kind of tricky. There's not really
   * a good solution that doesn't feel bloated in this version of the JDK. I could
   * abstract away numbers, which is a mess, (JScience does this), or convert cast
   * everything and use .getDoubleValue().
   * 
   * The most robust solution would be to come up with a general way of talking
   * about precision that tracks bit depths and all that, but if I'm going that
   * far, I'd rather just use C++ or something.
   * 
   * I'm not using doubles because I don't think anyone really needs 64-bit
   * precision in each color channel, except maybe astronomers. For reference,
   * most "HDR" textures in computer graphics are only 16 bits per color channel.
   * 
   * As for generic arrays vs ArrayLists -- I don't think it really matters. I'm
   * using arrays[] because I like the array operator. We don't need any of List's
   * nice functions for something this low-level :p
   */

  public float[] components;
  
  /**
   * Initalizes a zero vector with <code>dimension</code> components.
   * @param dimension
   */
  public Vecf(int dimension) {
    components = new float[dimension];
  }

  public Vecf(float... args) {
    components = new float[args.length];
    for (int i = 0; i < args.length; i++) {
      components[i] = args[i];
    }
  }

  // Shallow copy
  public Vecf(Vecf v) {
    components = new float[v.dimension()];
    for (int i = 0; i < components.length; i++) {
      components[i] = v.components[i];
    }
  }

  public int dimension() {
    return components.length;
  }

  // ================== INSTANCE METHODS ==================//
  
  public void add(Vecf a) {
    checkDimensions(a, this);
    for (int i = 0; i < components.length; i++) {
      components[i] += a.components[i];
    }
  }

}
// ==================  METHODS ==================//
  // Functions of two vectors
private  void checkDimensions(Vecf a, Vecf b) {
  if (a.dimension() != b.dimension()) {
    throw new IllegalArgumentException(
        "Vectors must have the same length: " + a.dimension() + " vs " + b.dimension());
  }
}

public boolean equals(Vecf a, Vecf b) {
  checkDimensions(a, b);
  for (int i = 0; i < a.components.length; i++) {
    if(a.components[i] != b.components[i]) return false;
  }
  return true;
}

public Vecf add(Vecf a, Vecf b) {
  checkDimensions(a, b);
  Vecf sum = new Vecf(a.components.length);
  for (int i = 0; i < a.components.length; i++) {
    sum.components[i] = a.components[i] + b.components[i];
  }
  return sum;
}

public Vecf sub(Vecf a, Vecf b) {
  checkDimensions(a, b);
  Vecf diff = new Vecf(a.components.length);
  for (int i = 0; i < a.components.length; i++) {
    diff.components[i] = a.components[i] - b.components[i];
  }
  return diff;
}

public Vecf max(Vecf a, Vecf b) {
  checkDimensions(a, b);
  Vecf mx = new Vecf(a.components.length);
  for (int i = 0; i < a.components.length; i++) {
    mx.components[i] = Math.max(a.components[i], b.components[i]);
  }
  return mx;
}

public Vecf min(Vecf a, Vecf b) {
  checkDimensions(a, b);
  Vecf mx = new Vecf(a.components.length);
  for (int i = 0; i < a.components.length; i++) {
    mx.components[i] = Math.min(a.components[i], b.components[i]);
  }
  return mx;
}

public float dot(Vecf a, Vecf b) {
  checkDimensions(a, b);
  float dotproduct = 0.f;
  for (int i = 0; i < a.components.length; i++) {
    dotproduct += a.components[i] * b.components[i];
  }
  return dotproduct;
}

public Vecf multComponents(Vecf a, Vecf b) {
  checkDimensions(a, b);
  Vecf prod = new Vecf(a.components.length);
  for (int i = 0; i < a.components.length; i++) {
    prod.components[i] = a.components[i] * b.components[i];
  }
  return prod;
}

public Vecf divComponents(Vecf a, Vecf b) {
  checkDimensions(a, b);
  Vecf prod = new Vecf(a.components.length);
  for (int i = 0; i < a.components.length; i++) {
    prod.components[i] = a.components[i] / b.components[i];
  }
  return prod;
}

// Functions of one vector
public Vecf onesLike(Vecf a) {
  Vecf ones = new Vecf(a.dimension());
  for (int i = 0; i < a.dimension(); i++) {
    ones.components[i] = 1.f;
  }
  return ones;
}
public Vecf zeroesLike(Vecf a) {
  Vecf zeroes = new Vecf(a.dimension());
  for (int i = 0; i < a.dimension(); i++) {
    zeroes.components[i] = 0.f;
  }
  return zeroes;
}

public Vecf abs(Vecf a) {
  Vecf positives = new Vecf(a.dimension());
  for (int i = 0; i < a.dimension(); i++) {
    positives.components[i] = Math.abs(a.components[i]);
  }
  return positives;
}

public Vecf mult(Vecf a, float scalar) {
  Vecf prod = new Vecf(a.dimension());
  for (int i = 0; i < a.dimension(); i++) {
    prod.components[i] = a.components[i] * scalar;
  }
  return prod;
}

public Vecf round(Vecf a) {
  Vecf rounded = new Vecf(a.dimension());
  for (int i = 0; i < a.dimension(); i++) {
    rounded.components[i] = Math.round(a.components[i]);
  }
  return rounded;
}

public Vecf floor(Vecf a) {
  Vecf floored = new Vecf(a.dimension());
  for (int i = 0; i < a.dimension(); i++) {
    floored.components[i] = (long) Math.floor(a.components[i]);
  }
  return floored;
}

public Vecf ceil(Vecf a) {
  Vecf ceiled = new Vecf(a.dimension());
  for (int i = 0; i < a.dimension(); i++) {
    ceiled.components[i] = (long) Math.ceil(a.components[i]);
  }
  return ceiled;
}

public float magnitudeSquared(Vecf a) {
  float magSquared = 0.f;
  for (int i = 0; i < a.components.length; i++) {
    magSquared += a.components[i] * a.components[i];
  }
  return magSquared;
}

public float magnitude(Vecf a) {
  return (float) Math.sqrt(magnitudeSquared(a));
}
