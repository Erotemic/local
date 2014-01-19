import os
import subprocess
from subprocess import PIPE
import sys
import fnmatch


def find_files(directory, pattern):
    for root, dirs, files in os.walk(directory):
        for basename in files:
            if fnmatch.fnmatch(basename, pattern):
                filename = os.path.join(root, basename)
                yield filename


def random_pick(some_list, probabilities):
    import random
    norm = sum(probabilities)
    x = random.uniform(0, norm)
    cumulative_probability = 0.0
    for item, item_probability in zip(some_list, probabilities):
        cumulative_probability += item_probability
        if x < cumulative_probability:
            break
    return item


def slash_fix(path):
    if sys.platform == 'win32':
        return path.replace('/', '\\')
    else:
        return path.replace('\\', '/')


class DynStruct:
    def __init__(self):
        pass

    def fields(self):
        return [attr for attr in dir(self) if not callable(attr) and not attr.startswith("__")]


def call(cmdstr):
    import shlex
    if isinstance(cmdstr, str):
        args = shlex.split(cmdstr)
    else:
        args = cmdstr
    print("rob.call>Popen(%r))" % args)
    out = ''
    err = ''
    try:
        proc = subprocess.Popen(args, stdout=PIPE, stderr=PIPE)
        (out, err) = proc.communicate()
        return_code = proc.returncode  # NOQA
    except Exception:
        pass
    print ' * out = %r' % out
    print ' * err = %r' % err
    return (out, err)


def unique(in_list):
    # keeps things in order
    seen = set()
    out_list = []
    for item in in_list:
        if item not in seen:
            seen.add(item)
            out_list.append(item)
    return out_list


def dircheck(dname):
    if not os.path.exists(dname):
        os.makedirs(dname)


def phonetic(str_in):
    phenome_map = {'A': 'AE', 'M': 'EM', 'O': 'Oh', 'P': 'Pee', ' ': ' '}
    return ''.join(map(lambda (x): phenome_map[x], str_in))


def keyboard(banner=None):
    import code
    import sys

    ''' Function that mimics the matlab keyboard command '''
    # use exception trick to pick up the current frame
    try:
        raise None
    except:
        frame = sys.exc_info()[2].tb_frame.f_back
    print "# Use quit() to exit :) Happy debugging!"
    # evaluate commands in current namespace
    namespace = frame.f_globals.copy()
    namespace.update(frame.f_locals)
    try:
        code.interact(banner=banner, local=namespace)
    except SystemExit:
        return


def fix(in_str, quote="'"):
    return quote + in_str + quote


def ens(in_str, quote="'", valid=None):
    if valid is None:
        valid = [quote]
    if len(in_str) > 2:
        if in_str[0] not in valid:
            in_str = quote + in_str
        if in_str[-1] not in valid:
            in_str = in_str + quote
    else:
        in_str = fix(in_str)
    return in_str
