reinitialize
# Where Pymol find your PDB
load Path_To_The_PDB-File/file.pdb, 2P
# hide everything
hide
#Praeamble
# Define a new color which will be used for the carbons
set_color darkgrey,[69,69,69]
# Set the diameter of the spheres and the sticks for all atoms.
# note, that the (diameter of the spheres) = spherescale x (van der waals diameter)
set sphere_scale, 0.3
set stick_radius, 0.05
# redefine the color and the spherescale for selected elements
# C
set sphere_scale, 0.15, elem C
color darkgrey, elem C
# H
create H, elem H
set sphere_scale, 0.1, elem H
# N
set sphere_scale, 0.15, elem N
# O
set sphere_scale, 0.15, elem O
color red, elem O
# S
set sphere_scale, 0.2, elem S
color dash, elem S
# Fe
set sphere_scale, 0.25, elem Fe
color ruby, elem Fe
# Change the Van der Waals diameter for N,O,C so that they all have the same spherediameter
alter elem N, vdw=1.7
alter elem O, vdw=1.7
alter elem C, vdw=1.7
rebuild
#
bg_color white
# Enable background transparency for the png-Export
set ray_opaque_background, off
show spheres, all
show sticks, all
# Create the named selections Fea, O2 
create Fea, elem Fe and 2P
create O2, elem O and (Fea around 2.2) and 2P
# Make a dashed bond between O2 and N1 (Hydrogenbridge)
distance e, Fea, O2
hide labels, all
set depth_cue=0
set ray_trace_fog=0
# Mit get_view kriegt man das unten
set dash_color, grey
# After Adjusting the View with the mouse, you can save it with get_view and paste it in here.
# Set the origin of rotation
origin Fea
set_view (\
     0.025690084,    0.975155592,    0.220006928,\
     0.981839538,    0.016763220,   -0.188958615,\
    -0.187951177,    0.220864862,   -0.957024217,\
    -0.000000440,    0.000003060,  -30.120845795,\
    -0.343086064,    0.167116940,   -0.104641616,\
     7.526556492,   52.107307434,    0.000000000 )
# Makes your image look better, increase the number for better quality. You can save it with the png-command. 
ray 300
