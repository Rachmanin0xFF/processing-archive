import java.util.Random;
import java.util.Comparator;
 
GameState mystate;
void setup() {
  size(450, 450, P2D);
  background(0);
 
  mystate = new GameState();
  mystate.get_random_blocks();
  //frameRate(3);
}
ArrayList<Float> datalog = new ArrayList<Float>();
void draw() {
  background(0);
  step();
}
void keyPressed() {
  step();
}
int count = 0;
void step() {
  ArrayList<GameState> zero = new ArrayList<GameState>();
  zero.add(mystate);
 
  ArrayList<GameState> one = branch_all(zero);
  int best_id = -1;
  float best_score = 1000000000;
  for(int i = 0; i < one.size(); i++) {
    ArrayList<GameState> this_one = new ArrayList<GameState>();
    this_one.add(one.get(i));
 
 
    int iter = this_one.get(0).block_ids.size();
    for(int q = 0; q < iter; q++) {
      this_one = branch_all(this_one);
    }
    cull_to_size(this_one, min(100, this_one.size()));
    //if(this_one.size() < 10) this_one = branch_all(this_one);
    //this_one = branch_all(this_one);
    //this_one = branch_all(this_one);
    //cull_to_size_random(this_one, min(100, this_one.size()));
    //if(this_one.size() < 10000)
    //this_one = branch_all(this_one);
 
    float best_of_set = 1000000000;
    for(int j = 0; j < this_one.size(); j++) {
      this_one.get(j).calc_score_complex();
      if(this_one.get(j).score < best_of_set) best_of_set = this_one.get(j).score;
    }
    if(best_of_set < best_score) {
      best_score = best_of_set;
      best_id = i;
    }
  }
  datalog.add(best_score);
  float max = -10000000;
  float min = 1000000;
  for(int i = 0; i < datalog.size(); i++) {
    if(max < datalog.get(i)) max = datalog.get(i);
    if(min > datalog.get(i)) min = datalog.get(i);
  }
  stroke(255, 255);
  if(min != max)
  for(int i = 1; i < datalog.size(); i++) {
    float y0 = map(datalog.get(i-1), min, max, height, height-100);
    float y1 = map(datalog.get(i), min, max, height, height-100);
    
    line(i-1, y0, i, y1);
  }
  if(datalog.size() > width) datalog.remove(0);
  
  if(best_id >= 0) {
    mystate = one.get(best_id);
    count++;
  } else {
    println(count);
    count = 0;
    mystate = new GameState();
    mystate.get_random_blocks();
    datalog.clear();
  }
  blendMode(ADD);
  fill(255, 0, 0);
  zero.get(0).board.display(30);
  fill(0, 255, 0);
  mystate.board.display(30);
 
 
  if(mystate.block_ids.size() == 0) mystate.get_random_blocks();
 
  blendMode(BLEND);
 
  pushMatrix();
  translate(30, 30*10);
  for(int b : mystate.block_ids) {
    SHAPES[b].display(10);
    translate(100, 0);
  }
  noFill();
  stroke(0, 255, 0);
  popMatrix();
  rect(0, 0, 270, 270);
  fill(0, 255, 0);
  textSize(36);
  text(count, 30*9.5, 30*1.5);
}
 
void mousePressed() {
  mystate.board.togglebit(mouseX/50, mouseY/50);
}
 
void cull_to_size(ArrayList<GameState> states, int n) {
  assert(n <= states.size());
  for(GameState gs : states) gs.calc_score_simple();
  // An insertion sort-style method takes O(m*n) time, where n is the output size, and m is the source array size.
  // If n is some constant fraction of m (say 10%), then the complexity becomes O(n^2)
  // So a sorting method is probably best here.
  states.sort(Comparator.comparing(gs -> gs.score));
  states.subList(n, states.size()).clear();
}
 
void cull_to_size_random(ArrayList<GameState> states, int n) {
  assert(n <= states.size());
  for(GameState gs : states) gs.calc_randn();
  // An insertion sort-style method takes O(m*n) time, where n is the output size, and m is the source array size.
  // If n is some constant fraction of m (say 10%), then the complexity becomes O(n^2)
  // So a sorting method is probably best here.
  states.sort(Comparator.comparing(gs -> gs.randn));
  states.subList(n, states.size()).clear();
}
 
ArrayList<GameState> branch_all(ArrayList<GameState> states) {
  ArrayList<GameState> out = new ArrayList<GameState>();
  for(GameState gs : states) {
    out.addAll(gs.branch());
  }
  return out;
}
 
class GameState {
  Bitboard board;
  ArrayList<Integer> block_ids;
  float score = 0;
  float randn = 0;
  GameState() {
    board = new Bitboard();
    block_ids = new ArrayList<Integer>();
  }
  void calc_randn() {
    randn = random(1);
  }
  GameState(Bitboard brd, ArrayList<Integer> blk_ids) {
    board = brd;
    block_ids = blk_ids;
  }
  void get_random_blocks() {
    for(int i = 0; i < 3; i++) block_ids.add(EVERY_SHAPE[(int)random(EVERY_SHAPE.length)]);
  }
  void calc_score_simple() {
    score = board.bit_count();
    score += board.count_borders()*0.3;
  }
  void calc_score_complex() {
    //score = board.bit_count();
    //score -= board.count_options(EVERY_SHAPE);
    
    
    //score -= board.count_unique_blocks_that_fit();
    score = board.bit_count();
    //score -= board.count_options(EVERY_SHAPE)*0.1;
    /*
    for(Bitboard b : GAME_MASKS) {
      score += (and(b, board).bit_count() > 0) ? 1 : 0;
    }*/
    //score += board.count_borders()*0.1;
    score += board.count_borders()*0.3;
    //score -= board.count_unique_blocks_that_fit();
  }
  ArrayList<GameState> branch() {
    ArrayList<GameState> out = new ArrayList<GameState>();
    int j = 0;
    if(block_ids.size() > 0)
    for(int block_id : block_ids) {
      ArrayList<Bitboard> branched = board.branch(block_id);
      ArrayList<Integer> shrunk_ids = new ArrayList<Integer>(block_ids);
      shrunk_ids.remove(j++);
      for(Bitboard b : branched) {
        b.resolve();
        out.add(new GameState(b, shrunk_ids));
      }
    }
    else
    for(int block_id : EVERY_SHAPE) {
      ArrayList<Bitboard> branched = board.branch(block_id);
      ArrayList<Integer> ids = new ArrayList<Integer>();
      for(Bitboard b : branched) {
        b.resolve();
        out.add(new GameState(b, ids));
      }
    }
    return out;
  }
}
 
Bitboard and(Bitboard x, Bitboard y) {
  Bitboard o = new Bitboard(x.a, x.b);
  o.a &= y.a; o.b &= y.b;
  return o;
}
 
class Bitboard {
  long a;
  int b;
  Bitboard() {}
  Bitboard(long a, int b) {
    this.a = a;
    this.b = b;
  }
  int bit_count() {
    return Long.bitCount(a) + Integer.bitCount(b);
  }
  int count_borders() {
    int sum = 0;
    int s2 = 0;
    for(int x = 0; x < 9; x++) {
      for(int y = 0; y < 9; y++) {
        s2 = 0;
        if(!getbit(x, y)) {
          s2 += getbit(x+1,y)?1:0;
          s2 += getbit(x-1,y)?1:0;
          s2 += getbit(x,y+1)?1:0;
          s2 += getbit(x,y-1)?1:0;
        }
        sum += s2;
      }
    }
    return sum;
  }
  ArrayList<Bitboard> branch(int... blocks) {
    ArrayList<Bitboard> o = new ArrayList<Bitboard>();
    for(int z : blocks) {
    for(int i = 0; i < 10 - SHAPE_WIDTHS[z]; i++) for(int j = 0; j < 10 - SHAPE_HEIGHTS[z]; j++) {
      Bitboard to_add = new Bitboard();
      int shift = i + j*9;
        if(shift < 64) {
          to_add.a |= SHAPES[z].a << shift;
          if(shift > 24) to_add.b |= SHAPES[z].a >>> (64 - shift);
        } else  {
          to_add.b |= SHAPES[z].a << shift;
        }
        to_add.b = (to_add.b << 47) >> 47;
        if((to_add.a & a) == 0 && (to_add.b & b) == 0) {
          to_add.a |= a; to_add.b |= b;
          o.add(to_add);
        }
      }
    }
    return o;
  }
  int count_options(int... blocks) {
    int o = 0;
    for(int z : blocks) {
    for(int i = 0; i < 10 - SHAPE_WIDTHS[z]; i++) for(int j = 0; j < 10 - SHAPE_HEIGHTS[z]; j++) {
      Bitboard to_add = new Bitboard();
      int shift = i + j*9;
        if(shift < 64) {
          to_add.a |= SHAPES[z].a << shift;
          if(shift > 24) to_add.b |= SHAPES[z].a >>> (64 - shift);
        } else  {
          to_add.b |= SHAPES[z].a << shift;
        }
        to_add.b = (to_add.b << 47) >> 47;
        o += ((to_add.a & a) == 0 && (to_add.b & b) == 0) ? 1 : 0;
      }
    }
    return o;
  }
  int count_unique_blocks_that_fit() {
    int o = 0;
    for(int z : EVERY_SHAPE) {
      for(int i = 0; i < 10 - SHAPE_WIDTHS[z]; i++) for(int j = 0; j < 10 - SHAPE_HEIGHTS[z]; j++) {
        Bitboard to_add = new Bitboard();
        int shift = i + j*9;
        if(shift < 64) {
          to_add.a |= SHAPES[z].a << shift;
          if(shift > 24) to_add.b |= SHAPES[z].a >>> (64 - shift);
        } else  {
          to_add.b |= SHAPES[z].a << shift;
        }
        to_add.b = (to_add.b << 47) >> 47;
        if((to_add.a & a) == 0 && (to_add.b & b) == 0) {
          o++;
          i = 10; j = 10; break;
        }
      }
    }
    return o;
  }
  void setbit(int x, int y, boolean bit) {
    int n = x + y*9;
    if(bit) {
      if(n < 64)
      a |= 1L << n; else
      b |= 1 << (n-64);
    } else {
      if(n < 64)
      a &= ~(1L << n); else
      b &= ~(1 << (n-64));
    }
  }
  boolean getbit(int x, int y) {
    if(x < 0 || x > 8 || y < 0 || y > 8) return true;
    int n = x + y*9;
    if(n < 64)
    return (a & (1L << n)) != 0;
    return (b & (1 << (n-64))) != 0;
  }
  void togglebit(int x, int y) {
    int n = x + y*9;
    if(n < 64)
    a ^= 1L << n; else
    b ^= 1 << (n-64);
  }
  void resolve() {
    long tmpa = a;
    int tmpb = b;
    for(Bitboard bb : GAME_MASKS) {
      if((a & bb.a) == bb.a && (b & bb.b) == bb.b) {
        tmpa &= ~bb.a;
        tmpb &= ~bb.b;
      }
    }
    a = tmpa;
    b = tmpb;
  }
  void randomize() {
    a |= new Random().nextLong();
    b |= new Random().nextInt();
  }
  void print_nums() {
    println("----------------------------");
    println("A (HEX): " + Long.toHexString(a));
    println("B (HEX): " + Integer.toHexString(b));
    println("A (BIN): " + Long.toBinaryString(a));
    println("B (BIN): " + Integer.toBinaryString(b));
    println("A (DEC): " + a);
    println("B (DEC): " + b);
  }
  void display(float r) {
    blendMode(BLEND);
    stroke(0, 255);
    for(int x = 0; x < 9; x++) {
      for(int y = 0; y < 9; y++) {
        int n = x + y*9;
        if(n < 64) {
          if(((a >> n) & 1)>0)
            rect(x*r, y*r, r, r);
        } else {
          n -= 64;
          if(((b >> n) & 1) == 1)
            rect(x*r, y*r, r, r);
        }
      }
    }
  }
}
