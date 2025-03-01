#include <Servo.h>
Servo s;
Servo s2;
void setup() {
  Serial.begin(9600);
  s.attach(9);
  s2.attach(10);
}
void loop() {
  int sensorValue = analogRead(A0);
  int sensorValue2 = analogRead(A1);
  float k = 3;
  int g = (int)(((float)sensorValue/1000)*180/k);
  int g2 = (int)(((float)sensorValue2/1000)*180/k);
  Serial.println(g);
  Serial.println(g2);
  delay(1);
  s.write(g2);
  s2.write(180-g-60);
}
