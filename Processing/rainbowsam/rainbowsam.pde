t X;
int Y;

int hue;

void setup(){
  size(500,500);
  colorMode(HSB);
}

void draw(){
  if(mousePressed){
    line(pmouseX,pmouseY,mouseX,mouseY);
    hue++;
  }
  if(hue > 255)
    hue = 0;
  if(keyPressed){
    background(255);
  }
  stroke(random(0,255),random(0,255)random(0,255));
}
