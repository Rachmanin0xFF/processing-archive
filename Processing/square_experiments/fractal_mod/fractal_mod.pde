void setup() {
  size(800, 800, P2D);
  smooth(8);
  //noSmooth();
  background(0);
  fill(255, 20);
  noStroke();
}

void draw() {
  blendMode(BLEND);
  strokeCap(SQUARE);
  noStroke();
  noFill();
  //blendMode(ADD);
  stroke(255, 200, 100, 20*max(1, thibn/8.f));
  stroke(255, 200, 100, 20*max(1, thibn/8.f));
  strokeWeight(2);
  for(int i = 0; i < 10000; i++) {
      int x = round(random(width));
      int y = round(random(height));
      rectagon(1, x, y, 256, 0.f, false, 0);
      float val = (maxx-minx)/20.f;
      stroke(val, 255);
      point(x, y);
      tot = 0;
      minx = 1000000.f;
      maxx = -1000000.f;
  }
  if (thibn > moon*2) thibn /= 1.5f; else thibn = moon;
}
float moon = 1;
float thibn = 16;

void mouseMoved() {
  thibn = 16;
}

// Note: 109 is excluded from this list
int[] primes = new int[]{2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97, 101, 103, 107, 113, 127, 131, 137, 139, 149, 151, 157, 163, 167, 173, 179, 181, 191, 193, 197, 199, 211, 223, 227, 229, 233, 239, 241, 251, 257, 263, 269, 271, 277, 281, 283, 293, 307, 311, 313, 317, 331, 337, 347, 349};

float nooscoo = 100.f;
float rondum(float x, float y, float molt) {
  return ((noise(x/nooscoo, y/nooscoo))*8.f)%molt;
}
float minx = 1000000.f;
float maxx = -1000000.f;
int tot = 0;
int pod = 0;
void rectagon(int trek, float x, float y, float r, float z, boolean boon, int iter) {
  tot++;
  if(x < minx) minx = x;
  if(x > maxx) maxx = x;
  //rect(x-r, y-r, r*2.f, r*2.f);
  if(boon) {
    //strokeWeight(r);
    //point(x, y);
    //ellipse(x, y, r*2.f, r*2.f);
  }
  if(r > thibn) {
  switch((int)rondum(x + (float)trek/r, y, 4)) {
    case 0:
      roopagon(trek*primes[iter], x-r*2.f, y, r/2.f, z, iter+4);
      break;
    case 1:
      roopagon(trek*primes[iter+1], x+r*2.f, y, r/2.f, z, iter+4);
      break;
    case 2:
      roopagon(trek*primes[iter+2], x, y-r*2.f, r/2.f, z, iter+4);
      break;
    case 3:
      roopagon(trek*primes[iter+3], x, y+r*2.f, r/2.f, z, iter+4);
      break;
    default:
      break;
  }
  switch((int)rondum(x + (float)trek/r - 403.89, y + 102.f, 4)) {
    case 0:
      roopagon(trek*primes[iter], x-r*2.f, y, r/2.f, z, iter+4);
      break;
    case 1:
      roopagon(trek*primes[iter+1], x+r*2.f, y, r/2.f, z, iter+4);
      break;
    case 2:
      roopagon(trek*primes[iter+2], x, y-r*2.f, r/2.f, z, iter+4);
      break;
    case 3:
      roopagon(trek*primes[iter+3], x, y+r*2.f, r/2.f, z, iter+4);
      break;
    default:
      break;
  }
  }
  //else point(x, y);
}
int k1 = 2;
int k2 = 2;

void roopagon(int trek, float x, float y, float r, float z, int iter) {
  switch((int)rondum(x - (float)trek/r - 509.77, y, 4)) {
    case 0:
      rectagon(trek*primes[iter], x+r, y+r, r, z, true, iter+4);
      break;
    case 1:
      rectagon(trek*primes[iter+1], x+r, y-r, r, z, true, iter+4);
      break;
    case 2:
      rectagon(trek*primes[iter+2], x-r, y+r, r, z, true, iter+4);
      break;
    case 3:
      rectagon(trek*primes[iter+3], x-r, y-r, r, z, true, iter+4);
      break;
    default:
      break;
  }
  switch((int)rondum(x - (float)trek/r - 583.77, y - 7120.f, 4)) {
    case 0:
      rectagon(trek*primes[iter], x+r, y+r, r, z, true, iter+4);
      break;
    case 1:
      rectagon(trek*primes[iter+1], x+r, y-r, r, z, true, iter+4);
      break;
    case 2:
      rectagon(trek*primes[iter+2], x-r, y+r, r, z, true, iter+4);
      break;
    case 3:
      rectagon(trek*primes[iter+3], x-r, y-r, r, z, true, iter+4);
      break;
    default:
      break;
  }
}