int x=0;
int y=0;
void setup(){
  size(1010,1010);
  background(0);
  noSmooth();
  frameRate(20);
  fill(255);
  stroke(255);
}
void draw(){
  println(frameRate);
  for(int rs=0;rs<10000;rs++){
    point(x,y);
    if(random(100)<33){
      x=x/2;
      y=y/2;
    } else {
      if(random(100)<33){
        x=(2000-x)/2;
        y=y/2;
        
      } else {
        x=x/2;
        y=(2000-y)/2;
      }
    }
  }
}

void keyPressed(){
  saveFrame();
}
