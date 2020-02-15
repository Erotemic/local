from rob_interface import *

def webcam_test(r):
    import pyopencv as cv
    cv.NamedWindow("w1", cv.CV_WINDOW_AUTOSIZE)
    capture = cv.CaptureFromCAM(0)

    def repeat():
        frame = cv.QueryFrame(capture)
        cv.ShowImage("w1", frame)
    while True:
        repeat()
    
def fix_date_to_front(r):
    fname_list = os.listdir(os.getcwd())
    for fname in fname_list:
        fname_, ext = os.path.splitext(fname)
        firstpos=fname_.find('-')
        if firstpos > 0:
            name = fname_[0:firstpos]
            date   = fname_[firstpos+1:]
            [month, day, year] = date.split('-')
            fname2 = year+'-'+month+'-'+day+'-'+name+ext
            os.rename(fname, fname2)

# ON UNIX: 
#(<class 'psutil.Process'>, 'parent')
#(<class 'psutil._common.constant'>, 'status')
#(<class 'psutil._common.group'>, 'gids')
#(<class 'psutil._common.user'>, 'uids')
#(<type 'instancemethod'>, 'getcwd')
#(<type 'instancemethod'>, 'kill')
#(<type 'instancemethod'>, 'resume')
#(<type 'instancemethod'>, 'suspend')
#(<type 'instancemethod'>, 'terminate')
#(<type 'instancemethod'>, 'wait')
#(<type 'int'>, 'nice')
#(<type 'int'>, 'pid')
#(<type 'int'>, 'ppid')
#(<type 'list'>, 'cmdline')
#(<type 'str'>, 'exe')
#(<type 'str'>, 'name')
#(<type 'str'>, 'terminal')
#(<type 'str'>, 'username')

# ON WINDOWS: 
#attr_names = [attr for attr in dir(proc) if attr.find('_') == -1]
#def proc_attr(proc, attr):
    #try: 
        #return eval('type(proc.'+attr+')')
    #except psutil._error.AccessDenied as ex:
        #if sys.platform == 'win32':
            #try: 
                #from winsys import security
                #with security.change_privileges(["security"]):
                    #return eval('type(proc.'+attr+')')
            #except Exception as ex:
                #print(repr(ex))
        #return None
#attr_types = [proc_attr(proc, attr) for attr in attr_names]
##attr_types = [eval('type(proc.'+attr+')') for attr in attr_names]
#print '\n'.join(map(repr, zip(attr_types, attr_names)))

def assign_folder_to_drive(r):
    if r.d.COMPUTED_NAME == 'BakerStreet':
        # I guess this doesn't work using
        #using: Visual Subst instead
        # ok, so to get rid of the stupid lock: 
        # Right click->Properties->Security->Edit->Add-> Add Users click ok.
        os.system(r'DISKPART ASSIGN LETTER=E MOUNT=D:\sys\E')


def test_devmgr(r):
    robos.test_devmgr()

def move_target_files(r):
    import os
    from os.path import join
    import shutil
    target_files = '''
    list of newline spearated filenames
    '''
    target_list = [_.strip() for _ in target_files.split('\n')]
    for (root, dir_list, file_list) in os.walk(os.getcwd()):
        for fname in file_list:
            if fname in target_list:
                print(fname)
                shutil.copy(join(root,fname), join(os.getcwd(),fname))


def test_devmgr(r):
    robos.test_devmgr()

def move_target_files(r):
    import os
    from os.path import join
    import shutil
    target_files = '''
    list of newline spearated filenames
    '''
    target_list = [_.strip() for _ in target_files.split('\n')]
    for (root, dir_list, file_list) in os.walk(os.getcwd()):
        for fname in file_list:
            if fname in target_list:
                print(fname)
                shutil.copy(join(root,fname), join(os.getcwd(),fname))


def flat_dlink(r, target, pattern, recurse=False):
    import os.path
    import os
    import fnmatch
    #if not os.path.isdir(target):
        #raise Exception('!!!')
    cwd = slash_fix(os.getcwd())
    basedir, _ = os.path.split(pattern)

    print("Target=    %s " % target)
    print("Pattern=   %s " % pattern)
    print("Rescursing=%r" % recurse)
    print("CWD=%r" % cwd)
    print("BASE=%r" % basedir)

    for root, dirs, files in os.walk(basedir):
        #cmd = 'MKLINK /J %s %s' % (target, root)
        #print cmd
        #os.system(cmd)
        for fname in files:
            fpath = os.path.abspath(os.path.join(root, fname))
            if fnmatch.fnmatch(fpath, pattern):
                print fpath
                lpath = os.path.join(target,fname)
                #create_link(r, fpath, lpath)
                cmd = 'MKLINK %s %s' % (lpath, fpath)
                print cmd
                os.system(cmd)
        if recurse in [False, 'False']:
            break

def pref_shortcuts(r):
    dircheck(r.d.TOOLBAR)
    create_shortcut(r, (r.f.crallj_ahk,'',r.d.AHK_SCRIPTS), r.d.STARTUP)
    portable_shortcuts = [\
            r.f.calc_exe,\
            r.f.rap_ee_exe,\
            r.f.console_exe,\
            ]
    installed_shortcuts = [\
             r.f.winedt_exe , \
             r.f.spotify_exe,\
             r.f.qiqqa_exe,\
             r.f.vim_exe,\
             r.f.chrome_exe,\
            (r.f.git_bash_sc, '', r.d.CODE) \
            ]
    other_shortcuts = [\
            (r.f.matlab_exe, '', r.f.hotspotter_matlab)\
            ]
    sc_list = portable_shortcuts + installed_shortcuts + other_shortcuts
    for sc in sc_list:
        create_shortcut(r, sc, r.d.TOOLBAR)


def refresh(r):
  robos.refresh()

def add_extension(r, ext='.png'):
    fname_list = os.listdir(os.getcwd())
    for fname in fname_list:
        if len(fname) >= len(ext) and fname[-len(ext)-1:-1] == fname:
            print fname
        #fname2 = fname.rfind
        #print "renaming: ", fname, "to", fname+ext
        #os.rename(fname, fname+ext)

            
def rename(r, search, replace, keep_ext=None):
    fname_list = os.listdir(os.getcwd())
    for fname in fname_list:
        if os.path.isfile(fname):
            isKeepExt = keep_ext != None and fname.find(keep_ext) > 0
            if isKeepExt:
                fname = fname.replace(keep_ext,'')
            fname2 = fname.replace(search, replace)
            if isKeepExt:
                fname2 += keep_ext
                fname  += keep_ext
            if fname != fname2:
                print "renaming: ", fname, "to", fname2
                os.rename(fname, fname2)

def hide_pyc(r):
    'makes gnome .hidden file'
    hidden_txt = ''
    cwd = os.getcwd()
    print 'Hiding *.pyc in '+cwd
    for path in os.listdir(cwd):
        if os.path.splitext(path)[1] == '.pyc':
            hidden_txt += path +'\n'
    with open(cwd+'/.hidden', 'w') as file:
        file.write(hidden_txt)
    
