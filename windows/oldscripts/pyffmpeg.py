import sys
import fnmatch
import os
import os.path
import subprocess
from subprocess import PIPE

def to_avi(fpath):
    print "<----------------------------"
    print "Converting: "+fpath
    ffmpeg_exe = r'C:/Program Files (x86)/WinFF/ffmpeg.exe'
    threads = '' #r'-threads 2 '
    avi_args = r' -acodec libmp3lame -vcodec msmpeg4 -ab 192kb -b 1000kb -s 640x480 -ar 44100 '
    in_args = r'-i "%s" ' % fpath
    out_args = r'-i "%s_postavi.avi" ' % fpath
    cmd = '"'+ffmpeg_exe+'" ' + threads + in_args + avi_args + out_args
    print "FFMPEG COMMAND:\n"+cmd+"\n\n\n"
    proc = subprocess.Popen(cmd, stdout=PIPE, stderr=PIPE)
    (out, err) = proc.communicate()
    print out
    print err
    return_code = proc.returncode 
    print return_code
    print "---------------------------->"

if __name__ == '__main__':
    print sys.argv
    print sys.argv[1:]
    for (argc, argv) in enumerate(sys.argv[1:]):
        print os.path.isfile(argv) 
        print fnmatch.fnmatch(argv, '*_postavi.avi')
        if os.path.isfile(argv) and\
           not fnmatch.fnmatch(argv, '*_postavi.avi'):
            to_avi(argv)
