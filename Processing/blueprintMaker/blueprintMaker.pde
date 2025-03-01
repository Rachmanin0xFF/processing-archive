PImage target;
void setup() {
  target = loadImage("greys.jpg");
  size(target.width, target.height);
  filterBlue(target, 0, 20, 100, false, false, 20);
}
/**
* This will take your image, 'blueprint' it, and draw it.
* p - The Image to filter.
* smoothing - The amount to blur the image, giving smoother edges.
* threshold - The higher, the more is turned white.
* linespacing - The amount to space the gridlines.
* edgeDetect - If you want to detect only edges before the blue filter
* edgeDetect2 - If you want to detect edges after the blue filter.
* edgth - The edge detecting threshold. The lower, the more white.
*/
void filterBlue(PImage p, int smoothing, int threshold, int linespacing, boolean edgeDetect, boolean edgeDetect2, int edgth) {
  color prussianBlue = color(102, 102, 204);
  color white = color(255, 255, 255);
  color black = color(0, 0, 0);
  p.filter(BLUR, smoothing);
  if(edgeDetect) {
    PImage q = createImage(p.width, p.height, RGB);
    for(int x = 1; x < p.width-1; x++)
      for(int y = 1; y < p.height-1; y++) {
        int i0 = y*p.width + x;
        float i1 = brightness(p.pixels[y*p.width + x + 1]);
        float i2 = brightness(p.pixels[y*p.width + x - 1]);
        float i3 = brightness(p.pixels[(y + 1)*p.width + x]);
        float i4 = brightness(p.pixels[(y - 1)*p.width + x]);
        if(abs(brightness(p.pixels[i0])-i1) > edgth || abs(brightness(p.pixels[i0])-i2) > edgth || abs(brightness(p.pixels[i0])-i3) > edgth || abs(brightness(p.pixels[i0])-i4) > edgth)
          q.pixels[i0] = black;
        else
          q.pixels[i0] = white;
      }
    arrayCopy(q.pixels, p.pixels);
  }
  for(int i = 0; i < p.pixels.length; i++) {
    float b = brightness(p.pixels[i]);
    if(b > 255-threshold)
      p.pixels[i] = prussianBlue;
    else
      p.pixels[i] = white;
  }
  if(edgeDetect2) {
    PImage q = createImage(p.width, p.height, RGB);
    for(int x = 1; x < p.width-1; x++)
      for(int y = 1; y < p.height-1; y++) {
        int i0 = y*p.width + x;
        float i1 = brightness(p.pixels[y*p.width + x + 1]);
        float i2 = brightness(p.pixels[y*p.width + x - 1]);
        float i3 = brightness(p.pixels[(y + 1)*p.width + x]);
        float i4 = brightness(p.pixels[(y - 1)*p.width + x]);
        if(abs(brightness(p.pixels[i0])-i1) > edgth || abs(brightness(p.pixels[i0])-i2) > edgth || abs(brightness(p.pixels[i0])-i3) > edgth || abs(brightness(p.pixels[i0])-i4) > edgth)
          q.pixels[i0] = white;
        else
          q.pixels[i0] = prussianBlue;
      }
    arrayCopy(q.pixels, p.pixels);
  }
  image(target, 0, 0);
  stroke(255, 255, 255, 120);
  strokeWeight(1);
  smooth();
  for(int i = 0; i < width; i+=linespacing)
    line(i, 0, i, height);
  for(int i = 0; i < height; i+=linespacing)
    line(0, i, width, i);
  stroke(255, 255, 255, 50);
  for(int i = 0; i < width; i+=linespacing/4)
    line(i, 0, i, height);
  for(int i = 0; i < height; i+=linespacing/4)
    line(0, i, width, i);
}
