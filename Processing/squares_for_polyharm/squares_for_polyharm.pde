float[][] arr = new float[9][9];
PFont atkinson;
int[][] fixed_ones = new int[3][3];
void setup() {
  size(512, 512);
  smooth(16);
  fixed_ones[0] = new int[]{2, 6, 200};
  fixed_ones[1] = new int[]{1, 2, 0};
  fixed_ones[2] = new int[]{7, 3, 100};
  for (int i = 0; i < fixed_ones.length; i++) {
    arr[fixed_ones[i][0]][fixed_ones[i][1]] = fixed_ones[i][2];
  }
  atkinson = loadFont("AtkinsonHyperlegible-Regular-16.vlw");
  textSize(16);
  textFont(atkinson, 16);
}

void draw() {
  background(0);
  for(int x = 0; x < 9; x++) for(int y = 0; y < 9; y++) {
    fill(arr[x][y]*0.1, arr[x][y]*0.2, arr[x][y]);
    rect(x / 9.0 * width, y/9.0 * width, 1.0 / 9.0 * width, 1.0 / 9.0 * width);
    fill(255, 30);
    text(nf(arr[x][y], 0, 1), x/ 9.0 * width + width / 18.0, y/ 9.0 * width + width / 18.0);
  }
  strokeWeight(4);
  strokeCap(ROUND);
   stroke(255);
  for (int i = 0; i < fixed_ones.length; i++) {
    float val = arr[fixed_ones[i][0]][fixed_ones[i][1]] = fixed_ones[i][2];
    int x = fixed_ones[i][0];
    int y = fixed_ones[i][1];
    //fill(val*0.1, val*0.2, val);
    //rect(x / 9.0 * width, y/9.0 * width, 1.0 / 9.0 * width, 1.0 / 9.0 * width);
    //fill(255);
    textAlign(CENTER, CENTER);
    //text(nf(val, 0, 1), x/ 9.0 * width + width / 18.0, y/ 9.0 * width + width / 18.0);
  }
  noStroke();
  
  if(frameCount > 10)
  for(int j = 0; j< frameCount/3; j++) {
  for(int x = 0; x < 9; x++) for(int y = 0; y < 9; y++) {
    float nb_cells = 0.0;
    float avg = 0.0;
    avg = arr[x][y];
    nb_cells++;
    if(x > 0) {
      nb_cells++;
      avg += arr[x-1][y];
    }
    if(y > 0) {
      nb_cells++;
      avg += arr[x][y-1];
    }
    if(y < 8) {
      nb_cells++;
      avg += arr[x][y+1];
    }
    if(x < 8) {
      nb_cells++;
      avg += arr[x+1][y];
    }
    boolean is_fixed = false;
    for (int i = 0; i < fixed_ones.length; i++) {
      if(fixed_ones[i][0] == x && fixed_ones[i][1] == y)
        is_fixed = true;
    }
    if(!is_fixed)
    arr[x][y] = avg / nb_cells;
  }
  }
  
  if(mousePressed)
  saveFrame("out-" + frameCount + ".png");
}

/*
boolean is_fixed = false;
    for (int i = 0; i < fixed_ones.length; i++) {
      if(fixed_ones[i][0] == x && fixed_ones[i][1] == y)
        is_fixed = true;
    }
    */
