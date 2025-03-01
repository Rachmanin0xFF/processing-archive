
class Chunk {
  /*
  get( sprite x, sprite y) -> return value at location (in chunk space)
   set( sprite x, sprite y,int val) -> set value at location (in chunk space)
   data -> int[25][75] of sprite data: x first
   */
  static final int U=20;
  static final int V=80;
  int[][] data=new int[U][V];
  int[][] light=new int[U][V];
  int[][] lgtmp = new int[Chunk.U][Chunk.V];
  int[][] lightLink = new int[Chunk.U][Chunk.V];
  boolean[][] done = new boolean[Chunk.U][Chunk.V];
  int id = 0;
  Chunk() {
  for (int i=0; i<U; i++) {
    for (int j=0; j<V; j++) {
      data[i][j]=0;
      light[i][j]=0;
      lgtmp[i][j]=0;
      done[i][j]=false;
      lightLink[i][j]=-1;
    }
  }
  }
  Chunk(int id) {
  this.id = id;
  for (int i=0; i<U; i++) {
    for (int j=0; j<V; j++) {
      data[i][j]=0;
      light[i][j]=0;
      done[i][j]=false;
      lightLink[i][j]=-1;
    }
  }
  }
  int get(int u, int v) {
  return data[u][v];
  }
  color getCol(int u, int v) {
  if(u < 0 && map.containsKey(id-1)) return map.get(id-1).getCol(U-1, min(V-1, max(0, v)));
  if(u > Chunk.U-1 && map.containsKey(id+1)) return map.get(id+1).getCol(0, min(V-1, max(0, v)));
  return light[min(U-1, max(0, u))][min(V-1, max(0, v))];
  }
  void set(int u, int v, int val) {
  data[u][v]=val;
  }
  void smartSet(int u, int v, int val) {
  if(v < 0 || v > V-1) return;
  if(u < 0 && map.containsKey(id-1)) { map.get(id-1).smartSet(u + U, v, val); return; }
  if(u > U-1 && map.containsKey(id+1)) { map.get(id+1).smartSet(u - U, v, val); return; }
  if(val == 0 && lightLink[u][v] != -1) blockLights.remove(lightLink[u][v]);
  data[u][v] = val;
  }
}