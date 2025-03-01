PGraphics pg;

float BROWNIAN = 0.5;
float DAMPING = 0.98;
float SMOOTH_ITER = 10;
//color c_outline  = color(217, 231, 236, 255);
//color c_fill     = color(26, 38, 41, 255);
color c_outline = color(0);
color c_fill = color(255);
float line_width = 3;

String[] sizes = new String[]{
  "1000x60",
  "1185x265",
  "50x50",
  "1091x716",
  "512x512",
  "901x779"
};

void setup() {
  size(1280, 720, P2D);
  background(120, 0, 505);
  smooth(16);
  hint(DISABLE_ASYNC_SAVEFRAME);
  
  for(int i = 0; i < sizes.length; i++) {
    int w = int(sizes[i].split("x")[0]);
    int h = int(sizes[i].split("x")[1]);
    draw_box(w, h);
  }
}

void draw_box(int ww, int hh) {
  int w = ww*2;
  int h = hh*2;
  pg = createGraphics(w+100, h+100);
  pg.hint(DISABLE_ASYNC_SAVEFRAME);
  
  pg.noSmooth();
  pg.beginDraw();
  //pg.clear();
  pg.stroke(c_outline);
  pg.strokeWeight(line_width*2);

  fuzz_line(pg, 50, 50, 50+w, 50);
  fuzz_line(pg, 50, 50+h, 50+w, 50+h);
  fuzz_line(pg, 50, 50, 50, 50+h);
  fuzz_line(pg, 50+w, 50, 50+w, 50+h);
  pg.loadPixels();
  flood_fill(pg, (w+50)/2, (h+50)/2, c_fill);
  pg.updatePixels();
  pg.endDraw();
  image(pg, 0, 0, pg.width/2, pg.height/2);
  pg.loadPixels();
  pg.updatePixels();
  pg.loadPixels();
  PImage p = pg.get();
  p.resize(p.width/2, p.height/2);
  p.save("box_" + ww + "x" + hh + ".png");
}

void fuzz_line(PGraphics pg, float x0, float y0, float x1, float y1) {
  PVector dir = new PVector(x1-x0, y1-y0);
  int len = round(dir.mag());
  dir.normalize();
  PVector step = new PVector(x0, y0);
  PVector offset = new PVector(-dir.y, dir.x);
  float[] off = fuzz_coords(len);
  for(int i = 0; i < len; i++) {
    step.add(dir);
    PVector coord = PVector.add(step, PVector.mult(offset, off[i]));
    pg.point(coord.x, coord.y);
  }
}

float[] fuzz_coords(int w) {
  float[] o = new float[w];
  float[] o2 = new float[w];
  float cval = 0.0;
  for(int i = 0; i < w-1; i++) {
    o[i] = cval;
    cval += BROWNIAN*random(-1, 1);
    cval *= DAMPING;
  }
  for(int j = 0; j < SMOOTH_ITER; j++) {
    for(int i = 1; i < w-1; i++) {
      o2[i] = 0.5*(o[i-1] + o[i+1]);
    }
    for(int i = 1; i < w-1; i++) {
      o[i] = 0.5*(o2[i-1] + o2[i+1]);
    }
  }
  return o2;
}


void flood_fill(PGraphics pg, int x0, int y0, int fill_color) {
  pg.loadPixels();
  boolean[][] converted = new boolean[pg.width][pg.height];
  for(int y = 0; y < pg.height; y++) {
    for(int x = 0; x < pg.width; x++) {
      converted[x][y] = pg.pixels[x + y*pg.width] != c_outline;
    }
  }
  boolean[][] result = flood_fill(converted, x0, y0);
  for(int y = 0; y < pg.height; y++) {
    for(int x = 0; x < pg.width; x++) {
      if(result[x][y]) pg.pixels[x + y*pg.width] = fill_color;
    }
  }
  pg.updatePixels();
}


// modified scanline floodfill method
// very fast, i think
import java.util.Stack;
boolean[][] flood_fill(boolean[][] arr, int x0, int y0) {

  int xres = arr.length;
  int yres = arr[0].length;
  if (!arr[x0][y0]) {
    println("spot not fillable!");
    return null;
  }

  boolean[][] in_sink = new boolean[xres][yres];
  Stack<ScanPT> pts = new Stack<ScanPT>();
  pts.push(new ScanPT(x0, x0, x0+1, x0-1, y0, (byte)1));
  pts.push(new ScanPT(x0, x0, x0+1, x0-1, y0, (byte)-1));

  int x = 0;
  int iter = 0;

  while (!pts.empty()) {
    ScanPT l = pts.pop();

    if (!in_sink[l.x0][l.y]) {

      // fill center region
      for (x = l.x0; x <= l.x1; x++) in_sink[x][l.y] = true;

      // fill right side
      for (; x < xres; x++)
        if (arr[x][l.y]) in_sink[x][l.y] = true;
        else break;

      l.x1 = x-1; // store right edge

      // fill left side
      for (x = l.x0; x >= 0; x--)
        if (arr[x][l.y]) in_sink[x][l.y] = true;
        else break;

      l.x0 = x+1; // store left edge

      int left_side = l.x0;
      boolean c_arr = false;
      boolean p_arr = false;

      // sweep whole range
      if (l.y + l.direction < yres && l.y + l.direction >= 0) {
        for (x = l.x0; x <= l.x1; x++) {
          c_arr = arr[x][l.y+l.direction];
          if (!p_arr && c_arr) // are we on a new fillable region?
            left_side = x;    // if so, mark the start of it
          else if (p_arr && !c_arr) // are we on a new unfillable region?
            pts.push(new ScanPT(left_side, x-1, l.x0, l.x1, l.y + l.direction, l.direction)); // if so, add the old fillable region to the stack
          p_arr = c_arr;
        }
        if (p_arr) pts.push(new ScanPT(left_side, x-1, l.x0, l.x1, l.y + l.direction, l.direction)); // if we reached the end in a fillable space, dump the region to the stack
      }

      if (l.y - l.direction < yres && l.y - l.direction >= 0) {
        if (l.x1 > l.px1) { // is the new right bound bigger than the old one?
          left_side = l.px1;
          c_arr = false;
          p_arr = false;
          for (x = l.px1; x <= l.x1; x++) {
            c_arr = arr[x][l.y-l.direction]; // negative direction!
            if (!p_arr && c_arr) left_side = x;
            else if (p_arr && !c_arr) pts.push(new ScanPT(left_side, x-1, l.x0, l.x1, l.y - l.direction, (byte)-l.direction));
            p_arr = c_arr;
          }
          if (p_arr) pts.push(new ScanPT(left_side, x-1, l.x0, l.x1, l.y - l.direction, (byte)-l.direction));
        }

        if (l.x0 < l.px0) { // is the new left bound smaller than the old one?
          left_side = l.px0;
          c_arr = false;
          p_arr = false;
          for (x = l.px0; x >= l.x0; x--) {
            c_arr = arr[x][l.y-l.direction]; // negative direction!
            if (!p_arr && c_arr) left_side = x;
            else if (p_arr && !c_arr) pts.push(new ScanPT(x+1, left_side, l.x0, l.x1, l.y - l.direction, (byte)-l.direction));
            p_arr = c_arr;
          }
          if (p_arr) pts.push(new ScanPT(x+1, left_side, l.x0, l.x1, l.y - l.direction, (byte)-l.direction));
        }
      }
    }
    iter++;
  }
  return in_sink;
}
final class ScanPT {
  public int x0;
  public int x1;
  public byte direction;
  public int px0;
  public int px1;
  public int y;
  public ScanPT(int x0, int x1, int px0, int px1, int y, byte direction) {
    this.x0 = x0;
    this.x1 = x1;
    this.px0 = px0;
    this.px1 = px1;
    this.y = y;
    this.direction = direction;
  }
}
