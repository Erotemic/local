from __future__ import print_function
import os
import _winreg
import win32con
import win32gui
import datetime
import new_win_reg

class RegistryLogger(object):
    def __init__(self):
        self.messages = []
    def print(self, msg):
        msg = 'registry_log: '+msg
        print(msg)
        self.messages.append(msg)
    def dump(self):
        print('\n'.append(map(repr,self.messages)))

log = RegistryLogger()

def printDBG(msg):
    print(msg)
    pass

def printEXCEPT(ex, func_name):
    print('\n\n<!!!!!!!!!!!!!!!!!!!!!')
    print('!!! Error in :'+func_name)
    print(repr(ex))
    print('!!!!!!!!!!!!!!!!!!!!!>\n\n')
# NEW
# from http://stackoverflow.com/questions/1085852/interface-for-modifying-windows-environment-variables-from-python


#-------------------------------
# Window interface
#-------------------------------

def env_keys_user():
    root = _winreg.HKEY_CURRENT_USER
    subkey = 'Environment'
    return root, subkey

def env_keys_root():
    root = _winreg.HKEY_LOCAL_MACHINE
    subkey = r'SYSTEM\CurrentControlSet\Control\Session Manager\Environment'
    return root, subkey

def env_keys(user=True):
    'Returns windows root / subkey corresponding to environment variables'
    if user:
        root, subkey = env_keys_user()
    else: 
        root, subkey = env_keys_root()
    return root, subkey

def get_env(name, user=True):
    print('get_env(%r, %r)' % (name, user))
    root, subkey = env_keys(user)
    # Get the key holding environment variables
    #key = _winreg.OpenKey(root, subkey, 0, _winreg.KEY_READ)
    key = _winreg.OpenKey(root, subkey, 0, _winreg.KEY_ALL_ACCESS)
    # Get the name value from the key
    try:
        log.print('_winreg.QueryValueEx(%r, %r)' % (key, name))
        __print_key(key)
        value, _ = _winreg.QueryValueEx(key, name)
    except WindowsError as ex:
        printEXCEPT(ex, 'get_env(%r, %r)' % (name, user))
        raise
        return ''
    return value

def set_env(name, value):
    log.print('set_env(%r, %r)' % (name, value))
    key = _winreg.OpenKey(_winreg.HKEY_CURRENT_USER, 'Environment', 0, _winreg.KEY_ALL_ACCESS)
    _winreg.SetValueEx(key, name, 0, _winreg.REG_EXPAND_SZ, value)
    _winreg.CloseKey(key)
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
            printDBG('GET_KEY_VAL: '+key_str)
            if var_str == '(Default)':
                pass
            #ans = raw_input('Its that key. val:'+repr(var_str))
            #if ans == 'y':
                #import IPython 
                #ipython.embed()
        key = _winreg.OpenKey(reg_ROOT, reg_SUBKEY, 0, (_winreg.KEY_WOW64_32KEY + _winreg.KEY_ALL_ACCESS))
        if tkey == key_str:
            print(key)
            #print(key.handle)
            #for _a in dir(key):
                #if _a.find('__') == 0: continue
                #print(repr(_a) + repr(_a))
            #raw_input('We opened it')
        valtup = _winreg.QueryValueEx(key, var_str)
        if tkey == key_str:
            print(repr(valtup))
            #raw_input('We QUERIED?!')
        _winreg.CloseKey(key)
    except WindowsError as ex:
        if tkey == key_str:
            print(repr(ex))
            #raw_input('Oh, we failed. Bummer')
        return None
    return valtup[0]

def set_key_value(key_str, var_str, value, type_str):
    (reg_ROOT, reg_SUBKEY) = __keystr2_winreg(key_str)
    reg_TYPE                  = __type2_winreg(type_str)

    print('SET_KEY_VAL: '+key_str)
    # (type_str, var_str) = values
    print(' * (%r, %r) = %r' % (type_str , var_str, value))
    return
    try:
        key = _winreg.CreateKeyEx(reg_ROOT, reg_SUBKEY, 0, _winreg.KEY_WRITE)
        _winreg.SetValueEx(key, var_str, 0, reg_TYPE, value)
        print('-----------')
        _winreg.CloseKey(key)
    except Exception as ex:
        print(repr(ex))

def get_subkeys(instr):
    (reg_ROOT, reg_SUBKEY) = __keystr2_winreg(instr)
    key = _winreg.OpenKey(reg_ROOT, reg_SUBKEY)
    (num_subkeys, num_values, lastModifiedNanoJan1600) = _winreg.QueryInfoKey(key)
    return [_winreg.EnumKey(key,ix) for ix in xrange(num_subkeys)]
    
TIMEZONE_DIFF = -18000000000 # for Eastern Standard Time
JAN_1_1601 = datetime.datetime(year=1600, month=1, day=1)
def timestamp_from_windows_time(windows_time):
    microseconds = (windows_time*0.1)+TIMEZONE_DIFF
    delta = datetime.timedelta(microseconds=microseconds)
    timestamp = JAN_1_1601 + delta
    return timestamp 

def __key_info(key):
    info = []
    append = info.append
    #
    append('_winreg.QueryInfoKey(key)')
    (num_subkeys, num_values, windows_time) = _winreg.QueryInfoKey(key)
    last_modified = timestamp_from_windows_time(windows_time)
    append(' * num_subkeys: '+str(num_subkeys))
    append(' * num_values: '+str(num_values))
    append(' * last_modified: '+str(last_modified))
    append('Listing Values...')
    for i in xrange(num_subkeys):
        append(' * ---------')
        enum_key_ret = _winreg.EnumKey(key,i)
        append(' * _winreg.EnumKey(key, i=%r) = %r' % (i, enum_key_ret))
        append(' * * _winreg.EnumValue(TYPE; NAME) = VAL')
        for i in xrange(0,num_values):
            (val_name, val_data, val_type) = _winreg.EnumValue(key,i)
            a = __typebin2_str(val_type)
            append(' * * _winreg.EnumValue(%r, %r) = %r' % (val_type_str, val_name, val_data))
            _winreg.CloseKey(key)
            append(' * * ----------')
    info_str = '\n'.join(info)
    return info_str

def infostr_key(instr):
    info_str  = '===================\n'
    info_str += 'key INFO: '+instr+'\n'
    (root, subkey) = __keystr2_winreg(instr)
    key            =  _winreg.OpenKey(root, subkey)
    return info_str + __key_info(key)

def __print_key(key):
    print('query info key')
    (num_subkeys, num_values, windows_time) = _winreg.QueryInfoKey(key)
    last_modified = timestamp_from_windows_time(windows_time)
    print(' *  num_subkeys: '+str(num_subkeys))
    print(' *  num_values: '+str(num_values))
    print(' *  last_modified: '+str(last_modified))
    print('QUERY VALUE')

    print('Enumerating subkey:')
    for i in xrange(num_subkeys):
        try:
            print(' *  * '+_winreg.EnumKey(key,i))
            print('ENUM VALUE (TYPE; NAME) = VAL')
        except Exception as ex:
            print(' * * Cannot access '+str(i)+'th subkey: '+ repr(ex))

    print('Enumerating values:')
    for i in xrange(num_values):
        try:
            (val_name, val_data, val_type) = _winreg.EnumValue(key,i)
            val_type_str = __typebin2_str(val_type)
            print(' * * (%r, %r) = %r' % (val_type_str, val_name, val_data))
        except Exception as ex:
            print(' * * Cannot access '+str(i)+'th value: '+ repr(ex))
        _winreg.CloseKey(key)
        print('===================' )

def print_key(instr):
    print('===================' )
    print('KEY_INFO: '+instr)
    (root, subkey) = __keystr2_winreg(instr)
    key = _winreg.OpenKey(root, subkey)
    return __print_key(key)

def __get_typemap():
    return {'BINARY':_winreg.REG_BINARY,\
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

def __type2_winreg(type_str):
    typemap = __get_typemap()
    return typemap[type_str]

def __typebin2_str(type_bin):
    typemap = __get_typemap()
    for key in typemap.keys():
        if typemap[key] == type_bin:
            return key
    
def __keystr2_winreg(instr):
    '''Takes a registry string and extracts a tuple (_winreg.HIVE, root_str)'''
    root_map = {'HKEY_CURRENT_USER':_winreg.HKEY_CURRENT_USER,\
                'HKEY_CLASSES_ROOT':_winreg.HKEY_CLASSES_ROOT,\
                'HKEY_LOCAL_MACHINE':_winreg.HKEY_LOCAL_MACHINE,\
                'HKEY_USERS':_winreg.HKEY_USERS,\
                'HKEY_CURRENT_CONFIG':_winreg.HKEY_CURRENT_CONFIG}
    for root_str in root_map.keys():
        if instr.find(root_str) == 0:
            return (root_map[root_str], instr[len(root_str)+1:])
    raise Exception('WinRegistryException', instr+' is not a valid hive')
