import numpy as np
import matplotlib.pyplot as plt
import types
tau = np.float64(np.pi * 2)
def cirlce_rad2xy(radians):
    return  np.cos(radians), np.sin(radians)
# The base of the ring 
_BASE = 12 # number of times to evenly split circle
# Build the positions of each note on the constellation
# shift by tau/4 so it starts with the root on the top 
chromatic_theta = (np.arange(0,_BASE)*(tau/_BASE) + tau/4)[::-1]
chromatic_xy = np.array(zip(*cirlce_rad2xy(chromatic_theta)))

def ring_diff(scale):
    shift = np.append(np.diff(scale), [scale[0]+_BASE - scale[-1]])
    return shift
def ring_inte(shift):
    scale = np.roll(np.mod(shift.cumsum(), _BASE),1)
    return scale


def build_modes(base_scale, name_list):
    if not type(name_list) is types.ListType:
        name_list = [str(name_list)+str(num) for num in xrange(len(base_scale))]
    base_shift = ring_diff(base_scale)
    modes = {}
    for ix in xrange(len(base_scale)):
        mode_name  = name_list[ix]
        mode_shift = np.roll(base_shift,-ix)
        mode_scale = ring_inte(mode_shift) 
        modes[mode_name] = mode_scale
    return modes, name_list


def hex_to_rgb(value):
    value = value.lstrip('#')
    lv = len(value)
    return tuple(float(int(value[i:i+int(lv/3)], 16))/255 for i in range(0, lv, int(lv/3)))

#arm_color      = hex_to_rgb('75EAC1') 
#chrm_txt_color = hex_to_rgb('AED0E9')
#hand_txt_color = hex_to_rgb('FFC77F')
#name_color= hex_to_rgb('FFC77F') 

arm_color      = hex_to_rgb('0000FF') 
chrm_txt_color = hex_to_rgb('000000')
hand_txt_color = hex_to_rgb('FF0000')
name_color     = hex_to_rgb('000000') 

def plot_constellation(scale, pos_xy=(0.,0.), **kwargs):
    fig = plt.gcf()
    ax  = plt.gca()
    # Pick your scale out of the chromatic scale
    scale_xy = chromatic_xy[scale,:]
    scale_theta = chromatic_theta[scale,:]

    chrm_sf = .318
    txt_sf  = 1.3
    root_sf = 1.15
    pos_x, pos_y = np.array(pos_xy)
    ## Plot background
    for note_x, (chrm_xy, chrm_theta)\
            in enumerate(zip(chromatic_xy, chromatic_theta)):
        arm_x, arm_y = chrm_xy 
        x_data = [pos_x, pos_x + arm_x*chrm_sf]
        y_data = [pos_y, pos_y + arm_y*chrm_sf]
        txt_degrees = round(np.mod(4*(chrm_theta)/tau,2))
        ax.text(pos_x + arm_x * txt_sf*1.3,
                pos_y + arm_y * txt_sf*1.3,
                str(note_x+1),
                rotation=txt_degrees, 
                horizontalalignment='center',
                verticalalignment='center',
                color=chrm_txt_color,
                size=8)
        chrm_artist = plt.Line2D(x_data, y_data, color=arm_color)
        ax.add_artist(chrm_artist)

    # Plot Arm Directions
    for scale_x, (arm_xy, arm_theta) in enumerate(zip(scale_xy, scale_theta)):
        arm_x, arm_y = arm_xy
        if scale_x == 0:
            #Plot Root Direction
            dx, dy = arm_xy * root_sf
            root_artist = plt.Arrow(pos_x, pos_y,
                                    dx, dy,
                                    color=arm_color, 
                                    width=.2)
            ax.add_artist(root_artist)
        else:
            hand_artist = plt.Circle((pos_x + arm_x, pos_y + arm_y), .05, color=arm_color) 
            ax.add_artist(hand_artist)

        x_data = [pos_x, pos_x + arm_x]
        y_data = [pos_y, pos_y + arm_y]
        arm_artist = plt.Line2D(x_data, y_data, color=arm_color,linewidth=2)
        ax.add_artist(arm_artist)

        #txt_x, txt_y = arm_x*txt_sf, arm_y*txt_sf
        txt_degrees = round(np.mod(4*(arm_theta)/tau,2))
        plt.text(pos_x + arm_x * txt_sf,
                pos_y + arm_y * txt_sf,
                str(scale_x+1),
                color=hand_txt_color,
                horizontalalignment='center',
                verticalalignment='center',
                rotation=txt_degrees,
                size=14)
                #rotation=180*text_theta/np.pi
        ax.add_artist(arm_artist)

#hand_txt_color = [1, .4,   .3]
#fig_width = 19.2*2
#fig_height = 10.8*2
#y_shift = -fig_height * (1 - 0.618)/4
#hungarian_minor = np.array([ 1, 3, 4, 7, 8, 9, 12])-1
#hungarian_major = np.array([ 1, 4, 5, 7, 8, 10, 11])-1
#blues = np.array([ 1, 4, 6, 7, 8, 11])-1

'''
from midiutil.MidiFile import MIDIFile
#line1 = plt.Line2D([0, 0, 0], [-50, 0, 0], linewidth=80)
#ax.add_line(line1)

MyMIDI = MIDIFile(1)

# Tracks are numbered from zero. Times are measured in beats.

track = 0   
time = 0

# Add track name and tempo.
MyMIDI.addTrackName(track,time,"Sample Track")
MyMIDI.addTempo(track,time,120)

# Add a note. addNote expects the following information:
track = 0
channel = 0


A 
A = 440
AOctave = A * 2**(np.arange(0,11)/12.)

octave_list = []
for i in range(-4,5):
    octave_list += [AOctave*2**i]
AllOctaves = np.array(octave_list)
A440Octave = A * 2**(np.arange(0,11)/12.)

A*2**(0)
A2 = 880

MiddleC = 60
CSharp=65
pitch = A
time = 0
duration = 1
volume = 100

# Now add the note.
MyMIDI.addNote(track,channel,pitch,time,duration,volume)

# And write it to disk.
binfile = open("output.mid", 'wb')
MyMIDI.writeFile(binfile)
binfile.close()
MyMIDI = MIDIFile(1)
track = 0
channel = 0
pitch = 60
time = 0
duration = 1
volume = 100
MyMIDI.addNote(track,channel,pitch,time,duration,volume)

'''
