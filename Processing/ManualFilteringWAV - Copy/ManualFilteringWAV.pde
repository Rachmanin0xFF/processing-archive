






//helo ll





//ho

//hi


//Ok so hi this is Adam I'm the wone whot wroted this codes

//Press ur 'r' bootan to start/stop recordant

//Press ur 's' bootan to save stuff

//b sure to write in ur music's file nambe

//Plese look at the MANGLE() function for info on wut u can gonna do here

//Thankgs

// ;)

import ddf.minim.*;
import ddf.minim.signals.*;

Minim minim;
AudioOutput out;
AudioRecorder recorder;
boolean recorded;
Resonator signalGen;

float[] songInput;
void setup() {
  size(800, 800, P2D);
  frameRate(60);
  dispWaveVals = new float[width];
  initMinim();
  blendMode(ADD);
  noSmooth();
  background(0);
  fill(255, 255, 255, 255);
  textAlign(CENTER, CENTER);
  text("Loading file & applying filter...", width/2, height/2);
}

void initMinim() {
  //Load ur sog here
  songInput = loadWAV("D:\\Processing\\Processing 3.x\\ManualFilteringWAV\\musics\\flim.wav");
  
  //HAUUAUUAAAHHEHHEHEHEHEHEEEE
  
  //Git minim starhted.
  minim = new Minim(this);
  out = minim.getLineOut(Minim.MONO);
  
  //Boot up our link to minim and patch it into the output signal.
  signalGen = new Resonator();
  out.addSignal(signalGen);
  
  //Attach the recorder to minim's line out (apparently this works)
  recorder = minim.createRecorder(out, "SoundOut.wav");
}

//FUCK THAT SIGNAL UP
void MANGLE() {
  //Alright, so this is your playground.
  //You're basically making a sound filter here.
  //You're taking a wave and transforming it.
  //That's a pretty vague assignment.
  //Like, you could simulate the sound bouncin' off walls 'n stuff.
  //Or make the pitch higher.
  //Anyways, now that you know what ur doin'...
  //
  //Your main goal here is to hack apart the songInput[] array until 
  //it is a beautiful melodic cacophony of harmonics and lobit noise.
  //Your materials:
  //  The songInput[] float array
  //Your tools:
  //  Processing
  //Git goin' and good luck.
  
  
  ///THIS IS AN EXAMPLE FILTER
  for(int i = 0; i < songInput.length; i++) {
    float k = (sin(((float)i)/30000.f)*0.5 + 0.5)*40.f + 3.f;
    songInput[i] = ((float)floor(k*songInput[i]))/k+0.5f/k;
  }
  ///DON'T WEAR HEADPHONES WITH THIS ONE PROBABLY
}

boolean mangled = false;
void draw() {
  //I do this little thing here in draw because minim doesn't run in the
  //same thread as the rest of Processing ('cause it's sound stuff).
  if(!mangled) {
    MANGLE();
    mangled = true;
  }
  noStroke();
  fill(0, 0, 0, 100);
  rect(0, 0, width, height);
  background(0);
  //Draw that sexy smooth wave
  displayWave();
  //Draw those smokin' hot buttony icons
  if(recorder.isRecording()) {
    noStroke();
    fill(255, 0, 0, 255);
    ellipse(width - 30, 30, 20, 20);
  }
  if(saved > 0) {
    saved--;
    noStroke();
    fill(0, 255, 0, 255);
    beginShape();
    vertex(width - 40, 30);
    vertex(width - 20, 30);
    vertex(width - 30, 40);
    endShape(CLOSE);
  }
}

float[] dispWaveVals;
void displayWave() {
  stroke(100, 200, 200, 255);
  for(int i = 1; i < dispWaveVals.length; i++) {
    //Wave values are from -1.f to 1.f (electricity remember) so this works (don't question my logic).
    line(i-1, dispWaveVals[i-1]*float(height/2)+height/2, i, dispWaveVals[i]*float(height/2)+height/2);
  }
}

int wavIndex = 0;
float update() {
  float wavSample = 0.f;
  //Send Minim our sound and move things along UNLESS we haven't filtered it yet.
  if(mangled && wavIndex < songInput.length) {
    wavSample = songInput[wavIndex];
    wavIndex++;
  }
  //Clamp the signal between -1.0 and 1.0 (this almost certainly happens later down the line, but I'm just bein' safe).
  return clamp(wavSample, -1.f, 1.f);
}

//Audio recording setup (executed on key press)
int saved = 0;
void keyPressed() {
  //I literally copy-pasted this out of the minim recording exmple.
  if(!recorded && key == 'r') {
    if(recorder.isRecording()) {
      recorder.endRecord();
      recorded = true;
    } else {
      recorder.beginRecord();
    }
  }
  if(recorded && key == 's') {
    recorder.save();
    //Give us a good second of fancy-looking green button.
    saved = 60;
  }
}

//The class we use to transmit our audio data to minim.
class Resonator implements AudioSignal {
  void generate(float[] samp) {
    for(int i = 0; i < samp.length; i++) {
      samp[i] = update();
    }
    for(int i = 0; i < dispWaveVals.length; i++)
      dispWaveVals[i] = samp[i];
  }
  void generate(float[] left, float[] right) {
    //Mono sound output :P
  }
}

//Close minim resources
void stop() {
  out.close();
  minim.stop();
  super.stop();
}

//Hand-made WAV loading function, @author Adam Lastowka.
//Heavy use is not reccomended because this ignores a lot of stuff but it works well with Audacity so it's okay.
import java.io.*;
import java.nio.ByteBuffer;
float[] loadWAV(String fileLocation) {
  long size = 0;
  size = (new File(fileLocation)).length();
  print("Loading file with a size of " + size + " bytes.");
  //We use a BufferedInputStream then load everything as bytes 'cause we gotta do it all manually ;)
  BufferedInputStream bis = null;
  float[] data = new float[(int)(size)/4];
  int dataCount = 0;
  float LRMIX = 1.0f;
  try {
    bis = new BufferedInputStream(new FileInputStream(fileLocation));
    long count = 0;
    while (count < 26) { bis.read(); count++; }
    while (count < size-5) {
      //Load left-channel bytes (probably)
      byte aL = (byte)bis.read();
      byte bL = (byte)bis.read();
      
      //Load right-channel bytes (probably)
      byte aR = (byte)bis.read();
      byte bR = (byte)bis.read();
      
      //Convert bytes to int form
      int valL = bytesToInt(bL, aL, (byte)0, (byte)0);
      int valR = bytesToInt(bR, aR, (byte)0, (byte)0);
      
      //Cast the ints to floats and fade the left and right channels.
      //LRMIX = sin((float)dataCount/20000.f)*0.5f + 0.5f; //Rotational fade example
      float mono = lerp((float)valL, (float)valR, LRMIX);
      
      //Save to temporary "data" array and increase count.
      data[dataCount] = ((float)(mono))/3000000000.f;
      dataCount++;
      count+=4;
    }
  } catch (IOException e) {
    e.printStackTrace();
  } finally {
    try {
      if (bis != null)bis.close();
    } catch (IOException ex) {
      ex.printStackTrace();
    }
  }
  return data;
}
//Thanks, StackOverflow.
int bytesToInt(byte... bytes) {
  return ByteBuffer.wrap(bytes).getInt();
}
//Thanks for playing the code!!!!