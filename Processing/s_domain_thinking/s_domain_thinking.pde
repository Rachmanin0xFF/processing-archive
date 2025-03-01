ComplexPlane scape;

void setup() {
  size(1600, 900, P2D);
  scape = new ComplexPlane(50, 50, 800, 800);
}

void draw() {
   background(0);
   scape.display();
}

class ComplexPlane {
  float r_bounds = 3;
  float xp;
  float yp;
  float wp;
  float hp;
  ComplexPlane(float x, float y, float w, float h) {
    xp = x;
    yp = y;
    wp = w;
    hp = h;
  }
  //x - to - screen
  float xts(float x) {
    return map(x, -r_bounds, r_bounds, xp, xp+wp);
  }
  //y - to - screen
  float yts(float y) {
    return map(y, -r_bounds, r_bounds, yp + hp, yp);
  }
  
  float stx(float sx) {
    return map(sx, xp, xp + wp, -r_bounds, r_bounds);
  }
  float sty(float sy) {
    return map(sy, yp + hp, yp, -r_bounds, r_bounds);
  }
  Cpl stCpl(float sx, float sy) {
    return new Cpl(stx(sx), sty(sy));
  }
  void Cplpt(Cpl z) {
    point(xts(z.re), yts(z.im));
  }
  
  void display() {
    draw_cols();
    blendMode(ADD);
    stroke(255);
    line(xts(0), yts(-r_bounds), xts(0), yts(r_bounds));
    line(xts(-r_bounds), yts(0), xts(r_bounds), yts(0));
    noFill();
    rect(xp, yp, wp, hp);
    ellipse(xts(0), yts(0), xts(1)-xts(0), yts(1)-yts(0));
    draw_exp_mouse();
    test_draw();
    blendMode(BLEND);
  }
  
  void draw_cols() {
    int rd = 4;
    colorMode(HSB);
    strokeWeight(rd);
    for(float x = xp; x < xp + wp; x += rd) {
      for(float y = yp; y < yp + hp; y += rd) {
        Cpl z = stCpl(x, y);
        //Cpl sf = div(new Cpl(1.0, 0.0), add(mult(z, z), add(z, new Cpl(1.0, 0.0))));
        Cpl sf = div(new Cpl(1.0, 0.0), mult(add(z, new Cpl(1.0, 0.0)), add(z, new Cpl(2.0, 0.0))));
        float r = mod(sf);
        float k = 360.0*(arg(sf)+PI)/TWO_PI;
        stroke(k, 100.0, r*255.f);
        //z = add(z, new Cpl(-r*0.2,-r*0.2));
        Cplpt(z);
      }
    }
    colorMode(RGB);
    strokeWeight(1);
  }
  
  void test_draw() {
    Cpl s = stCpl(mouseX, mouseY);
    noFill();
    beginShape();
    for(int i = 0; i < 2048; i++) {
      float t = i/20.f;
      Cpl z = exp(mult(s, -t));
      Cpl f = new Cpl(exp(-2.0*t)*(exp(t)-1.0), 0.0);
      Cpl q = mult(z, f);
      //vertex(xts(q.re), yts(q.im));
    }
    endShape();
    
    stroke(100, 240, 90);
    beginShape();
    Cpl sm = new Cpl(0, 0);
    for(int i = 0; i < 1024; i++) {
      float t = i/20.f;
      Cpl z = exp(mult(s, -t));
      //Cpl f = new Cpl(2.0*exp(-t/2.0)*sin(sqrt(3)/2.0*t)/sqrt(3), 0);
      Cpl f = new Cpl(exp(-2.0*t)*(exp(t)-1.0), 0.0);
      Cpl q = mult(z, f);
      vertex(xts(q.re), yts(q.im));
      sm = add(q, sm);
    }
    endShape();
    sm = mult(sm, 1.0 / 20.0);
    stroke(250, 255, 100);
    strokeWeight(30);
    Cplpt(sm);
    strokeWeight(1);
    
    fill(255);
    textAlign(LEFT, TOP);
    text(mod(sm), 40, 40);
    noFill();
  }
  void draw_exp_mouse() {
    Cpl s = stCpl(mouseX, mouseY);
    stroke(100, 240, 90);
    beginShape();
    for(int i = 0; i < 256; i++) {
      float t = i/10.f;
      Cpl z = exp(mult(s, -t));
      float y = mod(z);
      
      float f = sin(t*0.8);
      
      float wiggle = z.re;
      vertex(mouseX + i*2, mouseY - wiggle*100);
      
      //Cpl summd = mult(z, f);
      
      //point(mouseX + i*2, mouseY - summd.re*100);
    }
    endShape();
    line(mouseX, mouseY, mouseX + 512, mouseY);
    stroke(180, 40, 250);
    beginShape();
    for(int i = 0; i < 256; i++) {
      float t = i/10.f;
      Cpl z = exp(mult(s, -t));
      float y = mod(z);
      float wiggle = z.im;
      vertex(mouseX + i*2, mouseY - wiggle*100);
    }
    endShape();
    fill(255); textAlign(RIGHT); textSize(24);
    text("e^-(s*t)", mouseX, mouseY);
  }
}
