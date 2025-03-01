boolean menuOpen=true;
float menuness=1.0;
TB title=new TB("GOOM: THE GAME", width/2, 150, 150);
TB begin=new TB("Begin", width/2, 300, 72);
TB settings=new TB("Settings", width/2, 400, 72);
TB clickbait=new TB("Click Bait", width/2, 500, 72);
class TB {
  String text;
  int x;
  int y;
  int size;
  boolean state;
  TB(String text, int x, int y, int size) {
    this.text=text;
    this.x=x;
    this.y=y;
  }
  void run() {
    run(x, y);
  }
  void run(float dx, float dy) {
    textRect(text, x+(int)dx, y+(int)dy, int(state)*150);
  }
  void clik(float dx, float dy) {
    if (mouseInRect(text, (int)dx+x, (int)dy+y)) {
      state=true;
      triggerAudio("boop");
    }
  }
  void unclik() {
    state=false;
  }
  void unclik(float dx, float dy) {
    state=false;
  }
}

void textRect(String text, int x, int y) {
  noSmooth();
  //rectMode(CENTER);
  textAlign(CENTER, CENTER);
  textSize(72);
  float w=textWidth(text);
  float h=textAscent()+textDescent();
  noFill();
  rect(x-w/2, y-textAscent(), w, h);
  text(text, x, y);
}
void textRect(String text, int x, int y, int fill) {
  noSmooth();
  //rectMode(CENTER);
  textAlign(CENTER, BOTTOM);
  textSize(72);
  float w=textWidth(text);
  float h=textAscent()+textDescent();
  fill(124/2, 237/2, 192, fill);
  stroke(124, 237, 192);
  strokeWeight(4);
  rect(x-w/2, y, w, h);
  fill(124, 237, 192);
  text(text, x, y+textAscent()+textDescent());
}
boolean mouseInRect(String text, int x, int y) {
  textSize(72);
  float w=textWidth(text);
  float h=textAscent()+textDescent();
  return(x-w/2<mouseX&&x+w/2>mouseX&&y<mouseY&&y+h>mouseY);
}
void menuDraw() {
  //println(menuOpen, me.p.size);
  title.x=width/2;
  begin.x=width/2;
  settings.x=width/2;
  clickbait.x=width/2;

  tint(255, menuness*127);
  image(menuBkd, 0, 0);
  //pushMatrix();
  fill(0, menuness*127);
  noStroke();
  tint(255);
  rect(0, 0, width, height);

  //translate(0,-menuness*height);
  title.run(0, (1f-menuness)*height);
  begin.run(0, (1f-menuness)*height);
  settings.run(0, (1f-menuness)*height);
  clickbait.run(0, (1f-menuness)*height);
  rectMode(CORNER);
  //popMatrix();
  if (begin.state) {
    begin.state=false;
    menuOpen=false;
    stopAudio("intro1");
    stopAudio("huge");
    
  }
  if (title.state) {
    title.text="GOOM: THE MENU";
  }
  if (settings.state) {
    settings.state=false;
    me.body=401-me.body;
    me.p.size=90-me.p.size;
    triggerAudio("huge");
  }
  if (clickbait.state) {
    clickbait.state=false;
    launch("start http://www.reddit.com/r/copypasta");
  }
}