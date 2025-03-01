class Toggler {
  boolean state;
  int x, y, w, h;
  boolean pmp = false;
  Toggler(int x, int y, int w, int h) {
    this.x = x; this.y = y;
    this.w = w; this.h = h;
  }
  void update() {
    if(mouseX < x + w && mouseY < y + h && mouseX > x && mouseY > y) {
      if(mousePressed && !pmp) {
        state = !state;
      }
      pmp = mousePressed;
    }
  }
  void display() {
    stroke(255, 255);
    fill(20);
    strokeWeight(1);
    rect(x, y, w, h);
    if(state) {
      fill(255);
      rect(x + 5, y + 5, w-10, h-10);
    }
    noFill();
  }
}

class ButtonList {
  Toggler[] toggles;
  ButtonList(int size) {
    toggles = new Toggler[size];
    int xc = 10;
    int yc = 10;
    for(int i = 0; i < size; i++) {
      toggles[i] = new Toggler(xc, yc, 20, 20);
      xc += 30;
      if(xc > width - 100) {
        xc = 10; yc += 30;
      }
    }
  }
  void update() {
    for(int i = 0; i < toggles.length; i++) {
      toggles[i].update();
      toggles[i].display();
    }
  }
  boolean[] get_array() {
    boolean[] b = new boolean[toggles.length];
    for(int i = 0; i < b.length; i++) {
      b[i] = toggles[i].state;
    }
    return b;
  }
}
