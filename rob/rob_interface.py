import os
from rob_helpers import *  # NOQA
import rob_helpers
from datetime import datetime  # NOQA
import urllib  # NOQA
if sys.platform == 'win32':
    import rob_helpers_windows as robos
else:
    import rob_linux_helpers as robos
    pass
import re
#import webbrowser
from os.path import normpath, realpath, join, split, isdir, isfile, exists, dirname  # NOQA
from rob_alarm import *  # NOQA
from rob_nav import *  # NOQA
import rob_nav
#
from os.path import expanduser


def focus(r, window_name):
    print(robos.EnumWindowTest())
    print(robos.GetForegroundWindow())


def fix_sid(r, keep_ext=None):
    search  = 'sID(cm56x3p;)'
    replace = 'sID(5062,cm56x3p;)'
    fname_list = os.listdir(os.getcwd())
    for fname in fname_list:
        if os.path.isfile(fname):
            fname2 = fname.replace(search, replace)
            if fname != fname2:
                print('renaming: %s to %s' % (fname, fname2))
                #os.rename(fname, fname2)


def texinit(r):
    import shutil
    print('Initializing latex directory')

    cralldef_fname    = join(r.d.PORT_LATEX, 'CrallDef.tex')
    crallpreamb_fname = join(r.d.PORT_LATEX, 'CrallPreamb.tex')
    template_fname    = join(r.d.PORT_LATEX, 'template.tex')
    latexmain_fname   = join(r.d.PORT_LATEX, 'template.tex.latexmain')

    #symlink(r, source=r.d.PORT_LATEX, target)
    shutil.copy(cralldef_fname,    './CrallDef.tex')
    shutil.copy(crallpreamb_fname, './CrallPreamb.tex')
    shutil.copy(template_fname,  'main.tex')
    shutil.copy(latexmain_fname, 'main.tex.latexmain')


def write_rob_pathcache(pathlist):
    fname = join(dirname(__file__), 'pathcache%s.txt' % sys.platform)
    with open(fname, 'a') as file:
        for path in pathlist:
            file.write('\n%s' % path)


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
    '''
    this is the right command August31
    newpath.bat will do everything
    '''
    pathvar_list = r.path_vars_list
    for pathvar in pathvar_list:
        print(pathvar)
    robos.add_path_vars(pathvar_list)
    print('Send, #r newpath {enter}')


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
        if not flags is None and \
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


def project_dpaths():
    return map(expanduser, ['~/code/hotspotter', '~/code/hesaff'])


# Grep my projects
def gp(r, regexp):
    rob_nav._grep(r, [regexp], recursive=True, dpath_list=project_dpaths(), regex=True)


# Sed my projects
def sp(r, regexpr, repl, force=False):
    rob_nav._sed(r, regexpr, repl, force=force, recursive=True, dpath_list=project_dpaths())


def grep(r, *tofind_list):
    rob_nav._grep(r, tofind_list, recursive=True)


def grepnr(r, *tofind_list):
    rob_nav._grep(r, tofind_list, recursive=False)


def grepc(r, *tofind_list):
    rob_nav._grep(r, tofind_list, case_insensitive=False)


def grepr(r, regexpr, recursive=True):
    rob_nav._grep(r, [regexpr], recursive=recursive, regex=True)


def sedr(r, regexpr, repl, force=False):
    sed(r, regexpr, repl, force=force, recursive=True)


def sed(r, regexpr, repl, force=False, recursive=False):
    rob_nav._sed(r, regexpr, repl, force, recursive)


def search(r, *tofind_list):
    dpath = os.getcwd()
    print('Searching %s for %r' % (dpath, tofind_list))
    num_found = 0
    for root, dname_list, fname_list in os.walk(dpath):
        for name in fname_list + dname_list:
            name_ = name.lower()
            if find_in_list(name_, tofind_list, all):
                print(os.path.join(root, name_))
                num_found += 1
    print(' * num_found=%d' % (num_found))


def preprocess_research(input_str):
    input_str = re.sub('\\\\cite{[^}]*}', '', input_str)
    input_str = re.sub('et al.', 'et all', input_str)  # Let rob say et al.
    input_str = re.sub(r'\\r', '', input_str)  # Let rob say et al.
    input_str = re.sub(r'\\n', '', input_str)  # Let rob say et al.
    input_str = re.sub('\\\\', '', input_str)  # Let rob say et al.
    #input_str = re.sub('[a-z]?[a-z]', 'et all', input_str) # Let rob say et al.
    input_str = re.sub('\\.[^a-zA-Z0-1]+', '.\n', input_str)  # Split the document at periods
    input_str = re.sub('\r\n', '\n', input_str)
    input_str = re.sub('^ *$\n', '', input_str)
    input_str = re.sub('\n\n*', '\n', input_str)
    return input_str


def process_research_line(line):
    line = re.sub('([A-Za-z ]*, 20[0-9][0-9])', '', line)  # (Name, Year) Citations
    line = re.sub('\\[[0-9, ]+\\]', '', line)  # remove numerical citations.
    line = re.sub('- ', '', line)  # Fix Qiqqa output
    line = re.sub('-', ' ', line)  # Remove remaining dashes
    line = re.sub('[^A-Za-z0-9., ? ]', '', line)  # Remove remaining weird characters
    line = re.sub(' *,', ', ', line)  # Fix commas
    line = re.sub(',+', ', ', line)  # Fix commas
    line = re.sub('  *', ' ', line)
    line = re.sub('  *', ' ', line)
    line = re.sub('NBNN', 'Naive Bayes Nearest Neighbor', line)
    line = re.sub('\\(i\\)', '1)', line)
    line = re.sub('\\(ii\\)', '2)', line)
    line = re.sub('\\(iii\\)', '3)', line)

    lots_of_numbers = re.compile('[0-9]+ [0-9]+ [0-9]+ [0-9]+')
    if len(lots_of_numbers.findall(line)) > 0:
        line = ''
    if len(line) < 3:
        line = ''
    return line


def research_clipboard(r, start_line_str=None, rate='3', sentence_mode=True, open_file=False):
    to_speak = robos.get_clipboard()
    write_research(r, to_speak)
    research(r, start_line_str='0', rate=rate, sentence_mode=True, open_file=False)


def print_clipboard(r):
    clipboard = robos.get_clipboard()
    print(clipboard)


def sync_clipboard_to(r, remote):
    send_clipboard_to(r, remote)
    #DISPLAY=:10.0 xsel
    #remote_cmd = 'DISPLAY=:10.0 xsel --clipboard < ~/clipboard.txt'
    #send_command(r, remote, remote_cmd)


def dump_clipboard(r, clipboard_fname):
    clipboard = robos.get_clipboard()
    with open(clipboard_fname, 'w') as file_:
        file_.write(clipboard)


def send_clipboard_to(r, remote):
    clipboard_fname = 'clipboard.txt'
    dump_clipboard(r, clipboard_fname)
    rob_helpers.scp_push(remote, clipboard_fname)


def send_command(r, remote, remote_cmd):
    args = ['ssh', '-X', remote, '"' + remote_cmd + '"']
    cmdstr = ' '.join(args)
    print(cmdstr)
    rob_helpers.call(cmdstr)


def write_research(r, to_write, rate=-5):
    fname = join(split(__file__)[0], 'to_speak.txt')
    file = open(fname, 'w')
    file.write(to_write)
    file.close()


def research(r, start_line_str=None, rate='3', sentence_mode=True, open_file=False):
    fname = join(split(__file__)[0], 'to_speak.txt')
    if start_line_str == "prep":
        os.system(fname)
        return
    if open_file is True:
        os.system(fname)
    f = open(fname, mode='rb')
    input_str = preprocess_research(f.read())
    if sentence_mode:
        input_str = input_str.replace('\n', ' ').replace('. ', '.\n')
        input_str = re.sub('  *', ' ', input_str)

    line_count = 0
    page = 0
    page_re = re.compile(' *--- Page [0-9]* *--- *')
    if start_line_str is None:
        try:
            start_page = 0
            start_line = int(raw_input('Did you forget the start line?'))
        except Exception:
            pass
    elif start_line_str.find('page') != -1:
        start_page = int(start_line_str.replace('page', ''))
        start_line = 0
    else:
        start_page = 0
        start_line = int(start_line_str)

    print('Starting on line: %d' % (start_line))
    print('Starting on page: %d' % (start_page))
    for line in input_str.split('\n'):
        print('____')
        # Check for page marker
        if page_re.findall(line) != []:
            page = int(re.sub(' *--- Page ', '', line).replace('---', ''))
        # Print out what is being read
        line_count += 1
        print('%d, %d > %s' % (page, line_count, line))
        if start_line > line_count or start_page > page:
            continue
        # Preprocess the line
        line = process_research_line(line)
        if line == '':
            continue
        print('--')
        robos.speak(r, line, rate)
        #subprocess.call(r.f.nircmd_exe + ' speak text \"'+line+'\" '+str(rate))


def info(r):
    'Provides interface help'
    import rob_interface
    print("===================\n")
    help(rob_interface)
    print("===================\n")


def symlink(r, source=None, target=None):
    'Creates a hard link to the source in the current directory or linked_dest if specified'
    if source is None:
        raise Exception('must at least specify a source')
    #if target == None:
        #target = slash_fix('C:/tmp/'+os.path.basename(source))
    if sys.platform == 'win32':
        if os.path.isdir(source):
            call('MKLINK /D "%s" "%s"' % (target, source))
        else:
            call('MKLINK "%s" "%s"' % (target, source))
    else:
        print(os.path.islink(target))
        call(['ln', '-s', os.path.normpath(source),  os.path.normpath(target)])


def make_dpath(r, dpath):
    if not os.path.exists(dpath):
        os.makedirs(dpath)


#=====================
# SETUP COMMANDS
#=====================
def print_path(r):
    print('\n----------------')
    print('os.environ["PATH"]:')
    path = os.environ['PATH']
    for line in path.split(';'):
        print(' * ' + line)

    print('\n----------------')
    print('robos.get_env_var("PATH"):')
    path = robos.get_env_var('PATH')
    for line in path.split(';'):
        print(' * ' + line)


def print_env(r):
    print(sys.environs)
    #print_path(r)
    #for varval in r.env_vars_list:
        #print(varval[0]+' = '+varval[1])


def pref_env(r):
    'Function that sets Envirornment Preferences'
    for (envvar, envval) in r.env_vars_list:
        print(envvar + '=' + envval)
        #robos.set_env_var(envvar, envval)
        #robos.set_env_var('ROB_'+envvar, envval)
    path_list = r.path_vars_list
    for path in path_list:
        print(path)
        #robos.append_to_path(path)


def setup_global():
    pref_env()
    pass


def fix_path(r):
    """ Removes duplicates from the path Variable """
    PATH_SEP = os.path.pathsep
    pathstr = robos.get_env_var('PATH')

    pathlist = unique(pathstr.split(PATH_SEP))

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
            print('PATH=%s does not exist!!' % s)
            failed_bit = True
    #remove trailing semicolons

    if failed_bit:
        ans = raw_input('Should I overwrite the path? yes/no?')
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


def create_shortcut(r, what, where=''):
    # TODO Move to windows helpers
    print('\n\n+---- Creating Shortcut ----')
    print('What = %s\n Where=%s' % (what, where))
    run_in    = ''
    what_args = ''
    if isinstance(what, tuple):
        tup       = what
        what      = tup[0]
        what_args = tup[1]
        run_in    = tup[2]
        if run_in == ' ':
            run_in = ''
        if what_args == ' ':
            what_args = ''
    if where == '':
        target = what + '.lnk'
    else:
        dircheck(where)
        base_what = os.path.basename(what)
        if len(base_what) > 0:
            if base_what[-1] in ['"', "'"]:
                base_what = base_what[0:-1]

        target = where + '/' + base_what + '.lnk'
    helpers_vbs = r.f.create_shortcut_vbs
    cmd = 'cscript "%s" "%s" "%s" "%s" "%s"' % (helpers_vbs, target, what,
                                                what_args, run_in)
    print(cmd)
    call(cmd)


def send(r, keys, pause=.05):
    import SendKeys
    pause = float(pause)
    SendKeys.SendKeys(keys, pause=pause, with_spaces=False, with_tabs=True,
                      with_newlines=False, turn_off_numlock=True)
