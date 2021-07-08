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


DevNotes:
    ls /usr/share/X11/xkb/symbols
    cat /usr/share/X11/xkb/symbols/pc
    cat /usr/share/X11/xkb/symbols/us
    cat /usr/share/X11/xkb/symbols/inet

    grep -i tab /usr/share/X11/xkb/symbols/*
    grep -i enter /usr/share/X11/xkb/symbols/*
    grep -i return /usr/share/X11/xkb/symbols/inet
    grep -i space /usr/share/X11/xkb/symbols/*

    cat /usr/share/X11/xkb/symbols/inet | grep '"evdev"' -C 200
    cat /usr/share/X11/xkb/symbols/inet | grep '"evdev"' -C 200 | grep XF86Launch8
    cat /usr/share/X11/xkb/symbols/inet | grep '"evdev"' -C 200 | grep Toggle
    cat /usr/share/X11/xkb/symbols/inet | grep '"evdev"' -C 200 | grep FK
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
import ubelt as ub
from os.path import join


def ensure_config_files():
    dpath = ub.ensuredir(ub.expandpath('$HOME/.xkb/'))
    kbd_dpath = ub.ensuredir((dpath, 'keymap'))
    sym_dpath = ub.ensuredir((dpath, 'symbols'))

    # Each profile will have a db config file which points to a sym symbols
    # file that does the actual remap
    profile_info = {
        'default': {
            'kdb_fpath': join(kbd_dpath, 'kbd_default'),
            'sym_fpath': join(sym_dpath, 'sym_default'),
        },
        'tek_cleave': {
            'kdb_fpath': join(kbd_dpath, 'kbd_tek_cleave'),
            'sym_fpath': join(sym_dpath, 'sym_tek_cleave'),
        }
    }

    stamp = ub.CacheStamp('gen_keymap_stamp', dpath=dpath,
                          depends=ub.hash_file(__file__))
    if stamp.expired():
        default_text = ub.cmd('setxkbmap -print')['out'].replace('\t', ' ')

        # Looks something like this
        if __debug__:
            expected_default_text = ub.codeblock(
                """
                xkb_keymap {
                    xkb_keycodes  { include "evdev+aliases(qwerty)" };
                    xkb_types     { include "complete" };
                    xkb_compat    { include "complete" };
                    xkb_symbols   { include "pc+us+us:2+inet(evdev)" };
                    xkb_geometry  { include "pc(pc105)" };
                };
                """
            )

            if not ub.allsame([_.replace(' ', '') for _ in [expected_default_text, default_text]]):
                # print('warning')
                pass

        profile = profile_info['default']
        profile['kdb_text'] = default_text

        """
        CLEAVE Custom Layout looks like:
        BACK_TAB( F16 )      PASTE( F22 )             UNDO( F23 e
                             CUT( F20 )               COPY( F21 )
                             CENTER_DELETE( FK19 )     BACKSPACE(----)
        LEFT_SPACEBAR( F18 ) CENTER_SHIFT( FK17 )
        """
        profile = profile_info['tek_cleave']
        # TODO: Modify with a parsed representation
        profile['kdb_text'] = ub.codeblock(
            '''
            xkb_keymap {
             xkb_keycodes  { include "evdev+aliases(qwerty)" };
             xkb_types     { include "complete" };
             xkb_compat    { include "complete" };
             xkb_symbols   { include "pc+us+us:2+inet(evdev)+sym_tek_cleave(sym_custom_cleave)" };
             xkb_geometry  { include "pc(pc105)" };
            };
            ''')
        profile['sym_text'] = ub.codeblock(
            '''
            partial modifier_keys
            xkb_symbols "sym_custom_cleave" {
                replace key <LCTL>  { [ Shift_L ] };
                replace key <LFSH> { [ Control_L ] };

                replace key <FK16> { [ f ] };  // Back-tab

                replace key <FK17> { [ space ] };  // Left Space
                replace key <FK18> { [ Return ] }; // Center Shift

                replace key <FK19> { [ Tab ] };  // center delete
                replace key <FK20> { [ Tab ] };  // Cut
                replace key <FK21> { [ Tab ] };  // Copy
                replace key <FK22> { [ Super_L ] };  // Paste
                replace key <FK23> { [ Super_L ] };  // Undo
            };
            ''')

        for profile in profile_info.values():

            fpath = profile.get('kdb_fpath', None)
            text = profile.get('kdb_text', None)
            if fpath is not None and text is not None:
                with open(fpath, 'w') as file:
                    file.write(text)

                print('fpath = {!r}'.format(fpath))
                print(ub.readfrom(fpath))

            fpath = profile.get('sym_fpath', None)
            text = profile.get('sym_text', None)
            if fpath is not None and text is not None:
                with open(fpath, 'w') as file:
                    file.write(text)

                print('fpath = {!r}'.format(fpath))
                print(ub.readfrom(fpath))

        '''
        Reload commands:
            ls $HOME/.xkb/keymap
            xkbcomp -I$HOME/.xkb $HOME/.xkb/keymap/kbd_tek_cleave $DISPLAY
            xkbcomp -w0 -I$HOME/.xkb $HOME/.xkb/keymap/kdb_default $DISPLAY
        '''

        stamp.renew()

    return profile_info


def use_profile(profile_name):
    if profile_name == 'auto':
        info = ub.cmd('hwinfo --keyboard --short', verbose=3)
        CLEAVE_NAME = 'TrulyErgonomic.com Truly Ergonomic CLEAVE Keyboard'
        if CLEAVE_NAME in info['out']:
            profile_name = 'tek_cleave'
        else:
            profile_name = 'default'
    profile_info = ensure_config_files()
    if profile_name not in profile_info:
        raise KeyError(ub.paragraph(
            '''
            Got profile_name={}. Valid choices are: auto, {}
            '''.format(profile_name, ', '.join(profile_info.keys()))
        ))
    profile = profile_info[profile_name]
    cmd_text = ub.paragraph(
        '''
        xkbcomp -w0 -I$HOME/.xkb {kdb_fpath} $DISPLAY
        ''').format(**profile)
    ub.cmd(cmd_text, shell=True, verbose=3, check=True)


def cli():
    import click

    context_settings = {
        'help_option_names': ['-h', '--help'],
        'allow_extra_args': True,
        'ignore_unknown_options': True}

    @click.group(context_settings=context_settings)
    def cli_group():
        pass

    @cli_group.add_command
    @click.command('auto', context_settings=context_settings)
    def auto():
        use_profile('auto')

    @cli_group.add_command
    @click.command('tek_cleave', context_settings=context_settings)
    def tek_cleave():
        use_profile('tek_cleave')

    @cli_group.add_command
    @click.command('default', context_settings=context_settings)
    def default():
        use_profile('default')

    cli_group()


if __name__ == '__main__':
    """
    CommandLine:
        xkbcomp -w0 -I$HOME/.xkb $HOME/.xkb/keymap/default_kbd $DISPLAY

        python ~/local/tools/keyboard_mods.py tek_cleave
        python ~/local/tools/keyboard_mods.py default
        python ~/local/tools/keyboard_mods.py
    """
    cli()
