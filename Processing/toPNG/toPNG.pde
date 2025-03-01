BufferedReader reader;
String line;
void setup() {
  reader = createReader("sponza.mtl");
  try {
    while((line = reader.readLine()) != null) {
      if(line.contains("map_Kd ")) {
        PImage in = loadImage(line.split(" ")[1]);
        println(line.split(" ")[1].split("\\.")[0] + ".png");
        in.save(line.split(" ")[1].split("\\.")[0] + ".png");
      }
    }
  } catch(IOException e) {
    e.printStackTrace();
  }
  System.out.println("Converted All Files!");
}
