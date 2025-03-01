void physics(Phys ob) {
  ob.physUp();



  stroke(255, 0, 0);
  line(ob.x+0.5*ob.size, ob.y+0.5*ob.size, ob.x+0.5*ob.size+ob.v.x*5, ob.y+0.5*ob.size+ob.v.y*5);
  stroke(0);
  println("####################### BEGIN FIZZ #######################");
  println("V:", ob.v.x, ob.v.y);
  ob.v.y=0.1;
  for (int run=0; run<2; run++) {
    int lasthit=-1;
    float dist=1;
    int closest=0;
    int point=0;
    ArrayList<Edge> local=buildLocal(toChunk(ob.x),bicX(ob.x),bicY(ob.y),3);
    for (int ei=0; ei<local.size(); ei++) {
      Edge e=local.get(ei);
      Edge a=new Edge(ob.x, ob.y, ob.x+ob.v.x, ob.y+ob.v.y);
      Edge b=new Edge(ob.x, ob.y+ob.size, ob.x+ob.v.x, ob.y+ob.v.y+ob.size);
      Edge c=new Edge(ob.x+ob.size, ob.y+ob.size, ob.x+ob.v.x+ob.size, ob.y+ob.v.y+ob.size);
      Edge d=new Edge(ob.x+ob.size, ob.y, ob.x+ob.v.x+ob.size, ob.y+ob.v.y);

      Edge f=new Edge(e.a.x-ob.v.x, e.a.y-ob.v.y, e.a.x, e.a.y);
      Edge g=new Edge(e.b.x-ob.v.x, e.b.y-ob.v.y, e.b.x, e.b.y);

      //Edge j=new Edge(ob.x+ob.v.x, ob.y+ob.v.y, ob.x+ob.size+ob.v.x, ob.y+ob.v.y);
      //Edge k=new Edge(ob.x+ob.v.x, ob.y+ob.size+ob.v.y, ob.x+ob.size+ob.v.x, ob.y+ob.size+ob.v.y);
      //Edge l=new Edge(ob.x+ob.v.x, ob.y+ob.v.y, ob.x+ob.v.x, ob.y+ob.v.y+ob.size);
      //Edge m=new Edge(ob.x+ob.v.x, ob.y+ob.v.y, ob.x+ob.v.x, ob.y+ob.v.y+ob.size);
      PVector obPos =new PVector(ob.x, ob.y);

      Edge j=new Edge(PVector.add(obPos, ob.v), 0, ob.size);
      Edge k=new Edge(PVector.add(obPos, ob.v), ob.size, 0);
      obPos.x+=ob.size;
      obPos.y+=ob.size; 
      Edge l=new Edge(PVector.add(obPos, ob.v), 0, -ob.size);
      Edge m=new Edge(PVector.add(obPos, ob.v), -ob.size, 0);
      
      obPos =new PVector(ob.x, ob.y);
      Edge n=new Edge(obPos, 0, ob.size);
      Edge o=new Edge(obPos, ob.size, 0);
      obPos.x+=ob.size;
      obPos.y+=ob.size; 
      Edge p=new Edge(obPos, 0, -ob.size);
      Edge q=new Edge(obPos, -ob.size, 0);
      //boolean inside = (ob.x+ob.v.x<e.a.x&&e.a.x<ob.x+ob.v.x+ob.size&&ob.y+ob.v.y<e.a.y&&e.a.y<ob.y+ob.size+ob.v.y)||(ob.x+ob.v.x<e.b.x&&e.b.x<ob.x+ob.v.x+ob.size&&ob.y+ob.v.y<e.b.y&&e.b.y<ob.y+ob.v.y+ob.size);
      PVector dues=PVector.mult(ob.v, 1);
      boolean inside=(insideBox(ob.x+dues.x, ob.y+dues.y, ob.size, ob.size, e.a)&&!insideBox(ob.x, ob.y, ob.size, ob.size, e.a))&&(insideBox(ob.x+dues.x, ob.y+dues.y, ob.size, ob.size, e.b)&&!insideBox(ob.x, ob.y, ob.size, ob.size, e.a));

      // inside, insideBox(ob.x+ob.v.x, ob.y+ob.v.y, ob.size, ob.size, e.a), insideBox(ob.x+ob.v.x, ob.y+ob.v.y, ob.size, ob.size, e.b));
      boolean eIntersect=(j.intersectOpenInterval(e)||k.intersectOpenInterval(e)||l.intersectOpenInterval(e)||m.intersectOpenInterval(e));
      boolean fIntersect=(n.intersectOpenInterval(f)||o.intersectOpenInterval(f)||p.intersectOpenInterval(f)||q.intersectOpenInterval(f));
      boolean gIntersect=(n.intersectOpenInterval(g)||o.intersectOpenInterval(g)||p.intersectOpenInterval(g)||q.intersectOpenInterval(g));
      println(eIntersect, fIntersect, gIntersect, inside,"\t", j.intersectOpenInterval(e), k.intersectOpenInterval(e), l.intersectOpenInterval(e), m.intersectOpenInterval(e));
      if (eIntersect||fIntersect||gIntersect||inside) {
        println("edge: ", ei, "\t", f.a.x, f.a.y, f.b.x, f.b.y);
        if (a.intersect(e))if (dist>a.intersectAmt(e)) {
          dist=a.intersectAmt(e);
          closest=ei;
          point=0;
        }
        if (b.intersect(e))if (dist>b.intersectAmt(e)) {
          dist=b.intersectAmt(e);
          closest=ei;
          point=0;
        }
        if (c.intersect(e))if (dist>c.intersectAmt(e)) {
          dist=c.intersectAmt(e);
          closest=ei;
          point=0;
        }
        if (d.intersect(e))if (dist>d.intersectAmt(e)) {
          dist=d.intersectAmt(e);
          closest=ei;
          point=0;
        }

        // A
        if (f.intersect(n))if (dist>1-f.intersectAmt(n)) {
          dist=1-f.intersectAmt(n);
          closest=ei;
          point=1;
        }
        if (g.intersect(n))if (dist>1-g.intersectAmt(n)) {
          dist=1-g.intersectAmt(n);
          closest=ei;
          point=1;
        }
        // B
        if (f.intersect(o))if (dist>1-f.intersectAmt(o)) {
          dist=1-f.intersectAmt(o);
          closest=ei;
          point=2;
        }
        if (g.intersect(o))if (dist>1-g.intersectAmt(o)) {
          dist=1-g.intersectAmt(o);
          closest=ei;
          point=2;
        }
        // C
        if (f.intersect(p))if (dist>1-f.intersectAmt(p)) {
          dist=1-f.intersectAmt(p);
          closest=ei;
          point=1;
        }
        if (g.intersect(p))if (dist>1-g.intersectAmt(p)) {
          dist=1-g.intersectAmt(p);
          closest=ei;
          point=1;
        }
        // D
        if (f.intersect(q))if (dist>1-f.intersectAmt(q)) {
          dist=1-f.intersectAmt(q);
          closest=ei;
          point=2;
        }
        if (g.intersect(q))if (dist>1-g.intersectAmt(q)) {
          dist=1-g.intersectAmt(q);
          closest=ei;
          point=2;
        }
      }
    }


    ob.x+=ob.v.x*dist;
    ob.y+=ob.v.y*dist;
    if (dist<1) {
      PVector tempVec=new PVector();
      if (point==0)tempVec=local.get(closest).vec().copy();
      else if (point==1)tempVec=new PVector( 0,1);
      else tempVec=new PVector(1,0);
      ob.v=PVector.mult(tempVec.normalize(), ob.v.copy().dot(tempVec.normalize()));
      //else ob.v.set(0,0);
    } //else run++;
    println(dist, ob.x, ob.y,"V:", ob.v.x, ob.v.y);
  }
  //
}


class Phys {
  float x;
  float y;
  PVector v=new PVector(0, 0);
  PVector d=new PVector(0, 0);
  int size=30;
  Phys(float x, float y) {
    this.x=x;
    this.y=y;
  }
  void draw() {
    rect(x, y, size, size);
    line(x+size/2, y+size/2, x+size/2+v.x, y+size/2+v.y);
    //println(isContact(this));
  }
  void physUp() {
    if (true) {
      //v.x*=0.5;
      if (keyPressed&&key=='a') {
        v.x=-3;
      }
      if (keyPressed&&key=='d') {
        v.x=3;
      }
      if (keyPressed&&key=='w') {
        v.y=+4;
        //println(v.y);
      }
    }
  }
}

ArrayList<Phys> P=new ArrayList<Phys>();

class Edge {
  PVector a;
  PVector b;
  Edge(float lx, float ly, float dx, float dy) {
    a=new PVector(lx, ly);
    b=new PVector(dx, dy);
  }
  Edge(float x, float y, PVector delta) {
    a=new PVector(x, y);
    b=PVector.add(a, delta);
  }
  Edge(PVector pos, float x, float y) {
    a=pos.copy();
    b=a.copy();
    b.x+=x;
    b.y+=y;
  }
  //boolean intersect(edge e){
  //  float t=(e.l.sub(l).cross(e.d)).z/e.d.cross(l).z;
  //  float u=(l.sub(e.l).cross(d)).z/d.cross(e.l).z;
  //  println(t,u);
  //  return false;
  //  //t = (q − p) × s / (r × s);
  //}
  boolean intersect(Edge e) {
    PVector A=a;
    PVector B=b;
    PVector C=e.a;
    PVector D=e.b;
    float denom=(D.y-C.y)*(B.x-A.x)-(D.x-C.x)*(B.y-A.y);
    float ua=(D.x-C.x)*(A.y-C.y)-(D.y-C.y)*(A.x-C.x);
    float ub=(B.x-A.x)*(A.y-C.y)-(B.y-A.y)*(A.x-C.x);
    ua/=denom;
    ub/=denom;
    //println(ua, ub);
    return -0.01<=ua&&ua<=1.05&&-0.01<=ub&&ub<=1.01;
  }
  boolean intersectOpenInterval(Edge e) {
    PVector A=a;
    PVector B=b;
    PVector C=e.a;
    PVector D=e.b;
    float denom=(D.y-C.y)*(B.x-A.x)-(D.x-C.x)*(B.y-A.y);
    float ua=(D.x-C.x)*(A.y-C.y)-(D.y-C.y)*(A.x-C.x);
    float ub=(B.x-A.x)*(A.y-C.y)-(B.y-A.y)*(A.x-C.x);
    ua/=denom;
    ub/=denom;
    //println(ua, ub);
    return 0<ua&&ua<1&&0<ub&&ub<1;
  }
  PVector intersectPoint(Edge e) {
    PVector A=a;
    PVector B=b;
    PVector C=e.a;
    PVector D=e.b;
    float denom=(D.y-C.y)*(B.x-A.x)-(D.x-C.x)*(B.y-A.y);
    float ua=(D.x-C.x)*(A.y-C.y)-(D.y-C.y)*(A.x-C.x);
    //float ub=(B.x-A.x)*(A.y-C.y)-(B.y-A.y)*(A.x-C.x);
    ua/=denom;
    //ub/=denom;
    float ix=A.x+ua*(B.x-A.x);
    float iy=A.y+ua*(B.y-A.y);
    return new PVector(ix, iy);
  }
  float intersectAmt(Edge e) {
    PVector A=a;
    PVector B=b;
    PVector C=e.a;
    PVector D=e.b;
    float denom=(D.y-C.y)*(B.x-A.x)-(D.x-C.x)*(B.y-A.y);
    float ua=(D.x-C.x)*(A.y-C.y)-(D.y-C.y)*(A.x-C.x);
    //float ub=(B.x-A.x)*(A.y-C.y)-(B.y-A.y)*(A.x-C.x);
    ua/=denom;
    //ub/=denom;
    //float ix=A.x+ua*(B.x-A.x);
    //float iy=A.y+ua*(B.y-A.y);
    return ua;
  }
  PVector vec() {
    return PVector.sub(a, b);
  }
  void draw() {
    line(a.x+mp_scroll, a.y, b.x+mp_scroll, b.y);
  }
}

//boolean insideBox(float x, float y, float w, float h, PVector p) {
//  return p.x-x>1&&x+w-p.x>1&&p.y-y>1&&y+h-p.y>1;
//}
boolean insideBox(float x, float y, float w, float h, PVector p) {
 return x<p.x&&p.x<x+w&&y<p.y&&p.y<y+h;
}
class EdgeList{
  ArrayList<Edge> edges=new ArrayList<Edge>();
  int chunk;
  EdgeList(int chunk){
    this.chunk=chunk;
  }
  void add(int u,int v,float x1,float y1,float x2,float y2){
    x1*=SPRITE_GRID;
    y1*=SPRITE_GRID;
    x2*=SPRITE_GRID;
    y2*=SPRITE_GRID;
    edges.add(new Edge((chunk*Chunk.CHUNK_U+u)*SPRITE_GRID+x1,v*SPRITE_GRID+y1,(chunk*Chunk.CHUNK_U+u)*SPRITE_GRID+x2,v*SPRITE_GRID+y2));
  }
}

ArrayList<Edge> buildLocal(int chunk, int u, int v, int radius) {
  EdgeList edges=new EdgeList(chunk);
  println("asdfa",max(0, u-radius), min(Chunk.CHUNK_U, u+radius));
  for (int i=max(0, u-radius); i<min(Chunk.CHUNK_U, u+radius); i++) {
    for (int j=max(0, v-radius); j<min(Chunk.CHUNK_V, v+radius); j++) {
      //println(i,j);
      int shape=getBlockPhys(chunk, i, j);
      int block=getBlock(chunk, i, j);
      //println("blockdat: ",block);
        if (block%1000==1||block%1000==2||block%1000==3||block%1000==4||block%1000==5) {
        if (getBlock(chunk, i, j-1)==0) {
          //bottom
          println("wut");
          edges.add(i, j,0,1,1,1);
        }
        if (getBlock(chunk, i, j+1)==0) {
          //bottom
          println("wut");
          edges.add(i, j,0,0,1,0);
        }
      }
    }
  }
  return edges.edges;
}