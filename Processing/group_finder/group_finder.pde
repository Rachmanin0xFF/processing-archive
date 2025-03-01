
import java.util.*;

void setup() {
  String[] info = loadStrings("info.txt");
  int minPerGroup = 0;
  int maxPerGroup = 0;
  int numGroups = 0;
  String[] groups = null;
  ArrayList<Person> peopleTemp = new ArrayList<Person>();
  boolean normalize_inputs = false;
  boolean calculate_groups = false;
  boolean complete_calculation = false;
  for(int i = 0; i < info.length; i++) {
    if(info[i].startsWith("#"))
      println(info[i].substring(2));
    else {
      if(info[i].contains("number_of_groups")) {
        numGroups = Integer.parseInt(parseS(info[i].split("=")[1]));
        println("Number of output groups set to " + numGroups);
      } else if(info[i].contains("minimum_per_group")) {
        minPerGroup = Integer.parseInt(parseS(info[i].split("=")[1]));
        println("Minimum group size set to " + maxPerGroup);
      } else if(info[i].contains("maximum_per_group")) {
        maxPerGroup = Integer.parseInt(parseS(info[i].split("=")[1]));
        println("Maximum group size set to " + maxPerGroup);
      } else if(info[i].contains("normalize_inputs")) {
        String boolStr = parseS(info[i].split("=")[1]);
        normalize_inputs = boolStr.equals("true");
        println("Normalize Inputs: " + normalize_inputs);
      } else if(info[i].contains("calculate_groups")) {
        String boolStr = parseS(info[i].split("=")[1]);
        calculate_groups = boolStr.equals("true");
        println("Caclulate Groups: " + calculate_groups);
      } else if(info[i].contains("complete_calculation")) {
        String boolStr = parseS(info[i].split("=")[1]);
        complete_calculation = boolStr.equals("true");
        println("Complete Calculation: " + complete_calculation);
      } else if(info[i].toLowerCase().contains("name")) {
        String lin = parseS(info[i].substring(4)).substring(1);
        groups = lin.split(",");
        for(String s : groups)
          s = parseS(s);
        print("Groups: {");
        for(int j = 0; j < groups.length; j++) {
          print(groups[j]);
          if(j != groups.length-1)
            print(", ");
        }
        print("}\n");
      } else {
        String[] choiceData = info[i].split(",");
        if(groups != null && choiceData.length == groups.length + 1) {
          float[] userscores = new float[groups.length];
          for(int j = 0; j < userscores.length; j++) {
            userscores[j] = Float.parseFloat(choiceData[j+1]);
          }
          peopleTemp.add(new Person(choiceData[0], userscores));
        }
      }
    }
  }
  Person[] people = new Person[peopleTemp.size()];
  for(int i = 0; i < people.length; i++) {
    people[i] = peopleTemp.get(i);
  }
  for(Person p : people) { print(p.name + " "); for(float f : p.rankings) print(f + " "); println("");}
  if(people.length > numGroups*maxPerGroup) {
    calculate_groups = false;
    complete_calculation = false;
    println("ERROR! You either have too many people, not enough groups, or need to increase the maximum group size. Cancelling calculations.");
  }
  if(calculate_groups) {
    int[] selections = new int[numGroups];
    ArrayList<Float> sums = new ArrayList<Float>();
    while(sums.size() < groups.length) sums.add(0.f); //Fill sums array with 0s
    for(int i = 0; i < people.length; i++) { //For each person
      for(int j = 0; j < people[i].rankings.length; j++) { //For each of their opinions
        sums.set(j, sums.get(j) + people[i].rankings[j]); //Add their opinion to the sum
      }
    }
    //Select the highest sums
    for(int i = 0; i < selections.length; i++) {
      int maxIndex = -1;
      float maxVal = -Float.MAX_VALUE;
      for(int j = 0; j < sums.size(); j++) {
        if(sums.get(j) > maxVal) {
          maxIndex = j;
          maxVal = sums.get(j);
        }
      }
      sums.remove(maxIndex); //Here's why we used an ArrayList (this is a sort of psuedo-score-sorting algorithm that only goes as far as it needs to)
      selections[i] = maxIndex;
    }
    print("MOST APPEALING GROUPS: ");
    for(int i = 0; i < selections.length; i++) {
      print(groups[selections[i]]);
      if(i != selections.length - 1) print(", ");
    }
  }
  if(complete_calculation) {
    long combcompt = (long)pow(groups.length, people.length);
    println("Combinatorical complexity time: " + combcompt);
    ArrayList<Dataset> recordings = new ArrayList<Dataset>();
    boolean done = false;
    Integer[] counter = new Integer[people.length];
    for(int i = 0; i < counter.length; i++) counter[i] = 0;
    long tick = 0;
    while(!done) {
      tick++;
      boolean satisfiesConditions = true;
      
      int grps = 0;
      List<Integer> q = Arrays.asList(counter);
      for(int i = 0; i < groups.length; i++) {
        if(q.contains(i)) grps++;
      }
      if(grps != numGroups) satisfiesConditions = false;
      
      if(satisfiesConditions) {
        float score = 0.f;
        for(int i = 0; i < counter.length; i++) {
          score += people[i].rankings[counter[i]];
        }
        recordings.add(new Dataset(score, counter));
      }
      
      counter[0]++;
      for(int i = 0; i < counter.length; i++) {
        if(counter[i] == groups.length) {
          if(i == counter.length-1) {
            done = true;
            break;
          } else {
            counter[i] = 0;
            counter[i+1]++;
          }
        }
      }
    }
    println(recordings.size());
  }
}

class Dataset {
  float score;
  int[] hatches;
  Dataset(float score, int... hatches) {
    this.score = score;
    this.hatches = hatches;
  }
  Dataset(float score, Integer[] htch) {
    this.score = score;
    hatches = new int[htch.length];
    for(int i = 0; i < hatches.length; i++) {
      hatches[i] = htch[i];
    }
  }
}

class Person {
  String name = "";
  float[] rankings;
  Person(String name, float... review) {
    this.name = name;
    rankings = review;
  }
}
String parseS(String in) {
  String s = new String(in.toCharArray());
  s = s.replace(" ", "");
  return s;
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
