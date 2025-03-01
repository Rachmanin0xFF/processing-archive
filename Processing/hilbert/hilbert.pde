String instructions = "A";
float dir = 0;
float x = 100;
float y = 100;
float px = 100;
float py = 100;
float m9x = 0;
float m9y = 0;
void setup() {
  size(700, 700, P2D);
  genInstructions();
  println(instructions);
  for(char c:instructions.toCharArray()) {
    if(c=='F') {x+=cos(dir)*4;y+=sin(dir)*4;}
    if(c=='+') dir += PI/2;
    if(c=='-') dir -= PI/2;
    line(x, y, px, py);
    px = x;
    py = y;
  }
  smooth(16);
}
void draw() {
  stroke(0);
  x = width/2;
  y = height/2;
  px = x; 
  py = y;
  dir = 0;
  
  background(255);
  float a1 = (m9x-width/2)/100000f+PI/2;
  float a2 = (m9y-height/2)/100000f+PI/2;
  for(char c:instructions.toCharArray()) {
    if(c=='F') {x+=cos(dir)*2;y+=sin(dir)*2;}
    if(c=='+') dir += a1;
    if(c=='-') dir -= a2;
    line(x, y, px, py);
    px = x;
    py = y;
  }
  m9x += (mouseX-m9x)*0.1f;
  m9y += (mouseY-m9y)*0.1f;
}
public void genInstructions() {
    for(int i = 0; i < 7; i++) {
      StringBuilder tmpInstructions = new StringBuilder();
      for(char c:instructions.toCharArray()) {
        if(c=='A')
          tmpInstructions.append("-BF+AFA+FB-");
        else if(c=='B')
          tmpInstructions.append("+AF-BFB-FA+");
        else
          tmpInstructions.append(c);
      }
      instructions = tmpInstructions.toString();
    }
}
