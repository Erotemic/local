from os.path import dirname
from sys import platform as os_type
import sys
import os
from platform import node as comp_name
from os.path import exists
from rob import rob_helpers as robh

# Add shortcuts for Prog Files 64 <-> 32
# Change Icons?
# Favorite Folders?
# C/D/E Drives?


def get_PATH(r):
    if sys.platform == 'win32':
        path_str = """
        AHK_SCRIPTS
        PORT_APPS
        WIN_SCRIPTS
        LOCAL + '/windows/auto_scripts'
        LOCAL + '/windows/scripts'
        LOCAL + '/scripts/windows'
        PYTHON
        PYTHON + '/Scripts'
        MSYS
        MSYS  + '/bin'
        MSYS  + '/lib'
        MINGW + '/bin'
        MINGW + '/lib'
        INSTALL64 + 'SlikSvn/bin'
        INSTALL32 + '/CMake 2.8/bin'
        INSTALL32 + '/MiKTeX 2.9/miktex/bin'
        INSTALL32 + '/OpenCV/bin'
        INSTALL32 + '/OpenCV/x86/mingw/bin/'
        INSTALL32 + '/OpenCV/x86/mingw/lib/'
        INSTALL32 + '/OpenCV/include'
        INSTALL32 + '/gs/gs9.07/bin'
        INSTALL64 + '/7-Zip'
        INSTALL32 + '/7-Zip'
        INSTALL32 + '/Graphviz2.36/bin'
        VIM_BIN
        GIT_BIN_
        GIT_CMD
        LOCALPATH
        """
    else:
        path_str = """
        """
    path_vars_list = []
    for pstr2 in path_str.split('\n'):
        path = pstr2.strip()
        if len(path) > 0:
            #path_vars_list.append(r.d.__dict__[path])
            dpath = eval('os.path.normpath(r.d.%s)' % path)
            if exists(dpath):
                path_vars_list.append(dpath)
            else:
                print('[rob] does not exist: %r' % dpath)
    return path_vars_list


def get_ENVVARS(r):
    ''' any variable in ROB_DIRECTORY becomes an envvar '''
    r.env_vars_list = []
    for var in r.d.__dict__.keys():
        _tupstr = "('%s', r.d.%s)" % (var, var)
        #exec 'r.env_vars_list.append(%s)' % _tupstr
        exec('r.env_vars_list.append(%s)' % _tupstr)
    return r.env_vars_list


def get_pip_packages():
    if sys.platform == 'win32':
        'WinSys-3.x'


class ROB_Files:
    def __init__(f, d):
        #if sys.platform == 'win32':
        #    f.calc_exe    = d.SYSTEM32    + '/calc.exe'

        #f.console_exe = d.PORT_APPS   + '/Console2/Console.exe'
        #f.rap_ee_exe  = d.PORT_APPS   + '/RapidEnvirornmentEditor/RapidEE.exe'
        if sys.platform == 'win32':
            f.nircmd_exe  = d.PORT_APPS + '/nircmd.exe'

        #f.winedt_exe  = d.INSTALL32 + '/WinEdt Team/WinEdt 7/WinEdt.exe'
        #f.qiqqa_exe   = d.INSTALL32 + '/Qiqqa/Qiqqa.exe'
        #f.spotify_exe = d.INSTALL32 + '/spotify.exe'
        #f.rpi_vpn_exe = d.INSTALL32 + '/Cisco/Cisco AnyConnect Secure Mobility Client/vpnui.exe'

        if sys.platform == 'win32':
            pass
            f.gvim_exe = d.VIM_BIN    + '/gvim.exe'
            f.vlc_exe  = d.INSTALL32 + '/VideoLAN/VLC/vlc.exe'
        else:
            f.gvim_exe = 'gvim'
        f.matlab_exe        = d.ROOT        + '/MATLAB/R2012a/bin/matlab.exe'
        f.crallj_ahk        = d.AHK_SCRIPTS + '/crallj.ahk'
        if sys.platform == 'win32':
            f.mk_shortcut_vbs   = d.WIN_SCRIPTS + '/Helpers/CreateShortcutHelper.vbs'

        f.alarm_videos = {
        }

        # Fix Slashes
        members = f.__dict__.keys()
        for mem in members:
            if isinstance(f.__dict__[mem], dict):
                for dkey in f.__dict__[mem].keys():
                    f.__dict__[mem][dkey] == robh.slash_fix(f.__dict__[mem][dkey])
            else:
                f.__dict__[mem] = robh.slash_fix(f.__dict__[mem])


# Change this to Environment Variables
class ROB_Directories:
    def __init__(d):
        import ubelt as ub
        # Cross platform names
        root_map  = {'win32': 'C:',     'linux2': '', 'linux': ''}  # /'s are never last
        store_map = {'win32': 'D:',     'linux2': '/media/Store', 'linux': '/media/Store'}
        media_map = {'win32': 'E:',     'linux2': '/media/Media', 'linux': '/media/Store'}
        home_map  = {'win32': '/Users', 'linux2': '/home', 'linux': '/home'}

        d.COMPUTER_NAME  = comp_name()
        d.HOME       = ub.userhome()

        d.USERNAME    =   os.environ.get('USER', dirname(d.HOME))
        d.ROOT        =   root_map[os_type]
        d.STORE       =  store_map[os_type]

        d.MEDIA       =  os.environ.get('ROB_MEDIA_DIR', media_map[os_type])

        d.INSTALLERS  = d.STORE + '/Installers'
        d.DATADIR     = d.STORE + '/data'
        d.WORK        = d.STORE + '/data/work'

        d.LOCAL      = d.HOME + '/local'
        d.LOCAL_DIR  = d.HOME + '/local'
        d.CODE       = d.HOME + '/code'
        d.CODE_DIR   = d.HOME + '/code'
        d.LATEX      = d.HOME + '/latex'
        d.CLOUD      = d.HOME + '/Dropbox'

        d.DESKTOP   = d.HOME + '/Desktop'

        d.PORT_CODE     = d.LOCAL + '/code'
        d.PORT_APPS     = d.CLOUD + '/Apps'
        #d.PORT_SCRIPTS  = d.CLOUD + '/Scripts'
        d.PORT_INSTALL  = d.CLOUD + '/Installers'
        d.PORT_SETTINGS = d.CLOUD + '/Settings'
        d.PORT_NOTES    = d.CLOUD + '/Notes'
        d.PORT_LATEX    = d.CLOUD + '/Latex'
        d.pvimrc        = d.LOCAL + '/vim/portable_vimrc'
        d.AHK_SCRIPTS   = d.LOCAL + '/ahk_scripts'

        d.ROB          = d.LOCAL + '/rob/rob'

        #WINDOWS
        d.TV            = os.environ.get('ROB_TV_DIR', d.MEDIA + '/TV')
        d.DOCUMENTARIES = os.environ.get('ROB_DOCUMENTARY_DIR', d.MEDIA + '/Documentaries')

        # Operating System Specific
        if sys.platform == 'win32':
            d.INSTALL32 = d.ROOT + '/Program Files (x86)'
            d.INSTALL64 = d.ROOT + '/Program Files'

            # WHY DID I EVER SET THESE?!
            #d.WINDOWS   = d.ROOT + '/Windows'
            #d.SYSTEM32   = d.WINDOWS + '/system32'

            d.VIM_BIN    = d.INSTALL32  + '/Vim/vim74'

            d.IPYTHONDIR = d.HOME + '/.ipython'

            d.STARTUP    = d.HOME + '/AppData/Roaming/Microsoft/Windows/Start Menu/Programs/Startup'
            d.TOOLBAR      = d.HOME + '/toolbar'
            d.WIN_SCRIPTS  = d.LOCAL + '/windows/scripts'

            d.GIT_BIN_     = d.LOCAL + '/git/bin'
            d.GIT_CMD      = d.LOCAL + '/git/cmd'
            d.LOCALPATH    = d.LOCAL + '/PATH'

            d.PYTHON       = d.ROOT + '/Python27'
            d.PYTHON_SCRIPTS  = d.PYTHON + '/Scripts'
            d.PYTHON_SITE_PACKAGES = d.PYTHON + '/Lib/site-packages'

            d.PYTHONPATH = os.pathsep.join([
                d.PYTHON,
                d.PYTHON_SITE_PACKAGES,
                d.CODE,
                d.PORT_CODE,
                d.HOTSPOTTER])

        # Fix Slashes
        members = d.__dict__.keys()
        for mem in members:
            d.__dict__[mem] = robh.slash_fix(d.__dict__[mem])

    def print_members(d):
        for mem in d.__dict__.keys():
            print(mem + ' = ' + d.__dict__[mem])


if __name__ == "__main__":
    d = ROB_Directories()
    f = ROB_Files(d)
    d.print_members()
