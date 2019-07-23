import ubelt as ub
from os.path import basename
from os.path import join
from os.path import splitext


def add_new_mimetype_association(ext, mime_name, exe_fpath=None, dry=True):
    """
    TODO: move to external manager and generalize

    Args:
        ext (str): extension to associate
        mime_name (str): the name of the mime_name to create (defaults to ext)
        exe_fpath (str): executable location if this is for one specific file

    References:
        https://wiki.archlinux.org/index.php/Default_applications#Custom_file_associations

    Args:
        ext (str): extension to associate
        exe_fpath (str): executable location
        mime_name (str): the name of the mime_name to create (defaults to ext)

    CommandLine:
        python -m ubuntu_tools --exec-add_new_mimetype_association
        # Add ability to open ipython notebooks via double click
        python -m ubuntu_tools --exec-add_new_mimetype_association --mime-name=ipynb+json --ext=.ipynb --exe-fpath=/usr/local/bin/ipynb

        xdoctest ~/local/init/ubuntu_tools.py add_new_mimetype_association --mime_name=ipynb+json --ext=.ipynb --exe_fpath=jupyter-notebook --force

        python -m ubuntu_tools --exec-add_new_mimetype_association --mime-name=sqlite --ext=.sqlite --exe-fpath=sqlitebrowser

    Example:
        >>> # SCRIPT
        >>> import ubelt as ub
        >>> ext = ub.argval('--ext', default=None)
        >>> mime_name = ub.argval('--mime_name', default=None)
        >>> exe_fpath = ub.argval('--exe_fpath', default=None)
        >>> dry = not ub.argflag('--force')
        >>> result = add_new_mimetype_association(ext, mime_name, exe_fpath, dry)
        >>> print(result)
    """
    import ubelt as ub
    terminal = True

    mime_codeblock = ub.codeblock(
        '''
        <?xml version="1.0" encoding="UTF-8"?>
        <mime-info xmlns="http://www.freedesktop.org/standards/shared-mime-info">
            <mime-type type="application/x-{mime_name}">
                <glob-deleteall/>
                <glob pattern="*{ext}"/>
            </mime-type>
        </mime-info>
        '''
    ).format(**locals())

    prefix = ub.expandpath('~/.local/share')
    mime_dpath = join(prefix, 'mime/packages')
    mime_fpath = join(mime_dpath, 'application-x-{mime_name}.xml'.format(**locals()))

    print(mime_codeblock)
    print('---')
    print(mime_fpath)
    print('L___')

    if exe_fpath is not None:
        exe_fname_noext = splitext(basename(exe_fpath))[0]
        app_name = exe_fname_noext.replace('_', '-')
        nice_name = ' '.join(
            [word[0].upper() + word[1:].lower()
             for word in app_name.replace('-', ' ').split(' ')]
        )
        app_codeblock = ub.codeblock(
            '''
            [Desktop Entry]
            Name={nice_name}
            Exec={exe_fpath}
            MimeType=application/x-{mime_name}
            Terminal={terminal}
            Type=Application
            Categories=Utility;Application;
            Comment=Custom App
            '''
        ).format(**locals())
        app_dpath = join(prefix, 'applications')
        app_fpath = join(app_dpath, '{app_name}.desktop'.format(**locals()))

        print(app_codeblock)
        print('---')
        print(app_fpath)
        print('L___')

    # WRITE FILES
    if not dry:
        ub.ensuredir(mime_dpath)
        ub.ensuredir(app_dpath)

        ub.writeto(mime_fpath, mime_codeblock)
        if exe_fpath is not None:
            ub.writeto(app_fpath, app_codeblock)

        # UPDATE BACKENDS

        #ub.cmd('update-mime-database /usr/share/mime')
        #~/.local/share/applications/mimeapps.list
        print(ub.codeblock(
            '''
            Run these commands:
            update-desktop-database ~/.local/share/applications
            update-mime-database ~/.local/share/mime
            '''
        ))
        if exe_fpath is not None:
            ub.cmd('update-desktop-database ~/.local/share/applications')
        ub.cmd('update-mime-database ~/.local/share/mime')
    else:
        print('dry_run')


def make_application_icon(exe_fpath, dry=True, props={}):
    r"""
    CommandLine:
        python -m ubuntu_tools --exec-make_application_icon --exe=cockatrice --icon=/home/joncrall/code/Cockatrice/cockatrice/resources/cockatrice.png
        python -m ubuntu_toolsil_ubuntu --exec-make_application_icon --exe=cockatrice --icon=/home/joncrall/code/Cockatrice/cockatrice/resources/cockatrice.png
        python -m ubuntu_tools --exec-make_application_icon --exe=/opt/zotero/zotero --icon=/opt/zotero/chrome/icons/default/main-window.ico

        python -m ubuntu_tools --exec-make_application_icon --exe "env WINEPREFIX="/home/joncrall/.wine" wine C:\\\\windows\\\\command\\\\start.exe /Unix /home/joncrall/.wine32-dotnet45/dosdevices/c:/users/Public/Desktop/Hearthstone.lnk" --path "/home/joncrall/.wine/dosdevices/c:/Program Files (x86)/Hearthstone"
        # Exec=env WINEPREFIX="/home/joncrall/.wine" wine /home/joncrall/.wine/drive_c/Program\ Files\ \(x86\)/Battle.net/Battle.net.exe

        --icon=/opt/zotero/chrome/icons/default/main-window.ico

        python -m ubuntu_tools --exec-make_application_icon --exe=/home/joncrall/code/build-ArenaTracker-Desktop_Qt_5_6_1_GCC_64bit-Debug

        update-desktop-database ~/.local/share/applications


    Example:
        >>> # DISABLE_DOCTEST
        >>> exe_fpath = ub.argval('--exe', default='cockatrice')
        >>> icon = ub.argval('--icon', default=None)
        >>> dry = not ub.argflag(('--write', '-w'))
        >>> props = {'terminal': False, 'icon': icon}
        >>> result = make_application_icon(exe_fpath, dry, props)
        >>> print(result)
    """
    exe_fname_noext = splitext(basename(exe_fpath))[0]
    app_name = exe_fname_noext.replace('_', '-')
    nice_name = ' '.join(
        [word[0].upper() + word[1:].lower()
         for word in app_name.replace('-', ' ').split(' ')]
    )
    lines = [
        '[Desktop Entry]',
        'Name={nice_name}',
        'Exec={exe_fpath}',
    ]

    if 'mime_name' in props:
        lines += ['MimeType=application/x-{mime_name}']

    if 'icon' in props:
        lines += ['Icon={icon}']

    if props.get('path'):
        lines += ['Path={path}']

    # if props.get('comment'):
    #     lines += ['Path={comment}']

    lines += [
        'Terminal={terminal}',
        'Type=Application',
        'Categories=Utility;Application;',
        'Comment=Custom App',
    ]
    fmtdict = locals()
    fmtdict.update(props)

    prefix = ub.expandpath('~/.local/share')
    app_codeblock = '\n'.join(lines).format(**fmtdict)
    app_dpath = join(prefix, 'applications')
    app_fpath = join(app_dpath, '{app_name}.desktop'.format(**locals()))

    print(app_codeblock)
    print('---')
    print(app_fpath)
    print('L___')

    if not dry:
        ub.writeto(app_fpath, app_codeblock)
        ub.cmd('update-desktop-database ~/.local/share/applications')


if __name__ == '__main__':
    """
    CommandLine:
        python ~/local/init/ubuntu_tools.py
    """
    import xdoctest
    xdoctest.doctest_module(__file__)
