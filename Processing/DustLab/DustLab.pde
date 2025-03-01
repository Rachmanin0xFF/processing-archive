
// TODO: COLOR SPACES!!! AND HISTO EQ!!! (also maybe HDR export? or at least data export not in 8-bit .png)
// also dither (probably would almost never need)

Dustbin binny;
void setup() {
  size(500, 500, P2D);
  noSmooth();
  binny = new Dustbin();
  noiseDetail(1, 0.5);
}

void draw() {
  background(0);
  binny.update();
  imageMode(CENTER);
  float m1 = (float)width/(float)binny.screen.width;
  float m2 = (float)height/(float)binny.screen.height;
  float m = min(m1, m2);
  image(binny.screen, width/2, height/2, m*binny.screen.width, m*binny.screen.height);
  if(binny.previewing) {
    stroke(255, 100);
    line(0, height/3.0, width, height/3.0);
    line(0, (height*2.0)/3.0, width, (height*2.0)/3.0);
    line(width/3.0, 0, width/3.0, height);
    line((width*2.0)/3.0, 0, (width*2.0)/3.0, height);
  } else {
    binny.draw_histo(0, height/5.0*4.0, width/2, height/5.0, 200);
  }
  
  //fill(0);
  //rect(0, 0, 100, 20);
  fill(255);
  text("FPS: " + nf(frameRate, 0, 2) + "\n" +
       nf(1000.f/frameRate, 0, 2) + "ms/frame\n" +
       "Photons: " + binny.film.count
       , 3, 15);
}
