import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;
 
Minim minim;
ArrayList<AudioPlayer> songs = new ArrayList<AudioPlayer>();

//00 - NightSong


HashMap<String, AudioSample> samps = new HashMap<String, AudioSample>();
//00 - Rock Clop

void initAudio() {
  minim = new Minim(this);
  loadSong(0, -15.0);
  loadSample("rockbop", -15.0);
  loadSample("rockpik", -20.0);
}

void loadSong(int id, float gain) {
  songs.add(minim.loadFile("audio/music/" + id + ".wav"));
  songs.get(songs.size()-1).setGain(gain);
}

void loadSample(String name, float gain) {
  samps.put(name, minim.loadSample("audio/soundFX/" + name + ".wav"));
  samps.get(name).setGain(gain);
  float val = map(mouseX, 0, width, 0, 48000);
  //samps.get(name).setPitch(0);
}

void startAudio() {
  songs.get(0).play();
}

void triggerAudio(String sound) {
  if(samps.containsKey(sound))
    samps.get(sound).trigger();
}