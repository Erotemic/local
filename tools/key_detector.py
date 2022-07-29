"""
See Also:
    xev - apt installable linux program that does this.
    keyboard_mods.py - other file in this dir

    qjoypad - map a joypad to a keypress

    # To initially configure a profile use
    qjoypad --notray

    # then map joystick keys to keyboard keys

"""
from pynput import keyboard


def on_press(key):
    try:
        print('Alphanumeric key pressed: {0} '.format(
            key.char))
    except AttributeError:
        print('special key pressed: {0}'.format(
            key))


def on_release(key):
    print('Key released: {0}'.format(
        key))
    if key == keyboard.Key.esc:
        # Stop listener
        return False


# Collect events until released
with keyboard.Listener(
        on_press=on_press,
        on_release=on_release) as listener:
    listener.join()
