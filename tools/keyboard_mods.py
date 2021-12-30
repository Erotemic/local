"""
Script to apply a custom keyboard mapping for a specific keyboard hardware id
(i.e. the CLEAVE).


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


def ensure_xkb_remap_config_files():
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


def linux_keyboard_info():
    info = ub.cmd('hwinfo --keyboard', verbose=3)
    items = []
    for part in info['out'].split('\n\n'):
        lines = part.strip().split('\n')
        line1, line2, *rest = lines
        item = {}
        item['line1'] = line1.strip()
        item['line2'] = line2.strip()
        for line in rest:
            key, value = line.strip().split(':', 1)
            key = key.strip()
            value = value.strip()
            item[key] = value
        if 'Device' in item:
            usb, product_code, product_name = item['Device'].split(' ', 2)
            if usb != 'usb':
                print('warning: {}'.format(item))
            item['product_code'] = product_code
            item['product_name'] = product_name.strip('"')
        if 'Vendor' in item:
            usb, vendor_code, vendor_name = item['Vendor'].split(' ', 2)
            if usb != 'usb':
                print('warning: {}'.format(item))
            item['vendor_code'] = vendor_code
            item['vendor_name'] = vendor_name.strip('"')
        items.append(item)
    return items


def use_xkb_profile(profile_name):
    if profile_name == 'auto':
        # info = ub.cmd('hwinfo --keyboard --short', verbose=3)
        items = linux_keyboard_info()
        CLEAVE_NAME = 'TrulyErgonomic.com Truly Ergonomic CLEAVE Keyboard'
        # if CLEAVE_NAME in info['out']:
        if any(CLEAVE_NAME in item['Model'] for item in items):
            profile_name = 'tek_cleave'
        else:
            profile_name = 'default'
    profile_info = ensure_xkb_remap_config_files()
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


def install_udev_rules():
    """
    This part requires sudo privledges. Running this will install a rule
    that executes this script whenever a USB device is added or removed.
    This should make using the CLEAVE more-or-less seemless.

    References:
        https://www.flatcar-linux.org/docs/latest/setup/systemd/udev-rules/
        https://askubuntu.com/questions/508236/how-can-i-run-code-whenever-a-usb-device-is-unplugged-without-requiring-root
        https://askubuntu.com/questions/625243/how-to-execute-c-program-whenever-a-usb-flash-drive-is-inserted
        https://stackoverflow.com/questions/43736924/ubuntu-run-script-as-user-when-usb-inserted

    lsusb

    sudo udevadm info --name=/dev/input/event2 --attribute-walk
    """
    import os
    import pathlib
    rule_fname = 'rob-keyboard.rules'
    real_rules_dpath = pathlib.Path('/etc/udev/rules.d')
    real_rules_fpath = real_rules_dpath / rule_fname

    script_fpath = os.path.abspath(pathlib.Path(__file__))
    command = 'python {} auto'.format(script_fpath)

    # service_text = ub.codeblock(
    #     '''
    #     [Unit]
    #     Description=Fixes keyboard mappings

    #     [Service]
    #     WorkingDirectory=/path/to/where/you/want/media/files
    #     Type=oneshot
    #     ExecStart=/usr/bin/echo 'custom device script'
    #     StandardOutput=journal

    #     [Install]
    #     WantedBy=custom-usb-event.service
    #     ''').format(command)

    # old_text = '''
    # # ACTION=="add", ATTRS{idProduct}=="XXXX", ATTRS{idVendor}=="YYYY", RUN+="/location/of/my/command"
    # # DRIVERS=="usb", RUN+="/bin/sh -c 'echo action=${ACTION} - id_vendor_id=$env{ID_VENDOR_ID} id_model_id=$env{ID_MODEL_ID} >> /home/joncrall/Desktop/usb-storage.log'"
    # #DRIVERS=="usb", RUN+="/bin/sh -c 'which python 2>&1 >> /home/joncrall/Desktop/udev-log.log'"
    # DRIVERS=="usb", TAG+="systemd", ENV{SYSTEMD_WANTS}="custom-usb-event.service"
    #     # DRIVERS=="usb", RUN+="/bin/sh -c '%s 2>&1 >> /home/joncrall/Desktop/udev-log.log'"
    # '''
    # DRIVERS=="usb", RUN+="/bin/sh -c 'echo $(date) hello world 2>&1 >> /home/joncrall/Desktop/udev-log.log'"

    # Not quite working

    username = os.environ['USER']
    # /bin/su {username} -c 'source $HOME/.bashrc && echo $(date) $USER - $VIRTUAL_ENV - $PATH >> /home/joncrall/Desktop/udev-log.log'
    # This is a big hack to get my environment and to run as a local user.
    # Probably should be using systemd instead
    run_command = ub.paragraph(
        '''
        /bin/su {username} -c 'source $HOME/.bashrc && python $HOME/local/tools/keyboard_mods.py auto >> /home/joncrall/Desktop/udev-log.log'
        ''').format(username=username)
    print('sudo ' + run_command)

    text = ub.codeblock(
        '''
        DRIVERS=="usb", RUN+="%s"
        ''') % (run_command,)
    print(text)
    # Write to temp path and then have user do the sudo move
    assert real_rules_dpath.exists()
    has_permission = os.access(real_rules_dpath, os.W_OK | os.X_OK)
    if not has_permission:
        print('Cant write directly, need to workaround')
        temp_root_dpath = pathlib.Path(ub.ensure_app_cache_dir('rob/temp_root'))
        rule_fpath = temp_root_dpath / rule_fname
        rule_fpath.write_text(text)
        print('Need superuser permissions to run:')
        super_user_commands = ub.codeblock(
            '''
            sudo cp {} {}
            sudo udevadm control --reload-rules
            ''').format(rule_fpath, real_rules_fpath).split('\n')
        ub.cmd(super_user_commands[0], verbose=2, shell=True, check=True)
        ub.cmd(super_user_commands[1], verbose=2, shell=True, check=True)
        assert real_rules_fpath.read_text() == rule_fpath.read_text()
        assert real_rules_fpath.read_text() == text
    else:
        real_rules_fpath.write(text)
        raise NotImplementedError


def remove_udev_rules():
    import pathlib
    rule_fname = 'rob-keyboard.rules'
    real_rules_dpath = pathlib.Path('/etc/udev/rules.d')
    real_rules_fpath = real_rules_dpath / rule_fname
    if real_rules_fpath.exists():
        ub.cmd('sudo rm {}'.format(real_rules_fpath), verbose=2, check=1, shell=True)
    ub.cmd('sudo udevadm control --reload-rules', verbose=2, check=1, shell=True)


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
        use_xkb_profile('auto')

    @cli_group.add_command
    @click.command('tek_cleave', context_settings=context_settings)
    def tek_cleave():
        use_xkb_profile('tek_cleave')

    @cli_group.add_command
    @click.command('default', context_settings=context_settings)
    def default():
        use_xkb_profile('default')

    @cli_group.add_command
    @click.command('install_udev_rules', context_settings=context_settings)
    def install_udev_rules2():
        install_udev_rules()

    @cli_group.add_command
    @click.command('remove_udev_rules', context_settings=context_settings)
    def remove_udev_rules2():
        remove_udev_rules()

    cli_group()


if __name__ == '__main__':
    """
    CommandLine:
        xkbcomp -w0 -I$HOME/.xkb $HOME/.xkb/keymap/default_kbd $DISPLAY

        python ~/local/tools/keyboard_mods.py tek_cleave
        python ~/local/tools/keyboard_mods.py default
        python ~/local/tools/keyboard_mods.py install_udev_rules
        python ~/local/tools/keyboard_mods.py remove_udev_rules
    """
    cli()
