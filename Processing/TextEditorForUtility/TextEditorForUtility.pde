///////////////////////////////////////////////////////////////////////////
//___________              __ ___________    .___.__  __                 //
//\__    ___/___ ___  ____/  |\_   _____/  __| _/|__|/  |_  ___________  //
//  |    |_/ __ \\  \/  /\   __\    __)_  / __ | |  \   __\/  _ \_  __ \ //
//  |    |\  ___/ >    <  |  | |        \/ /_/ | |  ||  | (  <_> )  | \/ //
//  |____| \___  >__/\_ \ |__|/_______  /\____ | |__||__|  \____/|__|    //
//             \/      \/             \/      \/                         //
//@author Adam Lastowka                                                  //
///////////////////////////////////////////////////////////////////////////

//EXAMPLE USAGE:
TextEditor t = new TextEditor(10, 10, 800, 800, "");

void setup() {
  size(900, 800);
  t.radius = 0;
  t.syntax_highlight = true;
}

void draw() {
  t.update();
  t.display();
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


int cursorMode125910251 = ARROW;

import java.awt.HeadlessException;
import java.awt.Toolkit;
import java.awt.datatransfer.*;
import java.io.IOException;

class TextEditor {
  float px;
  float py;
  float pw;
  float ph;
  color border_color = color(255, 255, 255, 255);
  color fill_color = color(0, 0, 0, 255);
  color highlight_color = color(255, 100);
  int cursorX = 0;
  int cursorTabsX = 0;
  int cursorY = 0;
  int selectX = 0;
  int selectTabsX = 0;
  int selectY = 0;
  int scrollX = 0;
  int scrollY = 0;
  float scrollBarF = 0.f;
  float scrollBarY = 0.f;
  float scrollBarXF = 0.f;
  float scrollBarX = 0.f;
  int scrollBarHeight = 35;
  int scrollBarWidth = 25;
  boolean draggingScrollBar = false;
  boolean draggingScrollBarX = false;
  boolean showScrollBarX = false;
  boolean syntax_highlight = false;
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
  int text_size = 16;
  int offset = 10;
  float line_spacing = 1.2f;
  int spaceForLetters = 0;
  boolean pasting = false;
  boolean shiftOn = false;
  boolean hasFocus = false;
  int ticksPassed = 0;
  int ticksPassedSinceCursorUsed = 1;
  int cursorBlinkRate = 70;
  int scanIndex = 0;
  float radius = 0.f;
  PFont text_font;
  color modifier_color = color(60, 90, 255);
  color string_color = color(180, 60, 255);
  color loop_conditional_color = color(50, 150, 50);
  color object_color = color(255, 127, 39);
  color type_color = object_color;
  color variable_color = color(250, 255, 0);
  color function_color = color(130, 150, 255);
  color operator_color = /*color(200, 100, 100);*/ border_color;
  color comment_color = color(100, 100, 100);
  boolean modify_cursor = true;
  
  public TextEditor(float x, float y, float w, float h, String startingText) {
    px = x;
    py = y;
    pw = w;
    ph = h;
    String[] tmp = startingText.split("\n");
    for(String s : tmp)
      data.add(s);
    viewLines = int(ph/(float(text_size)*line_spacing)-0.99f);
    text_font = createFont("DialogInput.plain", text_size);
  }
  public void updateKeyPress() {
    if(hasFocus) {
      if(keyPressed) {
        inputKeys.add(int(key));
        inputCodes.add(int(keyCode));
        inputCoded.add(key==CODED);
      }
      if(key == CODED && keyCode == SHIFT) shiftOn = true;
      if(key != CODED) updateFocusScroll();
    }
  }
  public void updateKeyRelease() {
    if(hasFocus)
      if(key == CODED && keyCode == SHIFT) shiftOn = false;
  }
  public void updateMouseWheel(float delta_scroll) {
    if(hasFocus) {
      scrollY = min(max(0, data.size() - viewLines), max(0, scrollY + int(delta_scroll)));
      updateViewScroll();
    }
  }
  public void updateMousePress() {
    if(mouseX  > px && mouseX < px + pw && mouseY > py && mouseY < py + ph) {
      hasFocus = true;
    } else {
      hasFocus = false;
    }
    if(hasFocus && !(mouseX > px + pw - scrollBarWidth) && !(mouseY > py + ph - scrollBarHeight) && !draggingScrollBar && !draggingScrollBarX) {
      ticksPassedSinceCursorUsed = 0;
      cursorY = cursorYToDataY(mouseY + viewScrollY);
      cursorX = cursorXToDataX(mouseX + viewScrollX, cursorY);
      selected = false;
    }
  }
  public void updateMouseDragged() {
    if(hasFocus && !(mouseX > px + pw - scrollBarWidth) && !(mouseY > py + ph - scrollBarHeight) && !draggingScrollBar && !draggingScrollBarX) {
      selectY = cursorYToDataY(mouseY + viewScrollY);
      selectX = cursorXToDataX(mouseX + viewScrollX, selectY);
      selected = true;
    }
  }
  public void display() {
    textFont(text_font);
    setDimensions(px, py, pw, ph);
    showScrollBarX = getMaxLineLengthTabToSpace() > lettersThatFitInto(pw-scrollBarWidth-1);
    if(data.size() > viewLines)
      spaceForLetters = lettersThatFitInto(pw - scrollBarWidth - 1);
    else
      spaceForLetters = lettersThatFitInto(pw - 1);
    
    cursorTabsX = tabToSpace(data.get(cursorY).substring(0, cursorX)).length();
    if(selected) selectTabsX = tabToSpace(data.get(selectY).substring(0, selectX)).length();
    
    if(showScrollBarX)
      viewLines = int((ph - scrollBarWidth)/(float(text_size)*line_spacing)-0.99f);
    else
      viewLines = int(ph/(float(text_size)*line_spacing)-0.99f);
    if(mouseX > px && mouseX < px + pw && mouseY > py && mouseY < py + ph && !draggingScrollBar && !draggingScrollBarX && cursorMode125910251 != HAND)
      cursorMode125910251 = TEXT;
    if((mouseX < px + pw && mouseX > px + pw - scrollBarWidth && mouseY > scrollBarY && mouseY < py + scrollBarY + scrollBarHeight || draggingScrollBar) && data.size() > viewLines)
      cursorMode125910251 = HAND;
    if((!pmousePressed && mouseX > px + scrollBarX && mouseX < px + scrollBarX + scrollBarHeight && mouseY > py + ph - scrollBarWidth && mouseY < py + ph || draggingScrollBarX) && showScrollBarX)
      cursorMode125910251 = HAND;
    if((mouseX < px + pw && mouseX > px + pw - scrollBarWidth && mouseY > py + ph - scrollBarWidth & mouseY < py + ph) && showScrollBarX && data.size() > viewLines)
      cursor(HAND);
    fill(fill_color);
    stroke(border_color);
    rect(px, py, pw, ph, radius);
    if(data.size() > viewLines) {
      if(showScrollBarX)
        rect(px + pw - scrollBarWidth, py, scrollBarWidth, ph - scrollBarWidth, radius);
      else
        rect(px + pw - scrollBarWidth, py, scrollBarWidth, ph, radius);
      if(!draggingScrollBar)
        fill(fill_color);
      else
        fill(red(border_color), green(border_color), blue(border_color), 100);
      rect(px + pw - scrollBarWidth, py + scrollBarY, scrollBarWidth, scrollBarHeight, radius);
    }
    fill(fill_color);
    stroke(border_color);
    if(showScrollBarX) {
      if(data.size() > viewLines)
        rect(px, py + ph - scrollBarWidth, pw - scrollBarWidth, scrollBarWidth, radius);
      else
        rect(px, py + ph - scrollBarWidth, pw, scrollBarWidth, radius);
      if(!draggingScrollBarX)
        fill(fill_color);
      else
        fill(red(border_color), green(border_color), blue(border_color), 100);
      rect(px + scrollBarX, py + ph - scrollBarWidth, scrollBarHeight, scrollBarWidth, radius);
    }
    fill(fill_color);
    stroke(border_color);
    if(showScrollBarX && data.size() > viewLines) {
      if(draggingScrollBar && draggingScrollBarX)
        fill(red(border_color), green(border_color), blue(border_color), 100);
      rect(px + pw - scrollBarWidth, py + ph - scrollBarWidth, scrollBarWidth, scrollBarWidth, radius);
    }
    
    fill(border_color);
    textSizeSpecial(text_size);
    textAlign(LEFT, TOP);
    int i9 = 0;
    if(showScrollBarX)
      i9 = int(scrollBarWidth/text_size*line_spacing);
    for(int i = scrollY; i < min(data.size(), scrollY + viewLines); i++) {
      if(data.size() > viewLines)
        textSpecialSyntax(i, tabToSpace(data.get(i)).substring(min(scrollX, tabToSpace(data.get(i)).length()), min(tabToSpace(data.get(i)).length(), lettersThatFitInto(pw - scrollBarWidth + viewScrollX))), px + offset, py + i*text_size*line_spacing + offset - viewScrollY);
      else
        textSpecialSyntax(i, tabToSpace(data.get(i)).substring(min(scrollX, tabToSpace(data.get(i)).length()), min(tabToSpace(data.get(i)).length(), lettersThatFitInto(pw + viewScrollX))), px + offset, py + i*text_size*line_spacing + offset - viewScrollY);
    }
    float cursorPosX = textWidthSpecial(tabToSpace(data.get(cursorY).substring(0, cursorX)));
    if(hasFocus && !((cursorY > scrollY + viewLines - 1)||(cursorY < scrollY)) && cursorTabsX >= scrollX && cursorTabsX < scrollX + lettersThatFitInto(pw - scrollBarWidth - 1) && (ticksPassedSinceCursorUsed % cursorBlinkRate < cursorBlinkRate / 2.f) && !selected)
      line(px + cursorPosX + offset - viewScrollX, py + cursorY*text_size*line_spacing + offset - viewScrollY, px + cursorPosX + offset - viewScrollX, py + (cursorY + 1)*text_size*line_spacing + offset - viewScrollY);
    
    fill(highlight_color);
    noStroke();
    if(selected) {
      int i1 = 0;
      int i2 = 0;
      if(data.get(cursorY).length() == 0 && scrollX == 0)
        i1 = text_size;
      if(data.get(selectY).length() == 0 && scrollX == 0)
        i2 = text_size;
      if(selectY < cursorY) {
        if(!(cursorY > scrollY + viewLines - 1) && !(cursorY < scrollY))
          rectSpecial(px + offset, py + cursorY*text_size*line_spacing + offset - viewScrollY, max(0, textWidthSpecial(tabToSpace(data.get(cursorY).substring(0, cursorX))) + i1 - viewScrollX), text_size*line_spacing);
        if(!(selectY < scrollY) && !(selectY > scrollY + viewLines - 1))
          rectSpecial(px + offset + max(0, textWidthSpecial(tabToSpace(data.get(selectY).substring(0, selectX))) - viewScrollX), py + selectY*text_size*line_spacing + offset - viewScrollY, max(0, textWidthSpecial(tabToSpace(data.get(selectY).substring(selectX, data.get(selectY).length()))) + i2 - (scrollX > selectTabsX ? max(0, (scrollX - selectTabsX)*TXS_SIZE*TXS_SPACING) : 0)), text_size*line_spacing);
      } else if(selectY > cursorY) {
        if(!(cursorY < scrollY) && !(cursorY > scrollY + viewLines-1))
          rectSpecial(px + offset + max(0, textWidthSpecial(tabToSpace(data.get(cursorY).substring(0, cursorX))) - viewScrollX), py + cursorY*text_size*line_spacing + offset - viewScrollY, max(0, textWidthSpecial(tabToSpace(data.get(cursorY).substring(cursorX, data.get(cursorY).length()))) + i1 - (scrollX > cursorTabsX ? max(0, (scrollX - cursorTabsX)*TXS_SIZE*TXS_SPACING) : 0)), text_size*line_spacing);
        if(!(selectY > scrollY + viewLines - 1) && !(selectY < scrollY))
          rectSpecial(px + offset, py + selectY*text_size*line_spacing + offset - viewScrollY, max(0, textWidthSpecial(tabToSpace(data.get(selectY).substring(0, selectX))) + i2 - viewScrollX), text_size*line_spacing);
      } else {
        int lowX = min(cursorX, selectX);
        int hiiX = max(cursorX, selectX);
        int lowTabsX = min(cursorTabsX, selectTabsX);
        int hiiTabsX = max(cursorTabsX, selectTabsX);
        rectSpecial(px + offset + textWidthSpecial(tabToSpace(data.get(cursorY).substring(0, lowX))) - min(viewScrollX, lowTabsX*TXS_SIZE*TXS_SPACING), py + cursorY*text_size*line_spacing + offset - viewScrollY, max(0, textWidthSpecial(tabToSpace(data.get(cursorY).substring(lowX, hiiX))) - (scrollX > lowTabsX ? max(0, (scrollX - lowTabsX)*TXS_SIZE*TXS_SPACING) : 0)), text_size*line_spacing);
      }
      int lowY = min(cursorY, selectY);
      int hiiY = max(cursorY, selectY);
      for(int i = max(scrollY, lowY + 1); i < min(scrollY + viewLines, hiiY); i++) {
        int i3 = 0;
        if(data.get(i).length() == 0)
          i3 = text_size;
        rectSpecial(px + offset, py + i*text_size*line_spacing + offset - viewScrollY, max(0, textWidthSpecial(tabToSpace(data.get(i))) + i3 - viewScrollX), text_size*line_spacing);
      }
    }
    if(modify_cursor) cursor(cursorMode125910251);
  }
  public void update() {
    cursorMode125910251 = ARROW;
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
    if(mousePressed && ticksPassed%2 == 0 && !draggingScrollBar && !draggingScrollBarX)
      updateFocusScroll();
    
    //println(objectNames);
    
    for(int i = 0; i < 10; i++) {
      if(scanIndex >= data.size()) {
        scanIndex = -1;
        objectNames.clear();
        functionNames.clear();
        objectNames = new ArrayList<String>(tempObjectNames);
        functionNames = new ArrayList<String>(tempFunctionNames);
        tempObjectNames.clear();
        tempFunctionNames.clear();
        tempObjectNames.add("String");
        tempObjectNames.add("ArrayList");
        tempObjectNames.add("Integer");
        tempObjectNames.add("Boolean");
        tempObjectNames.add("Float");
        tempObjectNames.add("Double");
        tempObjectNames.add("Char");
        
        tempFunctionNames.add("add");
        tempFunctionNames.add("get");
        tempFunctionNames.add("split");
        tempFunctionNames.add("equals");
        tempFunctionNames.add("size");
        tempFunctionNames.add("length");
        tempFunctionNames.add("round");
        tempFunctionNames.add("substring");
        tempFunctionNames.add("min");
        tempFunctionNames.add("max");
        tempFunctionNames.add("clear");
        tempFunctionNames.add("floor");
        tempFunctionNames.add("append");
        tempFunctionNames.add("contains");
      } else {
        String q = data.get(scanIndex);
        String[] q2 = q.split(" ");
        String prevString = "";
        boolean foundFunction = false;
        for(String s2 : q2) {
          String[] starr = s2.split("\\(");
          String s = new String(s2.toCharArray());
          if(starr.length > 1)
            s = starr[0];
          if(prevString.equals("class"))
            tempObjectNames.add(s);
          
          boolean prevIs = false;
          for(String r : objectNames) {
            if(prevString.equals(r))
              prevIs = true;
          }
          prevIs |= prevString.equals("int") || prevString.equals("float") || prevString.equals("double") || prevString.equals("char") || prevString.equals("boolean") || prevString.equals("void");
          
          if(!foundFunction && prevIs && !data.get(scanIndex).contains(";") && !s.equals("{")) {
            foundFunction = true;
            //tempFunctionNames.add(s);
          }
          
          //Syntax highlighting for variable names, unused.
          //It's fully implemented (well, sort of. It has a lot of very serious bugs.), but I'm not using it, it's a bit much for highlighting.
          /*
          if(prevIs && !s.equals("{"))
            variableNames.add(s);
          */
          prevString = s;
        }
      }
      scanIndex++;
    }
    
    pmousePressed = mousePressed;
    ticksPassed++;
  }
  ArrayList<String> tempObjectNames = new ArrayList<String>();
  ArrayList<String> tempFunctionNames = new ArrayList<String>();
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
      int distance = int(abs(mouseX + viewScrollX - (textWidthSpecial(tabToSpace(data.get(y).substring(0, i))) + px + offset)));
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
            scrollBarF = map(scrollBarY, 0.f, ph - scrollBarHeight - scrollBarWidth, 0.f, 1.f);
          } else {
            scrollBarY = max(0.f, min(scrollBarY, ph - scrollBarHeight));
            scrollBarF = map(scrollBarY, 0.f, ph - scrollBarHeight, 0.f, 1.f);
          }
          scrollY = round(scrollBarF*float(data.size() - viewLines));
        } else
          if(!pmousePressed && mouseX < px + pw && mouseX > px + pw - scrollBarWidth && mouseY > scrollBarY && mouseY < py + scrollBarY + scrollBarHeight)
            draggingScrollBar = true;
      } else {
        draggingScrollBar = false;
      }
      if(!draggingScrollBar && pscrollY != scrollY) {
        scrollBarF = float(scrollY)/float(data.size() - viewLines);
        if(showScrollBarX)
          scrollBarY = map(scrollBarF, 0.f, 1.f, 0.f, ph-scrollBarHeight-scrollBarWidth);
        else
          scrollBarY = map(scrollBarF, 0.f, 1.f, 0.f, ph-scrollBarHeight);
      }
    }
    if(showScrollBarX) {
      if(mousePressed) {
        if(draggingScrollBarX) {
          scrollBarX = mouseX - px - scrollBarHeight/2;
          if(data.size() > viewLines) {
            scrollBarX = max(0.f, min(scrollBarX, pw - scrollBarHeight - scrollBarWidth));
            scrollBarXF = map(scrollBarX, 0.f, pw - scrollBarHeight - scrollBarWidth, 0.f, 1.f);
          } else {
            scrollBarX = max(0.f, min(scrollBarX, pw - scrollBarHeight));
            scrollBarXF = map(scrollBarX, 0.f, pw - scrollBarHeight, 0.f, 1.f);
          }
          viewScrollX = int(round((scrollBarXF * float(getMaxLineLengthTabToSpace() - lettersThatFitInto(pw - scrollBarWidth - 1))*TXS_SIZE*TXS_SPACING)/(TXS_SIZE*TXS_SPACING))*TXS_SIZE*TXS_SPACING);
          scrollX = round((scrollBarXF * float(getMaxLineLengthTabToSpace() - lettersThatFitInto(pw - scrollBarWidth - 1))*TXS_SIZE*TXS_SPACING)/(TXS_SIZE*TXS_SPACING));
        } else
          if(!pmousePressed && mouseX > px + scrollBarX && mouseX < px + scrollBarX + scrollBarHeight && mouseY > py + ph - scrollBarWidth && mouseY < py + ph)
            draggingScrollBarX = true;
      } else {
        draggingScrollBarX = false;
      }
    }
    if(mousePressed && !pmousePressed && mouseX > px + pw - scrollBarWidth && mouseY > py + ph - scrollBarWidth && mouseX < px + pw && mouseY < py + ph && data.size() > viewLines && showScrollBarX) {
      draggingScrollBar = true;
      draggingScrollBarX = true;
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
    if(inputKeys.size() == 0)
      ticksPassedSinceCursorUsed++;
    else
      ticksPassedSinceCursorUsed = 1;
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
      //println(inputCoded.get(i) + " " + inputCodes.get(i) + " " + inputKeys.get(i));
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
  int getMaxLineLength() {
    int maxLength = 0;
    for(String s : data)
      if(s.length() > maxLength)
        maxLength = s.length();
    return maxLength;
  }
  int getMaxLineLengthTabToSpace() {
    int maxLength = 0;
    for(String s : data)
      if(tabToSpace(s).length() > maxLength)
        maxLength = tabToSpace(s).length();
    return maxLength;
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
  float TXS_SPACING = .6f;
  void textSpecial(String s, float x, float y) {
    float currentPos = 0;
    for(int i = 0; i < s.length(); i++) {
      text(s.charAt(i), x + i*TXS_SIZE*TXS_SPACING, y);
    }
  }
  void textExtraSpecial(int startingIndex, String s, float x, float y) {
    //println(spaceForLetters + " " + startingIndex);
    if(startingIndex + s.length() - scrollX < 0 || startingIndex - scrollX > spaceForLetters) return;
    if(startingIndex + s.length() - scrollX < spaceForLetters && startingIndex - scrollX > 0) {
      textSpecial(s, x, y);
      return;
    }
    float currentPos = 0;
    for(int i = 0; i < s.length(); i++) {
      float textXPos = x + i*TXS_SIZE*TXS_SPACING;
      if(startingIndex + i - scrollX < spaceForLetters)
        if(startingIndex + i - scrollX >= 0)
          text(s.charAt(i), textXPos, y);
    }
  }
  void textRegularSpecial(int dataIndex, String s, float x, float y) {
    s = tabToSpace(data.get(dataIndex));
    int q = 0;
    String[] arr = s.split(String.format(WITH_DELIMITER, "\\."));
    float textX = 0.f;
    for(int i = 0; i < arr.length; i++) {
      textExtraSpecial(q, arr[i], x + textX - viewScrollX, y);
      textX += arr[i].length()*TXS_SIZE*TXS_SPACING;
      q += arr[i].length();
    }
  }
  ArrayList<String> objectNames = new ArrayList<String>();
  ArrayList<String> variableNames = new ArrayList<String>();
  ArrayList<String> functionNames = new ArrayList<String>();
  void textSpecialSyntax(int dataIndex, String s, float x, float y) {
    s = tabToSpace(data.get(dataIndex));
    int q = 0;
    if(syntax_highlight) {
      String[] arr = quoteSpaceDotSplit(s);
      float textX = 0.f;
      boolean inComment = false;
      for(int i = 0; i < arr.length; i++) {
        fill(border_color);
        if(arr[i].equals("return") || arr[i].equals("null") || arr[i].equals("true") || arr[i].equals("false") || arr[i].equals("public") || arr[i].equals("static") || arr[i].equals("final") || arr[i].equals("void") || arr[i].equals("protected") || arr[i].equals("package") || arr[i].equals("import") || arr[i].equals("class") || arr[i].equals("new")) fill(modifier_color);
        if(arr[i].equals("boolean") || arr[i].equals("float") || arr[i].equals("double") || arr[i].equals("char") || arr[i].equals("int")) fill(type_color);
        for(String r : objectNames)
          if(arr[i].equals(r)) fill(object_color);
        for(String r : variableNames)
          if(arr[i].equals(r)) fill(variable_color);
        for(String r : functionNames)
          if(arr[i].equals(r)) fill(function_color);
        if(arr[i].equals("if") || arr[i].equals("for") || arr[i].equals("while") || arr[i].equals("else") || arr[i].equals("do")) fill(loop_conditional_color);
        if(arr[i].equals("=") || arr[i].equals("==") || arr[i].equals("+=") || arr[i].equals("-=")) fill(operator_color);
        if(arr[i].contains("\"")) fill(string_color);
        if(arr[i].equals("//") || arr[i].equals("#") || arr[i].equals("*")) inComment = true;
        if(inComment) fill(comment_color);
        textExtraSpecial(q, arr[i], x + textX - viewScrollX, y);
        textX += arr[i].length()*TXS_SIZE*TXS_SPACING;
        q += arr[i].length();
      }
    } else {
      textRegularSpecial(dataIndex, s, x, y);
    }
  }
  void textSizeSpecial(int s) {
    textSize(s);
    TXS_SIZE = s;
  }
  int textWidthSpecial(String s) {
    return int(s.length()*TXS_SIZE*TXS_SPACING);
  }
  int lettersThatFitInto(float space) {
    quoteSpaceDotSplit("\thoop hoop hoop! ArrayList<String>() = \"Hello world!\";");
    return floor(space/(TXS_SIZE*TXS_SPACING)-1);
  }
  void rectSpecial(float x, float y, float w, float h) {
    float maxXText = px + TXS_SPACING*TXS_SIZE*spaceForLetters + offset;
    if(x + w > maxXText) {
      rect(x, y, w - ((x + w) - (maxXText)), h);
    } else
      rect(x, y, w, h);
  }
  public String[] quoteSplit(String s) {
    ArrayList<String> outlist = new ArrayList<String>();
    StringBuilder strb = new StringBuilder(32);
    char[] c = s.toCharArray();
    boolean inQuotes = false;
    for(int i = 0; i < c.length; i++) {
      if(c[i] == '\"' && !inQuotes) {
        outlist.add(strb.toString());
        inQuotes = true;
        strb = new StringBuilder(32);
        strb.append(c[i]);
      } else if(c[i] == '\"' && inQuotes) {
        strb.append(c[i]);
        outlist.add(strb.toString());
        inQuotes = false;
        strb = new StringBuilder(32);
      } else
        strb.append(c[i]);
    }
    outlist.add(strb.toString());
    return outlist.toArray(new String[outlist.size()]);
  }
  static public final String WITH_DELIMITER = "((?<=%1$s)|(?=%1$s))";
  public String[] quoteSpaceDotSplit(String s) {
    String[] spoot = quoteSplit(s);
    ArrayList<String> outlist = new ArrayList<String>();
    for(int i = 0; i < spoot.length; i++) {
      if(spoot[i].contains("\"")) {
        outlist.add(spoot[i]);
      } else {
        String[] d = spoot[i].split(String.format(WITH_DELIMITER, " |<|>|\\.|[(]|[)]|\\[|\\]|//|#|;"));
        for(String k : d)
          outlist.add(k);
      }
    }
    return outlist.toArray(new String[outlist.size()]);
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
  public int containsNotInQuotes(String s, String regex) {
    String[] sArr = quoteSpaceDotSplit(s);
    int x = 0;
    for(String q : sArr) {
      if(q.contains(regex))
        return x;
      x += q.length();
    }
    return -1;
  }
}
