void physics(Phys ob) {
  ob.physUp();
  ob.draw();
  float frameAdjust=60/frameRate;
  ob.v.y+=0.4;

  PVector av=(ob.v.copy()).mult(frameAdjust);
  stroke(255, 0, 0);
  //line(ob.x+0.5*ob.size, ob.y+0.5*ob.size, ob.x+0.5*ob.size+av.x*5, ob.y+0.5*ob.size+av.y*5);
  stroke(0);
  //println("####################### BEGIN FIZZ #######################");
  //println("V:", av.x, av.y);

  for (int run=0; run<2; run++) {
    av=(ob.v.copy()).mult(frameAdjust);
    float dist=1;
    int closest=0;
    int point=0;
    boolean trad=false;
    ArrayList<Edge> local=buildLocal(toChunk(ob.x), bicX(ob.x), bicY(ob.y), 6);
    for (int ei=0; ei<local.size(); ei++) {
      Edge e=local.get(ei);
      e.draw();
      Edge a=new Edge(ob.x, ob.y, ob.x+av.x, ob.y+av.y);
      Edge b=new Edge(ob.x, ob.y+ob.size, ob.x+av.x, ob.y+av.y+ob.size);
      Edge c=new Edge(ob.x+ob.size, ob.y+ob.size, ob.x+av.x+ob.size, ob.y+av.y+ob.size);
      Edge d=new Edge(ob.x+ob.size, ob.y, ob.x+av.x+ob.size, ob.y+av.y);

      Edge f=new Edge(e.a.x-av.x, e.a.y-av.y, e.a.x, e.a.y);
      Edge g=new Edge(e.b.x-av.x, e.b.y-av.y, e.b.x, e.b.y);

      //Edge j=new Edge(ob.x+av.x, ob.y+av.y, ob.x+ob.size+av.x, ob.y+av.y);
      //Edge k=new Edge(ob.x+av.x, ob.y+ob.size+av.y, ob.x+ob.size+av.x, ob.y+ob.size+av.y);
      //Edge l=new Edge(ob.x+av.x, ob.y+av.y, ob.x+av.x, ob.y+av.y+ob.size);
      //Edge m=new Edge(ob.x+av.x, ob.y+av.y, ob.x+av.x, ob.y+av.y+ob.size);
      PVector obPos =new PVector(ob.x, ob.y);

      Edge j=new Edge(PVector.add(obPos, av), 0, ob.size);
      Edge k=new Edge(PVector.add(obPos, av), ob.size, 0);
      obPos.x+=ob.size;
      obPos.y+=ob.size; 
      Edge l=new Edge(PVector.add(obPos, av), 0, -ob.size);
      Edge m=new Edge(PVector.add(obPos, av), -ob.size, 0);

      obPos =new PVector(ob.x, ob.y);
      Edge n=new Edge(obPos, 0, ob.size);
      Edge o=new Edge(obPos, ob.size, 0);
      obPos.x+=ob.size;
      obPos.y+=ob.size; 
      Edge p=new Edge(obPos, 0, -ob.size);
      Edge q=new Edge(obPos, -ob.size, 0);
      //boolean inside = (ob.x+av.x<e.a.x&&e.a.x<ob.x+av.x+ob.size&&ob.y+av.y<e.a.y&&e.a.y<ob.y+ob.size+av.y)||(ob.x+av.x<e.b.x&&e.b.x<ob.x+av.x+ob.size&&ob.y+av.y<e.b.y&&e.b.y<ob.y+av.y+ob.size);
      PVector dues=PVector.mult(av, 1);
      boolean inside=(insideBox(ob.x+dues.x, ob.y+dues.y, ob.size, ob.size, e.a)&&!insideBox(ob.x, ob.y, ob.size, ob.size, e.a))&&(insideBox(ob.x+dues.x, ob.y+dues.y, ob.size, ob.size, e.b)&&!insideBox(ob.x, ob.y, ob.size, ob.size, e.a));

      // inside, insideBox(ob.x+av.x, ob.y+av.y, ob.size, ob.size, e.a), insideBox(ob.x+av.x, ob.y+av.y, ob.size, ob.size, e.b));
      boolean eIntersect=(j.intersectOpenInterval(e)||k.intersectOpenInterval(e)||l.intersectOpenInterval(e)||m.intersectOpenInterval(e));
      boolean fIntersect=(n.intersectOpenInterval(f)||o.intersectOpenInterval(f)||p.intersectOpenInterval(f)||q.intersectOpenInterval(f));
      boolean gIntersect=(n.intersectOpenInterval(g)||o.intersectOpenInterval(g)||p.intersectOpenInterval(g)||q.intersectOpenInterval(g));
      if (eIntersect||fIntersect||gIntersect||inside)//println(eIntersect, fIntersect, gIntersect, inside, "\t", j.intersectOpenInterval(e), k.intersectOpenInterval(e), l.intersectOpenInterval(e), m.intersectOpenInterval(e));
      if (eIntersect||fIntersect||gIntersect||inside) {
        //println("edge: ", ei, "\t", f.a.x, f.a.y, f.b.x, f.b.y);
        if (a.intersect(e))if (dist>a.intersectAmt(e)) {
          dist=a.intersectAmt(e);
          closest=ei;
          point=0;
          trad=true;
        }
        if (b.intersect(e))if (dist>b.intersectAmt(e)) {
          dist=b.intersectAmt(e);
          closest=ei;
          point=0;
          trad=true;
        }
        if (c.intersect(e))if (dist>c.intersectAmt(e)) {
          dist=c.intersectAmt(e);
          closest=ei;
          point=0;
          trad=true;
        }
        if (d.intersect(e))if (dist>d.intersectAmt(e)) {
          dist=d.intersectAmt(e);
          closest=ei;
          point=0;
          trad=true;
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


    ob.x+=av.x*dist;
    ob.y+=av.y*dist;
    if (dist<1) {
      PVector tempVec=new PVector();
      //println("---------------------------------------------------------PT:", point);
      if (point==0)tempVec=local.get(closest).vec().copy();
      else if (point==1)tempVec=new PVector( 0, 1);
      else tempVec=new PVector(1, 0);
      tempVec=tempVec.normalize();

      ob.v=PVector.mult(tempVec, av.copy().dot(tempVec)/frameAdjust);
    } else run++;
    //println(dist, ob.x, ob.y, "V:", av.x, av.y);
  }
}


class Phys {
  float x;
  float y;
  PVector v=new PVector(0, 0);
  PVector d=new PVector(0, 0);
  int size=16;
  boolean mirror = false;
  Phys(float x, float y) {
    this.x=x;
    this.y=y;
  }
  void draw() {
    fill(0, 0);
    //rect(x, y, size, size);
    //line(x+size/2, y+size/2, x+size/2+v.x, y+size/2+v.y);
    ////println(isContact(this));
  }
  void physUp() {
    if (true) {
      //v.x*=0.5;
      if (key('s')) {
        v.x*=0.5;
      }
      if (key(SHIFT)) {
        v.x*=0.1;
      }
      if (key('a')) {
        v.x=-5;
        mirror = true;
      }
      if (key('d')) {
        if (key('a'))v.x=0;
        else { 
          v.x=5; 
          mirror = false;
        }
      }
      if (key('w') && !wasJump) {
        v.y=-10;
        ////println(v.y);
      }
      wasJump = key('w');
    }
  }
}
boolean wasJump = false;

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
  //  //println(t,u);
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
    ////println(ua, ub);
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
    ////println(ua, ub);
    return (0<ua&&ua<1&&0<ub&&ub<1);
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
    stroke(255, 0, 0);
    strokeWeight(2);
    //line(a.x, a.y, b.x, b.y);
    stroke(1);
  }
}

//boolean insideBox(float x, float y, float w, float h, PVector p) {
//  return p.x-x>1&&x+w-p.x>1&&p.y-y>1&&y+h-p.y>1;
//}
/*boolean insideBox(float x, float y, float w, float h, PVector p) {
 return x<p.x-0.1&&p.x+0.1<x+w&&y<p.y-0.1&&p.y+0.1<y+h;
 }*/
boolean insideBox(float x, float y, float w, float h, PVector p) {
  return x<=p.x&&p.x<=x+w&&y<=p.y&&p.y<=y+h;
}
class EdgeList {
  ArrayList<Edge> edges=new ArrayList<Edge>();
  int chunk;
  EdgeList(int chunk) {
    this.chunk=chunk;
  }
  void add(int u, int v, float x1, float y1, float x2, float y2) {
    x1*=GRID;
    y1*=GRID;
    x2*=GRID;
    y2*=GRID;
    edges.add(new Edge((chunk*Chunk.U+u)*GRID+x1, v*GRID+y1, (chunk*Chunk.U+u)*GRID+x2, v*GRID+y2));
  }
}

ArrayList<Edge> buildLocal(int chunk, int u, int v, int radius) {
  EdgeList edges=new EdgeList(chunk);
  ////println("asdfa",max(0, u-radius), min(Chunk.U, u+radius));
  for (int i=u-radius; i<u+radius; i++) {
    for (int j=max(0, v-radius); j<min(Chunk.V-1, v+radius); j++) {
      ////println(i,j);
      int shape=getBlockPhys(chunk, i, j);
      int block=getBlock(chunk, i, j);
      ////println("blockdat: ",block);
      if (block%1000==1||block%1000==2||block%1000==3||block%1000==4||block%1000==5) {
        boolean above=getBlock(chunk, i, j-1)==0;
        boolean below=getBlock(chunk, i, j+1)==0;
        boolean left=getBlock(chunk, i-1, j)==0;
        boolean right=getBlock(chunk, i+1, j)==0;
        int subID=floor(block/1000);
        if (block%1000!=1)subID=0;
        // TOP
        if (above) {
          if (subID==1) {
            //Left Ramp
            edges.add(i, j, 0, 1, 1, 0);
            //edges.add(i, j, 1, 0, 1, 1);
          } else if (subID==2) {
            //Left Ramp
            edges.add(i, j, 0, 0, 1, 1);
            //edges.add(i, j, 0, 0, 0, 1);
          } else if (subID==4) {

            edges.add(i, j, 0.2, 0.3, 0.8, 0.3);//top
            edges.add(i, j, 0.0, 0.5, 0.0, 1.0);//Lside
            edges.add(i, j, 1.0, 0.5, 1.0, 1.0);//Rside
            edges.add(i, j, 0.2, 0.3, 0.0, 0.5);//Lramp
            edges.add(i, j, 0.8, 0.3, 1.0, 0.5);//Rramp
          } else if (subID==5) {
            //Left Ramp
            edges.add(i, j, 0.2, 0.8, 1.0, 0.0);
            edges.add(i, j, 0.2, 0.8, 1.0, 1.0);
            //edges.add(i, j, 1, 0, 1, 1);
          } else if (subID==6) {
            //Left Ramp
            edges.add(i, j, 0.0, 0.0, 0.8, 0.8);
            edges.add(i, j, 0.0, 1.0, 0.8, 0.8);
            //edges.add(i, j, 1, 0, 1, 1);
          } else {
            //Regular
            edges.add(i, j, 0, 0, 1, 0);
            //edges.add(i, j, 0, 0, 0, 1);
            //edges.add(i, j, 1, 0, 1, 1);
          }
        }

        // BOTTOM
        if (below) {
          if (subID!=5&&subID!=6) {
            //bottom
            edges.add(i, j, 0, 1, 1, 1);
          }
        }

        // LEFT SIDE
        if (left) {
          if (subID!=1&&subID!=4&&subID!=5&&subID!=6) {
            //left Side
            edges.add(i, j, 0, 0, 0, 1);
          }
        }

        // RIGHT SIDE
        if (right) {
          if (subID!=2&&subID!=4&&subID!=5&&subID!=6) {
            //right Side
            edges.add(i, j, 1, 0, 1, 1);
          }
        }
      }
    }
  }
  return edges.edges;
}