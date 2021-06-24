"""
References:
    https://unix.stackexchange.com/questions/65507/use-setxkbmap-to-swap-the-left-shift-and-left-control
    https://github.com/sezanzeb/key-mapper

setxkbmap -print -layout "us+ru:2+us:3+inet(evdev)+capslock(grouplock)+custom"

https://www.reddit.com/r/linux/comments/1ydiu7/howto_different_xkb_config_for_only_certain/
https://unix.stackexchange.com/questions/212573/how-can-i-make-backspace-act-as-escape-using-setxkbmap

https://superuser.com/questions/1133476/make-terminal-recognize-pageup-and-pagedown-when-remapped-to-different-keys/1168603#1168603
https://askubuntu.com/questions/882432/xkb-is-not-loading-microsoft4000-configuration


Use xev to handle finding what custom keys are doing

    xev


For CLEAVE-S V1

You are able to select the included ‘Custom Layout’ by pressing:

    [Fn][Esc][Q]



TO RESET CLEAVE:

    Fn-Esc-R

    Then to map center shift to Super_L

    Fn-Esc-(CENTER_SHIFT) -> 8



See Also:
    ls /usr/share/X11/xkb/symbols
    cat /usr/share/X11/xkb/symbols/pc
    cat /usr/share/X11/xkb/symbols/us
    cat /usr/share/X11/xkb/symbols/inet

    grep -i tab /usr/share/X11/xkb/symbols/*
    grep -i enter /usr/share/X11/xkb/symbols/*
    grep -i return /usr/share/X11/xkb/symbols/inet

    cat /usr/share/X11/xkb/symbols/inet | grep '"evdev"' -C 200

    cat /usr/share/X11/xkb/symbols/inet | grep '"evdev"' -C 200 | grep FK



#For left space and center shift

KeyPress event, serial 37, synthetic NO, window 0x4600001,
    root 0x1e2, subw 0x0, time 1851565142, (1483,990), root:(1578,1854),
    state 0x0, keycode 195 (keysym 0x1008ff48, XF86Launch8), same_screen YES,
    XLookupString gives 0 bytes:
    XmbLookupString gives 0 bytes:
    XFilterEvent returns: False

KeyPress event, serial 37, synthetic NO, window 0x4600001,
    root 0x1e2, subw 0x0e time 1851562536, (1483,990), root:(1578,1854),
    state 0x0, keycode 196 (keysym 0x1008ff49, XF86Launch9), same_screen YES,
    XLookupString gives 0 bytes:
    XmbLookupString gives 0 bytes:
    XFilterEvent returns: False

"""


def setup_config_files():
    import ubelt as ub
    ub.ensuredir(ub.expandpath('$HOME/.xkb/keymap'))
    ub.ensuredir(ub.expandpath('$HOME/.xkb/symbols'))
    info = ub.cmd('setxkbmap -print')

    default_text = info['out'].replace('\t', ' ')
    # Looks something like this
    """
    xkb_keymap {
     xkb_keycodes  { include "evdev+aliases(qwerty)" };
     xkb_types     { include "complete" };
     xkb_compat    { include "complete" };
     xkb_symbols   { include "pc+us+us:2+inet(evdev)" };
     xkb_geometry  { include "pc(pc105)" };
    };
    """

    # Modify the default text.
    # Add the symbols line to the xkb_symbols section
    # mykbd_text = default_text.copy()
    # Append custom code to the default
    # TODO: add with a parser?
    mykbd_text = ub.codeblock(
        '''
        xkb_keymap {
         xkb_keycodes  { include "evdev+aliases(qwerty)" };
         xkb_types     { include "complete" };
         xkb_compat    { include "complete" };
         xkb_symbols   { include "pc+us+us:2+inet(evdev)+mysym(custom_cleave)" };
         xkb_geometry  { include "pc(pc105)" };
        };
        ''')
    # mykbd_text = ub.codeblock(
    #     '''
    #     xkb_keymap {
    #      xkb_keycodes  { include "evdev+aliases(qwerty)" };
    #      xkb_types     { include "complete" };
    #      xkb_compat    { include "complete" };
    #      xkb_symbols   { include "pc+us+us:2+inet(evdev)+mysym(custom_cleave)" };
    #      xkb_geometry  { include "pc(pc105)" };
    #     };
    #     ''')

    """
    cat /usr/share/X11/xkb/symbols/inet | grep '"evdev"' -C 200 | grep XF86Launch8
    cat /usr/share/X11/xkb/symbols/inet | grep '"evdev"' -C 200 | grep Toggle

    CLEAVE Custom Layout looks like:


    BACK_TAB( F16 )      PASTE( F22 )             UNDO( F23 )

                         CUT( F20 )               COPY( F21 )

                         CENTER_DELETE( FK19 )     BACKSPACE(----)

    LEFT_SPACEBAR( F18 ) CENTER_SHIFT( FK17 )
    """

    mysym_text = ub.codeblock(
        '''
        partial modifier_keys
        xkb_symbols "custom_cleave" {
            replace key <LCTL>  { [ Shift_L ] };
            replace key <LFSH> { [ Control_L ] };

            replace key <FK16> { [ f ] };  // Back-tab

            replace key <FK17> { [ Super_L ] };   // Left Space
            replace key <FK18> { [ Return ] }; // Center Shift

            replace key <FK19> { [ a ] };  // center delete
            replace key <FK20> { [ Tab ] };  // Cut
            replace key <FK21> { [ Tab ] };  // Copy
            replace key <FK22> { [ Super_L ] };  // Paste
            replace key <FK23> { [ Super_L ] };  // Undo
        };
        ''')

    default_fpath = ub.expandpath('$HOME/.xkb/keymap/default_kbd')
    with open(default_fpath, 'w') as file:
        file.write(default_text)

    mykbd_fpath = ub.expandpath('$HOME/.xkb/keymap/mykbd')
    with open(mykbd_fpath, 'w') as file:
        file.write(mykbd_text)

    mysym_fpath = ub.expandpath('$HOME/.xkb/symbols/mysym')
    with open(mysym_fpath, 'w') as file:
        file.write(mysym_text)

    print(ub.readfrom(mykbd_fpath))
    print(ub.readfrom(mysym_fpath))
    # print(ub.readfrom(defa_fpath))

    reload_command = ub.codeblock(
        '''
        xkbcomp -I$HOME/.xkb $HOME/.xkb/keymap/mykbd $DISPLAY
        ''')

    default_command = ub.codeblock(
        '''
        xkbcomp -w0 -I$HOME/.xkb $HOME/.xkb/keymap/default_kbd $DISPLAY
        ''')


def main():
    import ubelt as ub
    import click

    context_settings = {
        'help_option_names': ['-h', '--help'],
        'allow_extra_args': True,
        'ignore_unknown_options': True}

    setup_config_files()

    @click.group(context_settings=context_settings)
    def cli_group():
        pass

    @cli_group.add_command
    @click.command('mysym', context_settings=context_settings)
    def mysym():
        ub.cmd(ub.paragraph(
            '''
            xkbcomp -w0 -I$HOME/.xkb $HOME/.xkb/keymap/mykbd $DISPLAY
            '''), shell=True, verbose=3)

    @cli_group.add_command
    @click.command('default', context_settings=context_settings)
    def default():
        ub.cmd(ub.paragraph(
            '''
            xkbcomp -w0 -I$HOME/.xkb $HOME/.xkb/keymap/default_kbd $DISPLAY
            '''), shell=True, verbose=3)

    cli_group()


if __name__ == '__main__':
    """
    CommandLine:
        python ~/local/tools/keyboard_mods.py mysym
        python ~/local/tools/keyboard_mods.py default
    """
    main()
