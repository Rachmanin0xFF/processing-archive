
final float speed = 0.3;
ArrayList<B> ab = new ArrayList<B>();

void setup() {
  size(1920*3/4, 1080*3/4, P2D);
  smooth();
  stroke(255);
  for(float i = 0; i < 10000.0f; i++)
    ab.add(new B(10 + 40f*noise(i/1000.0f+421515), 10 + 40f*noise(i/1000.0f), i/300000.0f + 1.01));
}

void draw() {
  background(0);
  for(B q : ab) {
    q.update();
    q.display();
  }
}

class B {
  float x;
  float y;
  float xv;
  float yv;
  float px;
  float py;
  float easing;
  public B(float x, float y, float easing) {
    this.x = x;
    this.y = y;
    this.easing = easing;
  }
  void update() {
    udp();
    
    if(keyPressed&&keyCode==UP)
      yv -= speed;
    if(keyPressed&&keyCode==DOWN)
      yv += speed;
    if(keyPressed&&keyCode==RIGHT)
      xv += speed;
    if(keyPressed&&keyCode==LEFT)
      xv -= speed;
    
    x += xv;
    y += yv;
    xv /= easing;
    yv /= easing;
    
    if(y < 0) {
      y = height;
      udp();
    }
    if(x < 0) {
      x = width;
      udp();
    }
    if(y > height) {
      y = 0;
      udp();
    }
    if(x > width) {
      x = 0;
      udp();
    }  
  }
  void udp() {
    px = x;
    py = y;
  }
  void display() {
    line(x, y, px, py);
    point(x, y);
  }
}
