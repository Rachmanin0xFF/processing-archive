class DeepNetwork {
  int layers = -1;
  Matrix[] w;
  Vector[] a;
  Vector[] b;
  Vector[] z;
  Vector[] delta;
  Vector[] bgrad;
  Matrix[] wgrad;
  
  Matrix[] wgradview; //Unused in math, used for display purposes
  float m = 0.f; //Batch index (used for averaging)
  float lr = 3.f; //Learning rate
  
  DeepNetwork(int[] layerSizes) {
    layers = layerSizes.length;
    
    //Deterministic
    a = new Vector[layers];
    z = new Vector[layers];
    
    //Variable
    b = new Vector[layers];
    w = new Matrix[layers];
    
    //Feedback
    delta = new Vector[layers];
    bgrad = new Vector[layers];
    wgrad = new Matrix[layers];
    wgradview = new Matrix[layers];
    
    for(int l = 0; l < layers; l++) {
      a[l] = new Vector(layerSizes[l]);
      z[l] = new Vector(layerSizes[l]); //Move down to if later possibly
      
      if(l > 0) {
        b[l] = new Vector(layerSizes[l]);
        w[l] = new Matrix(layerSizes[l], layerSizes[l-1]);
        for(int r=0;r<w[l].v.length;r++)for(int c=0;c<w[l].v[0].v.length;c++)w[l].v[r].v[c]=random(-1, 1);
        for(int r=0;r<b[l].v.length;r++)b[l].v[r]=random(-1, 1);
        
        delta[l] = new Vector(layerSizes[l]);
        bgrad[l] = new Vector(layerSizes[l]);
        wgrad[l] = new Matrix(layerSizes[l], layerSizes[l-1]);
        wgradview[l] = new Matrix(layerSizes[l], layerSizes[l-1]);
      }
    }
  }
  Vector transform(Vector input) {
    a[0] = cp(input);
    forwardPass();
    return a[layers-1];
  }
  void forwardPass() {
     for(int l = 1; l < layers; l++) {
       z[l] = add(mult(w[l], a[l-1]), b[l]);
       a[l] = sigmoid(z[l]);
       //if(l==layers-1) a[l] = z[l];
     }
  }
  //x - Input sample
  //y - Output sample
  void calcError(Vector x, Vector y) {
    a[0] = cp(x);
    forwardPass();
    delta[layers-1] = hadamard(sub(a[a.length-1], y), sigmoid_prime(z[layers-1]));
    for(int l = layers-2; l >= 0; l--) {
      float factor = delta[l+1].v.length;
      if(l == layers-2) factor = 1.f;
      delta[l] = mult(hadamard(mult(transpose(w[l+1]), delta[l+1]), sigmoid_prime(z[l])), factor);
    }
    for(int l = 1; l < layers; l++) {
      bgrad[l] = add(bgrad[l], delta[l]);
      wgrad[l] = add(wgrad[l], mult(v2m(delta[l], false), v2m(a[l-1], true)));
    }
    m++;
  }
  
  void learn() {
    for(int l = 1; l < layers; l++) {
      b[l] = add(b[l], mult(bgrad[l], -lr/m));
      w[l] = add(w[l], mult(wgrad[l], -lr/m));
      wgradview[l] = mult(w[l], 1.f);
      bgrad[l] = mult(bgrad[l], 0.f);
      wgrad[l] = mult(wgrad[l], 0.f);
    }
    m = 0.f;
  }
}