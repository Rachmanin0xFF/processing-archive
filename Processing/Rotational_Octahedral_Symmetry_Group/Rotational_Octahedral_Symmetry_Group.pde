void setup() {
  size(512, 512, P2D);
  gen_Rotations();
}



import java.util.HashSet;
import java.util.Set;

void gen_Rotations() {
  HashSet<iMat3> elements = new HashSet<>();
  elements.add(new iMat3());
  
  // Generating permutation matrices
  int[][] g_pm1 = {{-1, 0, 0}, {0, 1, 0}, {0, 0, 1}};
  int[][] g_pm2 = {{1, 0, 0}, {0, -1, 0}, {0, 0, 1}};
  int[][] g_pm3 = {{0, 1, 0}, {-1, 0, 0}, {0, 0, 1}};
  iMat3 p1 = new iMat3(g_pm1);
  iMat3 p2 = new iMat3(g_pm2);
  iMat3 p3 = new iMat3(g_pm3);
  
  for(int i = 0; i < 5; i++) {
    HashSet<iMat3> toAdd = new HashSet<>();
    for(iMat3 e : elements) {
      toAdd.add(mult(e, p1));
      toAdd.add(mult(e, p2));
      toAdd.add(mult(e, p3));
    }
    elements.addAll(toAdd);
    println(elements.size());
  }
  
  for(iMat3 e : elements) {
    e.print_nice();
  }
}
