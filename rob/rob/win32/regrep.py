""" Search the Windows registry.
"""
import _winreg
import itertools

RegRoots = {
    _winreg.HKEY_CLASSES_ROOT:   'HKEY_CLASSES_ROOT',
    _winreg.HKEY_CURRENT_USER:   'HKEY_CURRENT_USER',
    _winreg.HKEY_LOCAL_MACHINE:  'HKEY_LOCAL_MACHINE',
    _winreg.HKEY_USERS:          'HKEY_USERS',
    }

class RegKey:
    """ A handy wrapper around the raw stuff in the _winreg module.
    """
    def __init__(self, rawkey, root, path):
        self.key = rawkey
        self.root = root
        self.path = path

    def __str__(self):
        return "%s\\%s" % (RegRoots.get(self.root, hex(self.root)), self.path)

    def close(self):
        _winreg.CloseKey(self.key)

    def values(self):
        """ Enumerate the values in this key.
        """
        for ikey in itertools.count():
            try:
                yield _winreg.EnumValue(self.key, ikey)
            except EnvironmentError:
                break

    def subkey_names(self):
        """ Enumerate the names of the subkeys in this key.
        """
        for ikey in itertools.count():
            try:
                yield _winreg.EnumKey(self.key, ikey)
            except EnvironmentError:
                break

    def subkeys(self):
        """ Enumerate the subkeys in this key.
        """
        for subkey_name in self.subkey_names():
            if self.path:
                sub = self.path + '\\' + subkey_name
            else:
                sub = subkey_name
            yield OpenRegKey(self.root, sub)

def OpenRegKey(root, path):
    try:
        rawkey = _winreg.OpenKey(root, path)
    except Exception as e:
        #print("Couldn't open %r %r: %s" % (root, path, e))
        return None
    return RegKey(rawkey, root, path)

def grep_key(key, target):
    for name, value, typ in key.values():
        if isinstance(value, basestring) and target in value:
            print("%s\\%s = %r" % (key, name, value))

    for subkey in key.subkeys():
        if not subkey:
            continue
        grep_key(subkey, target)
        subkey.close()

def grep_registry(grep_str):
    for root in RegRoots.keys():
        grep_key(OpenRegKey(root, ""), grep_str)

