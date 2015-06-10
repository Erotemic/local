import utool as ut
from os.path import *


def init_console2():
    assert ut.WIN32, 'win32 only script'
    url = 'http://downloads.sourceforge.net/project/console/console-devel/2.00/Console-2.00b148-Beta_32bit.zip'
    unzipped_fpath = ut.grab_zipped_url(url)
    # FIXME: bugged
    unzipped_fpath2 = join(dirname(unzipped_fpath), 'Console2')
    win32_bin = ut.truepath('~/local/PATH')
    ut.copy(ut.ls(unzipped_fpath2), win32_bin)


if __name__ == '__main__':
    init_console2()
