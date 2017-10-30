#xrandr | grep " connected"

#xrandr --output DVI-I-2 --brightness .3
#xrandr --output DVI-I-3 --brightness .3

if [ "$1" == "-u" ]; then
    redshift -O 6500 -b 1.0
else
    #sudo apt-get install redshift
    #redshift -O 6500 -b 1.0
    #redshift -O 2500 -b .5
    redshift -O 2200 -b .4
    redshift -O 2000 -b .3
fi
