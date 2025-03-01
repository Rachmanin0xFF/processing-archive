import themidibus.*;
MidiBus midBus;
import javax.sound.midi.MidiMessage;
import javax.sound.midi.SysexMessage;
import javax.sound.midi.ShortMessage;

void setUpMIDI() {
  MidiBus.list();
  midBus = new MidiBus(this, 0, 0);
}

int lastMessageLength;
int lastMessageStatus;
byte[] lastMessage;

void midiMessage(MidiMessage message) { // You can also use midiMessage(MidiMessage message, long timestamp, String bus_name)
  String CMD = "";
  lastMessageStatus = message.getStatus();
  lastMessageLength = message.getLength();
  lastMessage = message.getMessage();
  boolean noteget = false;
  switch(lastMessageStatus) {
    case 128:
      CMD = "NOTEOFF";
      noteget = true;
      break;
    case 144:
      CMD = "NOTEON";
      noteget = true;
      break;
    default:
      break;
  }
  if(noteget==true) {
    int notenum = (int)(lastMessage[1] & 0xFF);
    int notevel = CMD.equals("NOTEOFF")?0:(int)(lastMessage[2] & 0xFF);
    noteVels[notenum] = notevel;
    println("Note " + notenum + " set to velocity of " + notevel);
  }
}
float[] noteVels = new float[120];