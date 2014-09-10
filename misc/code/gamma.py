import matplotlib
MPL_BACKEND = matplotlib.get_backend()
matplotlib.rcParams['toolbar'] = 'toolbar2'
if MPL_BACKEND != 'Qt4Agg':
    if multiprocessing.current_process().name == 'MainProcess':
        print('[df2] current backend is: %r' % MPL_BACKEND)
        print('[df2] matplotlib.use(Qt4Agg)')
    matplotlib.use('Qt4Agg', warn=True, force=True)
    MPL_BACKEND = matplotlib.get_backend()
    if multiprocessing.current_process().name == 'MainProcess':
        print('[df2] current backend is: %r' % MPL_BACKEND)
import matplotlib.pyplot as plt
import matplotlib.colors as colors
from scipy.special import gamma
import math
import scipy as sp
import numpy as np
import itertools

radius=10
dims=3
resolution=100
xbasis = np.linspace(-radius, radius, resolution)
ybasis = np.linspace(-radius, radius, resolution)
jbasis = np.linspace(-radius, radius, resolution)
xgrid, ygrid  =  np.meshgrid(xbasis,
                             ybasis,
                             indexing='ij',
                             sparse=False,
                             copy=False)

num = np.complex(0,1)
print gamma(10)
print math.gamma(10)

#def plot_function(xgrid, ygrid, jgrid, values):
image = np.zeros((resolution, resolution, 3))

def gray2rgb(gray):
    return np.concatenate((gray[:,:,None], gray[:,:,None], gray[:,:,None]),2)
xgrid_col = gray2rgb(xgrid)
ygrid_col = gray2rgb(ygrid)

image = (ygrid_col + xgrid_col)/2
image = np.sqrt(ygrid_col**2 + xgrid_col**2)
image = (image - image.min()) / (image.max() - image.min())
fig = plt.figure(1)
ax = fig.add_subplot(111)
ax.imshow(image, interpolation='nearest')
ax.set_xticklabels(xbasis)
ax.set_yticklabels(ybasis)
ax.set_xticks(xbasis)
ax.set_yticks(ybasis)
ax.set_xlabel('x'); ax.set_ylabel('y')
fig.show()
#plt.contourf
