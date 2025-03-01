float t;
float mTone;
void setup() {
  Serial.begin(9600);
  mTone = float(analogRead(0));
}
void loop() {
   float note = float(analogRead(0));
   if(note > mTone + 20 || note < mTone - 20)
     tone(8, saw(t)*100+(note-mTone + 400)*1.5);
   else
     noTone(8);
   Serial.println(note);
   t++;
}
float saw(float in) {
  return int(in)%3;
}
