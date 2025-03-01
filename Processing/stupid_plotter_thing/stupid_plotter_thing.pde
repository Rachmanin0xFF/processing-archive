float[] decays = new float[]{6.113, 6.070, 5.972, 5.817, 5.609};
void setup() {
  size(1500, 900, P2D);
  smooth(16);
  strokeWeight(2);
}
void draw() {
  background(255);
  stroke(0);
  fill(0);
  
  float plotMin = 5.3;
  float plotMax = 6.2;
  
  
  float bands_x = 540;
  float bands_w = 300;
  
  float gamma_x = 760;
  float gamma_spacing = -30;
  
  float arrow_xspacing = 45;
  float arrow_x0 = 239;
  float arrow_y = 88;
  println(mouseX, mouseY);
  
  line(arrow_x0 - arrow_xspacing, arrow_y, arrow_x0 + (arrow_xspacing+1)*decays.length, arrow_y);
  float py = 0;
  for(int i = 0; i < decays.length; i++) {
    float y = (decays[i] - plotMin)/(plotMax - plotMin) * (float)height;
    line(bands_x, y, bands_x + bands_w, y);
    
    drawArrow2(arrow_x0 + i*arrow_xspacing, arrow_y, -0.55, y, 15, 7);
    
    if(i > 0) {
      drawArrow(gamma_x + i*gamma_spacing, y, gamma_x + i*gamma_spacing, py, 15, 7);
    }
    py = y;
  }
  
  float marker_x = 900;
  float tw1 = 4;
  float tw2 = 12;
  py = 0;
  for(int i = 0; i < 58; i++) {
    float E = decays[0] - i/100.f;
    float y = (E - plotMin)/(plotMax - plotMin)*(float)height;
    line(marker_x - tw1, y, marker_x + tw1, y);
    if(i > 0) line(marker_x, y, marker_x, py);
    py = y;
  }
  
  
  textAlign(LEFT, CENTER);
  textSize(17);
  py = 0;
  for(int i = 0; i < 6; i++) {
    float E = decays[0] - i/10.f;
    float y = (E - plotMin)/(plotMax - plotMin)*(float)height;
    text(round(abs(E - decays[0])*1000.f) + " keV", marker_x + tw2*1.5, y - 5);
    line(marker_x - tw2, y, marker_x + tw2, y);
    py = y;
  }
  
  py = 0;
  for(int i = 0; i < 12; i++) {
    float E = decays[0] - i/20.f;
    float y = (E - plotMin)/(plotMax - plotMin)*(float)height;
    line(marker_x - tw2*0.7, y, marker_x + tw2*0.7, y);
    py = y;
  }
}

void drawArrow2(float x0, float y0, float slope, float y1, float hl, float hw) {
  float x1 = (y0-y1)*slope + x0;
  drawArrow(x0, y0, x1, y1, hl, hw);
}

void drawArrow(float x0, float y0, float x1, float y1, float headLength, float headWidth) {
  line(x0, y0, x1, y1);
  PVector v = new PVector(x1 - x0, y1 - y0);
  v.normalize();
  PVector ortho = new PVector(-v.y, v.x);
  v.mult(headLength);
  ortho.mult(headWidth);
  noStroke();
  triangle(x1, y1, x1 - v.x + ortho.x, y1 - v.y + ortho.y, x1 - v.x - ortho.x, y1 - v.y - ortho.y);
  stroke(0);
}
