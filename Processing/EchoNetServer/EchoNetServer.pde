
import processing.net.*;
Server node;
ArrayList<String> screenText = new ArrayList<String>();
ArrayList<String> log = new ArrayList<String>();
int port = 25560;

int adressTick = 0;

HashMap<String, TextStream> files = new HashMap<String, TextStream>(); //File name -> TextStream

ArrayList<String> toSend = new ArrayList<String>();

String fileNameListLocation = "data/fileNames.list";

void setup() {
  size(600, 800);
  node = new Server(this, port);
  PFont font = createFont("GungsuhChe", 15);
  textFont(font);
  background(0);
  screenText.add("Opened connection on " + port + ", awaiting clients...");
  String[] loadedLocations = loadStrings(fileNameListLocation);
  adressTick = Integer.parseInt(loadedLocations[0]);
  for(int i = 1; i < loadedLocations.length; i++) {
    files.put(loadedLocations[i], new TextStream(loadedLocations[i]));
    files.get(loadedLocations[i]).loadFrom(loadedLocations[i]);
  }
  log.add("Log Start @" + year() + "-" + month() + "-" + day() + "-" + hour() + "-" + minute() + "-" + second() + "-" + millis());
  log.add("Current ID Tick: " + adressTick);
}

void saveNames() {
  printR("Saving file names to " + fileNameListLocation + "...");
  ArrayList<String> strOut = new ArrayList<String>();
  strOut.add(adressTick + "");
  for(String toAdd : files.keySet()) {
    strOut.add(toAdd);
  }
  String[] arrOut = new String[strOut.size()];
  for(int i = 0; i < arrOut.length; i++)
    arrOut[i] = strOut.get(i);
  saveStrings(fileNameListLocation, arrOut);
  printR("File names saved.");
}

void saveLogs() {
  printR("Saving logs to server-side memory...");
  String[] logOut = new String[log.size()];
  for(int i = 0; i < logOut.length; i++)
    logOut[i] = log.get(i);
  saveStrings("data/logs/" + year() + "-" + month() + "-" + day() + "/" + year() + "-" + month() + "-" + day() + "-" + hour() + "-" + minute() + "-" + second() + "-" + millis() + ".log", logOut);
  log = new ArrayList<String>();
  log.add("Log Start @" + year() + "-" + month() + "-" + day() + "-" + hour() + "-" + minute() + "-" + second() + "-" + millis());
  log.add("Current ID Tick: " + adressTick);
  printR("Logs saved.");
}

void saveData() {
  saveLogs();
  for(TextStream ts : files.values())
    ts.saveData();
}

void saveData(String fName) {
  files.get(fName).saveData();
}

void draw() {
  fill(0, 50);
  rect(0, 0, width, height);
  fill(50, 255, 100);
 
  for(int i = 0; i < 20; i++) {
    Client nxtClient = node.available();
    if(nxtClient != null) {
      String dataIn = nxtClient.readString();
      if(dataIn != null) {
        String[] dataInArr = dataIn.split("~");
        for(String s : dataInArr)
          if(s.length()>0)
            parseCommand(s);
      }
    }
  }
  printScreenText();
  cycleThruToSend();
}

void parseCommand(String cmd) {
  try {
    try {
      try {
        subParse(cmd.split("`"));
      } catch(IndexOutOfBoundsException ioobe) {
        ioobe.printStackTrace();
      }
    } catch(StringIndexOutOfBoundsException sioobe) {
      sioobe.printStackTrace();
    }
  } catch(NumberFormatException ne) {
    ne.printStackTrace();
  }
  String toEcho = cmd;
  if(cmd.split("`").length > 1)
    if(!cmd.split("`")[1].equals("LOAD") && !cmd.split("`")[1].equals("FLIST") && !cmd.split("`")[1].equals("SAVE"))
      sendCommand(toEcho);
}

void subParse(String[] idSplit) {
  int recvId = Integer.parseInt(idSplit[0]);
  String cmd = idSplit[1];
  if(cmd.equals("LOAD")) {
    String fName = idSplit[2];
    if(!files.containsKey(fName)) {
      printR("Creating file with name of \"" + fName + "\"");
      createFile(fName);
    }
    files.get(fName).sendAll(recvId);
  }
  if(cmd.equals("SAVE")) {
    saveData(idSplit[2]);
  }
  if(cmd.equals("FLIST")) {
    String s = recvId + "`FLIST";
    for(String toAdd : files.keySet()) {
      s += "`" + toAdd;
    }
    sendCommand(s);
  }
  if(cmd.equals("PUSH") || cmd.equals("ISL") || cmd.equals("RMLN")) {
    int line = Integer.parseInt(idSplit[2]);
    String fName = idSplit[3];
    
    if(cmd.equals("PUSH")) {
      try {
        if(idSplit.length < 5) {
          files.get(fName).push(recvId, line, "");
          return;
        }
      } catch(NullPointerException npe) {
        npe.printStackTrace();
      }
      String data = idSplit[4];
      files.get(fName).push(recvId, line, data);
    }
    if(cmd.equals("ISL"))
      files.get(fName).insertLine(recvId, line+1);
    if(cmd.equals("RMLN"))
      files.get(fName).removeLine(recvId, line);
  }
}

void createFile(String name) {
  files.put(name, new TextStream(name));
  saveNames();
  files.get(name).saveData();
}

void keyPressed() {
  saveNames();
  saveData();
}

void cycleThruToSend() {
  for(String pool : toSend)
    actualSend(pool);
  toSend = new ArrayList<String>();
}

void serverEvent(Server server, Client client) {
  sendCommand("CONF " + adressTick);
  printR("A new client has connected. IP: " + client.ip() + " ID: 0x" + hex(adressTick));
  adressTick++;
}

void printScreenText() {
  if(screenText.size() > 52)
    screenText.remove(0);
  for(int i = 0; i < min(screenText.size(), 52); i++)
    text(screenText.get(i), 10, i*15 + 15);
}

void printR(String s) {
  screenText.add(s);
  log.add(s);
}

void sendCommand(String s) {
  toSend.add(s);
  printR("~" + s);
}

void actualSend(String s) {
  node.write("~" + s);
}

class TextStream {
  ArrayList<String> data = new ArrayList<String>();
  String name = "";
  int lastModifiedBy = -1;
  
  public TextStream(String fName) {
    name = fName;
    data.add("");
  }
  
  void removeLine(int id, int line) {
    data.remove(line);
    lastModifiedBy = id;
  }
  
  public void push(int id, int line, String s) {
    data.set(line, s);
    lastModifiedBy = id;
  }
  
  public void insertLine(int id, int line) {
    data.add(line, "");
    lastModifiedBy = id;
  }
  
  public void printData() {
    for(int i = 0; i < data.size(); i++)
      printR(data.get(i));
  }
  
  public void loadFrom(String location) {
    String[] readFromFile = loadStrings(location);
    data = new ArrayList<String>();
    for(int i = 0; i < readFromFile.length; i++)
      data.add(readFromFile[i]);
  }
  
  public void sendAll(int id) {
    for(int i = 0; i < data.size(); i++)
      sendCommand(id + "`LOADLINE`" + i + "`" + name + "`" + data.get(i));
  }
  
  public void saveData() {
    printR("Saving " + name + " to server database...");
    ArrayList<String> strOut = new ArrayList<String>();
    for(String toAdd : data) {
      strOut.add(toAdd);
    }
    String[] arrOut = new String[strOut.size()];
    for(int i = 0; i < arrOut.length; i++)
      arrOut[i] = strOut.get(i);
    saveStrings("data/" + name, arrOut);
    printR(name + " saved.");
  }
}
