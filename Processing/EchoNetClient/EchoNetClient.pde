//Adam Lastowka
//EchoNet (WIP)

import processing.net.*;
import java.awt.Toolkit;

Client rNode;
int charSpacing = 8;
int rowSpacing = 15;
TextEditor TD1;
int id = -1;
boolean hostDown = false;
PFont bigFont;
PFont regFont;
boolean pMousePressed = false;

String targetStream = "";

ArrayList<String> streamList;

int passedFrames = 0;
int stage = 0;
ScrollList fileSelect;
Button openFile;
Button refreshFileList;
Button saveAndExit;
Button save;
Button newStream;
DahrmaText newFileName;
Button createNewFile;
boolean squishCommands = false;

void getID() {
  if(rNode.available() > 0) {
    String dataIn = rNode.readString();
    if(dataIn != null) {
      String[] xxxx = dataIn.split(" ");
      id = Integer.parseInt(xxxx[1]);
    }
  } else
    hostDown = true;
}

void updateStreamList() {
  streamList = new ArrayList<String>();
  sendCommand("FLIST");
  delay(500);
  parseLineSet(5);
}

void setup() {
  size(1000, 800, P2D);
  regFont = createFont("DialogInput.plain", 15);
  bigFont = createFont("DialogInput.plain", 50);
  ArrayList<Integer> q = new ArrayList<Integer>();
  rNode = new Client(this, "127.0.0.1", 25560);
  delay(500);
  getID();
 
  streamList = new ArrayList<String>();
 
  updateStreamList();
 
  //regFont = createFont("GungsuhChe", 15);
  //regFont = createFont("Ubuntu", 15);
  regFont = createFont("DialogInput.plain", 15);
  bigFont = createFont("DialogInput.plain", 50);
  //bigFont = createFont("Ubuntu", 50);
  textFont(regFont);
  background(0);
  parseLineSet(1);
  fileSelect = new ScrollList(20, 20, width-40, height-40-100, streamList);
  openFile = new Button(20, height-100, 120, 80, false, "Open File");
  refreshFileList = new Button(160, height-100, 120, 80, false, "Refresh");
  saveAndExit = new Button(20, height-100, 120, 80, false, "Save and Exit");
  save = new Button(160, height-100, 120, 80, false, "Save");
  newStream = new Button(300, height-100, 120, 80, false, "New File");
  createNewFile = new Button(width/2 - 100, height/2-40, 200, 50, false, "Create File");
  newFileName = new DahrmaText(20, 200, width-40, 50);
  if(hostDown) TD1 = new TextEditor(20, 20, width-40, height-40);
}

void draw() {
  if(stage != 2) {
    fill(0, 50);
    rect(0, 0, width, height);
    fill(200, 200, 255);
  }
  if(!hostDown) {
    if(stage == 0) {
      newFileName.setOn(false);
      fileSelect.update();
      if(refreshFileList.isOn) {
        updateStreamList();
      }
      refreshFileList.update();
     
      if(((keyPressed && key == ENTER) || openFile.isOn) && fileSelect.POI >= 0) {
        TD1 = new TextEditor(20, 20, width-40, height-40-100);
        targetStream = fileSelect.getSelected();
        sendCommand("LOAD`" + targetStream);
        filter(BLUR, 1);
        delay(500);
        stage = 1;
      }
      openFile.update();
     
      if(newStream.isOn) {
        newFileName = new DahrmaText(20, 200, width-40, 50);
        fill(0, 100);
        rect(0, 0, width, height);
        fill(200, 200, 255);
        newFileName.setOn(true);
        textFont(bigFont);
        textAlign(CENTER);
        text("Enter File Name.", width/2, 100);
        textFont(regFont);
        stage = 2;
      }
      newStream.update();
    } else if(stage == 1) {
      newFileName.setOn(false);
      parseLineSet(5);
      TD1.update();
      if(save.isOn) {
        sendCommand("SAVE`" + targetStream);
      }
      save.update();
      if(saveAndExit.isOn) {
        updateStreamList();
        sendCommand("SAVE`" + targetStream);
        stage = 0;
      }
      saveAndExit.update();
    } else if(stage == 2) {
      createNewFile.update();
      newFileName.update();
      if(createNewFile.isOn) {
        targetStream = newFileName.info;
        sendCommand("LOAD`" + targetStream);
        TD1 = new TextEditor(20, 20, width-40, height-40-100);
        stage = 1;
      }
    }
  }
  if(hostDown) {TD1.update(); dispError();}
  passedFrames++;
  pMousePressed = mousePressed;
}

void parseLineSet(int times) {
  for(int i = 0; i < times; i++) {
    if(rNode.available() > 0) {
      String dataIn = rNode.readString();
      if(dataIn != null) {
        String[] dataInArr = dataIn.split("~");
        for(String s : dataInArr)
          if(s.length()>0) {
            String[] idSplit = s.split("`");
            if(idSplit.length > 1)
              parseCommand(idSplit);
          }
      }
    }
  }
}

void parseCommand(String[] idSplit) {
  try {
    try {
      try {
        subParse(idSplit);
      } catch(IndexOutOfBoundsException ioobe) {
        ioobe.printStackTrace();
      }
    } catch(StringIndexOutOfBoundsException sioobe) {
      sioobe.printStackTrace();
    }
  } catch(NumberFormatException ne) {
    ne.printStackTrace();
  }
}

void subParse(String[] idSplit) {
  int recvId = Integer.parseInt(idSplit[0]);
  String cmd = idSplit[1];
  if(cmd.equals("FLIST")) {
    for(int i = 2; i < idSplit.length; i++) {
      streamList.add(idSplit[i]);
    }
    if(fileSelect != null)
      fileSelect.setItems(streamList);
    return;
  }
  if(recvId == id) {
    if(cmd.equals("LOADLINE")) {
      int line = Integer.parseInt(idSplit[2]);
      if(line != 0)
        TD1.insertLine(line);
      if(idSplit.length > 4)
        TD1.push(line, idSplit[4]);
      else
        TD1.push(line, "");
    }
    return;
  }
  if(cmd.equals("PUSH") || cmd.equals("ISL") || cmd.equals("RMLN")) {
    int line = Integer.parseInt(idSplit[2]);
    String fName = idSplit[3];
    if(!fName.equals(targetStream))
      return;
    if(cmd.equals("PUSH")) {
      if(idSplit.length < 5) {
        TD1.push(line, "");
        return;
      }
      String data = idSplit[4];
      TD1.push(line, data);
    }
    if(cmd.equals("ISL"))
      TD1.insertLine(line+1);
    if(cmd.equals("RMLN"))
      TD1.removeLine(line);
  }
}

void keyPressed() {
  if(stage == 1) TD1.write();
  if(newFileName.isOn) newFileName.write();
}

void dispError() {
  filter(BLUR, 1);
  textAlign(CENTER);
  textFont(bigFont);
  fill(200, 200, 255);
  text("EchoNet is down", width/2, height/2);
  textFont(regFont);
  textAlign(LEFT);
  String c = round(random(1000))%2 + "";
  if(random(100) > 90)
    TD1.data.add("");
  if(random(100) > 80)
    c = " ";
  TD1.data.set(TD1.data.size()-1, TD1.data.get(TD1.data.size()-1) + c);
}

void sendCommand(String s) {
  rNode.write("~" + id + "`" + s);
}

void textSpecial(String s, int x, int y) {
  char[] arr = s.toCharArray();
  for(int i = 0; i < arr.length; i++)
    text(arr[i], x + i*charSpacing, y);
}

class DahrmaText {
  String info = "";
  int x;
  int y;
  int w;
  int h;
  boolean isOn = false;
 
  public DahrmaText(int x0, int y0, int w0, int h0) {
    x = x0;
    y = y0;
    w = w0;
    h = h0;
    info = "";
  }
 
  void setOn(boolean b) {
    isOn = b;
    if(b) { filter(BLUR, 2); filter(BLUR, 1); }
  }
 
  void write() {
    if(key != CODED && keyCode != BACKSPACE && keyCode != ENTER)
      info += key;
    if(keyCode == BACKSPACE) {
      if(info.length() > 1)
        info = info.substring(0, info.length()-1);
      else
        info = "";
    }
  }
 
  void update() {
    fill(0);
    rect(x, y, w, h);
    fill(200, 200, 255);
    textAlign(CENTER);
    text(info, x + w/2, y + h/2);
  }
}

class TextEditor {
  int x;
  int y;
  int w;
  int h;
  ArrayList<String> data;
  int row = 0;
  int col = 0;
  int targetCol = 0;
  boolean hasFocus = false;
  char lastKeyPressed;
 
  public TextEditor() {
    data = new ArrayList<String>();
    x = 0;
    y = 0;
    w = width;
    h = height;
  }
 
  public TextEditor(int x0, int y0, int w0, int h0) {
    data = new ArrayList<String>();
    data.add("");
    x = x0;
    y = y0;
    w = w0;
    h = h0;
  }
 
  public void update() {
    watchCursor();
    if(mousePressed)
        hasFocus = (mouseX > x && mouseY > y && mouseX < x + w && mouseY < y + h);
    drawText();
  }
 
  public void watchCursor() {
    if(row > data.size()-1)
      row = data.size()-1;
    if(col > data.get(row).length())
      col = data.get(row).length();
  }
 
  public void write() {
    watchCursor();
    ArrayList<String> cmdOut = new ArrayList<String>();
    {
      if(key != CODED && keyCode != BACKSPACE && keyCode != ENTER) {
        data.set(row, insertAt(data.get(row), key, col));
        col++;
        targetCol = col;
        sendCommand("PUSH`" + row + "`" + targetStream + "`" + data.get(row));
      }
      switch(keyCode) {
        case BACKSPACE:
          if(col != 0) {
            data.set(row, removeFrom(data.get(row), col));
            col--;
            sendCommand("PUSH`" + row + "`" + targetStream + "`" + data.get(row));
          } else {
            if(row != 0) {
              data.set(row-1, data.get(row-1) + data.get(row));
              int n = data.get(row).length();
              data.remove(row);
              row--;
              col = data.get(row).length()-n;
              sendCommand("RMLN`" + (row+1) + "`" + targetStream);
              sendCommand("PUSH`" + row + "`" + targetStream + "`" + data.get(row));
            }
          }
          targetCol = col;
          break;
        case LEFT:
          if(col > 0)
            col--;
          targetCol = col;
          break;
        case RIGHT:
          if(col < data.get(row).length())
            col++;
          targetCol = col;
          break;
        case UP:
          if(row > 0) {
            row--;
            col = min(targetCol, data.get(row).length());
          }
          break;
        case DOWN:
          if(row < data.size()-1) {
            row++;
            col = min(targetCol, data.get(row).length());
          }
          break;
        case ENTER:
          data.add(row+1, data.get(row).substring(col));
          data.set(row, data.get(row).substring(0, col));
          row++;
          col = 0;
          targetCol = col;
          if(squishCommands) {
            sendCommand("ISL`" + (row-1) + "`" + targetStream);
            sendCommand("PUSH`" + row + "`" + targetStream + "`" + data.get(row));
            sendCommand("PUSH`" + (row-1) + "`" + targetStream + "`" + data.get(row-1));
          } else {
            sendCommand("ISL`" + (row-1) + "`" + targetStream);
            String pushOut = "";
            for(int i = row-1; i < data.size(); i++) {
              pushOut += "~" + id + "`PUSH`" + i + "`" + targetStream + "`" + data.get(i);
            }
            rNode.write(pushOut);
          }
          break;
      }
    }
    for(String s : cmdOut)
      sendCommand(s);
  }
 
  public void removeLine(int i) {
    data.remove(i);
  }
 
  public void push(int i, String s) {
    data.set(i, s);
  }
 
  public void insertLine(int i) {
    data.add(i, "");
    if(i < row+2)
      row++;
  }
 
  public void drawText() {
    noFill();
    stroke(200, 200, 255);
    rect(x, y, w, h);
    fill(200, 200, 255);
    line(x + (col+1)*charSpacing, y + rowSpacing*row, x + (col+1)*charSpacing, y + rowSpacing*(row+1));
    for(int i = 0; i < data.size(); i++)
      textSpecial(data.get(i), x+charSpacing, y + (i+1)*rowSpacing);
  }
}

public String removeLast(String s) {
  String x = "";
  if(s.length() > 0)
    x = s.substring(0, s.length()-1);
  return x;
}

public String removeFrom(String s, int k) {
  String x = "";
  x = s.substring(0, k-1) + "" + s.substring(k, s.length()) + "";
  return x;
}

public String insertAt(String s, char c, int k) {
  return s.substring(0, k) + c + s.substring(k, s.length());
}

class Button {
  boolean toggle = true;
  boolean wasMousePressed = false;
  boolean isOn = false;
  String text = "";
  float x0;
  float y0;
  float x1;
  float y1;
  public Button(float xC, float yC, float xS, float yS, boolean t) {
    x0 = xC;
    y0 = yC;
    x1 = xC + xS;
    y1 = yC + yS;
    toggle = t;
  }
  public Button(float xC, float yC, float xS, float yS, boolean t, String txt) {
    x0 = xC;
    y0 = yC;
    x1 = xC + xS;
    y1 = yC + yS;
    toggle = t;
    text = txt;
  }
  public void update() {
    stroke(190, 220, 255);
    if(toggle && mouseX>x0 && mouseY>y0 && mouseX<x1 && mouseY<y1 && mousePressed && !wasMousePressed) {
      isOn = !isOn;
    }
    if(toggle && !(mouseX>x0 && mouseY>y0 && mouseX<x1 && mouseY<y1) && mousePressed)
      isOn = false;
    if(!toggle)
      isOn = false;
    if(!toggle && mouseX>x0 && mouseY>y0 && mouseX<x1 && mouseY<y1 && !wasMousePressed)
      if(mousePressed && !pMousePressed)
        isOn = true;
      else
        isOn = false;
   
    wasMousePressed = mousePressed;
    if(isOn)
      fill(200, 225, 255);
    else
      fill(10, 12, 14);
    rect(x0, y0, x1-x0, y1-y0);
    if(isOn)
      fill(0);
    else
      fill(255);
    textAlign(CENTER, CENTER);
    text(text, (x0 + x1)/2.0f, (y0 + y1)/2.0f);
    textAlign(LEFT);
    fill(255);
    noFill();
  }
}

class ScrollList {
  ArrayList<String> items = new ArrayList<String>();
  int x;
  int y;
  int w;
  int h;
  int scrollPos = 0;
  PGraphics tab;
  int stickMouseY = 0;
  int origPos = scrollPos;
  int POI = -1;
  boolean wasUp = false;
  boolean wasDown = false;
 
  public ScrollList(int a, int b, int c, int d, ArrayList<String> data) {
    x = a;
    y = b;
    w = c;
    h = d;
    tab = createGraphics(w, h);
    tab.textFont(regFont);
    items = data;
  }
 
  public void setItems(ArrayList<String> data) {
    items = data;
  }
 
  public void update() {
    if(!mousePressed) {
      stickMouseY = mouseY;
      origPos = scrollPos;
    }
    scrollPos = int(origPos + (mouseY - stickMouseY)*0.5f);
    if(scrollPos > 0)
      scrollPos = 0;
    if(scrollPos < -(items.size()-2)*rowSpacing*2)
      scrollPos = -(items.size()-2)*rowSpacing*2;
    if(mousePressed && mouseX > x && mouseY > y && mouseX < x + w && mouseY < y + h && pmouseY == mouseY) {
      int k = floor(float((mouseY - y - scrollPos))/float(rowSpacing*2));
      if(k < items.size())
        POI = k;
    }
    if(keyPressed && keyCode == UP && !wasUp)
      if(POI > 0)
        POI--;
    if(keyPressed && keyCode == DOWN && !wasDown)
      if(POI < items.size()-1)
        POI++;
   
    if(keyPressed && keyCode == UP) wasUp = true; else wasUp = false;
    if(keyPressed && keyCode == DOWN) wasDown = true; else wasDown = false;
    tab.beginDraw();
    tab.fill(15, 15, 20, 100);
    tab.stroke(200, 200, 255);
    tab.rect(0, 0, w-1, h-1);
    tab.fill(200, 200, 255);
    tab.textAlign(CENTER);
    tab.stroke(200, 200, 255, 100);
    for(int i = -1; i < items.size(); i++) {
      if(i >= 0) tab.text(items.get(i), w/2, (i+1)*rowSpacing*2 + scrollPos - 8);
      tab.line(0, (i+1)*rowSpacing*2+rowSpacing*0.5 + scrollPos - 8, w, (i+1)*rowSpacing*2+rowSpacing*0.5 + scrollPos - 8);
    }
    tab.fill(200, 200, 255);
    tab.rect(0, POI*rowSpacing*2 + scrollPos, w, rowSpacing*2);
    tab.fill(7, 7, 10);
    if(POI >= 0) tab.text(items.get(POI), w/2, (POI+1)*rowSpacing*2 + scrollPos - 8);
    tab.endDraw();
    image(tab, x, y);
  }
 
  public String getSelected() {
    return items.get(POI);
  }
}