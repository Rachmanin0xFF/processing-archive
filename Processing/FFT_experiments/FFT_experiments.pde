float[] arr = new float[512];

void setup() {
  size(512, 512, P2D);
  
}

void draw() {
  
  for(int i = 0; i < arr.length; i++) {
    arr[i] = sin(i * mouseX / 100.0 + (millis()*0.07251) % 10)*5.0 + random(-2, 2);
  }
  dft(arr, 512);
  
  background(10, 10, 50);
  stroke(255);
  
  for(int i = 0; i < arr.length-1; i++) {
    line(i*2, -arr[i]*0.25 + height/2, (i+1)*2, -arr[i+1]*0.25 + height/2);
  }
}


float sq_cos( float x,  float T) {
    //if (T == 1) return (x % 2) * 2 - 1;
    //return (32 - ((T - abs(x % (2 * T) - T)) * 64) / T)/32.0;
    //return sign(w)*(-w*w/32 + 2*w);
    //return ((x/T + 1)%2)*2 - 1;
    //return (int)32*cos(x * 3.141592 / T);
    return sign2(cos(PI*x/T));
    //return cos(PI*x/T);
    //return PI*0.5-acos(cos(PI*x/(4*T)));
}

float sign(float x) {
  if(x == 0) return 0;
  return x > 0 ? 1 : -1;
}
float sign2(float x) {
  if(abs(x) < 0.5) return 0;
  return x > 0 ? 1 : -1;
}

float sq_sin( float x, float T) {
    if (T == 1) return 0;
    return -sq_cos(x + T / 2, T);
}

void bit_reverse(float[] signal, int N) {
    float tmp = 0;
    int j = 0;
    for (int i = 0; i < N - 1; i++) {
        if (i < j) {
            tmp = signal[j];
            signal[j] = signal[i];
            signal[i] = tmp;
        }
        int k = (N >> 1);
        while (k <= j) {
            j -= k;
            k >>= 1;
        }
        j += k;
    }
}
void dft(float[] signal, int len) {
    int evi = 0, odi = 0;
    float ev_re, od_re, ev_im, od_im, exp_re, exp_im, res_re, res_im;
    bit_reverse(signal, len);

    float[] signal_im = new float[len];
    for (int i = 0; i < len; i++) signal_im[i] = 0;
    
    for (int n = 2; n <= len; n <<= 1) {
        for (int i = 0; i < len; i += n) {
            for (int k = 0; k < n / 2; k++) {
                evi = i + k;
                odi = i + k + (n / 2);

                ev_re = signal[evi];
                ev_im = signal_im[evi];

                od_re = signal[odi];
                od_im = signal_im[odi];

                exp_re = sq_cos(2 * k, n);
                exp_im = -sq_sin(2 * k, n);

                res_re = od_re * exp_re - od_im * exp_im;
                res_im = od_re * exp_im + od_im * exp_re;

                signal[evi] = ev_re + res_re;
                signal_im[evi] = ev_im + res_im;

                signal[odi] = ev_re - res_re;
                signal_im[odi] = ev_im - res_im;
            }
        }
    }
    

    for (int n = 0; n < len; n++) {
        signal[n] = (abs(signal[n]) +abs(signal_im[n])) / 4;
    }
}
