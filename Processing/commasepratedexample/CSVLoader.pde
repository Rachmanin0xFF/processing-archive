import javax.swing.*;

String consolePrintText = "";

void printQ(String s) {
  consolePrintText = s;
}

class CSVMaster {
  float x0;
  float y0;
  float xw;
  float yw;
  ArrayList<ArrayList<DataObj>> table;
  ArrayList<ArrayList<String>> stringTable;
 
  public CSVMaster(float w1, float h1) {
    try {
      UIManager.setLookAndFeel(UIManager.getSystemLookAndFeelClassName());
    } catch (Exception e) {
      e.printStackTrace();  
    }
    xw = w1;
    yw = h1;
  }
 
  public CSVMaster(float w0, float h0, float w1, float h1) {
     try {
      UIManager.setLookAndFeel(UIManager.getSystemLookAndFeelClassName());
    } catch (Exception e) {
      e.printStackTrace();  
    }
    x0 = w0;
    y0 = h0;
    xw = w1;
    yw = h1;
  }
 
  public void promptFile() {
    final JFileChooser fc = new JFileChooser();
    int returnVal = fc.showOpenDialog(null);
 
    if (returnVal == JFileChooser.APPROVE_OPTION) {
      File file = fc.getSelectedFile();
      if (file.getName().endsWith("csv")) {
        loadData(file.getAbsolutePath());
      }
    }
  }
 
  public void setBounds(float w0, float h0, float w1, float h1) {
    x0 = w0;
    y0 = h0;
    xw = w1;
    yw = h1;
  }
 
  public void loadData(String location) {
    printQ("Loading " + location + "...");
    
    //Clear ArrayLists so that we don't have the data from last time.
    table = new ArrayList<ArrayList<DataObj>>();
    for(ArrayList<DataObj> o : table)
      o = new ArrayList<DataObj>();
    
    stringTable = new ArrayList<ArrayList<String>>();
    for(ArrayList<String> o : stringTable)
      o = new ArrayList<String>();
    
    //Create our reader.
    BufferedReader cruncher = createReader(location);
    boolean crunched = false;
    
    //It's a Buffered reader, so the reader itself should be able to handle basically anything.
    //The table is limited by the RAM, though.
    while(!crunched) {
      try {
        String line = cruncher.readLine();
        if(line != null) {
          //Add a row now so that we can add things to table.get(table.size()-1).
          addRow();
          //Seperate values by commas.
          String[] values = line.split(",");
          //Iterate through String array and let DataObj sort out the data type.
          for(int i = 0; i < values.length; i++) {
            table.get(table.size()-1).add(new DataObj(values[i]));
            
            //Format the String using DataObj's constructor and add it to the string table.
            DataObj q = new DataObj(values[i]);
            String toAdd = q.getStringD();
            stringTable.get(stringTable.size()-1).add(toAdd);
          }
        } else {
          crunched = true;
        }
      } catch(IOException e) {
        e.printStackTrace();
        crunched = true;
      }
    }
    printQ(location + " loaded with " + stringTable.size() + " rows and " + stringTable.get(0).size() + " columns.");
  }
 
  //disp x-var1 y-var2w
  public String console(String command) {
    if(command.length()<=1)
      return "";
    String[] arguments = command.split(" ");
    if(arguments.length>0) {
      if(arguments[0].equals("disp"))
        return disp(arguments);
      else if(arguments[0].equals("fluxions"))
        return fluxions(arguments);
      else if(arguments[0].equals("save"))
        return saveData(arguments);
      else
        return "Command not recognized.";
    } else
      return "Command not recognized.";
  }
  
  public String saveData(String[] arguments) {
    String fName = "out.csv";
    for(String s: arguments) {
      if(s.startsWith("path-"))
        fName = s.substring(5);
    }
    String[] strout = new String[table.size()];
    int idex = 0;
    for(int i = 0; i < table.size(); i++) {
      String scat = "";
      for(int k = 0; k < table.get(0).size(); k++) {
        scat += new String(table.get(i).get(k).item.toCharArray()) + (k == table.get(0).size()-1 ? "" : ", ");
        idex++;
      }
      strout[i] = scat;
    }
    saveStrings(fName, strout);
    return "Saved to " + fName;
  }
  
  public String fluxions(String[] arguments) {
    ArrayList<String> integr8Strings = new ArrayList<String>();
    int mode = 0;
    float dt = 1.0f;
    for(String s : arguments) {
      if(s.startsWith("col-")) {
        integr8Strings.add(s.substring(4));
      }
      if(s.equals("-integrate"))
        mode = 1;
      if(s.equals("-derivative"))
        mode = 0;
      if(s.startsWith("dt-")) {
        dt = Float.parseFloat(s.substring(3));
      }
    }
    
    for(int k = 0; k < integr8Strings.size(); k++) {
      int lineToIntegrate = stringTable.get(0).indexOf(integr8Strings.get(k));
      if(lineToIntegrate < 0)
        return "Integration failed! No Variable by the name of " + integr8Strings.get(k) + " was found!";
      
      float sum = 0.0f;
      float prevVal = 0.0f;
      for(int i = 1; i < table.size(); i++) {
        float thisVal = table.get(i).get(lineToIntegrate).getFloatD();
        if(i == 1)
          prevVal = thisVal;
        sum += (thisVal + prevVal)/2.0f*dt;
        if(mode == 1) table.get(i).set(lineToIntegrate, new DataObj(sum));
        if(mode == 0) table.get(i).set(lineToIntegrate, new DataObj(prevVal - thisVal));
        prevVal = thisVal;
      }
    }
    
    return "Integration successful.";
  }
 
  public void dispColNames() {
    for(String s : stringTable.get(0))
      println(s);
  }
 
  public String[] getColNames() {
    String[] s = new String[stringTable.get(0).size()];
    for(int i = 0; i < s.length; i++)
      s[i] = table.get(0).get(i).item;
    return s;
  }
 
  public String disp(String[] arguments) {
    String xAxis = ""; boolean xi = false;
    String yAxis = ""; boolean yi = false;
    String zAxis = ""; boolean zi = false;
    ArrayList<String> textAxes = new ArrayList<String>();
    ArrayList<Integer> textIndexes = new ArrayList<Integer>();
    boolean connected = false;
    boolean smooth = false;
    boolean mouseCam = false;
    boolean uniformScaling = false;
    float xRot = 0f;
    float yRot = 0f;
    float zRot = 0f;
    int axes = 0;
    int mode = 0;
    for(String s : arguments) {
      if(s.equals("xi")) {xi = true; axes++;}
      if(s.equals("yi")) {yi = true; axes++;}
      if(s.equals("zi")) {zi = true; axes++;}
      if(s.equals("-c")) connected = true;
      if(s.equals("-s")) smooth = true;
      if(s.equals("-b")) mode = 1;
      if(s.equals("-mc")) mouseCam = true;
      if(s.startsWith("-u")) uniformScaling = true;
      if(s.startsWith("x-")) {
        xAxis = s.substring(2);
        axes++;
      }
      if(s.startsWith("t-")) {
        textAxes.add(s.substring(2));
      }
      if(s.startsWith("y-")) {
        yAxis = s.substring(2);
        axes++;
      }
      if(s.startsWith("z-")) {
        zAxis = s.substring(2);
        axes++;
      }
      try {
        if(s.startsWith("rx-")) xRot = Float.parseFloat(s.substring(3));
        if(s.startsWith("ry-")) yRot = Float.parseFloat(s.substring(3));
        if(s.startsWith("rz-")) zRot = Float.parseFloat(s.substring(3));
      } catch(NumberFormatException e) {
        return "Rotation number format unrecognized.";
      }
    }
    blendMode(ADD);
    rect(x0, y0, xw, yw);
    
    for(String s : textAxes)
      textIndexes.add(stringTable.get(0).indexOf(s));
    
    int xIndex = stringTable.get(0).indexOf(xAxis);
    int yIndex = stringTable.get(0).indexOf(yAxis);
    int zIndex = stringTable.get(0).indexOf(zAxis);
    
    float xmi = 1000000f; float xmx = -1000000f;
    float ymi = 1000000f; float ymx = -1000000f;
    float zmi = 1000000f; float zmx = -1000000f;
    for(int i = 1; i < table.size(); i++) {
      float xP = 0f;
      float yP = 0f;
      float zP = 0f;
      if(axes>0) if(!xi) if(xIndex==-1){printQ("No Variable by the name of "+xAxis+" was found!");return "No variable by the name of "+xAxis+" was found!";}
      if(axes>1) if(!yi) if(yIndex==-1){printQ("No Variable by the name of "+yAxis+" was found!");return "No variable by the name of "+yAxis+" was found!";}
      if(axes>2) if(!zi) if(zIndex==-1){printQ("No Variable by the name of "+zAxis+" was found!");return "No variable by the name of "+zAxis+" was found!";}
      if(axes>0) if(!xi) xP = table.get(i).get(xIndex).getFloatD(); else xP = i;
      if(axes>1) if(!yi) yP = table.get(i).get(yIndex).getFloatD(); else yP = i;
      if(axes>2) if(!zi) zP = table.get(i).get(zIndex).getFloatD(); else zP = i;
      if(axes>0) if(xP<xmi) xmi = xP; if(xP>xmx) xmx = xP;
      if(axes>1) if(yP<ymi) ymi = yP; if(yP>ymx) ymx = yP;
      if(axes>2) if(zP<zmi) zmi = zP; if(zP>zmx) zmx = zP;
    }
    
    if(axes == 3) {
      pushMatrix();
      if(!xi) if(xIndex==-1){printQ("No Variable by the name of "+xAxis+" was found!");return "No variable by the name of "+xAxis+" was found!";}
      if(!yi) if(yIndex==-1){printQ("No Variable by the name of "+yAxis+" was found!");return "No variable by the name of "+yAxis+" was found!";}
      if(!zi) if(zIndex==-1){printQ("No Variable by the name of "+zAxis+" was found!");return "No variable by the name of "+zAxis+" was found!";}
      float xPos = 0;
      float yPos = 0;
      float zPos = 0;
      if(mouseCam) {
        yRot = float(mouseX)/100.0f;
        xRot = float(mouseY)/100.0f;
      }
      if(mode==0) {
        stroke(255, 255, 255, 150);
        translate(x0+xw/2.0f, y0+yw/2.0f, 0);
        rotateX(xRot);
        rotateY(yRot);
        rotateZ(zRot);
        scale(0.36);
        pushMatrix();
        box(xw, yw, (xw+yw)/2.0f);
        stroke(255, 0, 0);
        line(0, 0, 0, 100, 0, 0);
        stroke(0, 255, 0);
        line(0, 0, 0, 0, 100, 0);
        stroke(0, 0, 255);
        line(0, 0, 0, 0, 0, 100);
        stroke(255);
        popMatrix();
        //translate(xw, yw*2.0, 0.0);
        stroke(190, 220, 255);
      }
      if(connected&&(mode==0||mode==1)) beginShape();
      for(int i = 1; i < table.size(); i++) {
        if(!xi) xPos = table.get(i).get(xIndex).getFloatD(); else xPos = i;
        if(!yi) yPos = table.get(i).get(yIndex).getFloatD(); else yPos = i;
        if(!zi) zPos = table.get(i).get(zIndex).getFloatD(); else zPos = i;
        
        if(uniformScaling) {
          float maxScale = max(xmx, ymx, zmx);
          float minScale = min(xmi, ymi, zmi);
          xPos = map(xPos, minScale, maxScale, -xw/2, xw/2);
          yPos = map(yPos, maxScale, minScale, -yw/2, yw/2);
          if(mode==0) zPos = map(zPos, minScale, maxScale, -(xw+yw)/4.0f, (xw+yw)/4.0f);
          if(mode==1) zPos = map(zPos, zmi, zmx, 1, 15);
        } else {
          xPos = map(xPos, xmi, xmx, -xw/2, xw/2);
          yPos = map(yPos, ymx, ymi, -yw/2, yw/2);
          if(mode==0) zPos = map(zPos, zmi, zmx, -(xw+yw)/4.0f, (xw+yw)/4.0f);
          if(mode==1) zPos = map(zPos, zmi, zmx, 1, 15);
        }
        
        for(Integer ii : textIndexes) {
          String text = stringTable.get(i).get(ii);
          if(mode==0) text(text, xPos, yPos, zPos);
          if(mode==1) text(text, xPos, yPos);
        }
        
        if(mode==0) {
          if(connected) {
            if(smooth) {
              if(i==1||i==table.size()-1)
                curveVertex(xPos, yPos, zPos);
              curveVertex(xPos, yPos, zPos);
            } else {
              vertex(xPos, yPos, zPos);
            }
          } else {
            point(xPos, yPos, zPos);
          }
        }
        if(mode==1) {
          strokeWeight(zPos);
          if(connected) {
            if(smooth) {
              if(i==1||i==table.size()-1)
                curveVertex(xPos, yPos);
              curveVertex(xPos, yPos);
            } else {
              vertex(xPos, yPos);
            }
          } else {
            point(xPos, yPos);
          }
        }
      }
      if(connected&&(mode==0||mode==1)) endShape();
      popMatrix();
    }
    
    if(axes == 2) {
      if(!xi) if(xIndex==-1){printQ("No Variable by the name of "+xAxis+" was found!");return "No Variable by the name of "+xAxis+" was found!";}
      if(!yi) if(yIndex==-1){printQ("No Variable by the name of "+yAxis+" was found!");return "No Variable by the name of "+yAxis+" was found!";}
      float xPos = 0;
      float yPos = 0;
      
      textAlign(RIGHT);
      text("(" + xmx + "," + ymx + ")", x0 + xw - 3, y0 + 12);
      text("(" + xmx + "," + ymx + ")", x0 + xw - 3, y0 + yw-5);
      textAlign(LEFT);
      text("(" + xmi + "," + ymi + ")", x0 + 3, y0 + yw - 5);
      text("(" + xmi + "," + ymx + ")", x0 + 3, y0 + 12);
      textAlign(LEFT);
      
      if(connected) beginShape();
      for(int i = 1; i < table.size(); i++) {
        if(!xi) xPos = table.get(i).get(xIndex).getFloatD(); else xPos = i;
        if(!yi) yPos = table.get(i).get(yIndex).getFloatD(); else yPos = i;
        xPos = map(xPos, xmi, xmx, x0, x0+xw);
        yPos = map(yPos, ymx, ymi, y0, y0+yw);
        
        for(Integer ii : textIndexes) {
          String text = stringTable.get(i).get(ii);
          text(text, xPos, yPos);
        }
        
        if(connected) {
          if(smooth) {
            if(i==1||i==table.size()-1)
              curveVertex(xPos, yPos);
            curveVertex(xPos, yPos);
          } else
            vertex(xPos, yPos);
        } else
          point(xPos, yPos);
      }
      if(connected) endShape();
    }
    
    if(axes == 1) {
      if(!xi) if(xIndex==-1){printQ("No Variable by the name of "+xAxis+" was found!");return "No Variable by the name of "+xAxis+" was found!";}
      printQ("\nListing Values-\n//////////////////////////////////////////////////////////////////////////");
      for(ArrayList<String> q : stringTable)
        printQ(q.get(xIndex));
      printQ("//////////////////////////////////////////////////////////////////////////\nDone list.");
    }
    
    strokeWeight(1);
    blendMode(BLEND);
    return "Display Successful.";
  }
 
  public void addRow() {
    table.add(new ArrayList<DataObj>());
    stringTable.add(new ArrayList<String>());
  }
}

private class DataObj {
  String item = "";
  float value = 0.0f;
  boolean number = false;
  DataObj() {
    item = "null";
  }
  DataObj(String x) {
    String finalized = x;
    //Remove any spaces and tabs at beginning.
    for(int i = 0; i < 10; i++) if(finalized.startsWith(" "))
      finalized = finalized.substring(1);
    for(int i = 0; i < 10; i++) if(finalized.startsWith("\t"))
      finalized = finalized.substring(1);
    //Check if the String is a number.
    number = isNumber(finalized);
    item = finalized;
    
    if(finalized.length()>=2)
    if(finalized.startsWith("\"")) {
      finalized = finalized.substring(1, finalized.length() - 1);
      number = false;
    }
    
    //If it is a number, set the value variable to the number.
    if(number) value = getFloatD(); else value = 0.0f;
  }
  DataObj(float x) {
    item = x + "";
    number = true;
  }
  String getStringD() {
    return item;
  }
  float getFloatD() {
    if(number)
      return Float.parseFloat(item);
    else
      return 0f;
  }
  int getIntD() {
    return Integer.parseInt(item);
  }
  boolean isNumber(String x) {
    if(x.length()==0)
      return false;
    for(char c : x.toCharArray()) {
      if(!isNumber(c))
        return false;
    }
    return true;
  }
  boolean isNumber(char x) {
    return Character.isDigit(x)||(x=='.')||(x=='-');
  }
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
      if(mousePressed)
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

float log10(float x) {
  return log(x)/log(10.0f);
}
