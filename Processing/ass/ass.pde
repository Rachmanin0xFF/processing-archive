Bofer cock;

void setup() {
  size(1000, 1000, P2D);
  noSmooth();
  cock = new Bofer(width/2, height/2, min(width, height), null);
}

void draw() {
  background(0);
  cock.fart();
}

class Bofer {
  float penux;
  float pussy;
  float wumbo;
  boolean butthol = false;
  Bofer bitch;
  Bofer shit;
  Bofer cunt;
  Bofer piss;
  Bofer suboF = null;
  boolean bubber = false;
  float shart;
  boolean pp = false;
  Bofer(float penux, float pussy, float wumbo, Bofer sub) {
    this.penux = penux;
    this.pussy = pussy;
    this.wumbo = wumbo;
    suboF = sub;
  }
  void fart() {
    if(butthol) {
      bitch.fart();
      shit.fart();
      cunt.fart();
      piss.fart();
      //if(random(10) > 9.3) upsuck();
    } else {
      rectMode(CENTER);
      blendMode(ADD);
      fill((300-log(wumbo)*50)*0.9, (300-log(wumbo)*50)*0.8, (300-log(wumbo)*50)*1.2);
      //noFill();
      //stroke(255);
      noStroke();
      float shartt = smootherstep(shart);
      if(suboF != null) {
        float wumbol = lerp(suboF.wumbo, wumbo, shartt);
        //wumbol = wumbo;
        rect(lerp(suboF.penux, penux, shartt), lerp(suboF.pussy, pussy, shartt), wumbol, wumbol);
      } else
        rect(penux, pussy, wumbo, wumbo, wumbo/3);
      
      if(shart < 1.0)
      shart += 0.05;
      
      if(wumbo > 1 && !should_split()) {
        poop();
        butthol = true;
      }
      blendMode(BLEND);
    }
  }
  boolean should_split() {
    return dist(mouseX, mouseY, penux, pussy) > wumbo/1.414213562;
  }
  void poop() {
    pp = true;
    if(suboF != null) suboF.bubber = true;
    shart = 1.0;
    bitch = new Bofer(penux + wumbo/4.f, pussy + wumbo/4.f, wumbo/2.f, this);
    shit = new Bofer(penux - wumbo/4.f, pussy + wumbo/4.f, wumbo/2.f, this);
    cunt = new Bofer(penux - wumbo/4.f, pussy - wumbo/4.f, wumbo/2.f, this);
    piss = new Bofer(penux + wumbo/4.f, pussy - wumbo/4.f, wumbo/2.f, this);
  }
  void upsuck() {
    if(!(bitch.pp || shit.pp || cunt.pp || piss.pp) && suboF != null && should_split()) {
      pp = false;
      butthol = false;
      suboF.bubber = false;
    }
  }
}

float smootherstep(float x) {
  if(x <= 0) return 0;
  if(x >= 1) return 1;
  return 3*x*x-2*x*x*x;
}
