
DeepNetwork skynet;
ArrayList<Vector> answers = new ArrayList<Vector>();

void setup() {
  size(896, 448, P2D);
  background(0);
  stroke(120, 180, 255);
  frameRate(600);
  loadData();
  
  skynet = new DeepNetwork(new int[]{784, 30, 10});
}

void mousePressed() {
  if(mouseButton==RIGHT)
    evolve();
}

PImage[] dispimgs = new PImage[32];
void draw() {
  background(0);
  
  if(frameCount==1) {
    //evolve();
  }
  for(int i = 0; i < 32; i++) {
    image(dispimgs[i], 28*i, 0);
  }
  int index = max(0, mouseX/28);
  Vector vp = skynet.transform(loadSample(index));
  for(int i = 0; i < 10; i++) {
    fill(255, 255);
    text(i + "", 15 + i*20, height-10);
    noFill();
    rect(11 + i*20, height-30, 18, -vp.v[i]*100);
  }
  fill(255, 255);
  textSize(48);
  text(o2n(vp), 240, 448-100);
  textSize(12);
  Vector samp = loadSample(index);
  int xc = 10;
  int yc = 30;
  strokeWeight(8);
  for(int i = 0; i < samp.v.length; i++) {
    stroke(255.f, samp.v[i]*255.f);
    point(xc, yc);
    xc+=8.f;
    if(i%28==0) {
      yc+=8.f;
      xc = 0;
    }
  }
  strokeWeight(8);
  xc = 0;
  yc = 0;
  for(int i = 0; i < samp.v.length; i++) {
    float val = skynet.wgradview[1].v[mouseY/20].v[i]*255;
    if(val > 0.f)
    stroke(val, val*0.6f, val*0.3f, 255);
    else
    stroke(-val*0.3f, -val*0.6f, -val, 255);
    point(xc*8+290, yc*8+40);
    xc++;
    if(xc==28) {
      yc++;
      xc = 0;
    }
  }
  for(int x = 0; x < skynet.w[2].v.length; x++) {
    for(int y = 0; y < skynet.w[2].v[0].v.length; y++) {
      stroke(skynet.wgradview[2].v[x].v[y]*255, 255);
      point(x*8+690, y*8+40);
    }
  }
  strokeWeight(1);
  stroke(120, 180, 255);
  fill(255, 100);
  rect(index*28, 0, 27, 27);
  fill(255, 255);
}

void calcAccuracy() {
  float samples = 10000.f;
  float sum = 0.f;
  for(int i = 0; i < samples; i++) {
    Vector guess = skynet.transform(loadSample(i));
    Vector truth = answers.get(i);
    if(o2n(guess)==o2n(truth)) sum++;
  }
  sum /= samples;
  println("Accuracy: " + sum*100.f + "%");
}

void evolve() {
  int epochs = 1;
  int batchSize = 30;
  for(int i = 0; i < epochs; i++) {
    println("Batch " + i + " " + ((float)i/100.f));
    for(int j = 0; j < batchSize; j++) {
      int index = (int)random(60000);
      skynet.calcError(loadSample(index), answers.get(index));
    }
    skynet.learn();
  }
  //calcAccuracy();
}

String getPath(int i) {
  return dataPath("") + "\\MNIST Database\\train-data\\" + i + ".bmp";
}
import java.io.FileReader;
void loadData() {
  //Load images for display
  for(int i = 0; i < dispimgs.length; i++) {
    dispimgs[i] = loadImage(getPath(i));
  } 
  //Load answers
  try {
    BufferedReader br = new BufferedReader(new FileReader(new File(dataPath("") + "\\MNIST Database\\inputData-mnist.txt")));
    String cline;
    while((cline = br.readLine()) != null) {
      String[] s = cline.split(" ");
      answers.add(new Vector(max(toFloatArray(s, 1), 0.f)));
    }
    br.close();
  } catch(IOException ioe) {}
}
float[] max(float[] data, float x) {
  float[] stuf = new float[data.length];
  for(int i = 0; i < data.length; i++) {
    stuf[i] = max(x, data[i]);
  }
  return stuf;
}

//Output to (2) number
int o2n(Vector a) {
  int b = 0;
  float max = -10000.f;
  for(int i = 0; i < a.v.length; i++) {
    if(a.v[i] > max) {
      max = a.v[i];
      b = i;
    }
  }
  return b;
}
Vector loadSample(int index) {
  PImage p = loadImage(getPath(index));
  float[] b = new float[p.pixels.length];
  for(int i = 0; i < p.pixels.length; i++) {
    b[i] = (float)(r(p.pixels[i])+g(p.pixels[i])+b(p.pixels[i]))/765.f;
  }
  g.removeCache(p);
  return new Vector(b);
}