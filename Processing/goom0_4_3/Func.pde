int isum(int... data) {
  int o = 0;
  for(int i : data) o += i;
  return o;
}

int imax(int... data) {
  int fm = -2147483648;
  for(int i : data) if(i > fm) fm = i;
  return fm;
}

int toChunk(float x){
  return floor(x/(float)(Chunk.U*GRID));
}
int blockInChunkX(float x){
  return floor(x/(float)GRID)%Chunk.U;
}
int blockInChunkY(float y){
  return floor(y/(float)GRID)%Chunk.V;
}
int bicX(float x){
  return blockInChunkX(x);
}
int bicY(float y){
  return blockInChunkY(y);
}