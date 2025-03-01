
ArrayList<boolean[][]> ALL_SHAPES;
AutoSolver au;

int divv = 0;
void setup() {
  size(225, 225, P2D);
  divv = width/9;
  
  Blocks myset = new Blocks();
  ALL_SHAPES = myset.b;
  au = new AutoSolver();
  frameRate(500);
}
void draw() {
  background(0);
  //bloc.resolve();
  //bloc.display(divv);
  //if(keyPressed) g.board[(int)random(9)][(int)random(9)] = true;
  //g.board = resolve(g.board);
  //println(branch_state(g).size());
  //display(g.board, divv);
  if(au.update()) {
    println(kk);
    kk++;
  }
  au.disp();
}
int kk = 0;
void keyPressed() {
  au = new AutoSolver();
  kk = 0;
}

int get_easiness(boolean[][] board, Blocks shapes) {
  int sum = 0;
  for(int i = 0; i < shapes.b.size(); i++) {
    sum += get_allowable_coords(board, shapes.b.get(i)).size();
  }
  return sum;
}

int get_easiness(boolean[][] board, ArrayList<boolean[][]> shapes) {
  int sum = 0;
  for(int i = 0; i < shapes.size(); i++) {
    sum += get_allowable_coords(board, shapes.get(i)).size();
  }
  return sum;
}


class AutoSolver {
  GameState current_state;
  AutoSolver() {
    current_state = new GameState();
  }
  boolean update() {
    if(current_state.current_shapes.size() == 0) {
      for(int i = 0; i < 3; i++) current_state.current_shapes.add(random_shape());
    }
    ArrayList<GameState> new_states = branch_state(current_state);
    int best = 0;
    for(GameState gs : new_states) {
      int score = gs.complex_goodness_2();
      if(score > best) {
        best = score;
        current_state = gs;
      }
    }
    return best != 0;
  }
  void disp() {
    display(current_state.board, divv);
  }
}

boolean[][] random_shape() {
  return ALL_SHAPES.get((int)random(ALL_SHAPES.size()));
}


// could use bitboards for speed in the future
class GameState {
  boolean[][] board;
  ArrayList<boolean[][]> current_shapes;
  ArrayList<Move> history;
  GameState() {
    board = new boolean[9][9];
    current_shapes = new ArrayList<boolean[][]>();
    history = new ArrayList<Move>();
  }
  GameState(boolean[][] b, ArrayList<boolean[][]> cs) {
    board = cpbb(b);
    current_shapes = new ArrayList<boolean[][]>();
    for(boolean[][] s : cs) {
      current_shapes.add(s);
    }
    history = new ArrayList<Move>();
  }
  GameState(GameState g) {
    board = cpbb(g.board);
    current_shapes = new ArrayList<boolean[][]>();
    for(boolean[][] s : g.current_shapes) {
      current_shapes.add(s);
    }
    history = new ArrayList<Move>();
  }
  int simple_goodness() {
    return get_easiness(board, current_shapes.size() == 0 ? ALL_SHAPES : current_shapes);
  }
  int very_simple_goodness() {
    int q = 0;
    for(int x = 0; x < board.length; x++) for(int y = 0; y < board[x].length; y++) {
      q += board[x][y]?0:1;
    }
    for(int x = 1; x < board.length-1; x++) for(int y = 1; y < board[x].length-1; y++) {
      int z = 0;
      if(!board[x][y]) {
        z += test(x-1, y) ? 1 : 0;
        z += test(x+1, y) ? 1 : 0;
        z += test(x, y+1) ? 1 : 0;
        z += test(x, y-1) ? 1 : 0;
      }
      if(z >= 3) {
        q -= 1;
      }
      if(z == 4) {
        q -= 3;
      }
    }
    return q;
  }
  boolean test(int x, int y) {
    return (x < 0 || x >= board.length || y < 0 || y > board[0].length) || board[x][y];
  }
  int complex_goodness() {
    ArrayList<GameState> sts = branch_state(this);
    int k = 0;
    for(GameState gs : sts) {
      k += gs.very_simple_goodness();
    }
    return k;
  }
  int complex_goodness_2() {
    ArrayList<GameState> sts = branch_state(this);
    int k = 0;
    for(GameState gs : sts) {
      if(gs.current_shapes.size()==0)
      k += gs.very_simple_goodness();
      else
      k += gs.complex_goodness();
    }
    return k;
  }
}

ArrayList<GameState> branch_states(ArrayList<GameState> gs_list) {
  ArrayList<GameState> out = new ArrayList<GameState>();
  for(GameState gs : gs_list) {
    out.addAll(branch_state(gs));
  }
  return out;
}
ArrayList<GameState> branch_state(GameState gs) {
  ArrayList<GameState> out = new ArrayList<GameState>();
  
  ArrayList<boolean[][]> shapes = gs.current_shapes.size() > 0 ? gs.current_shapes : ALL_SHAPES;
  for(int i = 0; i < shapes.size(); i++) {
    GameState gs_i = new GameState(gs);
    if(gs.current_shapes.size() > 0) gs_i.current_shapes.remove(i);
    boolean[][] shape = shapes.get(i);
    ArrayList<int[]> coords = get_allowable_coords(gs.board, shape);
    for(int[] cj : coords) {
      GameState gs_ij = new GameState(gs_i);
      place(gs_ij.board, shape, cj[0], cj[1]);
      gs_ij.history.add(new Move(i, cj[0], cj[1]));
      gs_ij.board = resolve(gs_ij.board);
      out.add(gs_ij);
    }
  }
  
  return out;
}


class Game {
  final int BLOCKS_PER_SET = 3;
  
  boolean[][] board;
  Blocks shapes;
  ArrayList<Integer> available_shapes = new ArrayList<Integer>();
  Game() {
    board = new boolean[9][9];
    shapes = new Blocks();
    get_new_shapes();
  }
  void get_new_shapes() {
    for(int i = 0; i < BLOCKS_PER_SET; i++) available_shapes.add((int)random(shapes.b.size()));
  }
  void step_auto() {
    Move m = get_next_move();
    place(board, shapes.b.get(available_shapes.get(m.shape)), m.x, m.y);
    board = resolve(board);
    available_shapes.remove(m.shape);
    if(available_shapes.size() == 0) get_new_shapes();
  }
  Move get_next_move() {
    Move best = null;
    
    int best_score = 0;
    for(int i = 0; i < available_shapes.size(); i++) {
      boolean[][] shape = shapes.b.get(available_shapes.get(i));
      ArrayList<int[]> coords = get_allowable_coords(board, shape);
      for(int[] c : coords) {
        boolean[][] nb = get_placed(board, shape, c[0], c[1]);
        nb = resolve(nb);
        
        ArrayList<boolean[][]> cshapes = new ArrayList<boolean[][]>();
        for(int ii = 0; ii < available_shapes.size(); ii++) {
          if(ii != i) cshapes.add(shapes.b.get(available_shapes.get(ii)));
        }
        if(cshapes.size() == 0) cshapes = shapes.b;
        
        int score = get_easiness(nb, cshapes);
        if(score > best_score) {
          best_score = score;
          best = new Move(i, c[0], c[1]);
        }
        
      }
    }
    
    return best;
  }
}
class Move {
  int shape;
  int x;
  int y;
  Move(int shape, int x, int y) {
    this.shape = shape;
    this.x = x;
    this.y = y;
  }
}


// this could be optimized a LOT
// also optimize across pieces with piece subset tree
ArrayList<int[]> get_allowable_coords(boolean[][] board, boolean[][] shape) {
  ArrayList<int[]> out = new ArrayList<int[]>();
  for(int x = 0; x < board.length - shape.length+1; x++) {
    for(int y = 0; y < board[0].length - shape[0].length+1; y++) {
      boolean good = true;
      for(int x2 = 0; (x2 < shape.length) && good; x2++) {
        for(int y2 = 0; (y2 < shape[0].length) && good; y2++) {
          good &= !(shape[x2][y2] && board[x+x2][y+y2]);
        }
      }
      if(good) out.add(new int[]{x, y});
    }
  }
  return out;
}

boolean[][] cpbb(boolean[][] b) {
  boolean[][] bb = new boolean[b.length][b[0].length];
  for(int i = 0; i < b.length; i++) for(int j = 0; j < b[i].length; j++) {
    bb[i][j] = b[i][j];
  }
  return bb;
}

boolean[][] get_placed(boolean[][] board, boolean[][] shape, int xc, int yc) {
  boolean[][] b = cpbb(board);
  for(int x = 0; x < shape.length; x++) for(int y = 0; y < shape[x].length; y++) {
    b[x+xc][y+yc] |= shape[x][y];
  }
  return b;
}

void place(boolean[][] board, boolean[][] shape, int xc, int yc) {
  for(int x = 0; x < shape.length; x++) for(int y = 0; y < shape[x].length; y++) {
    if(board[x+xc][y+yc] && shape[x][y]) println("BAD PLACEMENT!");
    board[x+xc][y+yc] |= shape[x][y];
  }
}

boolean[][] or(boolean[][] a, boolean[][] b) {
  boolean[][] o = new boolean[a.length][a[0].length];
  for(int i = 0; i < a.length; i++) for(int j = 0; j < a[0].length; j++) {
    o[i][j] = a[i][j] | b[i][j];
  }
  return o;
}

// There are 34 total allowable shapes:

// BLIPS (Trivial Group)
// -- Dot
// -- Square or 2-Dot
// -- Plus

// RODS (C2 group)
// -- 2-Line (x2)
// -- 3-Line (x2)
// -- 4-Line (x2)
// -- 5-Line (x2)

// SHAPES (C4 group)
// -- Corner (x4)
// -- Big Corner (x4)
// -- T-Junction (x4)
// -- Big T (x4)

// GLYPHS (D2 group, I think?)
// -- S-Curve (x2)
// -- Z-Curve (x2)

class Blocks {
  ArrayList<boolean[][]> b = new ArrayList<boolean[][]>();
  Blocks() {
    String[] s = loadStrings("blocks.txt");
    int line = 0;
    ArrayList<boolean[]> cb = new ArrayList<boolean[]>();
    while(line < s.length) {
      if(s[line].startsWith("--")) {
        if(cb.size() != 0) {
          boolean[][] to_add = new boolean[cb.size()][cb.get(0).length];
          for(int i = 0; i < cb.size(); i++) for(int j = 0; j < cb.get(0).length; j++) {
            to_add[i][j] = cb.get(i)[j];
            print(to_add[i][j]?'0':' ');
            if(j == cb.get(0).length-1) println("");
          }
          println("--");
          b.add(to_add);
        }
        cb = new ArrayList<boolean[]>();
        line++;
      } else {
        boolean[] converted = new boolean[s[line].length()];
        for(int i = 0; i < converted.length; i++) {
          converted[i] = (s[line].charAt(i) == '1');
        }
        cb.add(converted);
        line++;
      }
    }
    println(b.size() + " unique blocks loaded");
  }
}


void display(boolean[][] b, float r) {
  fill(242, 218, 50);
  for(int x = 0; x < b.length; x++) for(int y = 0; y < b[x].length; y++) {
    if(b[x][y]) rect(x*r, y*r, r, r);
  }
}
boolean[][] resolve(boolean[][] b) {
  boolean[][] b2 = new boolean[9][9];
  for(int x = 0; x < 9; x++) for(int y = 0; y < 9; y++) {
    b2[x][y] = b[x][y];
  }
  
  for(int i = 0; i < 9; i++) {
    boolean a0 = true;
    boolean a1 = true;
    for(int j = 0; j < 9; j++) {
      a0 &= b[i][j];
      a1 &= b[j][i];
    }
    if(a0 || a1) {
      for(int j = 0; j < 9; j++) {
        if(a0) b2[i][j] = false;
        if(a1) b2[j][i] = false;
      }
    }
    int y = (i/3)*3;
    int x = (i%3)*3;
    if(b[x][y]   && b[x+1][y]   && b[x+2][y]   &&
       b[x][y+1] && b[x+1][y+1] && b[x+2][y+1] &&
       b[x][y+2] && b[x+1][y+2] && b[x+2][y+2])
    {
       b2[x][y] = false;   b2[x+1][y] = false;   b2[x+2][y] = false; 
       b2[x][y+1] = false; b2[x+1][y+1] = false; b2[x+2][y+1] = false; 
       b2[x][y+2] = false; b2[x+1][y+2] = false; b2[x+2][y+2] = false; 
    }
  }
  return b2;
}
