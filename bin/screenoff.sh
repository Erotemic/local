#!/usr/bin/env bash
__doc__="
Turn Monitors Off via the Command Line (CLI)

Does exactly what it says. It will turn off all of your monitors
until the mouse is moved or a key is pressed.

Modified from HopeSeekr's BashScripts Collection in [3]_.

Original Author:
    Copyright © 2020-2024 Theodore R. Smith <theodore@phpexperts.pro>
    GPG Fingerprint: 4BF8 2613 1C34 87AC D28F  2AD8 EB24 A91D D612 5690

    License: Creative Commons Attribution v4.0 International

References:
    .. [1] https://superuser.com/questions/374637/how-to-turn-off-screen-with-shortcut-in-linux
    .. [2] https://askubuntu.com/a/1523161/426149
    .. [3] https://github.com/hopeseekr/BashScripts/blob/trunk/turn-off-monitors
"
if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
	# Running as a script
	set -eo pipefail
fi


function turn-off-screen-in-wayland()
{
    echo "Turning off monitors..."
    if [[ $XDG_SESSION_DESKTOP == gnome* ]]; then
        _trigger-monitors-off-in-gnome-wayland

        local interaction_event=$(wait_until_mouse_or_keyboard_event)
        echo "Event Type: ${interaction_event}"

        echo "Turning monitors back on..."
        _trigger-monitors-on-in-gnome-wayland

    elif [[ $XDG_SESSION_DESKTOP == "plasma" || $XDG_SESSION_DESKTOP == "KDE" ]]; then
        _trigger-monitors-off-in-kde-wayland
    else
        echo "ERROR: Unsupported Wayland Desktop Environment: $XDG_SESSION_DESKTOP"
        exit 2
    fi
    }

function _trigger-monitors-off-in-gnome-wayland()
{
    busctl --user set-property org.gnome.Mutter.DisplayConfig /org/gnome/Mutter/DisplayConfig org.gnome.Mutter.DisplayConfig PowerSaveMode i 1
}

function _trigger-monitors-on-in-gnome-wayland()
{
    busctl --user set-property org.gnome.Mutter.DisplayConfig /org/gnome/Mutter/DisplayConfig org.gnome.Mutter.DisplayConfig PowerSaveMode i 0
}

function _trigger-monitors-off-in-kde-wayland()
{
    kscreen-doctor --dpms off
}

### BUILT FROM framework/wait_until_mouse_or_keyboard_event.sh
function wait_until_mouse_or_keyboard_event()
{
    # Ensure libinput-tools is installed
    if ! command -v libinput >/dev/null 2>&1; then
        echo "Error: libinput-tools is not installed. Please install it and try again."
        exit 1
    fi

    if ! command -v sudo >/dev/null 2>&1; then
        echo "Error: sudo is not installed. Please install it and try again."
        exit 1
    fi

    # Turn off the monitors.

    # Start monitoring input events
    echo "Monitoring input events. Press Ctrl+C to stop."
    sudo stdbuf -oL libinput debug-events | while read -r line; do
        case "$line" in
            *"KEYBOARD_KEY"*)
                echo "KEYBOARD_KEY"; return 0;
                ;;
            *"POINTER_BUTTON"*)
                echo "MOUSE_CLICK"; return 0;
                ;;
            *"POINTER_MOTION"*)
                echo "MOUSE_MOVED"; return 0;
                ;;
            *"TOUCH_FRAME"*)
                echo "TOUCH_FRAME"; return 0;
                ;;
            *"TOUCH_MOTION"*)
                echo "TOUCH_MOTION"; return 0;
                ;;
        esac
    done
}
### END framework/wait_until_mouse_or_keyboard_event.sh

screenoff_main(){
    if [ "$XDG_SESSION_TYPE" == "tty" ]; then
        busctl --user set-property org.gnome.Mutter.DisplayConfig /org/gnome/Mutter/DisplayConfig org.gnome.Mutter.DisplayConfig PowerSaveMode i 1
    elif [ "$XDG_SESSION_TYPE" == "wayland" ]; then
        turn-off-screen-in-wayland
    else
        # sleep to prevent the key-up from entering this command causes the screen
        # to turn back on. It would be nice to have a more robust way of
        # accomplishing this.
        sleep 0.5; xset dpms force off
    fi
}


if [[ ${BASH_SOURCE[0]} != "$0" ]]; then
    # We are sourcing the library
    echo "Sourcing screenoff as a library and environment"
else
    screenoff_main
    exit $?
fi
