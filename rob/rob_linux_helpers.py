import subprocess
from subprocess import PIPE
# import rob_interface as robi  # NOQA


def get_clipboard():
    cmd = ["xclip", "-selection", "clipboard", "-o"]
    proc = subprocess.Popen(cmd, stdout=PIPE)
    tag = proc.communicate()[0]
    return tag


def check_installed_debian(pkgname):
    """
    References:
        http://www.cyberciti.biz/faq/find-out-if-package-is-installed-in-linux/
    """
    import ubelt as ub
    info = ub.cmd('hash ' + pkgname + ' 2>/dev/null', verbose=0, shell=True)
    is_installed = (info['ret'] == 0)
    return is_installed


def speak(r, to_speak, rate=-5):
    import unicodedata
    import ubelt as ub
    if not check_installed_debian('espeak'):
        raise AssertionError('espeak must be installed. run sudo apt-get install espeak')
    # ts1 = to_speak.decode('utf-8')
    ts1 = ub.ensure_unicode(to_speak)
    ts2 = unicodedata.normalize('NFKD', ts1)
    ts3 = ts2.encode('ascii', 'ignore')
    # ts4 = str(robi.preprocess_research(repr(ts3)))
    ts4 = ts3
    print('-----------')
    print('[robos.speak()] Speaking at rate ' + str(rate) + ':\n\n ')
    print(ts4)
    print('-----------')
    cmd_parts = ['espeak']
    # Interpret SSML markup
    cmd_parts += ['-m']
    # Speed in words per minute
    if rate == '3':
        cmd_parts += ['-s', '240']
    elif rate == '2':
        cmd_parts += ['-s', '220']
    else:
        cmd_parts += ['-s', str(200 + int(rate))]
    # Amplitude
    cmd_parts += ['-a', '10']
    # Pitch adjustment
    cmd_parts += ['-p', '80']
    cmd_parts += [ts4]
    #pause = ['-g', '1']  # pause between words (10ms) units
    #speed = ['-s', '175']  # 80 to 450 wpm #def 175
    #pitch = ['-p', '50']
    #stdout = ['--stdout']
    proc = subprocess.Popen(cmd_parts, stdout=subprocess.PIPE,
                            stderr=subprocess.PIPE)
    output = proc.communicate()
    return output
