import os
import numpy as np
import matplotlib
matplotlib.use('Qt4Agg', warn=True, force=True)
import matplotlib.pyplot as plt
from sklearn.decomposition import PCA
from PIL import Image

home = 'C:/Users/joncrall'
os.chdir(home+'/Dropbox/Code')

stride = 4 
img = plt.imread('micro.jpg')
imgGRAY = np.asarray(Image.open('micro.jpg').convert('L'))

(w, h, dims) = img.shape
data = img.reshape(w*h, dims)
tdims = 1
color_pca = PCA(copy=True, n_components=tdims, whiten=True)
color_pca.fit(data[::stride])
dataPCA = color_pca.transform(data)
dmin = dataPCA.min()
dmax = dataPCA.max()
dataPCA = (dataPCA - dmin) / (dmax-dmin)
imgPCA = 255 - np.array(dataPCA.reshape(w, h) * 255, dtype=np.uint8)

fig = plt.figure(1)
ax = fig.add_subplot(2,2,1)
ax.imshow(img, cmap='gray')

fig2 = plt.figure(2)
ax2 = fig2.add_subplot(2,2,1)
ax2.imshow(imgGRAY, cmap='gray')

cmaps = ['gray', 'hot', 'PRGn']

for (mx, cmap_) in enumerate(cmaps):
    print(mx)
    print(cmap_)
    #
    ax = fig.add_subplot(2,2,mx+2)
    cax = ax.imshow(imgPCA, cmap=cmap_)
    #fig.colorbar(cax,  orientation='horizontal')
    #
    ax2 = fig2.add_subplot(2,2,mx+2)
    cax2 = ax2.imshow(imgGRAY, cmap=cmap_)
    #fig2.colorbar(cax2,  orientation='horizontal')


color_pca = PCA(copy=True, n_components=3, whiten=False)
color_pca.fit(data[::stride])
dataPCA = color_pca.transform(data)
dmin = dataPCA.min()
dmax = dataPCA.max()
dataPCA = (dataPCA - dmin) / (dmax-dmin)
imgPCA = 255 - np.array(dataPCA.reshape(w, h, 3) * 255, dtype=np.uint8)
fig = plt.figure(3)
ax = fig.add_subplot(111)
ax.imshow(imgPCA)
