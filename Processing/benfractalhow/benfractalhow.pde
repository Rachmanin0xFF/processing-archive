
boolean zing = false;
int xref = 0;
int yref = 0;
int e;
int ev = 0;
float pix;
float xre,yre;
float zoom = 1f;
float p = 2;
float step = 0;
float steps = 200;
color black = color(0, 255);
float LOG_2 = 0.69314718056f;

void setup(){
  size(550,350,P2D);
  background(127);
  frameRate(600);
  background(255);
}

void draw(){
  fill(255, 60);
  rect(0, 0, width, height);
  background(255);
  println(frameRate);
  e += ev;
  if(zing)
    step = (step - 1)%steps;
  else
    step = (e/10.0)%steps;
  zoom = pow(p, (step/steps));
  
  for(xref = 0; xref < width; xref++){
    for(yref = 0; yref < height; yref++){
      xre = abs((xref - width/2)*zoom);
      yre = abs((yref - height/2)*zoom);
      pix = int(xre/exp(0.5+LOG_2*int(logP(yre))))%p;
      //pix = int(xre/int(yre))%p;
      if(pix == 0)
        set(xref, yref, black);
      //set(xref, yref, color(pix*(255/(p - 1))));
    }
  }
  //saveFrame("frame"+str(int(step))+".png");
}

void keyPressed(){
  if(key == ' '){
    zing = !zing;
  }
}
void mouseWheel(MouseEvent event) {
  ev += event.getCount()*20;
}

float logP (float x) {
  return (log(x) / log(p));
}