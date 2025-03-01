
class Player {
  Phys p = new Phys(0, 2000);
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
    p.size=40;
  }
  void display(int scroll) {
    int lx=int(p.x+scroll);
    int blockY=floor(p.y/SPRITE_GRID);
    float YY=(p.y/SPRITE_GRID)%1f;
    getS(body).display(0, blockY, lx, SPRITE_GRID-(int)(YY*SPRITE_GRID));
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