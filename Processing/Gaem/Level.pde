class Level {
  PImage[] img_bkg;
  int[][] bkg;
  int bkgRad = 512;
  float bkgScale = 1.f;
  public Level(String levelPath) {
    load(levelPath);
  }
  void load(String levelPath) {
    File dir = new File(levelPath + "/bkg");
    int num = dir.list().length;
    img_bkg = new PImage[num];
    for(int i = 0; i < num; i++) {
      img_bkg[i] = loadImage(levelPath + "/bkg/" + i + ".png");
    }
    String[] bkgplc = loadStrings(levelPath + "/bkg_placement.txt");
    int w = bkgplc[0].split(" ").length;
    int h = bkgplc.length;
    bkg = new int[w][h];
    for(int y = 0; y < h; y++) {
      String[] parts = bkgplc[y].split(" ");
      for(int x = 0; x < w; x++) {
        bkg[x][y] = Integer.parseInt(parts[x]);
      }
    }
  }
  void dispBkgAt(Player p) {
    int dsxrad = ceil((float)width/(float)bkgRad) - 1;
    int dsyrad = ceil((float)height/(float)bkgRad);
    
    int xindex = round(p.x/bkgRad);
    int yindex = round(p.y/bkgRad);
    
    int xstart = max(0, xindex - dsxrad);
    int xstop = min(bkg.length, xindex + dsxrad);
    int ystart = max(0, yindex - dsyrad);
    int ystop = min(bkg[0].length, yindex + dsyrad);
    
    for(int x = xstart; x < xstop; x++) {
      for(int y = ystart; y < ystop; y++) {
        image(img_bkg[bkg[x][y]], x*bkgRad, y*bkgRad, bkgRad, bkgRad);
      }
    } 
  }
}