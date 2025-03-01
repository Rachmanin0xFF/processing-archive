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
  void draw(int x, int y) {
    stroke(255, 255, 0, fade);
    fill((fade-50), 0, (fade-50), 150);
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
    fill(255);
    textSize(32);
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
}