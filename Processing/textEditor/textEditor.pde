

TextEditor t = new TextEditor(30, 30, 200, 200, "Lorem ipsum dolor sit amet,\nconsectetur adipisicing elit,\nsed do eiusmod tempor incididunt ut\nlabore et dolore magna aliqua.\nUt enim ad minim veniam,\nquis nostrud exercitation ullamco laboris\nnisi ut aliquip ex ea commodo consequat.\nDuis aute irure dolor in reprehenderit\nin voluptate velit esse cillum dolore\neu fugiat nulla pariatur.\nExcepteur sint occaecat cupidatat non proident,\nsunt in culpa qui officia deserunt mollit anim\nid est laborum.");
PImage bkg;
void setup() {
  size(1920, 1080, P2D);
  smooth(4);
  if(frame != null)
    frame.setResizable(true);
  stroke(255);
  background(0);
  bkg = loadImage("bkg.png");
  bkg.filter(BLUR, 2);
  PFont font = createFont("DialogInput.plain", t.text_size);
  textFont(font);
  frameRate(60);
}
void draw() {
  background(200);
  //image(bkg, 0, 0);
  t.update();
  t.display();
  t.setDimensions(30, 30, width-60, height-60);
}

import java.awt.HeadlessException;
import java.awt.Toolkit;
import java.awt.datatransfer.*;
import java.io.IOException;

class TextEditor {
  float px;
  float py;
  float pw;
  float ph;
  color textColor = color(0, 0, 0, 255);
  color bkgColor = color(200, 200, 200, 255);
  color highlightColor = color(0, 0, 0, 100);
  int cursorX = 0;
  int cursorY = 0;
  int selectX = 0;
  int selectY = 0;
  int scrollY = 0;
  float scrollBarF = 0.f;
  float scrollBarY = 0.f;
  int scrollBarHeight = 35;
  int scrollBarWidth = 25;
  boolean draggingScrollBar = false;
  boolean showScrollBarX = false;
  int focusX = 0;
  int focusY = 0;
  int viewScrollY = 0;
  int viewScrollX = 0;
  int viewLines = 0;
  int pscrollY = 0;
  boolean pmousePressed = false;
  boolean selected = false;
  int targetCursorX = 0;
  ArrayList<String> data = new ArrayList<String>();
  ArrayList<Integer> inputKeys = new ArrayList<Integer>();
  ArrayList<Integer> inputCodes = new ArrayList<Integer>();
  ArrayList<Boolean> inputCoded = new ArrayList<Boolean>();
  int text_size = 25;
  int offset = 10;
  float line_spacing = 1.2f;
  boolean pasting = false;
  boolean shiftOn = false;
  int ticksPassed = 0;
  
  public TextEditor(float x, float y, float w, float h, String startingText) {
    px = x;
    py = y;
    pw = w;
    ph = h;
    String[] tmp = startingText.split("\n");
    for(String s : tmp)
      data.add(s);
    //cursor(TEXT);
    viewLines = int(ph/(float(text_size)*line_spacing)-0.99f);
  }
  public void updateKeyPress() {
    if(keyPressed) {
      inputKeys.add(int(key));
      inputCodes.add(int(keyCode));
      inputCoded.add(key==CODED);
    }
    if(key == CODED && keyCode == SHIFT) shiftOn = true;
    if(key != CODED) updateFocusScroll();
  }
  public void updateKeyRelease() {
    if(key == CODED && keyCode == SHIFT) shiftOn = false;
  }
  public void updateMouseWheel(float delta_scroll) {
    scrollY = min(max(0, data.size() - viewLines), max(0, scrollY + int(delta_scroll)));
    updateViewScroll();
  }
  public void updateMousePress() {
    if(!(mouseX + viewScrollX > px + pw - scrollBarWidth) && !draggingScrollBar) {
      cursorY = cursorYToDataY(mouseY + viewScrollY);
      cursorX = cursorXToDataX(mouseX + viewScrollX, cursorY);
      selected = false;
    }
  }
  public void updateMouseDragged() {
    if(!(mouseX + viewScrollX > px + pw - scrollBarWidth) && !draggingScrollBar) {
      selectY = cursorYToDataY(mouseY + viewScrollY);
      selectX = cursorXToDataX(mouseX + viewScrollX, selectY);
      selected = true;
    }
  }
  public void display() {
    viewLines = int(ph/(float(text_size)*line_spacing)-0.99f);
    if(mouseX + viewScrollX > px && mouseX + viewScrollX < px + pw && mouseY > py && mouseY < py + ph && !draggingScrollBar)
      cursor(TEXT);
    else
      cursor(ARROW);
    if(mouseX + viewScrollX < px + pw && mouseX + viewScrollX > px + pw - scrollBarWidth && mouseY > scrollBarY && mouseY < py + scrollBarY + scrollBarHeight || draggingScrollBar)
      cursor(HAND);
    fill(bkgColor);
    stroke(textColor);
    rect(px, py, pw, ph, 7);
    if(data.size() > viewLines) {
      if(showScrollBarX)
        rect(px + pw - scrollBarWidth, py, scrollBarWidth, ph - scrollBarWidth, 7);
      else
        rect(px + pw - scrollBarWidth, py, scrollBarWidth, ph, 7);
      if(!draggingScrollBar)
        fill(bkgColor);
      else
        fill(red(textColor), green(textColor), blue(textColor), 100);
      rect(px + pw - scrollBarWidth, py + scrollBarY, scrollBarWidth, scrollBarHeight, 7);
    }
    fill(textColor);
    textSize(text_size);
    textAlign(LEFT, TOP);
    for(int i = scrollY; i < min(data.size(), scrollY + viewLines); i++) {
      text(tabToSpace(data.get(i)), px + offset - viewScrollX, py + i*text_size*line_spacing + offset - viewScrollY);
    }
    float cursorPosX = textWidth(tabToSpace(data.get(cursorY).substring(0, cursorX)));
    if(!((cursorY > scrollY + viewLines - 1)||(cursorY < scrollY)))
      line(px + cursorPosX + offset - viewScrollX, py + cursorY*text_size*line_spacing + offset - viewScrollY, px + cursorPosX + offset - viewScrollX, py + (cursorY + 1)*text_size*line_spacing + offset - viewScrollY);
    
    fill(highlightColor);
    noStroke();
    if(selected) {
      int i1 = 0;
      int i2 = 0;
      if(data.get(cursorY).length() == 0)
        i1 = text_size;
      if(data.get(selectY).length() == 0)
        i2 = text_size;
      if(selectY < cursorY) {
        if(!(cursorY > scrollY + viewLines - 1) && !(cursorY < scrollY))
          rect(px + offset, py + cursorY*text_size*line_spacing + offset - viewScrollY, textWidth(tabToSpace(data.get(cursorY).substring(0, cursorX))) + i1, text_size*line_spacing);
        if(!(selectY < scrollY) && !(selectY > scrollY + viewLines - 1))
          rect(px + offset + textWidth(tabToSpace(data.get(selectY).substring(0, selectX))), py + selectY*text_size*line_spacing + offset - viewScrollY, textWidth(tabToSpace(data.get(selectY).substring(selectX, data.get(selectY).length()))) + i2, text_size*line_spacing);
      } else if(selectY > cursorY) {
        if(!(cursorY < scrollY) && !(cursorY > scrollY + viewLines-1))
          rect(px + offset + textWidth(tabToSpace(data.get(cursorY).substring(0, cursorX))), py + cursorY*text_size*line_spacing + offset - viewScrollY, textWidth(tabToSpace(data.get(cursorY).substring(cursorX, data.get(cursorY).length()))) + i1, text_size*line_spacing);
        if(!(selectY > scrollY + viewLines - 1) && !(selectY < scrollY))
          rect(px + offset, py + selectY*text_size*line_spacing + offset - viewScrollY, textWidth(tabToSpace(data.get(selectY).substring(0, selectX))) + i2, text_size*line_spacing);
      } else {
        int lowX = min(cursorX, selectX);
        int hiiX = max(cursorX, selectX);
        rect(px + offset + textWidth(tabToSpace(data.get(cursorY).substring(0, lowX))), py + cursorY*text_size*line_spacing + offset - viewScrollY, textWidth(tabToSpace(data.get(cursorY).substring(lowX, hiiX))), text_size*line_spacing);
      }
      int lowY = min(cursorY, selectY);
      int hiiY = max(cursorY, selectY);
      for(int i = max(scrollY, lowY + 1); i < min(scrollY + viewLines, hiiY); i++) {
        int i3 = 0;
        if(data.get(i).length() == 0)
          i3 = text_size;
        rect(px + offset, py + i*text_size*line_spacing + offset - viewScrollY, textWidth(tabToSpace(data.get(i))) + i3, text_size*line_spacing);
      }
    }
  }
  public void update() {
    if(mousePressed)
      updateMouseDragged();
    if(cursorX == selectX && cursorY == selectY)
      selected = false;
    if(!mousePressed)
      addUI();
    focusX = cursorX;
    focusY = cursorY;
    if(selected) {
      focusX = selectX;
      focusY = selectY;
    }
    scrollY = min(max(0, data.size() - viewLines), max(0, scrollY));
    updateScrollBar();
    updateViewScroll();
    if(mousePressed && ticksPassed%2 == 0 && !draggingScrollBar)
      updateFocusScroll();
    pmousePressed = mousePressed;
    ticksPassed++;
  }
  public void setDimensions(float x, float y, float w, float h) {
    px = x;
    py = y;
    pw = w;
    ph = h;
    viewLines = int(ph/(float(text_size)*line_spacing)-0.99f);
  }
  
  int cursorYToDataY(int y) {
    return min(scrollY + viewLines, max(0, min(data.size()-1, max(scrollY-1, int((y - offset - py)/(text_size*line_spacing))))));
  }
  int cursorXToDataX(int x, int y) {
    int minDist = 16384;
    int target = 0;
    for(int i = 0; i <= data.get(y).length(); i++) {
      int distance = int(abs(mouseX + viewScrollX - (textWidth(tabToSpace(data.get(y).substring(0, i))) + px + offset)));
      if(distance < minDist) {
        minDist = distance;
        target = i;
      }
    }
    return max(0, min(data.get(y).length(), target));
  }
  void updateScrollBar() {
    if(data.size() > viewLines) {
      if(mousePressed) {
        if(draggingScrollBar) {
          scrollBarY = mouseY - py - scrollBarHeight/2;
          if(showScrollBarX) {
            scrollBarY = max(0.f, min(scrollBarY, ph - scrollBarHeight - scrollBarWidth));
            scrollBarF = map(scrollBarY, 0.f, ph-scrollBarHeight-scrollBarWidth, 0.f, 1.f);
          } else {
            scrollBarY = max(0.f, min(scrollBarY, ph - scrollBarHeight));
            scrollBarF = map(scrollBarY, 0.f, ph-scrollBarHeight, 0.f, 1.f);
          }
          scrollY = int(scrollBarF*float(data.size() - viewLines));
        } else
          if(!pmousePressed && mouseX + viewScrollX < px + pw && mouseX + viewScrollX > px + pw - scrollBarWidth && mouseY > scrollBarY && mouseY < py + scrollBarY + scrollBarHeight)
            draggingScrollBar = true;
      } else
        draggingScrollBar = false;
      if(!draggingScrollBar && pscrollY != scrollY) {
        scrollBarF = float(scrollY)/float(data.size() - viewLines);
        if(showScrollBarX)
          scrollBarY = map(scrollBarF, 0.f, 1.f, 0.f, ph-scrollBarHeight-scrollBarWidth);
        else
          scrollBarY = map(scrollBarF, 0.f, 1.f, 0.f, ph-scrollBarHeight);
      }
    }
    pscrollY = scrollY;
  }
  void updateFocusScroll() {
    focusX = cursorX;
    focusY = cursorY;
    if(selected) {
      focusX = selectX;
      focusY = selectY;
    }
    if(focusY < scrollY)
      scrollY = focusY;
    if(focusY > scrollY + viewLines - 1)
      scrollY = max(0, focusY - viewLines + 1);
    updateViewScroll();
  }
  void updateViewScroll() {
    viewScrollY = int(scrollY*text_size*line_spacing);
  }
  void addUI() {
    for(int i = 0; i < inputKeys.size(); i++) {
      if(!isWriteable(inputCoded.get(i), inputKeys.get(i), inputCodes.get(i))) {
        if(selected && ((inputKeys.get(i) == 10 && inputCodes.get(i) == 10) || (inputKeys.get(i) == 8 && inputKeys.get(i) == 8) || (inputKeys.get(i) == 22 && inputCodes.get(i) == 86))) deleteSelected();
        if(inputKeys.get(i) == 65535) {
          if(inputCodes.get(i) == 39) {
            if(shiftOn) {
              if(!selected) {
                selected = true;
                selectX = cursorX;
                selectY = cursorY;
              }
              selectRight();
            } else
              cursorRight();
            updateFocusScroll();
          }
          if(inputCodes.get(i) == 37) {
            if(shiftOn) {
              if(!selected) {
                selected = true;
                selectX = cursorX;
                selectY = cursorY;
              }
              selectLeft();
            } else
              cursorLeft();
            updateFocusScroll();
          }
          if(inputCodes.get(i) == 38) {
            if(shiftOn) {
              if(!selected) {
                selected = true;
                selectX = cursorX;
                selectY = cursorY;
              }
              selectUp();
            } else
              cursorUp();
            updateFocusScroll();
          }
          if(inputCodes.get(i) == 40) {
            if(shiftOn) {
              if(!selected) {
                selected = true;
                selectX = cursorX;
                selectY = cursorY;
              }
              selectDown();
            } else
              cursorDown();
            updateFocusScroll();
          }
        }
        if(!selected && inputKeys.get(i) == 8 && inputCodes.get(i) == 8) {
          cursorBackspace();
        }
        if(inputKeys.get(i) == 10 && inputCodes.get(i) == 10) {
          cursorEnter();
          updateFocusScroll();
        }
        if(inputKeys.get(i) == 22 && inputCodes.get(i) == 86) {
          pasting = true;
          insertSTR(getClipboard());
          pasting = false;
        }
        if(inputCodes.get(i) == 67 && inputKeys.get(i) == 3) {
          setClipboard(getSelection());
        }
        if(selected && ((inputKeys.get(i) == 10 && inputCodes.get(i) == 10) || (inputKeys.get(i) == 8 && inputKeys.get(i) == 8) || (inputKeys.get(i) == 22 && inputCodes.get(i) == 86))) selected = false;
      } else {
        if(selected) {
          if(inputKeys.get(i) == '\t') {
            boolean b = shouldSwap();
            conformSelection();
            cursorX = 0;
            selectX = data.get(selectY).length();
            if(shiftOn) {
              for(int j = cursorY; j <= selectY; j++) {
                if(data.get(j).startsWith("\t"))
                  data.set(j, data.get(j).substring(1, data.get(j).length()));
              }
              selectX = data.get(selectY).length();
            } else {
              selectX++;
              for(int j = cursorY; j <= selectY; j++)
                data.set(j, '\t' + data.get(j));
            }
            if(b) swapSelection();
          } else {
            deleteSelected();
            selected = false;
          }
        }
        if((selected && inputKeys.get(i) != '\t') || !selected) {
          if(inputKeys.get(i) == 125 && inputCodes.get(i) == 93 && data.get(cursorY).length() > 0 && data.get(cursorY).charAt(cursorX-1) == '\t') {
            cursorBackspace();
          }
          data.set(cursorY, insertAt(data.get(cursorY), char(inputKeys.get(i)), cursorX));
          cursorX++;
          targetCursorX = cursorX;
        }
      }
      println(inputCoded.get(i) + " " + inputCodes.get(i) + " " + inputKeys.get(i));
    }
    inputKeys = new ArrayList<Integer>();
    inputCodes = new ArrayList<Integer>();
    inputCoded = new ArrayList<Boolean>();
  }
  String getSelection() {
    String out = "";
    if(cursorY == selectY && cursorX == selectX) return "";
    boolean b = shouldSwap();
    conformSelection();
    if(cursorY == selectY) {
      out = data.get(cursorY).substring(cursorX, selectX);
    } else {
      out = data.get(cursorY).substring(cursorX, data.get(cursorY).length()) + "\n";
      for(int i = cursorY + 1; i < selectY; i++)
        out += data.get(i) + "\n";
      out += data.get(selectY).substring(0, selectX);
    }
    if(b) swapSelection();
    return out;
  }
  void conformSelection() {
    if(selectY < cursorY || (selectY == cursorY && selectX < cursorX)) {
      int a = cursorX;
      int b = cursorY;
      cursorX = selectX;
      cursorY = selectY;
      selectX = a;
      selectY = b;
    }
  }
  boolean shouldSwap() {
    return selectY < cursorY || (selectY == cursorY && selectX < cursorX);
  }
  void swapSelection() {
    int a = cursorX;
    int b = cursorY;
    cursorX = selectX;
    cursorY = selectY;
    selectX = a;
    selectY = b;
  }
  void deleteSelected() {
    conformSelection();
    String at = "";
    if(selectY > cursorY) {
      at = data.get(selectY).substring(selectX, data.get(selectY).length());
      data.set(cursorY, data.get(cursorY).substring(0, cursorX));
      data.set(selectY, data.get(selectY).substring(selectX, data.get(selectY).length()));
      cursorX = data.get(cursorY).length();
    } else {
      data.set(cursorY, data.get(cursorY).substring(0, cursorX) +  data.get(cursorY).substring(selectX, data.get(cursorY).length()));
    }
    for(int i = selectY; i > cursorY; i--)
      removeLine(i);
    data.set(cursorY, data.get(cursorY) + at);
  }
  void insertSTR(String str) {
    String o = "";
    for(char c : str.toCharArray()) {
      if(c != '\n') {
        data.set(cursorY, insertAt(data.get(cursorY), c, cursorX));
        cursorX++;
      } else {
        cursorEnter();
      }
    }
    targetCursorX = cursorX;
  }
  void cursorBackspace() {
    if(cursorX > 0) {
      data.set(cursorY, removeFrom(data.get(cursorY), cursorX));
      cursorX--;
    } else {
      if(cursorY > 0) {
        cursorX = data.get(cursorY-1).length();
        data.set(cursorY-1, data.get(cursorY-1) + data.get(cursorY));
        cursorY--;
        removeLine(cursorY+1);
      }
    }
    targetCursorX = cursorX;
  }
  void cursorEnter() {
    int tabNum = countTabs(data.get(cursorY));
    if(data.get(cursorY).endsWith("{") && cursorX == data.get(cursorY).length())
      tabNum++;
    if(cursorX < tabNum)
      tabNum--;
    if(pasting)
      tabNum = 0;
    String tabInserts = "";
    for(int i = 0; i < tabNum; i++)
      tabInserts += '\t';
    insertLine(cursorY+1);
    data.set(cursorY+1, tabInserts + data.get(cursorY).substring(cursorX, data.get(cursorY).length()));
    data.set(cursorY, data.get(cursorY).substring(0, cursorX));
    cursorY++;
    cursorX = tabNum;
  }
  void cursorRight() {
    if(selected) {
      conformSelection();
      cursorX = selectX;
      cursorY = selectY;
    } else {
      if(cursorX < data.get(cursorY).length())
        cursorX++;
      else {
        if(cursorY < data.size()-1) {
          cursorY++;
          cursorX = 0;
        }
      }
    }
    targetCursorX = cursorX;
    selected = false;
  }
  void cursorLeft() {
    if(selected)
      conformSelection();
    else {
      if(cursorX >= 1)
        cursorX--;
      else {
        if(cursorY > 0) {
          cursorY--;
          cursorX = data.get(cursorY).length();
        }
      }
    }
    targetCursorX = cursorX;
    selected = false;
  }
  void cursorUp() {
    if(cursorY > 0)
      cursorY--;
    cursorX = min(targetCursorX, data.get(cursorY).length());
    selected = false;
  }
  void cursorDown() {
    if(cursorY < data.size()-1)
      cursorY++;
    cursorX = min(targetCursorX, data.get(cursorY).length());
    selected = false;
  }
  void selectRight() {
    if(selectX < data.get(selectY).length() - 1 || (selectY == data.size()-1 && selectX < data.get(selectY).length()))
      selectX++;
    else {
      if(selectY < data.size()-1) {
        selectY++;
        selectX = 0;
      }
    }
    targetCursorX = selectX;
  }
  void selectLeft() {
    if(selectX >= 1)
      selectX--;
    else {
      if(selectY > 0) {
        selectY--;
        selectX = data.get(selectY).length();
      }
    }
    targetCursorX = selectX;
  }
  void selectUp() {
    if(selectY > 0)
      selectY--;
    selectX = min(targetCursorX, data.get(selectY).length());
  }
  void selectDown() {
    if(selectY < data.size()-1)
      selectY++;
    selectX = min(targetCursorX, data.get(selectY).length());
  }
  void removeLine(int y) {
    data.remove(y);
  }
  void setLine(int y, String s) {
    data.set(y, s);
  }
  void insertLine(int y) {
    data.add(y, "");
  }
  
  public int countTabs(String s) {
    int out = 0;
    for(char c : s.toCharArray()) {
      if(c == '\t')
        out++;
      else
        break;
    }
    return out;
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
  public String insertAt(String s, String c, int k) {
    return s.substring(0, k) + c + s.substring(k, s.length());
  }
  public boolean isWriteable(boolean coded, int c, int cc) {
    return !(cc == 67 && c == 3) && !(c == 22 && cc == 86) && ((!coded && c != BACKSPACE && c != ENTER && !isInRangeInclusive(c, 16, 18) && !isInRangeInclusive(c, 37, 40)) || cc == 222 || cc == 53 || cc == 55 || cc == 57);
  }
  public boolean isInRangeInclusive(int x, int a, int b) {
    for(int i = a; i <= b; i++)
      if(x == i)
        return true;
    return false;
  }
  public String tabToSpace(String s) {
    String o = "";
    for(char c : s.toCharArray()) {
      if(c == '\t')
        o += "      ";
      else
        o += c;
    }
    return o;
  }
  int TXS_SIZE = 0;
  float TXS_SPACING = 1.5f;
  void textSpecial(String s, float x, float y) {
    float currentPos = 0;
    for(int i = 0; i < s.length(); i++) {
      text(s.charAt(i), x + i*TXS_SIZE*TXS_SPACING, y);
    }
  }
  void textSizeSpecial(int s) {
    textSize(s);
    TXS_SIZE = s;
  }
  public String getClipboard() {
    try {
      try {
      return (String)Toolkit.getDefaultToolkit().getSystemClipboard().getData(DataFlavor.stringFlavor);
      } catch(IOException ioe) {}
    } catch(UnsupportedFlavorException ufe) {}
    return "";
  }
  public void setClipboard(String s) {
    StringSelection stringSelection = new StringSelection(s);
    Clipboard clpbrd = Toolkit.getDefaultToolkit().getSystemClipboard();
    clpbrd.setContents(stringSelection, null);
  }
}
void mouseWheel(MouseEvent me) {
  t.updateMouseWheel(me.getCount());
}
void mouseDragged() {
  t.updateMouseDragged();
}
void mousePressed() {
  t.updateMousePress();
}
void keyPressed() {
  t.updateKeyPress();
}
void keyReleased() {
  t.updateKeyRelease();
}