from datetime import timedelta, datetime  # NOQA
try:
    import win32con
    import win32gui
    import internal.win_registry as registry
    import internal.new_win_reg as registry2
except Exception as ex:
    print('win32con is not fully functional')
import rob_helpers
import os

from regrep import grep_registry
# rob was nice
# hax has spice

commands_of_interest = '''
EnableWindow

EnumWindows(callback, extra) - Enumerates all top-level windows on the screen by passing the handle to each window, in turn, to an application-defined callback function. EnumWindows continues until the last top-level window is enumerated or the callback function returns FALSE


win32gui
HWND  = GetActiveWindow()
GetCursorPos
GetCursor
GetDesktopWindow

GetFocus
GetForegroundWindow
GetMenu

GetParent
GetScrollInfo

GetWindow
(left, top, right, bottom) = GetWindowRect(hwnd)
GetWindowDC
GetWindowExtEx
GetWindowLong
GetWindowRgn
GetWindowText
GetWindowTextLength

IsWindow
IsChild
IsWindowEnabled
IsWindowVisible

MoveWindow

SetActiveWindow

SetCaretPos
SetCuror

SetFocus
SetForgroundWindow

SetWindowPlacement
SetWindowPos
SetWindowRgn

int = ShowWindow(hwnd, int cmdShow)
UpdateWindow(hwnd)
'''


def GetForegroundWindow():
    hwnd = win32gui.GetForegroundWindow()
    return hwnd


def FindWindow():
    '''
    hwnd = FindWindow(className, WindowName )
    className : int/string
    WindowName : string
    '''
    hwnd = win32gui.FindWindow
    #hwnd = win32gui.FindWindowEx


def SystemParametersInfo():
    win32gui.SystemParametersInfo()


def close_window():
    win32gui.CloseWindow


def GetActiveWindowText():
    hwnd = win32gui.GetForegroundWindow()
    text = win32gui.GetWindowText(hwnd)
    return text


def GetWindowText(hwnd, optional=None):
    text = win32gui.GetWindowText(hwnd)
    print(text)
    return 1


def MinimizeWindow():
    win32gui.ShowWindow(firefox[0], win32con.SW_MINIMIZE)


def EnumWindowTest():
    toplist = []
    winlist = []
    def enum_callback(hwnd, results):
        winlist.append((hwnd, win32gui.GetWindowText(hwnd)))
    win32gui.EnumWindows(enum_callback, toplist)
    return winlist


def check_settings(r):
    print(repr(r.path_vars_list))
    #print('\n**'.join(map(repr,r.path_vars_list)))
    #print('\n++'.join(map(repr,r.env_vars_list)))
    print('Current Settings: ')
    windows_path2 = registry2.get_env('PATH')
    print(windows_path2)


def add_path_vars(pathvar_list):
    print('\nAdding path variables...')
    registry2.prepend_path(pathvar_list)
    registry2.refresh()


def add_env_vars(r, envvar_list):
    print('\nAdding environment variables...')
    for name, rob_val in envvar_list:
        print(' * ENVAR: '+name+' '+rob_val)
        win_val = registry2.get_user_env(name)
        if win_val is None:
            registry2.set_user_env(name, rob_val)
        else:
            print(' * COM: '+name+' '+rob_val+' '+win_val)
            #ans == 'y'
            if rob_val != win_val:
                ans = raw_input('Conflict continue? ')
                if ans == 'y':
                    registry2.set_root_env(name, rob_val)
    registry2.refresh()


def default_assisted(r):
    disable_windows_login_screen()


def default_registry(r):
    print('Defaulting registry')
    __disable_areo_shake()
    __cmd_fonts()
    __nav_pane()
    __hide_file_bit(False)
    __disable_winL_lock()
    __show_sidebar_computer()
    __remove_sidebar_network()
    __autohotkey_editor(r.f.gvim_exe)


def __show_sidebar_computer():
    registry.set_key_value('HKEY_CLASSES_ROOT\CLSID\{20D04FE0-3AEA-1069-A2D8-08002B30309D}\ShellFolder', 'Attributes', 'b094010c', 'DWORD')


def __remove_sidebar_network():
    registry.set_key_value('HKEY_CLASSES_ROOT\CLSID\{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}ShellFolder', 'Attributes', 'b0040064', 'DWORD')


def __disable_winL_lock():  # Dont lock screeon on WIN+L
    registry.set_key_value(regkey('SYSTEM_POL'),   'DisableLockWorkstation', 1,       'DWORD')


def __hide_file_bit(bit=0):  # Don't Hide File Extensions
    bit = bool(bit)
    registry.set_key_value(regkey('EXPLORER_ADV'), 'HideFileExt', 0,                  'DWORD')


def __autohotkey_editor(editor):  # Autohotkey will use the right editor
    registry.set_key_value(regkey('AHK_CMD'),      '(Default)', '"'+editor+'" "%1"', 'SZ')


def __disable_areo_shake(): # Disable Aero Shake
    registry.set_key_value(regkey('EXPLORER_POL'), 'NoWindowMinimizingShortcuts', 1,  'DWORD')


def __nav_pane(): # Setup windows explorer sidebar
    registry.set_key_value(regkey('NAVBAR_HG'),   'Attributes', 'b084010c', 'DWORD')
    registry.set_key_value(regkey('NAVBAR_LIB'),  'Attributes', 'b080010d', 'DWORD')
    registry.set_key_value(regkey('NAVBAR_COMP'), 'Attributes', 'b094010c', 'DWORD')
    registry.set_key_value(regkey('NAVBAR_NET'),  'Attributes', 'b0040064', 'DWORD')


def __cmd_fonts(): # Get opendyslexic working in cmd
    #registry.set_key_value(regkey('TRUE_FONT'), '0',      'Lucida Console', 'SZ')
    #registry.set_key_value(regkey('TRUE_FONT'), '00',     'White Rabbit',   'SZ')
    #registry.set_key_value(regkey('TRUE_FONT'), '000',    'Consolas',       'SZ')
    # TODO: Set/Add key value (set seems to not work. try adding instead)
    registry.set_key_value(regkey('TRUE_FONT'), '0000',   'Mono Dyslexic Regular', 'SZ')
    registry.set_key_value(regkey('TRUE_FONT'), '00000',  'Mono Dyslexic', 'SZ')
    registry.set_key_value(regkey('TRUE_FONT'), '000000', 'Mono_Dyslexic', 'SZ')


#-------
def get_env_var(var):
    try:
        return registry.get_key_value(regkey('LOCAL_ENVVAR'), var)
    except WindowsError as ex:
        print(repr(ex))
        raise

def set_env_var(var, val):
    try:
        registry.set_key_value(regkey('LOCAL_ENVVAR'), var, val, 'EXPAND_SZ')
    except WindowsError as ex:
        print(repr(ex))
        raise

def speak(r, text, rate):
    nircmd(r, 'speak text '+rob_helpers.ens(text,'"')+' '+str(rate))

def set_volume(r, percent):
    volume = str(float(percent)*65535/100)
    nircmd(r,'setvolume 0 '+ volume + ' ' + volume )

def monitor(r, monitor_state):
    nircmd(r, 'monitor '+monitor_state)

def nircmd(r, command ):
    #r.f.nircmd_exe + '
    rob_helpers.call('nircmd '+ command )


def disable_windows_login_screen():
    os.system('sudo "control userpasswords2"')
    print('Click your name. Uncheck Box. Type password.')

def refresh():
    'Tell windows that settings have been changed'
    win32gui.SendMessage(win32con.HWND_BROADCAST, win32con.WM_SETTINGCHANGE, 0, 'Environment')

def regkey(key): # List of registry keys for easy access
    HLM = r'HKEY_LOCAL_MACHINE'
    HCU = r'HKEY_CURRENT_USER'
    HCR = r'HKEY_CLASSES_ROOT'

    k = rob_helpers.DynStruct()
    k.LOCAL_ENVVAR = HLM + r'\SYSTEM\CurrentControlSet\Control\Session Manager\Environment'
    k.PATH         = HLM + r'\SYSTEM\CurrentControlSet\Control\Session Manager\Environment'

    k.EXPLORER_POL = HCU + r'\Software\Policies\Microsoft\Windows\Explorer'
    k.AHK_CMD      = HCR + r'\AutoHotkeyScript\Shell\Edit\Command'
    k.SYSTEM_POL   = HCU + r'\Software\Microsoft\Windows\CurrentVersion\Policies\System'
    k.EXPLORER_ADV = HCU + r'\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
    k.TRUE_FONT    = HLM + r'\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Console\TrueTypeFont'
    k.NAVBAR_HG    = HCR + r'\CLSID\{B4FB3F98-C1EA-428d-A78A-D1F5659CBA93}\ShellFolder'
    k.NAVBAR_LIB   = HCR + r'\CLSID\{031E4825-7B94-4dc3-B131-E946B44C8DD5}\ShellFolder'
    k.NAVBAR_COMP  = HCR + r'\CLSID\{20D04FE0-3AEA-1069-A2D8-08002B30309D}\ShellFolder'
    k.NAVBAR_NET   = HCR + r'\CLSID\{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}\ShellFolder'

    #Logitech USB Camera (HD Webcam C270)
    return k.__dict__[key]

def save_power_settings_pref(r):
    (out, err) = rob_helpers.call('POWERCFG -LIST')
    outlines = out.split('\n')
    for line in outlines:
        if '(Balanced)' in line:
            guid_begin_pos = 19
            guid_str = line[19:55]
    rob_helpers.dircheck(r.d.PORT_SETTINGS + '\WinPowerDir')
    rob_helpers.call(r'POWERCFG -EXPORT "%PORT_SETTINGS%\WinPowerDir"\ '+guid_str)


#def append_to_path(to_add):
    #PATH_SEP = os.path.pathsep
    #path_str = robos.get_env_var('PATH')
    #if to_add in path_str.split(PATH_SEP):
        #print('Path='+to_add+' is already in the system PATH')
        #return
    #newpath = to_add+PATH_SEP+path_str
    #robos.set_env_var('PATH',newpath)


def test_devmgr():
    print(grep_registry('Presonus'))
    # MANUALLY FOUND
    #HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run
    to_delete = r'''
        HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{554BB593-3543-4AEB-A192-2AC87EC3FF31}_is1
        HKEY_LOCAL_MACHINE\SOFTWARE\PreSonus\Devices\audioboxdevice
        HKEY_LOCAL_MACHINE\SOFTWARE\PreSonus
        HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\PreSonus\Devices\audioboxdevice
        HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\PreSonus
        '''

    legacy_item = r"HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Enum\Root"
    #devmgr_key = r"HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services"
    presonus = r'HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Control\Class\{40EA0DC9-6AAB-440D-ACE5-C079DF364E23}'
    presonus = r'HKEY_LOCAL_MACHINE\SYSTEM\ControlSet002\Control\Class'

    dm1 = r'HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Control\Class'
    dm2 = r'HKEY_LOCAL_MACHINE\SYSTEM\ControlSet002\Control\Class'
    dm1_subkeys = registry.get_subkeys(dm1)
    dm2_subkeys = registry.get_subkeys(dm2)
    dvmgr = {}
    for (dm, subkey_list) in [(dm1, dm1_subkeys), (dm2, dm2_subkeys)]:
        for skey in  subkey_list:
            key = dm + '\\' + skey
            key_subkeys = registry.get_subkeys(key)
            for _kskey in key_subkeys:
                key2 = key + '\\' + _kskey
                Defaults2 = registry.get_key_value(key2, '(Default)')
                DriverDesc = registry.get_key_value(key2, 'DriverDesc')
                provider_name = registry.get_key_value(key2, 'ProviderName')
                if Defaults2 is None and DriverDesc is None:
                    continue
                dvmgr[key2] = (DriverDesc, Defaults2, provider_name, class_desc)
            _class = registry.get_key_value(key, 'Class')
            class_desc = registry.get_key_value(key, 'ClassDesc')
            defaults = registry.get_key_value(key, '(Default)')
            dvmgr[key] = (_class, defaults, class_desc)

    def multifind(str, to_find):
        fmt_str = repr(str).lower()
        return [fmt_str.find(_) != -1 for _ in to_find]
    def multifind_joint(str, to_find):
        return [all(multifind(str, to_find)) for to_find in to_find_joint]

    to_find = [u'audiobox', u'presonus', 'unknown usb']
    to_find_joint=[(u'audio',u'box'), (u'pre',u'sonus'), (u'unknown','usb')]
    to_find = [_.lower() for _ in to_find]
    tkey = 'HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Control\Class\{40EA0DC9-6AAB-440D-ACE5-C079DF364E23}'
    for key, val in dvmgr.iteritems():
        in_find = multifind(val,to_find) + multifind(key,to_find)
        in_multifind = multifind_joint(val, to_find_joint) +  multifind_joint(key, to_find_joint)
        #print(val)
        if not (any(in_find) or any(in_multifind)): continue
        #print('%r, %r' % (in_find, in_multifind))
        print(key+' = '+repr(val))
        if tkey == key:
            print('^^^ PRESONUS HERE ^^^')


    #for key in devmgr_keys:
        #registry.print_key(key)

    #driver_key = r"'HKEY_LOCAL_MACHINE\Drivers'"
    #registry.print_key(legacy_item)
    os.environ['devmgr_show_nonpresent_devices'] = '1'
    #os.system('devmgmt.msc')
    #print(get_env_var('DEVMGR_SHOW_NONPRESENT_DEVICES'))
    #print(devmgr_key)


def get_clipboard():
    # Requires pywin32
    import win32clipboard
    win32clipboard.OpenClipboard()
    clipboard_data = win32clipboard.GetClipboardData()
    win32clipboard.CloseClipboard()
    return clipboard_data


if __name__ == "__main__":
    import sys
    print("Evaling " + sys.argv[1])
    exec(sys.argv[1])
