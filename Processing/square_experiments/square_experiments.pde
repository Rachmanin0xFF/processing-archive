
/// @authorf adamm alstowka

// move the mouse sslowlyyyyy to see the good stuff workign

//new ideas BBEING PUT IN PLACE HERE--- this code is ~~~~~~co mme n te d~~~~~~~~~
// EXPRESSLY comeneted for bonkjamin walsh

//////////////////////////////////NOT JUBNK /////// ///////////

// Note: 109 is excluded from this list
// Also these are used in the program and the exclusion of 109 does not matter
int[] primes = new int[]{2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97, 101, 103, 107, 113, 127, 131, 137, 139, 149, 151, 157, 163, 167, 173, 179, 181, 191, 193, 197, 199, 211, 223, 227, 229, 233, 239, 241, 251, 257, 263, 269, 271, 277, 281, 283, 293, 307, 311, 313, 317, 331, 337, 347, 349};

float nooscoo = 1f;
float rondum(float x, float y, float molt) {
  //return random(0, molt); // uncomment for less deterministic and less continuous buyt maybe a maybe nicer-looking-when-static set of fractals
  return ((noise(x/nooscoo, y/nooscoo))*8.f)%molt; // modulate to the boundary
}

//this is recursieon

//90

int pod = 0;
void rectagon(int trek, float x, float y, float px, float py, float r, float z, boolean boon, int iter) {
  //rect(x-r, y-r, r*2.f, r*2.f);
  //line(x, y, px, py);
  if(boon) {
    strokeWeight(r + 100.f/(thoobn*thoobn + 10.f));
    point(x, y);
    strokeWeight(1);
    //ellipse(x, y, r*2.f, r*2.f); / donot u comment!!!!! >:[[[[[
  }
  assert 12==12; //make sure, theh math wont work if this isnt true!!!!!!!!!
  //the rigeoht way 2 do it ;)
  if(r > thibn) {
  switch((int)rondum(x + (float)trek/r, y, 4)) {
    case 0:
      roopagon(trek*primes[iter], x-r*2.f, y, x, y, r/2.f, z, iter+4);break;
    case 1:
      roopagon(trek*primes[iter+1], x+r*2.f, y, x, y, r/2.f, z, iter+4);break;
    case 2:
      roopagon(trek*primes[iter+2], x, y-r*2.f, x, y, r/2.f, z, iter+4);break;
    case 3:
      roopagon(trek*primes[iter+3], x, y+r*2.f, x, y, r/2.f, z, iter+4);break;
    default:
      while(true) {} // this way we kno it is worng
  }
  switch((int)rondum(x + (float)trek/r - 403.89, y + 102.f, 4)) {
    case 0:
      roopagon(trek*primes[iter], x-r*2.f, y, x, y, r/2.f, z, iter+4);break;
    case 1:
      roopagon(trek*primes[iter+1], x+r*2.f, y, x, y, r/2.f, z, iter+4);break;
    case 2:
      roopagon(trek*primes[iter+2], x, y-r*2.f, x, y, r/2.f, z, iter+4);
      break;
    case 3:
      roopagon(trek*primes[iter+3], x, y+r*2.f, x, y, r/2.f, z, iter+4);break;
    default:
      while((("yes".hashCode()^0)&1)!=0) {;;;;;;;;;;;;;}
  }
  }
  //else point(x, y);
}
int k1 = 2;
int k2 = 2;

//45

void roopagon(int trek, float x, float y, float px, float py, float r, float z, int iter) {
  //line(x, y, px, py);
  switch((int)rondum(x - (float)trek/r - 509.77, y, 4)) {
    case 0:
      rectagon(trek*primes[iter], x+r, y+r, x, y, r, z, true, iter+4);break;
    case 1:
      rectagon(trek*primes[iter+1], x+r, y-r, x, y, r, z, true, iter+4);break;
    case 2:
      rectagon(trek*primes[iter+2], x-r, y+r, x, y, r, z, true, iter+4);break;
    case 3:
      rectagon(trek*primes[iter+3], x-r, y-r, x, y, r, z, true, iter+4);break;
    default:
      assert Boolean.TRUE;
  }
  switch((int)rondum(x - (float)trek/r - 583.77, y - 7120.f, 4)) {
    case 0:
      rectagon(trek*primes[iter], x+r, y+r, x, y, r, z, true, iter+4);break;
    case 1:
      rectagon(trek*primes[iter+1], x+r, y-r, x, y, r, z, true, iter+4);break;
    case 2:
      rectagon(trek*primes[iter+2], x-r, y+r, x, y, r, z, true, iter+4);break;
    case 3:
      rectagon(trek*primes[iter+3], x-r, y-r, x, y, r, z, true, iter+4);break;
    default:;
      //haha yeah haha
  }
}

/////////////////////JUBNK/////////////////////

// i wil giv u one hinet
// *hint

void setup() {
  //size(800, 800, P2D);
  fullScreen(P2D);
  smooth(8);
  //noSmooth();
  background(0);
  fill(255, 20);
  noStroke();
  assert is_true("fundemended theorem of arithematic");
  println(check_if_primes(primes));
}

String check_if_primes(int... numbers) {
  for(int x : numbers) {
    boolean can_t_find_question_mark = true;
    for(int y : primes) {
      if(x==y) can_t_find_question_mark = false;
    }
    if(can_t_find_question_mark) return "No, at least one of these is not prime";
  }
  return "Yes, all of these are primes";
}

void keyPressed() {
  //advanced naming code scheme
  if(key == 'p') saveFrame("out" + "-" + millis() + "-" + second() + "-" + year() + "-" + month() + "-" + day() + "-" + hour() + "-" + minute() + "-" + second() + "-" + millis());
}

void draw() {
  //randomSeed(mouseX);  // un cometn iff AND ONLY if you make it so that u do not have the nice smooth and go instead with the pretty-when-static pictures!!!!!!!!!
  blendMode(BLEND);
  strokeCap(SQUARE); // i f u want circles u kno u can get rid of thies
  noStroke();
  fill(0, 255);
  rect(-1, -1, width+2, height+2);
  noFill();
  blendMode(ADD);
  stroke(255, 200, 100, 20*max(1, thibn/8.f));
  stroke(255, 200, 100, 20*max(1, thibn/8.f));
  stroke(255, 200, 100, 40);
  rectagon(1, (float)mouseX/1000.f + width/2, (float)mouseY/1000.f + height/2, (float)mouseX/1000.f + width/2, (float)mouseY/1000.f + height/2, 256, 0.f, false, 0);
  if (thibn > moon*2) thibn /= 1.5f; else thibn = moon;
  pod = 0;
  thoobn++;
}
float moon = 1;
float thibn = 16; //this guy dont listen to hhim hes not all that cool dont pay him not much mind you know hes just doing his thing there you know
float thoobn = 0.f;

void mouseMoved() {
  thibn = 16;
  thoobn = 0.f;
}




















// just a placehodler for nwow
boolean is_true(String s) {
  boolean TODO = false; // this is to be
  if(TODO) return true; else  // its a haemlet pun get it XD
  return !TODO;
}