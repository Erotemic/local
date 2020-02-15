# Some of these should be deprecated.
# Some might be useful for windows, but lets ignore that.


def add_path(r, path_):
    print('Requested adding %r to the PATH' % path_)
    dpath = normpath(realpath(path_))
    #print('Exists? %r' % exists(dpath))
    #print('IsDir? %r' % isdir(dpath))
    #print('IsFile? %r' % isfile(dpath))
    if not exists(dpath):
        raise Exception('%r must exist' % dpath)
    if not isdir(dpath):
        raise Exception('%r must be a directory' % dpath)
    print(' * Adding adding %r to the PATH' % dpath)
    write_rob_pathcache([dpath])
    robos.add_path_vars([dpath])
    fixpath2(r)


def fixpath2(r):
    print('Hack fix this in a bit. Make general')
    os.environ['PATH']  = robos.get_env_var('PATH')
    print('Killing Autohokey')
    kill(r, 'AutoHotkey')
    print('Changeing dir to: %r' % r.d.AHK_SCRIPTS)
    cwd = os.getcwd()
    os.chdir(r.d.AHK_SCRIPTS)
    print('Starting Autohotkey')
    os.system('start crallj.ahk')
    os.system(r'echo set PATH=%PATH% > C:\newest_path.bat')
    print('Changeing dir to: %r' % cwd)
    os.chdir(cwd)
    print(r'Run C:\newest_path.bat')


def update_path(r):
    """
    this is the right command August31
    newpath.bat will do everything
    """
    pathvar_list = r.path_vars_list
    for pathvar in pathvar_list:
        print(pathvar)
    #robos.add_path_vars(pathvar_list)
    print('\n\nSend, #r newpath {enter}')
    print('Please run newpath.bat')


def fix_path(r):
    """ Removes duplicates from the path Variable """
    PATH_SEP = os.path.pathsep
    pathstr = robos.get_env_var('PATH')
    import ubelt as ub

    pathlist = list(ub.unique(pathstr.split(PATH_SEP)))

    new_path = ''
    failed_bit = False
    for p in pathlist:
        if os.path.exists(p):
            new_path = new_path + p + PATH_SEP
        elif p == '':
            pass
        elif p.find('%') > -1 or p.find('$') > -1:
            print('PATH=%s has a envvar. Not checking existance' % p)
            new_path = new_path + p + PATH_SEP
        else:
            print('PATH=%s does not exist!!' % p)
            failed_bit = True
    #remove trailing semicolons

    if failed_bit:
        ans = input('Should I overwrite the path? yes/no?')
        if ans == 'yes':
            failed_bit = False

    if len(new_path) > 0 and new_path[-1] == PATH_SEP:
        new_path = new_path[0:-1]

    if failed_bit is True:
        print("Path FIXING Failed. A Good path should be: \n%s" % new_path)
        print("\n\n====\n\n The old path was:\n%s" % pathstr)
    elif pathstr == new_path:
        print("The path was already clean")
    else:
        robos.set_env_var('PATH', new_path)


def win32_default(r, assisted=False):
    #robos.default_envvars(r)
    #robos.default_path(r)
    robos.default_registry(r)
    print('Finished defaulting regisitry')
    os.system('%PORT_SETTINGS%/install_ipython.bat')
    if assisted:
        robos.default_assisted(r)
    else:
        print("win32_default: Run this command with True as an argument to get assisted options")


def focus(r, window_name):
    print(robos.EnumWindowTest())
    print(robos.GetForegroundWindow())


def update_env(r):
    envvar_list = r.env_vars_list
    for name, rob_val in envvar_list:
        print(' * ENVAR: %s %s' % (name, rob_val))
    robos.add_env_vars(r, envvar_list)


# https://code.google.com/p/psutil/
def ps(r, flags=None):
    import psutil
    for pid in psutil.get_pid_list():
        proc = psutil.Process(pid)
        if flags is not None and \
           (proc.name.find(flags) == -1 and ' '.join(proc.cmdline).find(flags) == -1):
            continue
        #print(proc)
        #print(proc.get_cpu_percent())
        #print(proc.get_cpu_times())
        printproc_2(proc)


def printproc_2(proc):
    print('pid=%r; username=%r; name=%r' % (proc.pid, proc.username, proc.name))
    print('cmdline=%r' % (proc.cmdline))
    #print('parent: '   +repr(proc.parent))
    print('----')


def printproc_(proc):
    if sys.platform == 'win32':
        attr_list = ['parent', 'status', 'pid', 'ppid',
                     'cmdline', 'name', 'username']
    else:
        attr_list = ['nice', 'pid', 'ppid', 'cmdline', 'exe',
                     'name', 'terminal', 'username']
    for attr in attr_list:
        try:
            val = eval('proc.%s' % attr)
            print('proc.%s=%r' % (attr, val))
        except Exception:
            print('proc.%s' % attr)
    try:
        print('proc.parent = %r' % proc.parent)
    except Exception:
        print('proc.parent')


def pykill(r, scriptname, needbash=True):
    import psutil
    needbash = bool(needbash)
    print(needbash)
    script_fname = '%s.py' % scriptname
    to_kill = []
    for proc in psutil.process_iter():
        if 'python' == proc.name:
            cmdstr = ' '.join(proc.cmdline)
            if proc.parent.name != 'bash' and not needbash:
                continue
            #printproc_2(proc)
            #print(cmdstr)
            #print(script_fname)
            if cmdstr.find(script_fname) == -1:
                continue
            to_kill.append(proc)
    for proc in to_kill:
        print(' --- killing ---')
        printproc_2(proc)
        proc.kill()


def hskill(r):
    pykill(r, '<defunct>')


def kill(r, procname):
    import psutil
    for proc in psutil.process_iter():
        if procname in proc.name:
            print(' killing: ')
            printproc_(proc)
            proc.kill()
    print('Finished killing tasks.')
    # windows only: os.system('taskkill /f /im exampleProcess.exe')
    ''' # Unix Only
    import subprocess, signal
    p = subprocess.Popen(['ps', '-A'], stdout=subprocess.PIPE)
    out, err = p.communicate()
    for line in out.splitlines():
        if procname in line:
            pid = int(line.split(None, 1)[0])
            os.kill(pid, signal.SIGKILL)'''


def invgrep(r, *tofind_list):
    rob_nav._grep(r, tofind_list, recursive=True, invert=True)


