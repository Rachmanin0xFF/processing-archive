from scipy.fft import fft, fftfreq, irfft, rfft
import matplotlib.pyplot as plt
import numpy as np
from scipy.signal import savgol_filter
import scipy.fftpack as fftpack



t = []
y = []
with open('autocorrelation.txt') as f:
    for line in f:
        k = line.split(" ")
        t.append(float(k[0]))
        y.append(float(k[1]))

yf = fft(y)
tf = fftfreq(len(y), d=1.0/10000.0)

def smooth_data_fft(arr, span):  # the scaling of "span" is open to suggestions
    w = fftpack.rfft(arr)
    spectrum = w ** 2
    cutoff_idx = spectrum < (spectrum.max() * (1 - np.exp(-span / 2000)))
    w[cutoff_idx] = 0
    return fftpack.irfft(w)

plt.plot(tf, yf)
plt.show()

yhat = smooth_data_fft(y, 3)
plt.plot(t, y)
plt.plot(t, yhat, color='red')
plt.show()

for i in range(0, len(y)):
    print(str(t[i]) + ' ' + str(yhat[i]))