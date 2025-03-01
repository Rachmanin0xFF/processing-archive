MNIST_data my_data; 

void setup() {
  size(512, 512, P2D);
  my_data = new MNIST_data("mnist_train.csv", "mnist_test.csv");
}

void draw() {
  background(0);
  draw_sample(my_data.train[mouseX]);
}


void draw_sample(Sample s) {
  stroke(10);
  for(int x = 0; x < s.data.length; x++) for(int y = 0; y < s.data[0].length; y++) {
    float xc = (x+1) / (float) (s.data.length    + 1);
    float yc = (y+1) / (float) (s.data[0].length + 1);
    xc = map(xc, 0, 1.0, 0, width);
    yc = map(yc, 0, 1.0, 0, height);
    fill(s.data[x][y]*255.0);
    float r = (float) width / (float) (s.data.length + 2);
    ellipse(xc, yc, r, r);
  }
}

//class Gate {
//  float[] hyperplane_direction;
//  float[] 

class Sample {
  float[][] data;
  int label;
  Sample() {
    data = new float[28][28];
  }
}

class MNIST_data {
  Sample[] train;
  Sample[] test;
  MNIST_data(String train_path, String test_path) {
    train = loadCSV(train_path);
    test = loadCSV(test_path);
    println("Loaded " + train.length + " training samples and " + test.length + " test samples.");
  }
  Sample[] loadCSV(String path) {
    String[] s = loadStrings(path);
    Sample[] samps = new Sample[s.length-1];
    for(int i = 1; i < s.length; i++) {
      String[] spl = s[i].split(",");
      samps[i-1] = new Sample();
      samps[i-1].label = int(spl[0]);
      for(int j = 1; j < spl.length; j++) {
        samps[i-1].data[(j-1)%28][(j-1)/28] = float(spl[j])/255.0;
      }
    }
    return samps;
  }
}
