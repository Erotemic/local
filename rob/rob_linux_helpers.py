import subprocess
from subprocess import PIPE
import rob_interface as robi


def get_clipboard():
    cmd = ["xclip","-selection", "clipboard", "-o"]
    proc = subprocess.Popen(cmd,stdout=PIPE)
    tag = proc.communicate()[0]
    return tag
    
        
def speak(r, to_speak, rate=-5):

    import unicodedata
    ts1 = to_speak.decode('utf-8')
    ts2 = unicodedata.normalize('NFKD', ts1)
    ts3 = ts2.encode('ascii','ignore')
    ts4 = str(robi.preprocess_research(repr(ts3)))
    print('-----------')
    print('[robos.speak()] Speaking at rate '+str(rate)+':\n\n ')
    print(ts4)
    print('-----------')

    pause = ['-g', '1'] # pause between words (10ms) units

    speed = ['-s', '175'] # 80 to 450 wpm #def 175

    pitch = ['-p', '50']  

    stdout = ['--stdout']

    proc = subprocess.Popen(['espeak', '-s', '220', '-a', '10', '-p', '80', ts4],
                            stdout=subprocess.PIPE,
                            stderr=subprocess.PIPE)
    output = proc.communicate()
