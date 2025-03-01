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
  loadSample("gooom_with_an_m","intro1",0);
  loadSample("huge",0);
  loadSample("boop",0);
}

void loadSong(int id, float gain) {
  songs.add(minim.loadFile("audio/music/" + id + ".wav"));
  songs.get(songs.size()-1).setGain(gain);
}

void loadSample(String name, float gain) {
  samps.put(name, minim.loadSample("audio/soundFX/" + name + ".wav"));
  samps.get(name).setGain(gain);
}
void loadSample(String name, String tag, float gain) {
  samps.put(tag, minim.loadSample("audio/soundFX/" + name + ".wav"));
  samps.get(tag).setGain(gain);
}

void startAudio() {
  songs.get(0).play();
}

void triggerAudio(String sound) {
  if(samps.containsKey(sound))
    samps.get(sound).trigger();
}

void stopAudio(String sound) {
  if(samps.containsKey(sound))
    samps.get(sound).stop();
}