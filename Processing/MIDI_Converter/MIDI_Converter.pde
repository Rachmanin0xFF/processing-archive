
MIDISong music;

void setup() {
  size(512, 256, P2D);
  background(50, 40, 60);
  music = loadMIDI(sketchPath("") + "take5.mid");
  music.parseEvents();
  music.printInfo();
  saveK("log.txt");
}

ArrayList<String> kstr = new ArrayList<String>();
void kprint(String s) {
  if(kstr.size()==0) {kstr.add(s); return;}
  kstr.set(kstr.size()-1, kstr.get(kstr.size()-1) + s);
}
void kprintln(String s) { kstr.add(s); }
void saveK(String floc) { String[] o = new String[kstr.size()];
  for(int i = 0; i < o.length; i++) o[i] = kstr.get(i);
  saveStrings(floc, o);
  kstr = new ArrayList<String>();
}

class MIDISong {
  ArrayList<MIDIEvent> events;
  short format = 0;
  short tracks = 0;
  boolean divisionMode = false; //1 For SMTPE frame mode, 0 is standard.
  short DTUnits = 0;
  public MIDISong(ArrayList<MIDIEvent> events) {
    this.events = events;
    format = bytesToShort(events.get(0).data[0], events.get(0).data[1]);
    tracks = bytesToShort(events.get(0).data[2], events.get(0).data[3]);
    short division = bytesToShort(events.get(0).data[4], events.get(0).data[5]);
    divisionMode = getBit(division, 15);
    DTUnits = (short)(division & 0xFFFE);
  }
  void parseEvents() {
    for(int i = 1; i < events.size(); i++) {
      MIDIEvent m = events.get(i);
      int currentByte = 0;
      boolean doneParsing = false;
      while(!doneParsing) {
        byte b = m.data[currentByte];
        switch((b>>4)&0xF) {
          case 8:
            //Note off
            kprint("-KEY PRESSED-");
            currentByte+=2;
          case 9:
            //Note on
            kprint("-KEY RELEASED-");
            currentByte+=2;
          case 0xA:
            //Polyphonic Key Pressure
            kprint("-KEY RELEASED-");
            currentByte+=2;
          case 0xB:
            //Controller change (pedals/sliders/etc.)
            kprint("-PEDAL-");
            currentByte+=2;
          case 0xC:
            //Program change (changes insturment/sound to be played)
            kprint("-PROGRAM CHANGE-");
            currentByte++;
          case 0xD:
            //Aftertouch, overall change in key pressure (not on a per-key basis)
            kprint("-AFTERTOUCH-");
            currentByte++;
          case 0xE:
            //Pitch bend
            kprint("-PITCH BEND-");
            currentByte+=2;
          case 0xF:
            switch(b&0xF) {
              case 0x0:
                kprint("-F0 SYSEX-");
              case 0x7:
                kprint("-F7 SYSEX-");
              case 0xF:
                kprint("-META EVENT-");
                currentByte++;
              default:
                kprint("-?F" + (b&0xF) + " " + bytesToHex(b) + "?-");
            }
          default:
            if(currentByte > m.data.length - 1) break;
            kprint(bytesToHex(m.data[currentByte]) + ":");
            long n = 0;
            int j = 0;
            for (j = 0; j < 32; j++) {
              int curByte = m.data[min(m.data.length-1, currentByte + j)] & 0xFF;
              n = (n << 7) | (curByte & 0x7F);
              if ((curByte & 0x80) == 0)
                break;
            }
            byte[] z = new byte[j+1];
            //for(int k = 0; k <= j; k++) z[k] = m.data[min(m.data.length-1, currentByte + k)]; kprint("" + bytesToHex(z) + "");
            currentByte++;
        }
        if(currentByte >= m.data.length-1) doneParsing = true;
        currentByte++;
      }
    }
  }
  void printInfo() {
    kprintln("Format:   " + format);
    kprintln("Tracks:   " + tracks);
    kprintln("Division:");
    kprintln("\tDivision mode: " + (divisionMode?1:0));
    if(divisionMode) {
      //TODO: Implement SMTPE Frame timing division
    } else {
      kprintln("\tDT Units in a quarter note: " + DTUnits);
    }
    kprintln("Event List:");
    kprintln("\t   Type      Length\n");
    for(MIDIEvent m : events) {
      kprint("\t" + String.format("%10d", m.type) + " " + String.format("%10d", m.dataLength));
      kprint("   " + bytesToHex(m.data) + "\n");
    }
  }
}
class MIDINote {
  
}
class MIDIEvent {
  int type;
  int dataLength;
  byte[] data;
  public MIDIEvent(int typ, int len, byte[] data) {
    type = typ;
    dataLength = len;
    this.data = data;
  }
}
import java.io.*;
import java.nio.ByteBuffer;
MIDISong loadMIDI(String fileLocation) {
  ArrayList<MIDIEvent> output = new ArrayList<MIDIEvent>();
  long size = 0;
  size = (new File(fileLocation)).length();
  kprintln("Loading file with a size of " + size + " bytes.");
  BufferedInputStream bis = null;
  try {
    bis = new BufferedInputStream(new FileInputStream(fileLocation));
    byte[] tmp = new byte[4];
    boolean fileEnd = false;
    long count = 0;
    while (count < size) {
      bis.read(tmp);
      int typ = bytesToInt(tmp);
      bis.read(tmp);
      int len = bytesToInt(tmp);
      byte[] data = new byte[len];
      for(int i = 0; i < len; i++) {
        data[i] = (byte)bis.read();
      }
      if(!fileEnd) {
        MIDIEvent m = new MIDIEvent(typ, len, data);
        output.add(m);
      }
      count += len + 8;
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
  return new MIDISong(output);
}
int bytesToInt(byte[] bytes) {
  return ByteBuffer.wrap(bytes).getInt();
}
//VARGS IS VERY DANGEROUS HERE (I just put it in for the shorthand capibilities) I WOULD NOT RECCOMEND DOING THIS IN YOUR CODE
short bytesToShort(byte... bytes) {
  return ByteBuffer.wrap(bytes).getShort();
}
boolean getBit(short s, int position) {
   return ((s >> position) & 1) == 1;
}
boolean getBit(byte b, int position) {
   return ((b >> position) & 1) == 1;
}
final protected static char[] hexArray = "0123456789ABCDEF".toCharArray();
public static String bytesToHex(byte... bytes) {
    char[] hexChars = new char[bytes.length * 2];
    for ( int j = 0; j < bytes.length; j++ ) {
        int v = bytes[j] & 0xFF;
        hexChars[j * 2] = hexArray[v >>> 4];
        hexChars[j * 2 + 1] = hexArray[v & 0x0F];
    }
    return new String(hexChars);
}

public String bytesToASCII(byte... bytes) {
  try {
    return new String(bytes, "US-ASCII");
  } catch(UnsupportedEncodingException uee) {
    //Do nothing.
  }
  return "FAILURE FAILURE ABORT ABORT MISSION ABOOOOORRRRRTTTTT";
}



//////////////////////////////////////////////////////////////////
//Taken From http://rosettacode.org/wiki/Variable-length_quantity
//////////////////////////////////////////////////////////////////

public byte[] encodeVLQ(long n)
{
  int numRelevantBits = 64 - Long.numberOfLeadingZeros(n);
  int numBytes = (numRelevantBits + 6) / 7;
  if (numBytes == 0)
    numBytes = 1;
  byte[] output = new byte[numBytes];
  for (int i = numBytes - 1; i >= 0; i--)
  {
    int curByte = (int)(n & 0x7F);
    if (i != (numBytes - 1))
      curByte |= 0x80;
    output[i] = (byte)curByte;
    n >>>= 7;
  }
  return output;
}
 
public long decodeVLQ(byte[] b)
{
  long n = 0;
  for (int i = 0; i < b.length; i++)
  {
    int curByte = b[i] & 0xFF;
    n = (n << 7) | (curByte & 0x7F);
    if ((curByte & 0x80) == 0)
      break;
  }
  return n;
}