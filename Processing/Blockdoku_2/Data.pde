Bitboard[] SHAPES = new Bitboard[]{
  new Bitboard(1L, 0),
  new Bitboard(1539L, 0),
  new Bitboard(527874L, 0),
  new Bitboard(513L, 0),
  new Bitboard(262657L, 0),
  new Bitboard(134480385L, 0),
  new Bitboard(68853957121L, 0),
  new Bitboard(3L, 0),
  new Bitboard(7L, 0),
  new Bitboard(15L, 0),
  new Bitboard(31L, 0),
  new Bitboard(1538L, 0),
  new Bitboard(1027L, 0),
  new Bitboard(515L, 0),
  new Bitboard(1537L, 0),
  new Bitboard(1837060L, 0),
  new Bitboard(1050631L, 0),
  new Bitboard(262663L, 0),
  new Bitboard(1835521L, 0),
  new Bitboard(263681L, 0),
  new Bitboard(3586L, 0),
  new Bitboard(525826L, 0),
  new Bitboard(1031L, 0),
  new Bitboard(265729L, 0),
  new Bitboard(1836034L, 0),
  new Bitboard(1052164L, 0),
  new Bitboard(525319L, 0),
  new Bitboard(263682L, 0),
  new Bitboard(3075L, 0),
  new Bitboard(525825L, 0),
  new Bitboard(1542L, 0),
  new Bitboard(514L, 0),
  new Bitboard(1025L, 0),
  new Bitboard(263172L, 0),
  new Bitboard(1049601L, 0),
  new Bitboard(786947L, 0),
  new Bitboard(787459L, 0),
  new Bitboard(2567L, 0),
  new Bitboard(3589L, 0)
};

int[] SHAPE_WIDTHS = new int[]{
  1, 2, 3, 1, 1, 1, 1, 2, 3, 4, 5, 2, 2, 2, 2, 3, 3, 3, 3, 2, 3, 2, 3, 3, 3, 3, 3, 2, 3, 2, 3, 2, 2, 3, 3, 2, 2, 3, 3
};
int[] SHAPE_HEIGHTS = new int[]{
  1, 2, 3, 2, 3, 4, 5, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3, 2, 3, 2, 3, 3, 3, 3, 3, 2, 3, 2, 2, 2, 3, 3, 3, 3, 2, 2
};

int[] EVERY_SHAPE = new int[]{
  0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38
};


Bitboard[] GAME_MASKS = new Bitboard[]{
  // HORIZONTAL LINES
  new Bitboard(((long)0x1ff), 0),
  new Bitboard(((long)0x1ff)<<9, 0),
  new Bitboard(((long)0x1ff)<<18, 0),
  new Bitboard(((long)0x1ff)<<27, 0),
  new Bitboard(((long)0x1ff)<<36, 0),
  new Bitboard(((long)0x1ff)<<45, 0),
  new Bitboard(((long)0x1ff)<<54, 0),
  new Bitboard(((long)0x1ff)<<63, 0xff),
  new Bitboard(0, 0x1ff00),
  // VERTICAL LINES
  new Bitboard(-9205322385119247871L, 256),
  new Bitboard(36099303471055874L, 513),
  new Bitboard(72198606942111748L, 1026),
  new Bitboard(144397213884223496L, 2052),
  new Bitboard(288794427768446992L, 4104),
  new Bitboard(577588855536893984L, 8208),
  new Bitboard(1155177711073787968L, 16416),
  new Bitboard(2310355422147575936L, 32832),
  new Bitboard(4620710844295151872L, 65664),
  // SQUARES
  new Bitboard(1838599L, 0),
  new Bitboard(246772580483072L, 0),
  new Bitboard(-9097271247288401920L, 1795),
  new Bitboard(14708792L, 0),
  new Bitboard(1974180643864576L, 0),
  new Bitboard(1008806316530991104L, 14364),
  new Bitboard(117670336L, 0),
  new Bitboard(15793445150916608L, 0),
  new Bitboard(8070450532247928832L, 114912),
};


void printall() {
  println("");
  for(int i = 0; i < 9; i++) {
    Bitboard bb = new Bitboard();
    for(int j = 0; j < 9; j++)
      bb.setbit(j, i, true);
    println("new Bitboard(" + bb.a + "L, " + bb.b + "),");
  }
  println("");
  for(int i = 0; i < 9; i++) {
    Bitboard bb = new Bitboard();
    for(int j = 0; j < 9; j++)
      bb.setbit(i, j, true);
    println("new Bitboard(" + bb.a + "L, " + bb.b + "),");
  }
  println("");
  for(int i = 0; i < 3; i++) {
    for(int j = 0; j < 3; j++) {
      Bitboard bb = new Bitboard();
      for(int x = 0; x < 3; x++) for(int y = 0; y < 3; y++) {
      bb.setbit(i*3+x, j*3+y, true);
      }
      println("new Bitboard(" + bb.a + "L, " + bb.b + "),");
    }
  }
}

void print_shapes() {
  ArrayList<boolean[][]> blks = new Blocks().b;
  for(boolean[][] arr : blks) {
    Bitboard bb = new Bitboard();
    for(int x = 0; x < arr.length; x++) for(int y = 0; y < arr[x].length; y++) {
      if(arr[x][y]) bb.setbit(x, y, true);
    }
    println("new Bitboard(" + bb.a + "L, " + bb.b + "),");
    //print(arr.length + ", ");
    //print(arr[0].length + ", ");
  }
  println("\n");
  for(boolean[][] arr : blks) print(arr.length + ", ");
  println("\n");
  for(boolean[][] arr : blks) print(arr[0].length + ", ");
}

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
