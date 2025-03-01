class Power {
  float chargeRate=100;
  float charge=0;
  int charges=0;
  int maxCharges=0;
  String name;
  color c;
  float hue1=0;
  float hue2=0;
  float fade=50;
  Power(float chargePerSec, int charges, String name, color c) {
    chargeRate=chargePerSec;
    maxCharges=charges;
    this.name=name;
    this.c=c;
  }
  Power(float chargePerSec, int charges, String name,color c, float hue1, float hue2) {
    chargeRate=chargePerSec;
    maxCharges=charges;
    this.name=name;
    this.c=c;
    this.hue1=hue1;
    this.hue2=hue2;
  }
  void draw(int x, int y) {
    tint(255);
    rectMode(CORNER);
    textAlign(CENTER,TOP);
    stroke(c);
    //fill(100+(fade-50), 100, 100+(fade-50), 150);
    noFill();
    fill(124/2, 237/2, 192, fade);
    strokeWeight(2+(fade-50)/20f);
    rect(x, y, 60, 60);
    strokeWeight(1);
    stroke(255);
    if (hue1!=hue2) {
      colorMode(HSB);
      float tcharge=charge;
      if (charges==maxCharges)tcharge=99f;
      for (int i=0; i<tcharge; i++) {
        stroke((hue1+(hue2-hue1)*(i/100f))%256f, 256, 256);
        line(x+5+i/2f, y+30, x+5+i/2f, y+40);
      }
    }
    noFill();
    stroke(c);
    rect(x+5, y+30, 50, 10);
    stroke(255);
    fill(c);
    //fill(124/2, 237/2, 192);
    textSize(18);
    text(name, x+30, y);
    textSize(16);
    if (maxCharges>4) {
      text(charges, x+5, y+55);
    } else {
      for (int i=0; i<maxCharges; i++) {
        if (i<charges) {
          fill(c);
        } else noFill();
        stroke(c);
        ellipse(x+10+i*12,y+50,10,10);
        
      }
    }
    colorMode(RGB);
  }
  void draw2(int x, int y) {
    tint(255);
    rectMode(CORNER);
    textAlign(TOP,CENTER);
    stroke(c, fade);
    fill(100+(fade-50), 100, 100+(fade-50), 150);
    strokeWeight(2+(fade-50)/60f);
    rect(x, y, 60, 60, 8);
    strokeWeight(1);
    stroke(255);
    if (hue1!=hue2) {
      colorMode(HSB);
      float tcharge=charge;
      if (charges==maxCharges)tcharge=99f;
      for (int i=0; i<tcharge; i++) {
        stroke((hue1+(hue2-hue1)*(i/100f))%256f, 256, 256);
        line(x+5+i/2f, y+30, x+5+i/2f, y+40);
      }
    }
    noFill();
    stroke(c);
    rect(x+5, y+30, 50, 10);
    stroke(255);
    fill(c);
    textSize(24);
    text(name, x+5, y+25);
    textSize(16);
    if (maxCharges>4) {
      text(charges, x+5, y+55);
    } else {
      for (int i=0; i<maxCharges; i++) {
        if (i<charges) {
          fill(c);
        } else noFill();
        stroke(c);
        ellipse(x+10+i*12,y+50,10,10);
        
      }
    }
    colorMode(RGB);
  }
  void update() {
    fade=max(50, fade-20);
    if (charges<maxCharges) {
      charge+=chargeRate;
      if (charge>100) {
        charge-=100;
        charges++;
      }
    }
  }

  boolean use() {
    if (charges>0) {
      charges--;
      fade=255;
      return true;
    } else return false;
  }
  void add(){
    charges=min(maxCharges,charges+1);
  }
  void full(){
    charges=maxCharges;
  }
}