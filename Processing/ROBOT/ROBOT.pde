import java.awt.*;
import java.awt.event.*;
Robot r;
void setup() {
  try {
    r = new Robot();
    r.setAutoDelay(0);
  } catch(Exception e) {}
  frameRate(100000000);
  delay(2000);
}
void draw() {
  for(int i = 0; i < 10000; i++)
    r.keyPress(java.awt.event.KeyEvent.VK_ENTER);
}

void delay(int delay) {
  int time = millis();
  while(millis() - time <= delay);
}

