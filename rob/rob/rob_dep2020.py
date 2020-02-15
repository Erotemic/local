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
