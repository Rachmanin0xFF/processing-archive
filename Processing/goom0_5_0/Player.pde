
class Player {
  Phys p = new Phys(2000, 0);
  int body=200;
  int equip=0;
  int hat=0;
  float HV=2;
  PVector facing;
  Power jump=new Power(0, 1, "Jumps", color(124, 237, 192));

  boolean facingLeft = false;
  Player() {
    p.size=29;
  }
  void display() {
    getS(body).mirror = p.mirror;
    float trailLength=7;
    for (int i=7; i>=1; i--) {
      tint(180, 255*(trailLength-i)/trailLength);
      getS(body).display(0, 0, p.x-p.v.x*i/trailLength, p.y-p.v.y*i/trailLength, 0);
    }
    tint(255);
    getS(body).display(0, 0, p.x, p.y, 0);

    println("Player pos:", p.x, p.y);
  }
  void drawStat() {
    jump.draw(100,5);
  }
  void update() {

    if (p.contacting)jump.full();
    jump.update();
    //if (key('a')||key('A')) {
    //  p.v.x-=0.5;
    //  facingLeft = true;
    //}
    //if (key('d')||key('D')) {
    //  p.v.x+=0.5;
    //  facingLeft = false;
    //}
    //getS(body).setMirror(facingLeft);
  }


  void keyAction(char keyP, boolean down) {
    if(keyP=='w'&&down){
      if(jump.use())p.v.y=-12;
    }
  }
}