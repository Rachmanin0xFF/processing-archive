
import java.net.*;
import java.io.*;
Organism g = getOrganism("http://en.wikipedia.org/wiki/Quercus_engelmannii");
Theme colorTheme = new Theme(color(255, 255), color(0, 255));
TextEditor t = new TextEditor(1280/2 + 10, 10, 1280/2 - 20, 710, "");
void setup() {
  size(1280, 720);
  background(colorTheme.fill_color);
  //frameRate(60);
  Organism g = getOrganism("http://en.wikipedia.org/w/index.php?search=syracuse&title=Special%3ASearch&go=Go");
  println(g.description);
  //text(g.description, 0, 100);
  t.set_theme(colorTheme);
  t.insertSTR(g.description);
  t.highlight_color = color(0, 100);
}

void draw() {
  background(colorTheme.fill_color);
  fill(0, 255);
  t.update();
  t.display();
}

Organism getOrganism(String url) {
  Organism output = new Organism();
  URL focus = null;
  try {
    focus = new URL(url);
  } catch(MalformedURLException murle) {
    println("Error! Malformed URL!");
  }
  ArrayList<String> pageData = new ArrayList<String>();
  ArrayList<String> pageSource = new ArrayList<String>();
  ArrayList<String> description = new ArrayList<String>();
  try {
    BufferedReader in = new BufferedReader(new InputStreamReader(focus.openStream()));
    String inputLine;
    boolean recording = false;
    boolean subrecording = false;
    boolean foundEnd = false;
    int i = 0;
    while ((inputLine = in.readLine()) != null) {
      if(inputLine.contains("<p class=\"mw-search-pager-bottom\">"))
        recording = false;
      if(recording) {
        if(!foundEnd) {
          String pgraphedited = "";
          char[] c = inputLine.toCharArray();
          for(int j = 0; j < c.length; j++) {
            if(c[j] == '<') {
              String s = inputLine.substring(j);
              if(s.startsWith("<p>")) {
                subrecording = true;
              }
              if(s.startsWith("</p>")) {
                subrecording = false;
                pgraphedited += "\n";
              }
            }
            if(subrecording)
              pgraphedited += c[j];
          }
          pgraphedited = editOutBrackets(editOutTags(pgraphedited));
          if(pgraphedited.startsWith("See also") || pgraphedited.startsWith("External links") || pgraphedited.startsWith("References")) {
            println("WOOOOOOOP");
            foundEnd = true;
            break;
          }
          String edited = editOutBrackets(editOutTags(inputLine));
          System.out.println(i + " " + inputLine);
          pageData.add(edited);
          pageSource.add(inputLine);
          if(pgraphedited.length() > 0)
            output.description += pgraphedited + "\n";
        }
      }
      if(inputLine.contains("<ul class=\"mw-search-results\">"))
        recording = true;
      i++;
    }
    in.close();
  } catch(IOException ioe) {}
  for(int i = 0; i < pageData.size(); i++) {
  }
  int timeSinceNewline = 0;
  for(int i = 0; i < output.description.length(); i++) {
    if(timeSinceNewline > 50 && output.description.charAt(i-1)==' ')
      output.description = output.description.substring(0, i) + "\n" + output.description.substring(i, output.description.length());
    if(output.description.charAt(i)=='\n')
      timeSinceNewline = 0;
    timeSinceNewline++;
  }
  output.description = output.description.substring(4, output.description.length());
  println("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
  return output;
}

String editOutTags(String s) {
  boolean recording = true;
  StringBuilder sb = new StringBuilder();
  for(char c : s.toCharArray()) {
    if(c=='<') recording = false;
    if(recording)
      sb.append(c);
    if(c=='>') recording = true;
  }
  return sb.toString();
}

String editOutBrackets(String s) {
  boolean recording = true;
  StringBuilder sb = new StringBuilder();
  for(char c : s.toCharArray()) {
    if(c=='[') recording = false;
    if(recording)
      sb.append(c);
    if(c==']') recording = true;
  }
  return sb.toString();
}

class Organism {
  String kingdom;
  ArrayList<String> unranked = new ArrayList<String>();
  String order;
  String family;
  String genus;
  String section;
  String species;
  String binomialName;
  String description;
  String commonName;
  int count = 0;
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
