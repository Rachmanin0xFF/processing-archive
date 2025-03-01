Network mynet;

int DIMENSIONS = 4;

void setup() {
  size(512, 512, P2D);
  make_graph();
}

void keyPressed() {
  make_graph();
}

void make_graph() {
  mynet = new Network();
  for(int i = 0; i < 5; i++) {
    float[] comps = new float[DIMENSIONS];
    for(int j = 0; j < DIMENSIONS; j++) {
      comps[j] = randomGaussian();
      if(j==0 || j==1) comps[j] += width/2;
    }
    mynet.add_node(new Node(comps));
  }
  float a = random(300);
  float b = random(300);
  float c = random(300);
  float d = random(300);
  float e = random(300);
  println(a, b, c, d);
  
  mynet.add_edge(0, 1, a);
  mynet.add_edge(1, 2, b);
  mynet.add_edge(2, 3, c);
  mynet.add_edge(3, 4, d);
  mynet.add_edge(4, 0, e);
  
  mynet.add_edge(0, 2, min(a+b, c+d+e));
  mynet.add_edge(1, 3, min(b+c, a+d+e));
  mynet.add_edge(2, 4, min(c+d, a+b+e));
  mynet.add_edge(3, 0, min(d+e, a+b+c));
  mynet.add_edge(4, 0, min(e+a, b+c+d));
}

void draw() {
  background(0);
  stroke(255);
  mynet.display();
  //for(int i = 0; i < 500; i++) mynet.solve_embedding_step(0.2);
  float strain = mynet.solve_embedding_step(0.3);
  text(strain, 10, 10);
}

class Node {
  Vecf r;
  Vecf f;
  public Node(float... components) {
    r = new Vecf(components);
    f = zeroesLike(r);
  }
  void add_force(Vecf dr) {
    f.add(dr);
  }
  void update_force(float dt) {
    r.add(mult(f, dt));
    f = zeroesLike(f);
  }
  void display() {
    point(r.components[0], r.components[1]);
  }
}
class Edge {
  int a;
  int b;
  float l;
  float strain;
  public Edge(int aa, int bb, float ll) {
    this.a = aa;
    this.b = bb;
    this.l = ll;
  }
}

class Network {
  ArrayList<Node> nodes; // indices are immutable, im not using pointers (don't delete nodes)
  ArrayList<Edge> edges;
  public Network() {
    nodes = new ArrayList<Node>();
    edges = new ArrayList<Edge>();
  }
  void add_node(Node n) {
    nodes.add(n);
  }
  void add_edge(Edge e) {
    edges.add(e);
  }
  void add_edge(int a, int b, float l) {
    edges.add(new Edge(a, b, l));
  }
  float solve_embedding_step(float dt) {
    float strain = 0.0;
    for(Edge e : edges) {
      Node n1 = nodes.get(e.a);
      Node n2 = nodes.get(e.b);
      
      Vecf r1 = n1.r;
      Vecf r2 = n2.r;
      
      Vecf vec_to = sub(r1, r2);
      float sep = magnitude(vec_to);
      float hooke = e.l - sep;
      e.strain = abs(hooke);
      strain += e.strain;
      
      
      Vecf direction = mult(vec_to, 1.0 / abs(sep));
      
      Vecf force_1 = mult(direction, hooke);
      Vecf force_2 = mult(direction, -hooke);
      
      n1.add_force(force_1);
      n2.add_force(force_2);
    }
    for(Node n : nodes) {
      n.update_force(dt);
    }
    return strain;
  }
  void display() {
    for(Node n : nodes) {
      n.display();
    }
    for(Edge e : edges) {
      Node n1 = nodes.get(e.a);
      Node n2 = nodes.get(e.b);
      float max_strain = 100.0;
      stroke(e.strain/max_strain*255.0, 255.0 - e.strain/max_strain*255.0, 10.0);
      line(n1.r.components[0], n1.r.components[1], n2.r.components[0], n2.r.components[1]);
    }
  }
}
