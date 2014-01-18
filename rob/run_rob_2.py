#!/bin/bash/python
import sys
import os
import sys
import platform

from helpers   import *
from sager     import *
from interface import *

# He's my robot friend

class ROB_Directories:
    def __init__(d):
        d.build_paths();

    def build_paths(d):
        comp_name = platform.node()
        os_type = os_type()

        user_map  = { 'win32':'jon.crall', 'linux':'joncrall'}
        root_map  = { 'win32':'C:',        'linux':''} #/'s are never last
        store_map = { 'win32':'D:',        'linux':'/media/Store' }
        media_map = { 'win32':'E:',        'linux':'/media/Media' } 
        home_map  = { 'win32':'/Users',    'linux':'/home'  }

        d.USERNAME       = slash_fix(  user_map[ os_type ] )
        d.ROOT           = slash_fix(  root_map[ os_type ] )
        d.STORE          = slash_fix( store_map[ os_type ] )

        d.INSTALLERS     = d.STORE + slash_fix('/Installers');
        d.DATA           = d.STORE + slash_fix('/data');
        d.BUILD          = d.STORE + slash_fix('/build');
        d.CODE           = d.STORE + slash_fix('/code');

        d.USERPROFILE   = d.ROOT + home_map[ os_type ] + slash_fix('/'+d.USERNAME) 
        d.CLOUD         = d.USERPROFILE + slash_fix('/Dropbox')

        d.CYGWIN        = d.ROOT + slash_fix('/Cygwin/bin')
        d.INSTALL32    = d.ROOT + slash_fix('/Program Files (x86)')
        d.INSTALL64    = d.ROOT + slash_fix('/Program Files')


        d.VIM_BIN       = d.INSTALL32  + slash_fix('/Vim/vim73')
        d.GIT_BIN       = d.INSTALL32  + slash_fix('/Git/bin')
        d.VLC_BIN       = d.INSTALL32  + slash_fix('/VideoLAN/VLC')

        d.STARTUP       = d.USERPROFILE + slash_fix('/AppData/Roaming/Microsoft/Windows/Start Menu/Programs/Startup')

        if comp_name == 'BakerStreet':
            d.DESKTOP = 'C:/Users/jon.crall/Favorites/Desktop'

        d.DESKTOP   = d.USERPROFILE + slash_fix('/Desktop')
        
        d.PORT_CODE     = d.CLOUD  + slash_fix('/Code')
        d.PORT_APPS     = d.CLOUD  + slash_fix('/Apps')
        d.PORT_SCRIPTS  = d.CLOUD  + slash_fix('/Scripts')
        d.PORT_INSTALL  = d.CLOUD  + slash_fix('/Installers')
        d.PORT_SETTINGS = d.CLOUD  + slash_fix('/Settings')

        d.AHK_SCRIPTS  = d.PORT_SCRIPTS + slash_fix('/ahk_scripts')
        d.ROB          = d.PORT_CODE + slash_fix('/ROB')
        d.HOTSPOTTER   = d.PORT_CODE + slash_fix('/HotSpotterPython')

        #WINDOWS
        d.TOOLBAR      = d.USERPROFILE + slash_fix('/toolbar');
        d.NIRCMD       = d.PORT_APPS    + slash_fix('/nircmd')
        d.PUTTY        = d.PORT_APPS    + slash_fix('/putty')
        d.CONSOLE2_BIN = d.PORT_APPS    + slash_fix('/Console2')
        d.WIN_SCRIPTS  = d.PORT_SCRIPTS + slash_fix('/win_scripts')

        d.BILLNYE   = d.STORE + slash_fix('/Videos/Bill Nye The Science Guy')
        d.BOBROSS   = d.STORE + slash_fix('/Videos/Bob Ross')


class ROB_Files:
    def __init__(f, d):
        calc_map      = {'Windows':slash_fix('C:/Windows/system32/calc.exe'),\
                         'Linux':'calc'}

        comp_name = platform.node()
        f.calc_exe    = slash_fix('C:/Windows/system32/calc.exe')
        f.nircmd_exe  = d.NIRCMD     + slash_fix('/nircmd.exe')
        print f.nircmd_exe

        f.console_exe = d.PORT_APPS  + slash_fix('/Console2/Console.exe')
        f.vlc_exe     = d.VLC_BIN    + slash_fix('/vlc.exe')


        f.winedt_exe  = d.INSTALL32 + slash_fix('/WinEdt Team/WinEdt 7/WinEdt.exe')
        f.rap_ee_exe  = d.PORT_APPS  + slash_fix('/RapidEnvirornmentEditor/RapidEE.exe')
        f.qiqqa_exe   = d.INSTALL32 + slash_fix('/Qiqqa/Qiqqa.exe')


        f.spotify_exe =  d.INSTALL32 + slash_fix('/spotify.exe')
        if comp_name == "Termina":
            f.spotify_exe = 'C:\Users\jon.crall\AppData\Roaming\Spotify\spotify.exe'
        if comp_name == "Ooo":
            f.spotify_exe = 'C:\Program Files (x86)\Spotify\spotify.exe'

        f.vim_exe     =  d.VIM_BIN    + slash_fix('/gvim.exe')
        chrome_root = d.INSTALL32
        if comp_name == 'Ooo':
            chrome_root = d.USERPROFILE + '/AppData/Local'
        f.chrome_exe  =  chrome_root + slash_fix('/Google/Chrome/Application/chrome.exe')
        f.matlab_exe  =  d.ROOT      + slash_fix('/MATLAB/R2012a/bin/matlab.exe')

        f.crallj_ahk  =  d.AHK_SCRIPTS  + slash_fix('/crallj.ahk')
        f.create_shortcut_vbs = d.WIN_SCRIPTS+slash_fix('/Helpers/CreateShortcutHelper.vbs')





class ROB:
    def __init__(r):
        r.comp_name = platform.node()
        r.d = ROB_Directories();
        r.f = ROB_Files(r.d);

        path_list = [
            'PUTTY',\
            'INSTALLERS',\
            'VIM_BIN',\
            'PORT_APPS',\
            'PORT_INSTALL',\
            'PORT_SCRIPTS',\
            'PORT_SETTINGS',\
            'WIN_SCRIPTS',\
            'ROB',\
            'HOTSPOTTER',\
            'DATA',\
            'CODE',\
            'STARTUP'
        ]

        r.path_vars = []
        for var in path_list:
            tuple_string = '(\''+var+'\', r.d.'+var+')'
            eval('r.path_vars.append( '+tuple_string+')')

        r.path_vars = [\
            ('PUTTY', 
            ('INSTALLERS',    r.d.INSTALLERS ),\
            ('VIM_BIN',       r.d.VIM_BIN     ),\

            ('AHK_SCRIPTS',   r.d.AHK_SCRIPTS ),\

            ('PORT_APPS',     r.d.PORT_APPS ),\
            ('PORT_INSTALL',  r.d.PORT_INSTALL ),\
            ('PORT_SCRIPTS',  r.d.PORT_SCRIPTS ),\
            ('PORT_SETTINGS', r.d.PORT_SETTINGS ),\

            ('WIN_SCRIPTS',   r.d.WIN_SCRIPTS ),\

            ('ROB',           r.d.ROB        ),\
            ('HOTSPOTTER',    r.d.HOTSPOTTER ),\
            ('DATA',          r.d.DATA ),\
            ('CODE',          r.d.CODE ),\
            ('STARTUP',       r.d.STARTUP ),\
            ]


        CONSOLE_LOCAL = r.d.USERPROFILE   + slash_fix('/AppData/Roaming/Console')
        CONSOLE_CLOUD = r.d.PORT_SETTINGS + slash_fix('/Console')

        SPYDER_LOCAL = r.d.USERPROFILE   + slash_fix('/.spyder2')
        SPYDER_CLOUD = r.d.PORT_SETTINGS + slash_fix('/spyder2')

        VIM_LOCAL = r.d.INSTALL32  + slash_fix('/Vim')
        VIM_CLOUD = r.d.PORT_SETTINGS + slash_fix('/vim/CopyToProgramFilesVim')


        r.symlink_local_cloud = [\
          ( CONSOLE_LOCAL, CONSOLE_CLOUD ),\
          (  SPYDER_LOCAL,  SPYDER_CLOUD )
                                 ]

        r.directcopy_local_cloud = [\
          ( VIM_LOCAL, VIM_CLOUD ),\
                                 ]

r = None

def process_args(r, argv):
    if len(argv) > 0:
        cmd_name = argv[0]
        if len(argv) == 1:
            if cmd_name == 'help':
                cmd_name = 'info'
            cmd = cmd_name+'(r)'
        else:
            args = argv[1:]
            if cmd_name == 'speak':
                arg_str = ","+ens(' '.join(args),'"')
                #arg_str = arg_str + ', -5'
            else:
                arg_str = ''
                for a in args:
                    arg_str = arg_str + ', \''+a+'\''
                #arg_str = ','.join(args)
            cmd = cmd_name+'(r'+arg_str+' )'
        print 'R.O.B. is evaluating: '+cmd
        print "\n\n"
        print "-----"
        eval(cmd)

def main():
    r = ROB()

    if len(sys.argv) > 1:
        ARG_SEP = ';'

        #Arguemnts are broken up with semicolons
        semi_pos = [i for i,a in enumerate(sys.argv) if a==ARG_SEP]+[-1]
        pre = 1
        for post in semi_pos:
            if post == -1:
                process_args(r, sys.argv[pre:])
            else:
                process_args(r, sys.argv[pre:post])


if __name__ == '__main__':
    print "\n\n\n\n================"

    ascii_rob_small = """
                                   __________
                                 |== ======|+
                                 ||  ;|  ;||/
                                  =========/
                                      ||$
                                    Z<$$$$$,
                                 MMMMMMMNMO~R
                              MMM  MMMMMMMMM~R
                            MMM         |:| MM
                          MMMMF     /MMMMMMMM9
                          NMM   /MMMMMR |:|  8
                                MMMMM   |:|  9
                                        |:| 6
                                    /MMMMMMMM
                                MMMMMMMMMMMMMMM
                               MMMM.MMM. .M.MMMM
                              MMMMMMM.M..MMMMMMM
                                  MMMMMMMMMMMM

____  ____  ___      _ ____    ____ _  _ _    _ _  _ ____
|__/  |  |  |__]     | [__     |  | |\ | |    | |\ | |___
|  \. |__| .|__] .   | ___]    |__| | \| |___ | | \| |___
"""

    print ascii_rob_small
    main()
    print '\n\nR.O.B. signing off'
    print "================"


