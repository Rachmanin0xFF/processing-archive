void fillFRandGauss(float[][] vals) {
  for(int xi = 0; xi < vals.length; xi++) {
    for(int yi = 0; yi < vals[xi].length; yi++) {
      vals[xi][yi] = randomGaussian();
    }
  }
}

void fillVRandGauss(PVector[][] vals) {
  for(int xi = 0; xi < vals.length; xi++) {
    for(int yi = 0; yi < vals[xi].length; yi++) {
      vals[xi][yi] = new PVector(randomGaussian(), randomGaussian(), randomGaussian());
    }
  }
}

float[][] imgToFArr(PImage p) {
  float[][] vals = new float[p.width][p.height];
  for(int xi = 0; xi < vals.length; xi++) {
    for(int yi = 0; yi < vals[xi].length; yi++) {
      vals[xi][yi] = red(p.get(xi, yi)) / 255.f;
    }
  }
  return vals;
}

void plotFArr(float[][] vals, float x, float y, float wh) {
  strokeCap(SQUARE);
  strokeWeight(wh / vals.length);
  float min =  100000000.0;
  float max = -100000000.0;
  for(int xi = 0; xi < vals.length; xi++) {
    for(int yi = 0; yi < vals[xi].length; yi++) {
      if(vals[xi][yi] < min) min = vals[xi][yi];
      if(vals[xi][yi] > max) max = vals[xi][yi];
    }
  }
  for(int xi = 0; xi < vals.length; xi++) {
    for(int yi = 0; yi < vals[xi].length; yi++) {
      stroke(map(vals[xi][yi], min, max, 0, 255));
      point((xi/(float)vals.length)*wh + x, (yi/(float)vals[xi].length)*wh + y);
    }
  }
}

void plotVArr(PVector[][] vals, float x, float y, float wh) {
  strokeCap(SQUARE);
  strokeWeight(wh / vals.length);
  float max = -100000000.0;
  for(int xi = 0; xi < vals.length; xi++) {
    for(int yi = 0; yi < vals[xi].length; yi++) {
      float mx = max(abs(vals[xi][yi].x), abs(vals[xi][yi].y), abs(vals[xi][yi].z));
      if(mx > max) max = mx;
    }
  }
  for(int xi = 0; xi < vals.length; xi++) {
    for(int yi = 0; yi < vals[xi].length; yi++) {
      stroke(map(vals[xi][yi].x, -max, max, 0, 255),
             map(vals[xi][yi].y, -max, max, 0, 255),
             map(vals[xi][yi].z, -max, max, 0, 255));
      point((xi/(float)vals.length)*wh + x, (yi/(float)vals[xi].length)*wh + y);
    }
  }
}

float[][] get_mag(PVector[][] vals) {
  float[][] mags = new float[vals.length][vals[0].length];
  for(int xi = 0; xi < vals.length; xi++) {
    for(int yi = 0; yi < vals[xi].length; yi++) {
      mags[xi][yi] = sqrt(vals[xi][yi].x*vals[xi][yi].x + vals[xi][yi].y*vals[xi][yi].y);
    }
  }
  return mags;
}

PVector[][] get_grad(float[][] vals) {
  PVector[][] q = new PVector[vals.length-1][vals[0].length-1];
  for(int xi = 0; xi < q.length; xi++) {
    for(int yi = 0; yi < q[xi].length; yi++) {
      q[xi][yi] = new PVector(vals[xi+1][yi] - vals[xi][yi],
                              vals[xi][yi+1] - vals[xi][yi]);
    }
  }
  return q;
}

void plotFArr3D(float[][] vals, float x, float y, float wh) {
  pushMatrix();
  camera(x + wh/2.0, y + wh/2.0, (height/2.0) / tan(PI*30.0 / 180.0), width/2, height/2, 0, 0, 1, 0);
  translate(x + wh/2, y + wh/2);
  rotateX(-0.3f);
  rotateY(millis()/1000.f);
  float min =  100000000.0;
  float max = -100000000.0;
  for(int xi = 0; xi < vals.length; xi++) {
    for(int yi = 0; yi < vals[xi].length; yi++) {
      if(vals[xi][yi] < min) min = vals[xi][yi];
      if(vals[xi][yi] > max) max = vals[xi][yi];
    }
  }
  noStroke();
  fill(255);
  for(int xi = 0; xi < vals.length-1; xi++) {
    for(int yi = 0; yi < vals[xi].length-1; yi++) {
      fill(map(vals[xi][yi], min, max, 0, 255));
      beginShape();
      vertex((xi/(float)vals.length-0.5)*wh, map(-vals[xi][yi], min, max, -wh/4, wh/4), (yi/(float)vals.length-0.5)*wh);
      vertex(((xi+1)/(float)vals.length-0.5)*wh, map(-vals[xi+1][yi], min, max, -wh/4, wh/4), (yi/(float)vals.length-0.5)*wh);
      vertex(((xi+1)/(float)vals.length-0.5)*wh, map(-vals[xi+1][yi+1], min, max, -wh/4, wh/4), ((yi+1)/(float)vals.length-0.5)*wh);
      vertex((xi/(float)vals.length-0.5)*wh, map(-vals[xi][yi+1], min, max, -wh/4, wh/4), ((yi+1)/(float)vals.length-0.5)*wh);
      endShape();
    }
  }
  popMatrix();
}
