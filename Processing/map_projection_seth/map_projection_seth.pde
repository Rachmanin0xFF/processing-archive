
PGraphics pg;

PVector[][] map_in;
PVector[][] map_out;

void setup() {
  size(1680, 840);
  map_in = toVectors(loadImage("topo.jpg"));
}
void draw() {
  strokeWeight(10);
  background(0);
  
  map_out = reproject(map_in, 1680/4, 840/4, mouseX - width/2, mouseY - height/2, 180, 1);
  PImage img = to_img(map_out);
  //img.save("map_out.png");
  image(img, 0, 0, width, height);
  //noLoop();
  
}

PImage to_img(PVector[][] v) {
  PImage img = createImage(v.length, v[0].length, RGB);
  for(int x = 0; x < img.width; x++) {
    for(int y = 0; y < img.height; y++) {
      img.pixels[x+y*img.width] = color(v[x][y].x, v[x][y].y, v[x][y].z);
    }
  }
  return img;
}

// proj_mode choices:
// 0 - Equirectangular
// 1 - Eckert IV
PVector[][] reproject(PVector[][] input, int w, int h, float lat, float lon, float choice, int proj_mode) {
  PVector[][] output = new PVector[w][h];
  for(int x = 0; x < w; x++) for(int y = 0; y < h; y++) {
    float lat_px = 0, lon_px = 0;
    PVector px_c = new PVector(0.5, 0.5);
    
    switch(proj_mode) {
      case 0:
        lat_px = (float)(h - y)/(float)h * PI - PI/2;
        lon_px = (float)(x)/(float)w * TWO_PI - PI + 0.0174532925*choice;
        break;
      case 1:
        px_c = get_Eckert_IV((x-w/2), -(y-h/2), 300*(float)w/(float)1680);
        
        lat_px = px_c.x;
        lon_px = px_c.y;
        break;
    }
    
    float xx = cos(lon_px)*cos(lat_px);
    float zz = sin(lon_px)*cos(lat_px);
    float yy = sin(lat_px);
    
    PVector n = new PVector(xx, yy, zz);
    float tx, ty, tz;
    float az = 0.0174532925*(lon + 90); // azimuth
    float alt = 0.0174532925*(lat+180); // altitude
    
    ty = sin(alt)*n.y + cos(alt)*n.z;
    tz = cos(alt)*n.y - sin(alt)*n.z;
    n = new PVector(n.x, ty, tz);
    
    tx = cos(az)*n.x - sin(az)*n.z;
    tz = sin(az)*n.x + cos(az)*n.z;
    n = new PVector(tx, n.y, tz);
    
    float xz_mag = sqrt(n.x*n.x + n.z*n.z);
    
    float lat_px2 = atan2(n.y, xz_mag);
    float lon_px2 = atan2(n.z, n.x);
    
    float samp_y = input[0].length*(lat_px2 + PI/2)/PI;
    float samp_x = input.length*(lon_px2 + PI)/TWO_PI;
    
    //samp_x = (samp_x + choice)%input.length;
    
    output[x][y] = getVecFiltered(input, samp_x, samp_y);
    if(Float.isNaN(px_c.x) || Float.isNaN(px_c.y) || px_c.x > PI || px_c.y > PI || px_c.x < -PI || px_c.y < -PI) {
      output[x][y]  = new PVector();
    }
  }
  return output;
}

PVector get_Eckert_IV(float x, float y, float R) {
  float theta = asin(y/(1.3265004*R));
  float lat = asin((theta + sin(theta)*cos(theta) + 2*sin(theta))/(2 + PI/2));
  float lon = 0 + x/(0.4222382*R*(1 + cos(theta)));
  return new PVector(lat, lon);
}

PVector ll_to_3d(float lon_deg, float lat_deg) {
  float lon = 0.0174532925*lon_deg;
  float lat = 0.0174532925*lat_deg;
  return new PVector(cos(lon)*cos(lat), sin(lat), sin(lon)*cos(lat));
}
