/**
 * Simple Read
 * 
 * Read data from the serial port and change the color of a rectangle
 * when a switch connected to a Wiring or Arduino board is pressed and released.
 * This example works with the Wiring / Arduino program that follows below.
 */


import processing.serial.*;

Serial myPort;  // Create object from Serial class
int val;      // Data received from the serial port
int SAMPLES = 128;
int[] vals = new int[SAMPLES];
void setup() 
{
  size(512, 512);
  // I know that the first port in the serial list on my mac
  // is always my  FTDI adaptor, so I open Serial.list()[0].
  // On Windows machines, this generally opens COM1.
  // Open whatever port is the one you're using.
  println(Serial.list());
  String portName = Serial.list()[1];
  myPort = new Serial(this, portName, 57600);
  delay(3000);
  noSmooth();
}

void draw()
{
  background(0);
  if (myPort.available() > 0) {  // If data is available,
    String val = myPort.readStringUntil('E');         // read it and store it in val
    if(val != null && val.startsWith("S")) {
      String[] all = val.split(",");
      if(all.length > SAMPLES/2)
      for(int i = 1; i < SAMPLES-1; i++) {
        vals[i] = int(all[i]);
      }
      vals[0] = int(all[0].substring(1));
    }
  }
  line(0, height/2, width, height/2);
  stroke(255);
  strokeWeight(1);
  strokeCap(SQUARE);
  for(int i = 0; i < SAMPLES; i++) {
    line(i*2, height/2, i*2, height/2 - vals[i]/2);
  }
}



/*

// Wiring / Arduino Code
// Code for sensing a switch status and writing the value to the serial port.

int switchPin = 4;                       // Switch connected to pin 4

void setup() {
  pinMode(switchPin, INPUT);             // Set pin 0 as an input
  Serial.begin(9600);                    // Start serial communication at 9600 bps
}

void loop() {
  if (digitalRead(switchPin) == HIGH) {  // If switch is ON,
    Serial.write(1);               // send 1 to Processing
  } else {                               // If the switch is not ON,
    Serial.write(0);               // send 0 to Processing
  }
  delay(100);                            // Wait 100 milliseconds
}

*/
