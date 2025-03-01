int res = 200;
boolean[][][] theIntel = new boolean[res][res][res];
PVector[] points = new PVector[100];
VoxDataParser v = new VoxDataParser();
int thigR = 10;
void setup() {
  size(256, 256);
  for(int i = 0; i < points.length; i++)
    points[i] = new PVector(random(thigR, res), random(thigR, res), random(thigR, res));
  for(int i = 0; i < points.length; i++)
    for(int k = 0; k < points.length; k++) {
      if(dist(points[i].x, points[i].y, points[i].z, points[k].x, points[k].y, points[k].z) < 55) {
        drawSphere(points[i].x, points[i].y, points[i].z, 5);
        drawLine(points[i].x, points[i].y, points[i].z, points[k].x, points[k].y, points[k].z, 2);
      }
    }
  v.exportDataToOBJ(theIntel, "sphrthig.obj");
}
void drawSphere(float xc, float yc, float zc, float r) {
  for(int x = 0; x < res; x++)
    for(int y = 0; y < res; y++)
      for(int z = 0; z < res; z++)
        if(dist(xc, yc, zc, x, y, z) <= r)
          theIntel[x][y][z] = true;
}

void drawLine(float x1, float y1, float z1, float x2, float y2, float z2, int r) {
  float dst = dist(x1, y1, z1, x2, y2, z2);
  float delta = 1.0f/dst;
  for(float i = 0.0f; i <= 1.0f; i += delta) {
    PVector p = mix(i, new PVector(x1, y1, z1), new PVector(x2, y2, z2));
    setBubbl(round(p.x), round(p.y), round(p.z), r);
  }
}

void setBubbl(int xc, int yc, int zc, int r) {
  for(int x = -r; x <= r; x++)
    for(int y = -r; y <= r; y++)
      for(int z = -r; z <= r; z++)
        theIntel[v.clamp(xc+x, 0, res-1)][v.clamp(yc+y, 0, res-1)][v.clamp(zc+z, 0, res-1)] = true;
}

PVector mix(float x, PVector a, PVector b) {
  float tx = a.x * (1.0f - x) + b.x * x;
  float ty = a.y * (1.0f - x) + b.y * x;
  float tz = a.z * (1.0f - x) + b.z * x;
  return new PVector(tx, ty, tz);
}


//--------------------------------------------------------------------------------------------------------//
// .vox importer/exporter, created by Adam Lastowka.
//--------------------------------------------------------------------------------------------------------//
// Example Usage:
//
// VoxDataParser vdp = new VoxDataParser();
// boolean[][][] b = v.parseFile("cat.vox");
// v.exportDataToOBJ(b, "catOBJ.obj");
//--------------------------------------------------------------------------------------------------------//
// Some specifications of the .vox file format:
// Comments can be inserted into files! Just preface them with a hashtag for safety.
// The dim command declares the size of the voxel region. dim 10 20 15 would preface a 10x20x15 dataset.
// The data is stored in slices. A 3x3x3 voxel data set would look like this in a file:
// Example_File.vox:
// 
// # This is a comment
// dim 3 3 3 
// 
// 110 # Fist slice
// 101
// 001
// 
// 011 # Second slice
// 000
// 010
// 
// 111 # Third slice
// 110
// 000
//
// End Example_File.vox.
//
// Of course, in order to compress things a bit, we don't put spaces in between the slices. Or commands.
// That's not to say you can't, though! The interpreter doesn't mind empty lines. 
// But it does mind ones with something in them, so always preface comments in files with a hashtag (#).
//
// The X dimension of a dataset is the number of blocks.
// The Y dimension of a dataset is the number of lines per block.
// The Z dimension of a dataset is the length of each line.
// The arguments of dim MUST correspond to these attributes!
//--------------------------------------------------------------------------------------------------------//
class VoxDataParser {
  //This will save the values in data in .vox data format to the specified location. 
  void saveToVOX(boolean[][][] data, String location) {
    ArrayList<String> outData = new ArrayList<String>();
    outData.add("dim " + data.length + " " + data[0].length + " " + data[0][0].length);
    for(int x = 0; x < data.length; x++)
      for(int y = 0; y < data[0].length; y++) {
        String biSlice = "";
        for(int z = 0; z < data[0][0].length; z++) {
          if(data[x][y][z])
            biSlice += "1";
          else
            biSlice += "0";
        }
        outData.add(biSlice);
      }
    saveStrings(location, outData.toArray(new String[outData.size()]));
  }
  
  //This will load a .vox file from the specified location and return a boolean array of the data in the file.
  boolean[][][] parseFile(String location) {
    return parseFile(loadStrings(location));
  }
  
  //This will convert a String array (taken from a loaded file in the .vox data format) and turn it into a boolean array.
  boolean[][][] parseFile(String[] data) {
    boolean[][][] voxData = null;
    int dataIndex = 0;
    int xDim = 0;
    int yDim = 0;
    int zDim = 0;
    for(int i = 0; i < data.length; i++) {
      if(data[i].startsWith("dim ")) {
        xDim = int(data[i].split(" ")[1]);
        yDim = int(data[i].split(" ")[2]);
        zDim = int(data[i].split(" ")[3]);
        voxData = new boolean[xDim][yDim][zDim];
      }
      if(data[i].startsWith("1") || data[i].startsWith("0")) {
        for(int k = 0; k < data[i].length(); k++) {
          voxData[dataIndex/yDim][dataIndex%yDim][k] = (data[i].charAt(k) == '1');
        }
        dataIndex++;
      }
    }
    return voxData;
  }
  
  //This will export the boolean values in data to .OBJ file format and save at the specified location.
  //This function in particular is pretty beautifully written :3
  void exportDataToOBJ(boolean[][][] data, String location) {
    int[][][] vertexPlaces = new int[data.length+1][data[0].length+1][data[0][0].length+1];
    ArrayList<String> outData = new ArrayList<String>();
    println("Generating vertices...");
    int vertexTick = 1;
    for(int x = 0; x < vertexPlaces.length; x++)
      for(int y = 0; y < vertexPlaces[0].length; y++)
        for(int z = 0; z < vertexPlaces[0][0].length; z++) {
          boolean placePoint = false;
          placePoint |= data[clamp(x, 0, data.length-1)][clamp(y, 0, data[0].length-1)][clamp(z, 0, data[0][0].length-1)];
          placePoint |= data[clamp(x-1, 0, data.length-1)][clamp(y, 0, data[0].length-1)][clamp(z, 0, data[0][0].length-1)];
          placePoint |= data[clamp(x, 0, data.length-1)][clamp(y-1, 0, data[0].length-1)][clamp(z, 0, data[0][0].length-1)];
          placePoint |= data[clamp(x, 0, data.length-1)][clamp(y, 0, data[0].length-1)][clamp(z-1, 0, data[0][0].length-1)];
          
          placePoint |= data[clamp(x-1, 0, data.length-1)][clamp(y-1, 0, data[0].length-1)][clamp(z, 0, data[0][0].length-1)];
          placePoint |= data[clamp(x, 0, data.length-1)][clamp(y-1, 0, data[0].length-1)][clamp(z-1, 0, data[0][0].length-1)];
          placePoint |= data[clamp(x-1, 0, data.length-1)][clamp(y, 0, data[0].length-1)][clamp(z-1, 0, data[0][0].length-1)];
          placePoint |= data[clamp(x-1, 0, data.length-1)][clamp(y-1, 0, data[0].length-1)][clamp(z-1, 0, data[0][0].length-1)];
          
          if(placePoint) {
            vertexPlaces[x][y][z] = vertexTick;
            outData.add("v " + x + " " + y + " " + z);
            vertexTick++;
          }
        }
    println("Slicing...");
    for(int x = 0; x < data.length; x++)
      for(int y = 0; y < data[0].length; y++) {
        boolean wasOn = false;
        for(int z = 0; z <= data[0][0].length; z++) {
          boolean isOn = false;
          if(z < data.length)
            isOn = data[x][y][z];
          if(isOn ^ wasOn) {
            outData.add("f " + vertexPlaces[x][y][z] + " " + vertexPlaces[x+1][y+1][z] + " " + vertexPlaces[x+1][y][z]);
            outData.add("f " + vertexPlaces[x][y][z] + " " + vertexPlaces[x][y+1][z] + " " + vertexPlaces[x+1][y+1][z]);
          }
          wasOn = isOn;
        }
      }
    println("Z Axis sliced.");
    for(int z = 0; z < data[0][0].length; z++)
      for(int x = 0; x < data.length; x++) {
        boolean wasOn = false;
        for(int y = 0; y <= data[0].length; y++) {
          boolean isOn = false;
          if(y < data.length)
            isOn = data[x][y][z];
          if(isOn ^ wasOn) {
            outData.add("f " + vertexPlaces[x][y][z] + " " + vertexPlaces[x+1][y][z+1] + " " + vertexPlaces[x+1][y][z]);
            outData.add("f " + vertexPlaces[x][y][z] + " " + vertexPlaces[x][y][z+1] + " " + vertexPlaces[x+1][y][z+1]);
          }
          wasOn = isOn;
        }
      }
    println("Y Axis sliced.");
    for(int y = 0; y < data[0].length; y++)
      for(int z = 0; z < data[0][0].length; z++) {
        boolean wasOn = false;
        for(int x = 0; x <= data.length; x++) {
          boolean isOn = false;
          if(x < data.length)
            isOn = data[x][y][z];
          if(isOn ^ wasOn) {
            outData.add("f " + vertexPlaces[x][y][z] + " " + vertexPlaces[x][y+1][z+1] + " " + vertexPlaces[x][y+1][z]);
            outData.add("f " + vertexPlaces[x][y][z] + " " + vertexPlaces[x][y][z+1] + " " + vertexPlaces[x][y+1][z+1]);
          }
          wasOn = isOn;
        }
      }
    println("X Axis sliced.");
    println("Saving file...");
    saveStrings(location, outData.toArray(new String[outData.size()]));
    println("Done! Saved file to " + location);
  }
  int clamp(int a, int x, int y) {
    if(x > y) return -1;
    if(a < x) return x;
    if(a > y) return y;
    return a;
  }
}
//--------------------------------------------------------------------------------------------------------//
