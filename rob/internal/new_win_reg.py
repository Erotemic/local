from __future__ import print_function
import os
import _winreg
import win32con
import win32gui
import datetime

 
def refresh():
    print('Broadcasting environment changed')
    win32gui.SendMessage(win32con.HWND_BROADCAST, win32con.WM_SETTINGCHANGE, 0, 'Environment')

def refresh_key(subkey):
    # broadcast change
    print('Broadcasting '+repr(subkey)+' changed')
    win32gui.SendMessage(win32con.HWND_BROADCAST, win32con.WM_SETTINGCHANGE, 0, subkey)

def get_env(name):
    return get_root_env(name)

def set_env(name, value):
    return set_root_env(name, value)

def set_root_env(name, value):
    (root, subkey) = __root_env_keys()
    key = _winreg.OpenKey(root, subkey, 0, _winreg.KEY_ALL_ACCESS)
    _winreg.SetValueEx(key, name, 0, _winreg.REG_EXPAND_SZ, value)
    _winreg.CloseKey(key)
    refresh_key(subkey)

def set_user_env(name, value):
    (root, subkey) = __user_env_keys()
    key = _winreg.OpenKey(root, subkey, 0, _winreg.KEY_ALL_ACCESS)
    _winreg.SetValueEx(key, name, 0, _winreg.REG_EXPAND_SZ, value)
    _winreg.CloseKey(key)
    refresh_key(subkey)

WIN_BIN_TYPES = {'BINARY':_winreg.REG_BINARY,\
             'DWORD':_winreg.REG_DWORD,\
             'DWORD_LITTLE_ENDIAN':_winreg.REG_DWORD_LITTLE_ENDIAN,\
             'DWORD_BIG_ENDIAN':_winreg.REG_DWORD_BIG_ENDIAN,\
             'EXPAND_SZ':_winreg.REG_EXPAND_SZ,\
             'LINK':_winreg.REG_LINK,\
             'MULTI_SZ':_winreg.REG_MULTI_SZ,\
             'NONE':_winreg.REG_NONE,\
             'RESOURCE_LIST':_winreg.REG_RESOURCE_LIST,\
             'FULL_RESOURCE_DESCRIPTOR':_winreg.REG_FULL_RESOURCE_DESCRIPTOR,\
             'RESOURCE_REQUIREMENTS_LIST':_winreg.REG_RESOURCE_REQUIREMENTS_LIST,\
             'SZ':_winreg.REG_SZ}

WIN_STR_TYPES = {}
for (key, val) in WIN_BIN_TYPES.iteritems():
    WIN_STR_TYPES[val] = key

# Window interface
def __user_env_keys():
    'Returns _winreg (root, subkey) corresponding to user environment variables'
    root = _winreg.HKEY_CURRENT_USER
    subkey = r'Environment'
    #subkey = r'Volatile Environment'
    return root, subkey

def __root_env_keys():
    'Returns _winreg (root, subkey) corresponding to system environment variables'
    root = _winreg.HKEY_LOCAL_MACHINE
    subkey = r'SYSTEM\CurrentControlSet\Control\Session Manager\Environment'
    return root, subkey

def __environ_key(user=False):
    'Key containing environment variables with all permissions'
    env_keys = __user_env_keys if user else __root_env_keys
    root, subkey = env_keys()
    key = _winreg.OpenKey(root, subkey, 0, _winreg.KEY_ALL_ACCESS)
    return key

def __get_environ(name, user=False):
    key = __environ_key(user)
    #print('USER = %r' % user)
    #__print_key(key)
    try:
        value, _ = _winreg.QueryValueEx(key, name)
    except WindowsError as ex:
        #print(repr(ex)+'\n> win_registry.get_environ(%r, %r)' % (name, user))
        return None
    return value

def get_user_env(name):
    return __get_environ(name, True)
def get_root_env(name):
    return __get_environ(name, False)

# end windows interface

def remove(list, item):
    while item in list:
        list.remove(item)
    return list

def unique(list):
    new_list = []
    seen = set([])
    for item in iter(list):
        if item not in seen:
            new_list.append(item)
            seen.add(item)
    return new_list

def prepend_path(values):
    current_path_str = get_root_env('Path')
    path_list = current_path_str.split(';')
    path_list = remove(path_list, '')
    for value in reversed(values):
        value = unicode(value)
        path_list.insert(0, value)
    path_list = unique(path_list)
    new_path_str = ';'.join(path_list)
    set_root_env('Path', new_path_str)

#values = ['C:\\Users\\joncrall\\Dropbox\\Scripts\\ahk_scripts', 'C:\\Users\\joncrall\\Dropbox\\Apps\\nircmd', 'C:\\Users\\joncrall\\Dropbox\\Scripts\\win_scripts', 'C:\\Python27', 'C:\\Python27\\Scripts', 'C:\\Program Files (x86)\\CMake 2.8\\bin', 'C:\\Program Files (x86)\\Vim\\vim74', 'C:\\Users\\joncrall\\Dropbox\\Apps\\git\\bin', 'C:\\MinGW\\msys\\1.0\\bin', 'C:\\MinGW\\msys\\1.0\\lib', 'C:\\MinGW\\bin' , 'C:\\MinGW\\lib']

#def prepend_env_pathext(values):
    #prepend_env('PathExt_User', values)
    #pathext = ';'.join([get_envar('PathExt_User'),
                        #get_envar('PathExt', user=False)])
    #set_env('PathExt', pathext)

TIMEZONE_DIFF = -18000000000 # for Eastern Standard Time
JAN_1_1601 = datetime.datetime(year=1600, month=1, day=1)
def timestamp_from_windows_time(windows_time):
    microseconds = (windows_time*0.1)+TIMEZONE_DIFF
    delta = datetime.timedelta(microseconds=microseconds)
    timestamp = JAN_1_1601 + delta
    return timestamp 

def __print_key(key):
    print('query info key')
    (num_subkeys, num_values, windows_time) = _winreg.QueryInfoKey(key)
    last_modified = timestamp_from_windows_time(windows_time)
    print(' *  num_subkeys: '+str(num_subkeys))
    print(' *  num_values: '+str(num_values))
    print(' *  last_modified: '+str(last_modified))

    print('Enumerating subkeys:')
    for subx in xrange(num_subkeys):
        try:
            enum_ret = _winreg.EnumKey(key, subx)
            print(' *  * '+repr(enum_ret))
            print('ENUM VALUE (TYPE; NAME) = VAL')
        except Exception as ex:
            print(' * * Cannot access subkey(%d/%d). Error: %r' % (subx+1, num_subkeys, ex))

    print('Enumerating values:')
    print(' * * _winreg.EnumValue(TYPE; NAME) = VAL')
    for valx in xrange(num_values):
        try:
            (val_name, val_data, val_type) = _winreg.EnumValue(key, valx)
            try: 
                val_type_str = WIN_STR_TYPES[val_type]
            except Exception: 
                val_type_str = type_val
            print(' * * name=%r, type=%r\n * * data=%r\n * ------' %\
                  (val_type_str, val_name, val_data))
        except Exception as ex:
            raise
            print(' * * Cannot access value(%d/%d). Error: %r' % (valx+1, num_values, ex))
    #_winreg.CloseKey(key)
    print('===================' )

if __name__ == '__main__':
    #name = 'Path'
    print('USER ENV VARS:')
    user_environ_key = __environ_key(True)
    __print_key(user_environ_key)
    print('ROOT ENV VARS:')
    root_environ_key = __environ_key(False)
    __print_key(root_environ_key)

    #print get_user_env('PathExt_USER')

