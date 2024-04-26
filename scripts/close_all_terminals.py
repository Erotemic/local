#!/usr/bin/env python3
"""
References:
    .. [AskUbuntu_608914] https://askubuntu.com/questions/608914/how-can-i-gracefully-close-all-instances-of-gnome-terminal
"""
import subprocess


def get_res():
    # get resolution
    xr = subprocess.check_output(["xrandr"]).decode("utf-8").split()
    pos = xr.index("current")
    return [int(xr[pos + 1]), int(xr[pos + 3].replace(",", ""))]


def main():
    from vimtk import xctrl
    import ubelt as ub
    current_window = xctrl.XWindow.current()
    current_window.wm_id

    terminal_pattern = xctrl._wmctrl_terminal_patterns()
    found_windows1 = xctrl.XWindow.findall(terminal_pattern)

    for w in found_windows1:
        pid = w._wmquery('pid')
        print(f'pid={pid!r}')
        # print(w.process())

    print(f'found_windows1 = {ub.urepr(found_windows1, nl=1)}')

    found_windows2 = [w for w in found_windows1 if 'gvim' not in w.process_name()]
    print(f'found_windows2 = {ub.urepr(found_windows2, nl=1)}')

    chosen_windows = [w for w in found_windows2 if w.wm_id != current_window.wm_id]
    if len(chosen_windows) != len(found_windows2):
        print('Current window is a terminal, ignoring that one')

    print(f'chosen_windows = {ub.urepr(chosen_windows, nl=1)}')
    # pid = subprocess.check_output(
    #     ["pidof", "gnome-terminal"]).decode("utf-8").strip()
    # res = get_res()
    # window_resolutions = subprocess.check_output(
    #     ["wmctrl", "-lpG"]).decode("utf-8").splitlines()

    for window in ub.ProgIter(chosen_windows, desc='Closing Terminals', time_thresh=0):
        # window = t.split()
        # in_current_workspace = all([0 < int(window[3]) < res[0], 0 < int(window[4]) < res[1]])
        # if in_current_workspace:
        # w_id = window[0]
        window.focus(sleeptime=0.1)
        xctrl.XCtrl.send_keys("Ctrl+Shift+Q", sleeptime=0.1)


if __name__ == '__main__':
    """
    CommandLine:
        python ~/local/scripts/close_all_terminals.py
    """
    main()
