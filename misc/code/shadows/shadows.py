from __future__ import division
import os
import numpy as np
os.chdir(os.environ['PORT_CODE']+'/shadows')
import matplotlib as plt
from pylab import *
import hotspotter.helpers as helpers
import hotspotter.load_data2 as ld2
import hotspotter.draw_func2 as df2

from os.path import join

#imgdir = join(ld2.WS_HARD, 'images')
imgdir = join(ld2.MOTHERS, 'images')


def sliding_window_signature(img):
    # TODO: Refocus light
    (W,H) = img.shape[0:2]
    x_percent = .05
    y_percent = .05
    patch_w = int(np.ceil(W * x_percent))
    patch_h = int(np.ceil(H * y_percent))
    stride  = 10
    u_range = range(0, W - patch_w, stride)
    v_range = range(0, H - patch_h, stride)
    new_img = np.zeros(map(len, (u_range, v_range)))
    uv_gen  = np.array([[(ux, vx, u1, v1) 
                        for ux, u1 in enumerate(u_range)] 
                        for vx, v1 in enumerate(v_range)]).reshape(len(u_range)*len(v_range),4)
    #np.random.shuffle(uv_gen)
    fmt = helpers.make_progress_fmt_str(len(uv_gen),'Sliding window: ')
    progress = 0
    for ux, vx, u1, v1 in uv_gen:
        helpers.print_(fmt % progress)
        #print ux, vx
        u2, v2 = u1+patch_w, v1+patch_h
        patch = img[u1:u2, v1:v2]
        patch_signature = patch.mean(axis=2).std()
        new_img[ux, vx] = patch_signature
        #if progress < 10 and False:
            #figure(progress)
            #imshow(patch)
        progress += 1
    print('')
    new_img = helpers.norm_zero_one(new_img)
    return new_img

def show_signature(img_path, fignum=1):
    print('Showing signature: '+img_path)
    img = plt.imread(join(imgdir, img_path))
    sig_img = sliding_window_signature(img)
    fig = plt.figure(fignum)
    ax1 = fig.add_subplot(1,2,1)
    ax2 = fig.add_subplot(1,2,2)
    ax1.imshow(img)
    ax2.imshow(sig_img)
    fig.show()
    fig.canvas.draw()

image_list =  np.array(os.listdir(imgdir), dtype=object)
img_path = image_list[0]
samplex = np.random.choice(range(len(image_list)), 5)
print samplex
sample = image_list[samplex]
for gx, img_path in enumerate(sample):
    show_signature(img_path, fignum=gx)

#set_cmap('gray')
df2.present()
