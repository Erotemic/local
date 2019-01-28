#xrandr | grep " connected"

#xrandr --output DVI-I-2 --brightness .3
#xrandr --output DVI-I-3 --brightness .3

echo '''
dim.sh
''' > /dev/null

if [ "$1" == "-u" ]; then
    redshift -O 6500 -b 1.0
elif [ "$1" == "1" ]; then
    redshift -O 3000 -b 0.6
elif [ "$1" == "2" ]; then
    redshift -O 2500 -b 0.5
elif [ "$1" == "3" ]; then
    redshift -O 2000 -b .3
else
    #sudo apt-get install redshift
    #redshift -O 6500 -b 1.0
    #redshift -O 3500 -b 1.0
    redshift -O 2900 -b 0.6
    redshift -O 2550 -b 0.5
    redshift -O 2300 -b .45
    #redshift -O 2200 -b .4
    redshift -O 2000 -b .3
fi
