CSVMaster c;
String command = "Enter Command Here";
String command2 = "Enter Command 2 Here";
String a2 = "";

ArrayList<String> list = new ArrayList<String>();
Button enterCommand = new Button(10, 10, 30, 30, true, "Edit");
Button enterCommand2 = new Button(10, 50, 30, 30, true, "Edit");
Button run2 = new Button(50, 50, 30, 30, false, "Run");
Button shouldLoad;

void setup() {
  size(1280, 720, P3D);
  noFill();
  background(0);
  c = new CSVMaster(30, 110, width-60, height-140);
  c.loadData("c.csv");
  shouldLoad = new Button(width-50, 10, 40, 40, false, "Load\nData");
}

void draw() {
  background(0);
  stroke(190, 220, 255);
  text(command, 53, 30);
  rect(53-4, 30-12, 490, 17);
  text(command2, 93, 70);
  rect(93-4, 70-12, 450, 17);
 
  String[] names = c.getColNames();
  String printString = "Columns: ";
  for(int i = 0; i < names.length; i++) {
    printString += names[i];
    if(i != names.length-1)
      printString += ", ";
  }
  text(printString, 10, 100);
  text("Column Length: " + (c.table.size() - 1), 400, 100);
 
  String a1 = c.console(command);
  if(run2.isOn) a2 = c.console(command2);
  fill(0, 255, 0);
  stroke(255);
  noFill();
  enterCommand.update();
  enterCommand2.update();
  shouldLoad.update();
  run2.update();
  if(shouldLoad.isOn)
    c.promptFile();
}

void keyPressed() {
  if(enterCommand.isOn) {
    if(keyCode==BACKSPACE) {
      if(command.length()>1)
        command = command.substring(0, command.length()-1);
      if(command.length()==1)
        command = "";
    } else
      if(key != CODED) command = command + key;
  } else if(enterCommand2.isOn) {
    if(keyCode==BACKSPACE) {
      if(command2.length()>1)
        command2 = command2.substring(0, command2.length()-1);
      if(command2.length()==1)
        command2 = "";
    } else
      if(key != CODED) command2 = command2 + key;
  }
}