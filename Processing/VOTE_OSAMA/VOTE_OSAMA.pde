PImage map;

float scale = 1.f;

void setup() {
  map = loadImage("Map_USA.bmp");
  size(1000, 800, P2D);
  frameRate(2147483647);
  background(255);
  loadData("2014_senate_election_results_accurate.csv");
  loadPollData("2014_senate_election_polls.csv");
  loadCoordinates("map_coordinates.csv");
  calculatePollingError();
  displayData();
  printAllInfo();
}

void draw() {}

//void mousePressed() { fillWith(new PVector(mouseX, mouseY), color(random(255), random(255), random(255))); print('o');}
void keyPressed() { saveFrame("VOTE_OSAMA " + year() + "-" + month() + "-" + day() + "-" + hour() + "-" + minute() + "-" + second() + "-" + millis() + ".png"); }

public void displayData() {
  println("");
  smooth(8);
  image(map, 0, 0, int(map.width*scale), int(map.height*scale));
  for(int i = 0; i < state_list.size(); i++) {
    println("Processing " + state_list.get(i).name + "...");
    for(int k = 0; k < state_list.get(i).coordinates.size(); k++) {
      
      color state_col = color(0, 0, 0, 255);
      
      float c = state_list.get(i).polling_error/max_polling_error;
      
      if(state_list.get(i).alignment == 'D')
        state_col = color(c, 255.f, 255.f, 255);
      else if(state_list.get(i).alignment == 'R')
        state_col = color(255.f, 255.f, c, 255);
        
      state_col = mix(color(0, 255, 0), color(255, 0, 0), c);
      
      if(state_list.get(i).politicians.get(0).poll_percentage < 0.f) state_col = color(190, 190, 190, 255);
      
      state_list.get(i).coordinates.set(k, fillWith(new PVector(state_list.get(i).coordinates.get(k).x/531.f*width, state_list.get(i).coordinates.get(k).y/335.f*height), state_col));
    }
  }/*
  for(int i = 0; i < unused_states.size(); i++) {
    for(int k = 0; k < unused_states.get(i).coordinates.size(); k++) {
      
      color state_col = color(0, 0, 0, 255);
      
      unused_states.get(i).coordinates.set(k, fillWith(new PVector(unused_states.get(i).coordinates.get(k).x/531.f*width, unused_states.get(i).coordinates.get(k).y/335.f*height), state_col));
    }
  }*/
  PFont font = loadFont("TimesNewRomanPSMT-24.vlw");
  textFont(font);
  textAlign(CENTER, CENTER);
  for(State s : state_list) {
    //fill(0, 0, 0, 255);
    //text(s.name, s.coordinates.get(0).x, s.coordinates.get(0).y);
  }
  loadPixels();
  updatePixels();
}

public void printAllInfo() {
  for(State s : state_list)
    s.printInfo();
  println("\n///////////STATES WITHOUT ELECTIONS///////////");
  for(State s : unused_states)
    s.printInfo();
}

String[] actual_data;
ArrayList<State> state_list = new ArrayList<State>();
public void loadData(String location) {
  actual_data = loadStrings(location);
  for(int i = 0; i < actual_data.length; i++) {
    String[] split = actual_data[i].split(",");
    if(split.length == 1) {
      state_list.add(new State(actual_data[i]));
    } else if(split.length > 1) {
      Demon d = new Demon(split[0].charAt(0), split[1], Float.parseFloat(split[2].substring(0, split[2].length()-1)), Integer.parseInt(split[3]));
      state_list.get(state_list.size() - 1).addDemon(d);
    }
  }
}

ArrayList<State> unused_states = new ArrayList<State>();
public void loadCoordinates(String location) {
  String[] strings_in = loadStrings(location);
  for(int i = 0; i < strings_in.length; i++) {
    String[] split = strings_in[i].split(",");
    int target_state_index = -1;
    boolean used = false;
    for(int k = 0; k < state_list.size(); k++) {
      if(split[0].equals(state_list.get(k).name)) {
        state_list.get(k).addCoordinates(Float.parseFloat(split[1]), Float.parseFloat(split[2]));
        used = true;
      }
    }
    if(!used) {
      boolean is_in_unused_states = false;
      for(int k = 0; k < unused_states.size(); k++) {
        if(split[0].equals(unused_states.get(k).name)) {
          unused_states.get(k).addCoordinates(Float.parseFloat(split[1]), Float.parseFloat(split[2]));
          is_in_unused_states = true;
        }
      }
      if(!is_in_unused_states)
        unused_states.add(new State(split[0], Float.parseFloat(split[1]), Float.parseFloat(split[2])));
    }
  }
}

public void loadPollData(String location) {
  String[] strings_in = loadStrings(location);
  int target_state = -1;
  for(int i = 0; i < strings_in.length; i++) {
    String[] split = strings_in[i].split(",");
    if(split.length == 2 && !split[1].contains("%")) {
      target_state = -1;
      for(int k = 0; k < state_list.size(); k++) {
        if(state_list.get(k).name.equals(split[0]))
          target_state = k;
      }
    }
    if(split.length == 3 && target_state != -1) {
      int targetPolitician = -1;
      for(int k = 0; k < state_list.get(target_state).politicians.size(); k++) {
        if(state_list.get(target_state).politicians.get(k).name.equals(split[1]))
          targetPolitician = k;
      }
      if(targetPolitician != -1) {
        state_list.get(target_state).politicians.get(targetPolitician).addPollPercentage(Float.parseFloat(split[2].substring(0, split[2].length()-1)));
      }
    }
  }
}

float max_polling_error = 0.f;
public void calculatePollingError() {
  for(State s : state_list) {
    s.calculateAccuracy();
    if(s.polling_error > max_polling_error) {
      max_polling_error = s.polling_error;
    }
  }
  println("\nMax Polling Error: " + max_polling_error);
}

public class State {
  String name = "";
  ArrayList<Demon> politicians = new ArrayList<Demon>();
  ArrayList<PVector> coordinates = new ArrayList<PVector>();
  char alignment = '*';
  float polling_error = 0.f;
  public State(String name) {
    this.name = name;
  }
  public State(String name, float x, float y) {
    this.name = name;
    coordinates.add(new PVector(x, y));
  }
  public void addDemon(Demon d) {
    politicians.add(d);
  }
  public void addCoordinates(float x, float y) {
    coordinates.add(new PVector(x, y));
  }
  public void calculateAccuracy() {
    float percentage_error = 0.f;
    for(Demon d : politicians) {
      if(d.winner) {
        alignment = d.alignment;
      }
      if(d.poll_percentage >= 0.f) {
        percentage_error += abs(d.poll_percentage - d.percentage);
      }
    }
    polling_error = percentage_error;
  }
  public void printInfo() {
    println("\nState Name- " + name);
    println("\nState Alignment- " + alignment);
    if(coordinates.size() > 0)
      for(PVector p : coordinates)
        println("State coordinates- (" + p.x + ", " + p.y + ")");
    for(Demon d : politicians)
      d.printInfo();
  }
}

class Demon {
  char alignment = '*';
  String name = "";
  float percentage = -1.f;
  float poll_percentage = -1.f;
  int number_votes = 0;
  boolean winner = false;
  boolean i_thing = false;
  public Demon(char alignment, String name, float percentage, int number_votes) {
    this.alignment = alignment;
    if(name.startsWith("Winner_")) {
      this.name = name.substring(7);
      winner = true;
    } else
      this.name = name;
    if(this.name.endsWith("_(i)")) {
      i_thing = true;
      this.name = this.name.substring(0, this.name.length()-4);
    }
    this.percentage = percentage;
    this.number_votes = number_votes;
  }
  public void addPollPercentage(float p) {
    poll_percentage = p;
  }
  public void printInfo() {
    println("Name- " + name + " Alignment- " + alignment + " Percentage- " + percentage + "% Poll Percentage- " + poll_percentage + "% Number of votes- " + number_votes + (winner?" WINNER":""));
  }
}

import javax.swing.*;
public String promptFile() {
  try {
    UIManager.setLookAndFeel("com.sun.java.swing.plaf.windows.WindowsLookAndFeel");
  } catch (Exception cnfe) {}
  final JFileChooser fc = new JFileChooser();
  int returnVal = fc.showOpenDialog(null);
  if (returnVal == JFileChooser.APPROVE_OPTION) {
    File file = fc.getSelectedFile();
    return file.getAbsolutePath();
  }
  return "";
}

public PVector fillWith(PVector p, color c) {
  boolean[][] is_full = new boolean[width][height];
  PVector avg = new PVector(0.f, 0.f);
  int total_pixels_filled = 0;
  is_full[round(p.x)][round(p.y)] = true;
  set(round(p.x), round(p.y), c);
  for(int i = 0; i < 180; i++) {
    int pixels_filled = 0;
    for(int x = 1; x < width-1; x++)
      for(int y = 1; y < height-1; y++) {
        if(!is_full[x][y]) {
          if(r(get(x, y)) > 20 && (is_full[x+1][y] || is_full[x-1][y] || is_full[x][y+1] || is_full[x][y-1])) {
            set(x, y, c);
            is_full[x][y] = true;
            pixels_filled++;
            total_pixels_filled++;
            avg.add(new PVector(x, y));
          }
        }
      }
    if(pixels_filled == 0) break;
  }
  avg.mult(1.f/(float)total_pixels_filled);
  return avg;
}

public void outlinedText(String s, float x, float y) {
  fill(255, 255, 255, 255);
  text(s, x - 1, y);
  text(s, x, y - 1);
  text(s, x + 1, y);
  text(s, x, y + 1);
  fill(0, 0, 0, 255);
  text(s, x, y);
} 

color mix(color x, color y, float a) {
  return color(r(x)*(1.f - a) + r(y)*a, g(x)*(1.f - a) + g(y)*a, b(x)*(1.f - a) + b(y)*a);
}

int r(color c) {return (c >> 16) & 255; }
int g(color c) {return (c >> 8) & 255;}
int b(color c) {return c & 255; }
