from __future__ import print_function
"""
"""
import os  # NOQA
import six
import win32con
import win32gui
import datetime
if six.PY2:
    import _winreg as winreg
else:
    import winreg
#import new_win_reg  # NOQA


class RegistryLogger(object):
    def __init__(self):
        self.messages = []
    def print(self, msg):
        msg = 'registry_log: ' + msg
        print(msg)
        self.messages.append(msg)
    def dump(self):
        print('\n'.append(map(repr, self.messages)))


log = RegistryLogger()


def printDBG(msg):
    print(msg)
    pass


def printEXCEPT(ex, func_name):
    print('\n\n<!!!!!!!!!!!!!!!!!!!!!')
    print('!!! Error in :' + func_name)
    print(repr(ex))
    print('!!!!!!!!!!!!!!!!!!!!!>\n\n')
# NEW
# from http://stackoverflow.com/questions/1085852/interface-for-modifying-windows-environment-variables-from-python


#-------------------------------
# Window interface
#-------------------------------


def env_keys_user():
    root = winreg.HKEY_CURRENT_USER
    subkey = 'Environment'
    return root, subkey


def env_keys_root():
    root = winreg.HKEY_LOCAL_MACHINE
    subkey = r'SYSTEM\CurrentControlSet\Control\Session Manager\Environment'
    return root, subkey


def env_keys(user=True):
    """
    Returns windows root / subkey corresponding to environment variables

    CommandLine:
        python -m xdoctest C:/Users/erote/local/rob/internal/win_registry.py env_keys

    Example:
        >>> root, subkey = env_keys()
        >>> print('root = {!r}'.format(root))
        >>> print('subkey = {!r}'.format(subkey))

    """
    if user:
        root, subkey = env_keys_user()
    else:
        root, subkey = env_keys_root()
    return root, subkey


def get_env(name, user=True):
    print('get_env(%r, %r)' % (name, user))
    root, subkey = env_keys(user)
    # Get the key holding environment variables
    #key = winreg.OpenKey(root, subkey, 0, winreg.KEY_READ)
    key = winreg.OpenKey(root, subkey, 0, winreg.KEY_ALL_ACCESS)
    # Get the name value from the key
    try:
        log.print('winreg.QueryValueEx(%r, %r)' % (key, name))
        __print_key(key)
        value, _ = winreg.QueryValueEx(key, name)
    except WindowsError as ex:
        printEXCEPT(ex, 'get_env(%r, %r)' % (name, user))
        raise
        return ''
    return value


def set_env(name, value):
    log.print('set_env(%r, %r)' % (name, value))
    key = winreg.OpenKey(winreg.HKEY_CURRENT_USER, 'Environment', 0, winreg.KEY_ALL_ACCESS)
    winreg.SetValueEx(key, name, 0, winreg.REG_EXPAND_SZ, value)
    winreg.CloseKey(key)
    win32gui.SendMessage(win32con.HWND_BROADCAST, win32con.WM_SETTINGCHANGE, 0, 'Environment')
#-------------------------------
# end windows interface
#-------------------------------


def remove(list, item):
    while item in list:
        list.remove(item)


def unique(list):
    new_list = []
    seen = set([])
    for item in iter(list):
        if item not in seen:
            new_list.append(item)
            seen.add(item)
    return new_list


def prepend_env(name, values):
    log.print('prepend_env(%r, %r)' % (name, values))
    for value in values:
        paths = get_env(name).split(';')
        remove(paths, '')
        paths = unique(paths)
        remove(paths, value)
        paths.insert(0, value)
        set_env(name, ';'.join(paths))


def prepend_env_pathext(values):
    log.print('prepend_env_pathext(%r)' % (values))
    prepend_env('PathExt_User', values)
    pathext = ';'.join([get_env('PathExt_User'),
                        get_env('PathExt', user=False)])
    set_env('PathExt', pathext)


#OLD


tkey = 'HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Control\Class\{40EA0DC9-6AAB-440D-ACE5-C079DF364E23}'


def get_key_value(key_str, var_str):
    (reg_ROOT, reg_SUBKEY) = __keystr2_winreg(key_str)
    try:
        if tkey == key_str:
            print('---------------------')
            printDBG('GET_KEY_VAL: ' + key_str)
            if var_str == '(Default)':
                pass
            #ans = raw_input('Its that key. val:'+repr(var_str))
            #if ans == 'y':
                #import IPython
                #ipython.embed()
        key = winreg.OpenKey(reg_ROOT, reg_SUBKEY, 0, (winreg.KEY_WOW64_32KEY + winreg.KEY_ALL_ACCESS))
        if tkey == key_str:
            print(key)
            #print(key.handle)
            #for _a in dir(key):
            #    if _a.find('__') == 0: continue
            #    print(repr(_a) + repr(_a))
            #raw_input('We opened it')
        valtup = winreg.QueryValueEx(key, var_str)
        if tkey == key_str:
            print(repr(valtup))
            #raw_input('We QUERIED?!')
        winreg.CloseKey(key)
    except WindowsError as ex:
        if tkey == key_str:
            print(repr(ex))
            #raw_input('Oh, we failed. Bummer')
        return None
    return valtup[0]


def set_key_value(key_str, var_str, value, type_str):
    (reg_ROOT, reg_SUBKEY) = __keystr2_winreg(key_str)
    reg_TYPE                  = __type2_winreg(type_str)

    print('SET_KEY_VAL: ' + key_str)
    # (type_str, var_str) = values
    print(' * (%r, %r) = %r' % (type_str , var_str, value))
    return
    try:
        key = winreg.CreateKeyEx(reg_ROOT, reg_SUBKEY, 0, winreg.KEY_WRITE)
        winreg.SetValueEx(key, var_str, 0, reg_TYPE, value)
        print('-----------')
        winreg.CloseKey(key)
    except Exception as ex:
        print(repr(ex))


def get_subkeys(instr):
    """
    CommandLine:
        python -m xdoctest C:/Users/erote/local/rob/internal/win_registry.py get_subkeys

    Example:
        >>> subkeys = get_subkeys('HKEY_CURRENT_USER/Environment')
        >>> print('subkeys = {!r}'.format(subkeys))

    """
    (reg_ROOT, reg_SUBKEY) = __keystr2_winreg(instr)
    print('reg_SUBKEY = {!r}'.format(reg_SUBKEY))
    print('reg_ROOT = {!r}'.format(reg_ROOT))
    key = winreg.OpenKey(reg_ROOT, reg_SUBKEY)
    (num_subkeys, num_values, lastModifiedNanoJan1600) = winreg.QueryInfoKey(key)
    return [winreg.EnumKey(key, ix) for ix in range(num_subkeys)]


TIMEZONE_DIFF = -18000000000  # for Eastern Standard Time
JAN_1_1601 = datetime.datetime(year=1600, month=1, day=1)


def timestamp_from_windows_time(windows_time):
    microseconds = (windows_time * 0.1) + TIMEZONE_DIFF
    delta = datetime.timedelta(microseconds=microseconds)
    timestamp = JAN_1_1601 + delta
    return timestamp


def __key_info(key):
    info = []
    append = info.append
    #
    append('winreg.QueryInfoKey(key)')
    (num_subkeys, num_values, windows_time) = winreg.QueryInfoKey(key)
    last_modified = timestamp_from_windows_time(windows_time)
    append(' * num_subkeys: ' + str(num_subkeys))
    append(' * num_values: ' + str(num_values))
    append(' * last_modified: ' + str(last_modified))
    append('Listing Values...')
    for i in range(num_subkeys):
        append(' * ---------')
        enum_key_ret = winreg.EnumKey(key, i)
        append(' * winreg.EnumKey(key, i=%r) = %r' % (i, enum_key_ret))
        append(' * * winreg.EnumValue(TYPE; NAME) = VAL')
        for i in range(0, num_values):
            (val_name, val_data, val_type) = winreg.EnumValue(key, i)
            a = __typebin2_str(val_type)
            append(' * * winreg.EnumValue(%r, %r) = %r' % (a, val_name, val_data))
            winreg.CloseKey(key)
            append(' * * ----------')
    info_str = '\n'.join(info)
    return info_str


def infostr_key(instr):
    info_str  = '===================\n'
    info_str += 'key INFO: ' + instr + '\n'
    (root, subkey) = __keystr2_winreg(instr)
    key            =  winreg.OpenKey(root, subkey)
    return info_str + __key_info(key)


def __print_key(key):
    print('query info key')
    (num_subkeys, num_values, windows_time) = winreg.QueryInfoKey(key)
    last_modified = timestamp_from_windows_time(windows_time)
    print(' *  num_subkeys: ' + str(num_subkeys))
    print(' *  num_values: ' + str(num_values))
    print(' *  last_modified: ' + str(last_modified))
    print('QUERY VALUE')

    print('Enumerating subkey:')
    for i in range(num_subkeys):
        try:
            print(' *  * ' + winreg.EnumKey(key, i))
            print('ENUM VALUE (TYPE; NAME) = VAL')
        except Exception as ex:
            print(' * * Cannot access ' + str(i) + 'th subkey: ' + repr(ex))

    print('Enumerating values:')
    for i in range(num_values):
        try:
            (val_name, val_data, val_type) = winreg.EnumValue(key, i)
            val_type_str = __typebin2_str(val_type)
            print(' * * (%r, %r) = %r' % (val_type_str, val_name, val_data))
        except Exception as ex:
            print(' * * Cannot access ' + str(i) + 'th value: ' + repr(ex))
        winreg.CloseKey(key)
        print('===================' )


def print_key(instr):
    print('===================' )
    print('KEY_INFO: ' + instr)
    (root, subkey) = __keystr2_winreg(instr)
    key = winreg.OpenKey(root, subkey)
    return __print_key(key)


def __get_typemap():
    return {
        'BINARY': winreg.REG_BINARY,
        'DWORD': winreg.REG_DWORD,
        'DWORD_LITTLE_ENDIAN': winreg.REG_DWORD_LITTLE_ENDIAN,
        'DWORD_BIG_ENDIAN': winreg.REG_DWORD_BIG_ENDIAN,
        'EXPAND_SZ': winreg.REG_EXPAND_SZ,
        'LINK': winreg.REG_LINK,
        'MULTI_SZ': winreg.REG_MULTI_SZ,
        'NONE': winreg.REG_NONE,
        'RESOURCE_LIST': winreg.REG_RESOURCE_LIST,
        'FULL_RESOURCE_DESCRIPTOR': winreg.REG_FULL_RESOURCE_DESCRIPTOR,
        'RESOURCE_REQUIREMENTS_LIST': winreg.REG_RESOURCE_REQUIREMENTS_LIST,
        'SZ': winreg.REG_SZ
    }


def __type2_winreg(type_str):
    typemap = __get_typemap()
    return typemap[type_str]


def __typebin2_str(type_bin):
    typemap = __get_typemap()
    for key in typemap.keys():
        if typemap[key] == type_bin:
            return key


def __keystr2_winreg(instr):
    """
    Takes a registry string and extracts a tuple (winreg.HIVE, root_str)
    """
    root_map = {
        'HKEY_CURRENT_USER': winreg.HKEY_CURRENT_USER,
        'HKEY_CLASSES_ROOT': winreg.HKEY_CLASSES_ROOT,
        'HKEY_LOCAL_MACHINE': winreg.HKEY_LOCAL_MACHINE,
        'HKEY_USERS': winreg.HKEY_USERS,
        'HKEY_CURRENT_CONFIG': winreg.HKEY_CURRENT_CONFIG
    }
    for root_str in root_map.keys():
        if instr.find(root_str) == 0:
            return (root_map[root_str], instr[len(root_str) + 1:])
    raise Exception('WinRegistryException', instr + ' is not a valid hive')


if __name__ == '__main__':
    r"""
    CommandLine:
        python C:/Users/erote/local/rob/internal/win_registry.py
    """
    import xdoctest
    xdoctest.doctest_module(__file__)
