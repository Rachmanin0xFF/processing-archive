//This code is written in Processing (https://processing.org/)
 
//@author Adam Lastowka
//Beware! Beware! I messed with the code to make some of the diagrams, so some of the booleans might not even do anything! Oooooo!
 
import processing.pdf.*;
 
final String SHARP = "\u266F";
final String FLAT = "\u266D";
final float SQRT_2 = 1.41421356237f;
 
int textSize = 9;
float circleSize = 40.f;
float miniCircleSize = 5.f;
float letterSpacing = 50.f;
boolean drawCircles = true;
boolean circleFill = true;
boolean colorFlats = false;
boolean rainbowTones = true;
float alpha = 60;
int startX = -40;
int endX = 40;
int startY = -40;
int endY = 40;
boolean drawEllipses = false;
boolean drawArrows = false;
boolean drawLines = true;
boolean drawCCircle = false;
int offset = 3;
 
void setup() {
  size(4096, 4096);
  //size(1020, 1320, PDF, "out.pdf"); //Uncomment this line for PDF.
  background(255);
  fill(0);
  PFont font = createFont("Arial Unicode MS", textSize);
  //PFont font = createFont("Lucide Sans Unicode", 24);
  textFont(font);
  textAlign(CENTER, CENTER);
  scale(4.f);
  drawZtennon();
  noFill();
  stroke(255, 255);
  strokeWeight(20);
  smooth(8);
}
 
void draw() {}
 
void keyPressed() {
  saveFrame("screenshot.png");
}
 
void drawZtennon() {
  String[] circle_of_fiths_SHARP = {"C", "G", "D", "A", "E", "B", "F"+SHARP, "C"+SHARP, "G"+SHARP, "D"+SHARP, "A"+SHARP, "F"};
  String[] circle_of_fiths_FLAT = {"C", "G", "D", "A", "E", "B", "G"+FLAT, "D"+FLAT, "A"+FLAT, "E"+FLAT, "B"+FLAT, "F"};
  String[] circle_of_fiths_NEUTRAL = {"C", "G", "D", "A", "E", "C"+FLAT+"-B", "G"+FLAT+"-F"+SHARP, "D"+FLAT+"-C"+SHARP, "A"+FLAT, "E"+FLAT, "B"+FLAT, "F"};
  String[] circle_of_fiths_NEUTRAL_EXTENDED = {"C", "G", "D", "A", "E", "C"+FLAT+"-B", "G"+FLAT+"-F"+SHARP, "D"+FLAT+"-C"+SHARP, "A"+FLAT+"-G"+SHARP, "E"+FLAT+"-D"+SHARP, "B"+FLAT+"-A"+SHARP, "F"};
  stroke(0, 45);
  for(float i = letterSpacing/SQRT_2; i < 10000.f; i += letterSpacing*2.f) {
    //line(0, i, i*3.f, 0);
  }
  for(int y = startY; y < endY; y++) {
    for(int x = startX; x < endX; x++) {
      float xCoordinate = x*letterSpacing + y*letterSpacing*4;
      float yCoordinate = x*letterSpacing;
      int index = ((x+y)+12*200+4) + offset;
      String text = circle_of_fiths_NEUTRAL_EXTENDED[index%12];
      if(drawCCircle && text.equals("C")) {
        stroke(0, 120);
        noFill();
        ellipse(xCoordinate, yCoordinate, circleSize*2, circleSize*2);
      }
      noFill();
      if(circleFill) {
        fill(0, alpha); stroke(0, alpha);
        if((text.contains(SHARP) || text.contains(FLAT)) && !text.startsWith("C"+FLAT) && colorFlats)
          fill(0, alpha*2.f);
        if(rainbowTones) {
          colorMode(HSB);
          fill(index%12*19, 90, 255, alpha*5.f);
          colorMode(RGB);
        }
      }
      if(drawCircles)
        ellipse(xCoordinate, yCoordinate, circleSize, circleSize);
      fill(0, 255);
      stroke(0, 255);
      if(circleFill) {fill(0, alpha*2.f); stroke(0, alpha*2.f);}
     
      float BRX = xCoordinate + circleSize/2/SQRT_2; float BRY = yCoordinate + circleSize/2/SQRT_2; float BR2X = xCoordinate - circleSize/2/SQRT_2 + letterSpacing; float BR2Y = yCoordinate - circleSize/2/SQRT_2 + letterSpacing;
      float URX = xCoordinate - circleSize/2/SQRT_2; float URY = yCoordinate + circleSize/2/SQRT_2; float UR2X = xCoordinate + circleSize/2/SQRT_2 - letterSpacing; float UR2Y = yCoordinate - circleSize/2/SQRT_2 + letterSpacing;
      stroke(0, 255);
      if(drawLines) {
        line(BRX, BRY, BR2X, BR2Y);
        line(URX, URY, UR2X, UR2Y);
      }
     
      strokeWeight(0.55f);
      stroke(0, 255);
      fill(0, 255);
      if(drawEllipses) {
        ellipse((BRX*3.f + BR2X)/4.f + miniCircleSize/1.25f/SQRT_2, (BRY*3.f + BR2Y)/4.f - miniCircleSize/1.25f/SQRT_2, miniCircleSize, miniCircleSize);
        ellipse((BRX + BR2X)/2.f + miniCircleSize/1.25f/SQRT_2, (BRY + BR2Y)/2.f - miniCircleSize/1.25f/SQRT_2, miniCircleSize, miniCircleSize);
        ellipse((BRX + BR2X)/2.f - miniCircleSize/1.25f/SQRT_2, (BRY + BR2Y)/2.f + miniCircleSize/1.25f/SQRT_2, miniCircleSize, miniCircleSize);
        ellipse((BRX + BR2X*3.f)/4.f - miniCircleSize/1.25f/SQRT_2, (BRY + BR2Y*3.f)/4.f + miniCircleSize/1.25f/SQRT_2, miniCircleSize, miniCircleSize);
       
        ellipse((URX*3.f + UR2X)/4.f + miniCircleSize/1.25f/SQRT_2, (URY*3.f + UR2Y)/4.f + miniCircleSize/1.25f/SQRT_2, miniCircleSize, miniCircleSize);
        ellipse((URX + UR2X*3.f)/4.f - miniCircleSize/1.25f/SQRT_2, (URY + UR2Y*3.f)/4.f - miniCircleSize/1.25f/SQRT_2, miniCircleSize, miniCircleSize);
       
        noFill();
        ellipse((BRX*3.f + BR2X)/4.f - miniCircleSize/1.25f/SQRT_2, (BRY*3.f + BR2Y)/4.f + miniCircleSize/1.25f/SQRT_2, miniCircleSize, miniCircleSize);
        ellipse((BRX + BR2X*3.f)/4.f + miniCircleSize/1.25f/SQRT_2, (BRY + BR2Y*3.f)/4.f - miniCircleSize/1.25f/SQRT_2, miniCircleSize, miniCircleSize);
       
        ellipse((URX + UR2X)/2.f + miniCircleSize/1.25f/SQRT_2, (URY + UR2Y)/2.f + miniCircleSize/1.25f/SQRT_2, miniCircleSize, miniCircleSize);
        ellipse((URX + UR2X)/2.f - miniCircleSize/1.25f/SQRT_2, (URY + UR2Y)/2.f - miniCircleSize/1.25f/SQRT_2, miniCircleSize, miniCircleSize);
        ellipse((URX + UR2X*3.f)/4.f + miniCircleSize/1.25f/SQRT_2, (URY + UR2Y*3.f)/4.f + miniCircleSize/1.25f/SQRT_2, miniCircleSize, miniCircleSize);
        ellipse((URX*3.f + UR2X)/4.f - miniCircleSize/1.25f/SQRT_2, (URY*3.f + UR2Y)/4.f - miniCircleSize/1.25f/SQRT_2, miniCircleSize, miniCircleSize);
        if(drawArrows) {
          drawArrow((URX*5.f + UR2X)/6.f - miniCircleSize*1.25f, (URY*5.f + UR2Y)/6.f - miniCircleSize*1.25f, (URX + UR2X*5.f)/6.f - miniCircleSize*1.25f, (URY + UR2Y*5.f)/6.f - miniCircleSize*1.25f, 3.f, HALF_PI/1.5f);
          drawArrow((URX + UR2X*5.f)/6.f + miniCircleSize*1.25f, (URY + UR2Y*5.f)/6.f + miniCircleSize*1.25f, (URX*5.f + UR2X)/6.f + miniCircleSize*1.25f, (URY*5.f + UR2Y)/6.f + miniCircleSize*1.25f, 3.f, HALF_PI/1.5f);
          drawArrow((BRX*5.f + BR2X)/6.f + miniCircleSize*1.25f, (BRY*5.f + BR2Y)/6.f - miniCircleSize*1.25f, (BRX + BR2X*5.f)/6.f + miniCircleSize*1.25f, (BRY + BR2Y*5.f)/6.f - miniCircleSize*1.25f, 3.f, HALF_PI/1.5f);
          drawArrow((BRX + BR2X*5.f)/6.f - miniCircleSize*1.25f, (BRY + BR2Y*5.f)/6.f + miniCircleSize*1.25f, (BRX*5.f + BR2X)/6.f - miniCircleSize*1.25f, (BRY*5.f + BR2Y)/6.f + miniCircleSize*1.25f, 3.f, HALF_PI/1.5f);
        }
      }
     
      strokeWeight(1);
     
      fill(0, 255);
      text2(text, xCoordinate, yCoordinate);
    }
  }
 
  for(int y = startY; y < endY; y++) {
    for(int x = startX; x < endX; x++) {
      float xCoordinate = x*letterSpacing + y*letterSpacing*4;
      float yCoordinate = (x-2)*letterSpacing;
      int index = ((x+y)+12*200+6) + offset;
      String text = circle_of_fiths_NEUTRAL_EXTENDED[index%12] + 'm';
      noFill();
      if(circleFill) {
        fill(0, alpha); stroke(0, alpha);
        if((text.contains(SHARP) || text.contains(FLAT)) && !text.startsWith("C"+FLAT) && colorFlats)
          fill(0, alpha*2.f);
        if(rainbowTones) {
          colorMode(HSB);
          fill((index-2)%12*19, 200, 50, alpha*5.f);
          colorMode(RGB);
        }
      }
      if(drawCircles)
        ellipse(xCoordinate, yCoordinate, circleSize, circleSize);
      fill(0, 255);
      stroke(0, 255);
      if(circleFill) {fill(0, alpha*2.f); stroke(0, alpha*2.f);}
      float BRX = xCoordinate + circleSize/2/SQRT_2; float BRY = yCoordinate + circleSize/2/SQRT_2; float BR2X = xCoordinate - circleSize/2/SQRT_2 + letterSpacing; float BR2Y = yCoordinate - circleSize/2/SQRT_2 + letterSpacing;
      float URX = xCoordinate - circleSize/2/SQRT_2; float URY = yCoordinate + circleSize/2/SQRT_2; float UR2X = xCoordinate + circleSize/2/SQRT_2 - letterSpacing; float UR2Y = yCoordinate - circleSize/2/SQRT_2 + letterSpacing;
      stroke(0, 255);
      if(drawLines) {
        line(BRX, BRY, BR2X, BR2Y);
        line(URX, URY, UR2X, UR2Y);
      }
     
      strokeWeight(0.55f);
      stroke(0, 255);
      fill(0, 255);
      if(drawEllipses) {
        ellipse((BRX*3.f + BR2X)/4.f + miniCircleSize/1.25f/SQRT_2, (BRY*3.f + BR2Y)/4.f - miniCircleSize/1.25f/SQRT_2, miniCircleSize, miniCircleSize);
        ellipse((BRX + BR2X)/2.f + miniCircleSize/1.25f/SQRT_2, (BRY + BR2Y)/2.f - miniCircleSize/1.25f/SQRT_2, miniCircleSize, miniCircleSize);
        ellipse((BRX + BR2X)/2.f - miniCircleSize/1.25f/SQRT_2, (BRY + BR2Y)/2.f + miniCircleSize/1.25f/SQRT_2, miniCircleSize, miniCircleSize);
        ellipse((BRX + BR2X*3.f)/4.f - miniCircleSize/1.25f/SQRT_2, (BRY + BR2Y*3.f)/4.f + miniCircleSize/1.25f/SQRT_2, miniCircleSize, miniCircleSize);
       
        ellipse((URX*3.f + UR2X)/4.f + miniCircleSize/1.25f/SQRT_2, (URY*3.f + UR2Y)/4.f + miniCircleSize/1.25f/SQRT_2, miniCircleSize, miniCircleSize);
        ellipse((URX + UR2X*3.f)/4.f - miniCircleSize/1.25f/SQRT_2, (URY + UR2Y*3.f)/4.f - miniCircleSize/1.25f/SQRT_2, miniCircleSize, miniCircleSize);
       
        noFill();
        ellipse((BRX*3.f + BR2X)/4.f - miniCircleSize/1.25f/SQRT_2, (BRY*3.f + BR2Y)/4.f + miniCircleSize/1.25f/SQRT_2, miniCircleSize, miniCircleSize);
        ellipse((BRX + BR2X*3.f)/4.f + miniCircleSize/1.25f/SQRT_2, (BRY + BR2Y*3.f)/4.f - miniCircleSize/1.25f/SQRT_2, miniCircleSize, miniCircleSize);
       
        ellipse((URX + UR2X)/2.f + miniCircleSize/1.25f/SQRT_2, (URY + UR2Y)/2.f + miniCircleSize/1.25f/SQRT_2, miniCircleSize, miniCircleSize);
        ellipse((URX + UR2X)/2.f - miniCircleSize/1.25f/SQRT_2, (URY + UR2Y)/2.f - miniCircleSize/1.25f/SQRT_2, miniCircleSize, miniCircleSize);
        ellipse((URX + UR2X*3.f)/4.f + miniCircleSize/1.25f/SQRT_2, (URY + UR2Y*3.f)/4.f + miniCircleSize/1.25f/SQRT_2, miniCircleSize, miniCircleSize);
        ellipse((URX*3.f + UR2X)/4.f - miniCircleSize/1.25f/SQRT_2, (URY*3.f + UR2Y)/4.f - miniCircleSize/1.25f/SQRT_2, miniCircleSize, miniCircleSize);
        if(drawArrows) {
          drawArrow((URX*5.f + UR2X)/6.f - miniCircleSize*1.25f, (URY*5.f + UR2Y)/6.f - miniCircleSize*1.25f, (URX + UR2X*5.f)/6.f - miniCircleSize*1.25f, (URY + UR2Y*5.f)/6.f - miniCircleSize*1.25f, 3.f, HALF_PI/1.5f);
          drawArrow((URX + UR2X*5.f)/6.f + miniCircleSize*1.25f, (URY + UR2Y*5.f)/6.f + miniCircleSize*1.25f, (URX*5.f + UR2X)/6.f + miniCircleSize*1.25f, (URY*5.f + UR2Y)/6.f + miniCircleSize*1.25f, 3.f, HALF_PI/1.5f);
          drawArrow((BRX*5.f + BR2X)/6.f + miniCircleSize*1.25f, (BRY*5.f + BR2Y)/6.f - miniCircleSize*1.25f, (BRX + BR2X*5.f)/6.f + miniCircleSize*1.25f, (BRY + BR2Y*5.f)/6.f - miniCircleSize*1.25f, 3.f, HALF_PI/1.5f);
          drawArrow((BRX + BR2X*5.f)/6.f - miniCircleSize*1.25f, (BRY + BR2Y*5.f)/6.f + miniCircleSize*1.25f, (BRX*5.f + BR2X)/6.f - miniCircleSize*1.25f, (BRY*5.f + BR2Y)/6.f + miniCircleSize*1.25f, 3.f, HALF_PI/1.5f);
        }
      }
     
      strokeWeight(1);
     
      fill(255, 255);
      text2(text, xCoordinate, yCoordinate);
    }
  }
}
void text2(String s, float x, float y) {
  float xo = -textSize*0.7*(s.length()-1)*0.5;
  for(char c : s.toCharArray()) {
    text(c, x + xo, y);
    xo += textSize*0.7;
  }
}
void drawArrow(float start_x, float start_y, float end_x, float end_y, float barb_length, float barb_theta) {
  line(start_x, start_y, end_x, end_y);
  PVector v = new PVector(start_x - end_x, start_y - end_y);
  v.normalize();
  v.mult(barb_length);
  v.rotate(barb_theta/2.);
  line(end_x, end_y, end_x + v.x, end_y + v.y);
  v.rotate(-barb_theta);
  line(end_x, end_y, end_x + v.x, end_y + v.y);
}