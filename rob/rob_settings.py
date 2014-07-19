from sys         import platform as os_type
from platform    import node     as comp_name
from rob_helpers import *  # NOQA
from os.path import exists
import rob_helpers as robh

# Add shortcuts for Prog Files 64 <-> 32
# Change Icons?
# Favorite Folders?
# C/D/E Drives?


def get_PATH(r):
    #ROOT  + '/gnuwin32/bin'
    #ROOT  + '/gnuwin32/lib'
    #ROOT  + '/gnuwin32/include'
    #INSTALL64 + '/SlikSvn/bin'
    if sys.platform == 'win32':
        path_str = """
        AHK_SCRIPTS
        PORT_APPS
        WIN_SCRIPTS
        HOME  + '/code/utool/util_scripts'
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
        exec 'r.env_vars_list.append(%s)' % _tupstr
    return r.env_vars_list


def get_pip_packages():
    if sys.platform == 'win32':
        'WinSys-3.x'


class ROB_Files:
    def __init__(f, d):
        #if sys.platform == 'win32':
            #f.calc_exe    = d.SYSTEM32    + '/calc.exe'

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
            'BBC Life':              d.DOCUMENTARIES + '/BBC Life',
            'Bill Nye':              d.TV + '/Bill Nye the Science Guy',
            'Bob Ross':              d.TV + '/Bob Ross',
            'Freakazoid':            d.TV + '/Freakazoid',
            'Sheep in the Big City': d.TV + '/Sheep in the Big City',
        }

        # Weird Variables go Here
        #chrome_root  = d.HOME + '/AppData/Local' if comp_name() in ['Ooo']  else d.INSTALL32
        #f.chrome_exe =  chrome_root + '/Google/Chrome/Application/chrome.exe'
        if comp_name() == "Termina":
            f.spotify_exe = 'C:/Users/jon.crall/AppData/Roaming/Spotify/spotify.exe'
        if comp_name() == "Ooo":
            f.spotify_exe = 'C:/Program Files (x86)/Spotify/spotify.exe'
        # Shortcut Tuples
        f.git_bash_sc = d.MSYS + '/../Git Bash'
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
        # Cross platform names
        root_map  = {'win32': 'C:',     'linux2': ''}  # /'s are never last
        store_map = {'win32': 'D:',     'linux2': '/media/Store'}
        media_map = {'win32': 'E:',     'linux2': '/media/Media'}
        home_map  = {'win32': '/Users', 'linux2': '/home'}

        #d.CC='gcc'
        #d.CFLAGS = 'O2'
        #d.CFLAGS='-O2'
        #d.CXX='g++'
        #d CXXFLAGS='-O3'
        #export LDFLAGS=''
        #export CXXPP

        d.COMPUTER_NAME  = comp_name()

        d.USERNAME    =   'joncrall'
        d.ROOT        =   root_map[os_type]
        d.STORE       =  store_map[os_type]
        d.MEDIA       =  media_map[os_type]
        if comp_name() == 'BakerStreet':  # uses this now
            d.USERNAME = 'jon.crall'
            d.MEDIA   =  'D:\sys\e'

        d.INSTALLERS  = d.STORE + '/Installers'
        d.DATADIR     = d.STORE + '/data'
        d.WORK        = d.STORE + '/data/work'

        d.HOME       = d.ROOT + home_map[os_type] + '/' + d.USERNAME
        d.LOCAL      = d.HOME + '/local'
        d.CODE       = d.HOME + '/code'
        d.LATEX      = d.HOME + '/latex'
        d.CLOUD      = d.HOME + '/Dropbox'

        d.MINGW = d.ROOT + '/MinGW'
        d.MSYS  = d.MINGW + '/msys/1.0'

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

        d.ROB          = d.LOCAL + '/rob'
        d.HOTSPOTTER   = d.CODE + '/hotspotter'
        d.HS           = d.HOTSPOTTER
        #d.CRALL_QUALS  = d.LATEX + 'crall-quals-2013'

        #WINDOWS
        d.TV            = d.MEDIA + '/TV'
        d.DOCUMENTARIES = d.MEDIA + '/Documentaries'

        # Operating System Specific
        if sys.platform == 'win32':
            d.INSTALL32 = d.ROOT + '/Program Files (x86)'
            d.INSTALL64 = d.ROOT + '/Program Files'

            # WHY DID I EVER SET THESE?!
            #d.WINDOWS   = d.ROOT + '/Windows'
            #d.SYSTEM32   = d.WINDOWS + '/system32'

            d.VIM_BIN    = d.INSTALL32  + '/Vim/vim74'
            #d.VIM        = d.INSTALL32  + '/Vim'
            #d.VIMFILES   = d.INSTALL32  + '/Vim/vimfiles'
            #d.VIMRUNTIME = d.INSTALL32  + '/Vim/vim74'

            #if comp_name() == 'BakerStreet':
                #d.VS2010_VC        = d.INSTALL32  + '/Microsoft Visual Studio 10.0/VC'
                #d.VS90COMMONTOOLS  = d.INSTALL32  + '/Microsoft Visual Studio 10.0/VC'
            #VS110COMNTOOLS
            #VS100COMNTOOLS
            # Need to run this command so python can find things SET VS90COMNTOOLS=%VS100COMNTOOLS% for vs2010

            d.IPYTHONDIR = d.HOME + '/.ipython'

            d.STARTUP    = d.HOME + '/AppData/Roaming/Microsoft/Windows/Start Menu/Programs/Startup'
            d.TOOLBAR      = d.HOME + '/toolbar'
            d.WIN_SCRIPTS  = d.LOCAL + '/windows/scripts'

            d.GIT_BIN_     = d.LOCAL + '/git/bin'
            d.GIT_CMD      = d.LOCAL + '/git/cmd'
            d.LOCALPATH    = d.LOCAL + '/PATH'

            #d.GIT_SSH      = d.PUTTY + '/plink.exe'
            #d.PUTTY        = d.PORT_APPS    + '/putty'
            #d.BOOST        = d.ROOT + '/boost_1_53_0'

            d.PYTHON       = d.ROOT + '/Python27'
            d.PYTHON_SCRIPTS  = d.PYTHON + '/Scripts'
            d.PYTHON_SITE_PACKAGES = d.PYTHON + '/Lib/site-packages'

            d.PYTHONPATH = os.pathsep.join([
                d.PYTHON,
                d.PYTHON_SITE_PACKAGES,
                d.CODE,
                d.PORT_CODE,
                d.HOTSPOTTER])
                             #,
                             #d.PORT_CODE]

        #elif os_type == 'linux2':
            #d.GUI_CMD = 'gnome-terminal'
            #d.VIMFILES   = d.HOME + '/.vim'
            #d.INSTALL32 = d.HOME + '/.wine/drive_c/Program Files'
            #d.INSTALL64 = d.HOME + '/.wine/drive_c/Program Files'
            #pass

        # Fix Slashes
        members = d.__dict__.keys()
        for mem in members:
            d.__dict__[mem] = robh.slash_fix(d.__dict__[mem])

    def print_members(d):
        for mem in d.__dict__.keys():
            print mem + ' = ' + d.__dict__[mem]


def WINDOWS_DEFAULT_VAR_DICT(d):
    w = robh.DynStruct()
    # Envvars that come with windows, so keep it happy
    w.SystemDrive       =  d.ROOT
    w.SystemRoot        =  d.WINDOWS
    w.WinDir            =  d.WINDOWS
    w.SystemDirectory   =  d.SYSTEM32
    w.ComSpec           =  d.SYSTEM32 + '/cmd.exe'
    w.ProgramFiles      =  d.INSTALL32
    w.ProgramFiles      =  d.INSTALL32
    w.ProgramFilesW6432 =  d.INSTALL64
    w.TEMP              =  d.WINDOWS + '/TEMP'
    w.TMP               =  d.WINDOWS + '/TEMP'
    w.HOMEDRIVE         =  d.ROOT
    w.HOMEDRIVE         =  '/Users/' + d.USERNAME
    w.OS                =  'Windows_NT'
    w.USERDOMAIN        =  d.COMPUTER_NAME
    w.USERNAME          =  d.USERNAME
    w.USERPROFILE       =  d.HOME


if __name__ == "__main__":
    d = ROB_Directories()
    f = ROB_Files(d)
    d.print_members()
