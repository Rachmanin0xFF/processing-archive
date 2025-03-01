  //This work is licensed under a Creative Commons Attribution-NonCommercial 4.0 International License.
//Anthony Catalano-Johnson//
//careful on runing out of box//
//read all comments before runing//
import processing.pdf.*;  //imports tools for making pdf
//pre window setup//
//would not play with any settings in this block//
//most comments here will only make sence later//
ArrayList<PVector> past = new ArrayList<PVector>();  //logs all circle cords
boolean art = true;  //play pause toggle
boolean closer = false;  //for checking if a circle is to colse to any other circle
int save = 0;  //frame count
//int n = 0;  //color one
//int n2 = 0;  //color two
float sShift = random(-1, 1);  //size shift
float mShift = random(-1.5, 1.5);  //cord shift
//float x = 0;  //x position
//float y = 0;  //y position
//end setup//

PVector[] coler = { //list of colors//
  //colors use rgb 0-225 scale changing values changes the color//
  //if you want diffrent colors you can change them here//
  new PVector(176, 225, 118), 
  new PVector(177, 178, 183), 
  new PVector(225, 241, 202), 
  new PVector(133, 167, 168), 
  new PVector(113, 144, 191), 
  new PVector(184, 164, 127), 
  new PVector(139, 177, 154), 
  new PVector(57 , 94 , 164)
};
int f = coler.length;  //finds length of color array

void setup() { //sets up the window
  size(2560, 1600, P2D);  //window size
  strokeWeight(1f);  //with of lines
  smooth(8);  //smooth
  background(57, 94, 164);  //sets the background color
  frameRate(100000);  //sets frame rate
  beginRecord(PDF, "thing.pdf");  //starts to log window for pdf
}
void draw() {  //draw loop
  closer = false;
  save = 1 + save;  //adds one to the frame count
  float x = random(0, width);  //makes a random x value from 0-width of window
  float y = random(0, height);  //makes a random y value from 0-width of window
  for (PVector p : past) {  //loop for closeness check  
    if (dist(p.x, p.y, x, y) < 75) {
      closer = true;  //sets closer to true(if true it does not draw circle)
    }
  }
  if (closer == false) {  //if false draws circle 
    past.add(new PVector(x, y));  //logs x and y 
    int n = floor(random(0, f));  //picks outer color
    int n2 = floor(random(0, f));  //picks iner color
    while (n==n2) {  //loop for color repick is colors are the same
      n2 = floor(random(0, f));  //picks new iner color
    }
    VFill(n);  //colors outer circle
    ellipse(x, y, 150 + sShift, 150 + sShift);  //draws outer circle
    VFill(n2);  //colors iner circle
    ellipse(x + mShift, y + mShift, 75 + sShift, 75 + sShift);  //draws iner circle
   // if (save%100 == 0) {  //saves only some frames
   //   saveFrame();  //save frame command
   // }
  }
  frame.setTitle(random(4) + " " + str(int(frameRate)));  //sets window title to the frame rate
}
void keyPressed() {  //checks keys that are  
  if(key=='a') {
    if (art) noLoop();  //play and puases draw loop wh
    else loop();
    art = !art;  //toggles true, false
  } else if(key=='p') {
    endRecord();
    saveFrame("thing.png");
  }
}

void VFill(int i) {  
  PVector v = coler[i];  //sets 'v' to a color in position 'i' in the color array
  fill(v.x, v.y, v.z);  //breaks PVector 'v' to an array of floats to color circles 
}

