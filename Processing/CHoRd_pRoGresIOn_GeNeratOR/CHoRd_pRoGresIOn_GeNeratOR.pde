/**
  * This sketch demonstrates how to create synthesized sound with Minim using an AudioOutput and
  * an Instrument we define. By using the playNote method you can schedule notes to played 
  * at some point in the future, essentially allowing to you create musical scores with code. 
  * Because they are constructed with code, they can be either deterministic or different every time. 
  * This sketch creates a deterministic score, meaning it is the same every time you run the sketch.
  * <p>
  * For more complex examples of using playNote check out algorithmicCompExample and compositionExample
  * in the Synthesis folder.
  * <p>
  * For more information about Minim and additional features, visit http://code.compartmental.net/minim/
  */

import ddf.minim.*;
import ddf.minim.ugens.*;

Minim minim;
AudioOutput out;

// to make an Instrument we must define a class
// that implements the Instrument interface.
class SineInstrument implements Instrument {
  Oscil wave;
  Oscil mod;
  Line  ampEnv;
  
  SineInstrument( float frequency ) {
    // make a sine wave oscillator
    // the amplitude is zero because 
    // we are going to patch a Line to it anyway
    wave   = new Oscil( frequency, 0, Waves.SINE );
    ampEnv = new Line();
    mod = new Oscil( 1, 1f, Waves.SINE );
    ampEnv.patch( wave.amplitude );
    //mod.patch(wave.amplitude);
  }
  
  // this is called by the sequencer when this instrument
  // should start making sound. the duration is expressed in seconds.
  void noteOn( float duration ) {
    // start the amplitude envelope
    ampEnv.activate(duration, 0.2f, 0 );
    // attach the oscil to the output so it makes sound
    wave.patch( out );
  }
  
  // this is called by the sequencer when the instrument should
  // stop making sound
  void noteOff() {
    wave.unpatch( out );
  }
}

void setup() {
  println(getFreq(49));
  size(512, 200, P3D);
  
  minim = new Minim(this);
  
  // use the getLineOut method of the Minim object to get an AudioOutput object
  out = minim.getLineOut();
}
void keyPressed() {
  println("=-=-=-=-=-=-=-=-=-=-=-=-=-=-=");
  //pentatonic((int)random(30, 40), 0.f, 2.f);
  //note(58, 0.f, 2.f);
  for(int i = 0; i < 4; i++) {
    //if(random(10) > 5)
    //pentatonic((int)random(38, 56), i/8.f, .5f);
    //pentatonic((int)random(38, 56), i/2.f, .5f);
    if(random(1)>.5f) {
      chord_Xm((int)random(38, 56), i/2.f, .5f);
    } else {
      chord_X((int)random(38, 56), i/2.f, .5f);
    }
  }
}


void note(int index, float startTime, float duration) {
  out.playNote(startTime, duration, new SineInstrument(getFreq(index)/2.f));
}

int[] addvals = new int[]{2, 3, 2, 2, 3};
void pentatonic(int index, float startTime, float duration) {
  int j = 0;
  for(int i = 0; j < index; i++) {
    j += addvals[i%addvals.length];
  }
  out.playNote(startTime, duration, new SineInstrument(getFreq(j)));
}

void chord_X(int index, float startTime, float duration) {
  out.playNote(startTime, duration, new SineInstrument(getFreq(index)));
  out.playNote(startTime, duration, new SineInstrument(getFreq(index+4)));
  out.playNote(startTime, duration, new SineInstrument(getFreq(index+7)));
  println(frequency_to_note_letter(getFreq(index)));
}

void chord_Xm(int index, float startTime, float duration) {
  out.playNote(startTime, duration, new SineInstrument(getFreq(index)));
  out.playNote(startTime, duration, new SineInstrument(getFreq(index+3)));
  out.playNote(startTime, duration, new SineInstrument(getFreq(index+7)));
  println(frequency_to_note_letter(getFreq(index)) + "m");
}

void chord_Xm7(int index, float startTime, float duration) {
  out.playNote(startTime, duration, new SineInstrument(getFreq(index)));
  out.playNote(startTime, duration, new SineInstrument(getFreq(index+3)));
  out.playNote(startTime, duration, new SineInstrument(getFreq(index+7)));
  out.playNote(startTime, duration, new SineInstrument(getFreq(index+10)));
  println(frequency_to_note_letter(getFreq(index)) + "m7");
}

void chord_XM7(int index, float startTime, float duration) {
  out.playNote(startTime, duration, new SineInstrument(getFreq(index)));
  out.playNote(startTime, duration, new SineInstrument(getFreq(index+4)));
  out.playNote(startTime, duration, new SineInstrument(getFreq(index+7)));
  out.playNote(startTime, duration, new SineInstrument(getFreq(index+11)));
  println(frequency_to_note_letter(getFreq(index)) + "M7");
}

float getFreq(int key_num) {
  return (float)(pow(1.0594630943592952645618253, key_num - 49.0)*440.0);
}

void draw() {
  background(0);
  stroke(255);
  
  // draw the waveforms
  for(int i = 0; i < out.bufferSize() - 1; i++) {
    line( i, 50 + out.left.get(i)*50, i+1, 50 + out.left.get(i+1)*50 );
    line( i, 150 + out.right.get(i)*50, i+1, 150 + out.right.get(i+1)*50 );
  }
}
