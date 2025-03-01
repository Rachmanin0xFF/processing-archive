int r(color c) {return (c >> 16) & 255; }
int g(color c) {return (c >> 8) & 255;}
int b(color c) {return c & 255; }

class Trail {
  PVector[] pos;
  int cidx = 0;
  int maxidx = 0;
  boolean goin = false;
  Trail(int len) {
    pos = new PVector[len];
  }
  void add_pt(dVec3 v) {
    PVector p = new PVector((float)v.x, (float)v.y, (float)v.z);
    pos[cidx] = p;
    cidx++;
    if(cidx == pos.length) { cidx = 0; goin = true; }
    maxidx = max(maxidx, cidx);
  }
  void display(color c) {
    for(int i = 0; i < cidx; i++) {
      int im1 = i-1; if(im1 == -1) im1 = pos.length-1;
      if(!goin && i == 0) im1 = 0;
      float cc = cidx < i ? (cidx+pos.length)-i : cidx-i;
      cc /= pos.length;
      strokeWeight(cc+1.0);
      stroke(r(c), g(c), b(c), 255*(1.0 - cc)*(1.0 - cc));
      line(pos[im1].x, pos[im1].y, pos[im1].z, pos[i].x, pos[i].y, pos[i].z);
    }
    if(goin) {
      for(int i = cidx+1; i < pos.length; i++) {
        int im1 = i-1; if(im1 == -1) im1 = pos.length-1;
        float cc = cidx < i ? (cidx+pos.length)-i : cidx-i;
        cc /= pos.length;
        strokeWeight(cc+1.0);
        stroke(r(c), g(c), b(c), 255*(1.0 - cc)*(1.0 - cc));
        line(pos[im1].x, pos[im1].y, pos[im1].z, pos[i].x, pos[i].y, pos[i].z);
      }
    }
  }
}
