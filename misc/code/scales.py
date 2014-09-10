from __future__ import division
import matplotlib.pyplot as plt
import numpy as np
from wiki_scale_list import *
from modes import *

kwargs = {}

#bgcolor = hex_to_rgb('00070E') 
bgcolor        = hex_to_rgb('FFFFFF') 

# Written in base 1. Converted to base 0
ionian = np.array([ 1, 3, 5, 6, 8,10,12])-1
greek_mode_dict, greek_mode_names = build_modes(ionian, ['Ionian',
                                                     'Dorian',
                                                     'Phyrgian',
                                                     'Lydian',
                                                     'Mixolydian',
                                                     'Aeolian',
                                                     'Locrian'])

txt_yshift = 2

def write_all_plots_to_disk():
    mode_dict = get_wiki_modes()
    mode_names = get_wiki_mode_names()
    for scale_num, scale_name in enumerate():
        scale = mode_dict[scale_name]
        fig = plt.figure(scale_num, figsize=(6,6))
        ax  = plt.subplot(111)
        ax.set_aspect('equal')
        ax.set_xlim(-3,3)
        ax.set_ylim(-3,3)
        pos_xy=(0.,0.)
        plot_constellation(scale, pos_xy=pos_xy)
        plt.text(pos_xy[0], pos_xy[1] - txt_yshift, scale_name,
                color=name_color,
                horizontalalignment='center', verticalalignment='top', size=18)
        fig.savefig(scale_name+'.png',format='png')
        

def plot_modes(mode_dict, mode_names):
    #mode_dict = greek_mode_dict
    #mode_names = greek_mode_names
    num_scales = len(mode_dict)
    fig_width  = 30
    fig_height = max(6 * int(num_scales / 7),6)

    step_size  = 11*tau/16
    cur_x = -step_size*(num_scales-1) / 2
    y_shift = 0 
    fig = plt.figure(0, figsize=(fig_width, fig_height))
    fig.clf()
    ax = fig.add_subplot(111)
    ax.set_axis_bgcolor(bgcolor)
    ax.set_xlim(-fig_width/2.0, fig_width/2.0)
    ax.set_ylim((-fig_height/2.0)-y_shift, fig_height/2.0-y_shift)
    ax.set_aspect('equal')

    level = 0
    for count, scale_name in enumerate(mode_names):
        pos_xy=(cur_x,0.)
        cur_x += step_size
        scale = mode_dict[scale_name]
        plot_constellation(scale, pos_xy=pos_xy)
        plt.text(pos_xy[0], pos_xy[1] - txt_yshift, scale_name,
                color=name_color,
                horizontalalignment='center', verticalalignment='top', size=18)
        if np.mod(count, 7) == 0:
            level+=1
    fig.show()

#plot_modes(greek_mode_dict, greek_mode_names)

misheberak_scale = np.array([1,3,5,7,8,10,12])-1
ukranian_dorian = np.array([1,3,4,7,8,10,11])-1
tmp_d = {'Misheberak (Altered Dorian)':misheberak_scale,
         'Ukranian Dorian':ukranian_dorian}
plot_modes(tmp_d,tmp_d.keys())


plt.show()
plt.draw()
