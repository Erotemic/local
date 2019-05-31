__heredoc__='''
dim.sh
''' 

# notes:
#xrandr | grep " connected"
#xrandr --output DVI-I-2 --brightness .3
#xrandr --output DVI-I-3 --brightness .3


# Simple cases:
if [ "$1" == "-u" ]; then
    redshift -O 6500 -b 1.0
elif [ "$1" == "0" ]; then
    redshift -O 6500 -b 1.0
elif [ "$1" == "1" ]; then
    redshift -O 3000 -b 0.6
elif [ "$1" == "2" ]; then
    redshift -O 2500 -b 0.5
elif [ "$1" == "3" ]; then
    redshift -O 2000 -b .3
else
    # Complex case, interpolate betweeen integer values:
    CMD=$(python -c "
import math

def interpolate(pts, x):
    x = max(min(pts.keys()), x)
    x = min(max(pts.keys()), x)

    x1 = math.floor(x)
    x2 = math.ceil(x)

    y1 = pts[x1]
    y2 = pts[x2]

    if y1 == y2:
        y = y1
    else:
        alpha = (x2 - x) / (x2 - x1)
        y = (alpha * y1) + ((1 - alpha) * y2)
    return y

def main():
    arg = '$1'
    if arg:
        x = float(arg)

        O_pts = {
            0: 6500,
            1: 3000,
            2: 2500,
            3: 2000,
            4: 1000,  # Absolute min xrandr blueness
        }
        b_pts = {
            0: 1.0,
            1: 0.6,
            2: 0.5,
            3: 0.3,
            4: 0.1, # Absolute min xrandr brightness
        }

        O = int(interpolate(O_pts, x))
        b = float(interpolate(b_pts, x))

        print('redshift -O {} -b {:.4f}'.format(O, b))
    else:
        print('echo no argument')

main()
")
    echo "CMD = $CMD"
    $CMD
##sudo apt-get install redshift
##redshift -O 6500 -b 1.0
##redshift -O 3500 -b 1.0
#redshift -O 2900 -b 0.6
#redshift -O 2550 -b 0.5
#redshift -O 2300 -b .45
##redshift -O 2200 -b .4
#redshift -O 2000 -b .3
fi
