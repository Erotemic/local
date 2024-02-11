#!/usr/bin/env bash
WINTITLE="IPython" # Main Thunderbird window has this in titlebar
PROGNAME="$PORT_SCRIPTS/linux_scripts/qtc" # This is the name of the binary for t-bird

if [ `wmctrl -l | grep -c "$WINTITLE"` != 0 ]
then
wmctrl -a "$WINTITLE" 
else
cd ~/code/hotspotter
$PROGNAME & 
fi
exit 0
