
class Player {
  Phys p = new Phys(2000, 0);
  int body=200;
  int equip=0;
  int hat=0;
  float HV=4;
  PVector facing;

  int jumps=0;
  int maxJumps=2;
  boolean jumped=false;

  boolean facingLeft = false;
  Player(){
    p.size=29;
  }
  void display() {
    getS(body).mirror = p.mirror;
   
    for(int i=5;i>=0;i--){
      tint(255,255*(5-i)/5.0);
       getS(body).display(0,0,int(p.x-p.v.x*i/5f),int(p.y-p.v.y*i/5f));
    }
    println("Player pos:",p.x,p.y);
  }

  void update() {
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

  }
}