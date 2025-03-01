import java.util.HashSet;
import java.util.Set;
import java.util.List;
import java.util.Arrays;

int degree = 6;
boolean save_table = true;

void setup() {
  size(512, 512, P2D);
  /*
  while(degree > 0) {
    int[][] g = gen_symmetric_group(degree, true);
    if(save_table)
      saveStrings("symmetric/A_" + degree + ".txt", to_str_array(g));
    degree--;
  }*/
  int[][] g = gen_D8();
  saveStrings("dihedral/D_8.txt", to_str_array(g));
}

ArrayList<Integer> as_list(int[] x) {
  ArrayList<Integer> o = new ArrayList<Integer>();
  for(int y : x) o.add(y);
  return o;
}

String[] to_str_array(int[][] dat) {
  String[] o = new String[dat.length];
  for(int i = 0; i < dat.length; i++) {
    o[i] = to_str(as_list(dat[i]));
  }
  return o;
}

String to_str(ArrayList<Integer> l) {
  String s = "";
  for(int n : l) s += (n + " ");
  s = s.substring(0, s.length()-1);
  return s;
}

ArrayList<Integer> swap(ArrayList<Integer> x, int ai, int bi) {
  ArrayList<Integer> y = new ArrayList<>(x);
  y.set(ai, x.get(bi));
  y.set(bi, x.get(ai));
  return y;
}

// "applies" the permutation y to the set x
ArrayList<Integer> compose(ArrayList<Integer> x, ArrayList<Integer> y) {
  ArrayList<Integer> o = new ArrayList<Integer>();
  for(int n : y) o.add(x.get(n));
  return o;
}

int factorial(int n) {
  int o = 1; for(int i = 1; i <= n; i++) o *= i;
  return o;
}

float log10(float x) {
  return log(x)/log(10);
}

int[][] gen_symmetric_group(int degree, boolean alternating) {
  if(degree > 7) {
    println("NO!\nYou will run out of heap space.\nYou get identity instead.");
    return new int[][]{{0}};
  }
  if(alternating && degree < 3) {
    println("No! Why do you want this! You get identity instead.");
    return new int[][]{{0}};
  }
  HashSet<ArrayList> elements = new HashSet<>();
  ArrayList<Integer> indices = new ArrayList<Integer>();
  
  // add the identity element
  for(int i = 0; i < degree; i++) indices.add(i);
  elements.add(indices);
  
  // generate the set
  int psize = -1;
  int iterations = 0;
  while(psize != elements.size()) {
    psize = elements.size();
    HashSet<ArrayList<Integer>> toAdd = new HashSet<>();
    for(ArrayList<Integer> e : elements) {
      for(int j = 1; j < degree; j++) {
        if(alternating) {
          toAdd.add(swap(swap(e, 1, 2), 0, j));
        } else {
          toAdd.add(swap(e, 0, j));
        }
      }
    }
    elements.addAll(toAdd);
    iterations++;
  }
  println("Group " + (alternating?"A":"S") + "_" + degree + " generated with order " + elements.size() + " after " + iterations + " iterations.");
  
  // create the Cayley table
  int[][] cayley = new int[elements.size()][elements.size()];
  List<ArrayList<Integer>> list_elems = new ArrayList<>(elements);
  for(int i = 0; i < list_elems.size(); i++) {
    for(int j = 0; j < list_elems.size(); j++) {
      cayley[i][j] = list_elems.indexOf(compose(list_elems.get(i), list_elems.get(j)));
    }
  }
  return cayley;
}

int[][] gen_D8() {
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
  
  int[][] cayley = new int[elements.size()][elements.size()];
  List<iMat3> list_elems = new ArrayList<>(elements);
  for(int i = 0; i < list_elems.size(); i++) {
    list_elems.get(i).print_nice();
    for(int j = 0; j < list_elems.size(); j++) {
      cayley[i][j] = list_elems.indexOf(mult(list_elems.get(i), list_elems.get(j)));
    }
  }
  return cayley;
}
