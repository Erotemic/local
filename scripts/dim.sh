__heredoc__='''
dim.sh
''' 

# notes:
#xrandr | grep " connected"
#xrandr --output DVI-I-2 --brightness .3
#xrandr --output DVI-I-3 --brightness .3


if [ "$(which redshift)" == "" ]; then
    echo "ERROR: REQUIRES REDSHIFT"
    echo "apt install redshift"
    exit 1
fi


if [ "$#" -gt 0 ]; then
    ARG_0="$1"
else
    ARG_0="1"
fi

# Simple cases:
if [ "$ARG_0" == "-u" ]; then
    #redshift -O 6500 -b 1.0
    redshift -x
elif [ "$ARG_0" == "0" ]; then
    #redshift -O 6500 -b 1.0
    redshift -x
elif [ "$ARG_0" == "1" ]; then
    redshift -O 3000 -b 0.6
elif [ "$ARG_0" == "2" ]; then
    redshift -O 2500 -b 0.5
elif [ "$ARG_0" == "3" ]; then
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
    arg = '$ARG_0'
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
fi
