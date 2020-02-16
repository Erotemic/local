import getpass
import os
import shutil
import paramiko
from stat import S_ISDIR

hwdir = 'hw3'

usernames = '''
'''


server = 'linux.cs.rpi.edu'
port = 22
sshuser = 'cralljp'
sshpass = getpass.getpass('Enter your password for ' + sshuser + '\n')
transport = paramiko.Transport((server, port))
transport.connect(username=sshuser, password=sshpass)
#scp = SCPClient(ssh.get_transport())
sftp = paramiko.SFTPClient.from_transport(transport)


dir_format = '/projects/submit2/csci4530/' + hwdir + '/%s'
gradesheet = hwdir + '_gradesheet.txt'


def recursive_get(sftp, remotedir, localdir='.'):
    cwd = sftp.getcwd()
    print('Transfering files from ' + remotedir + ' to ' + localdir)
    if not os.path.exists(localdir):
        print('Creating ' + localdir)
        os.mkdir(localdir)
    sftp.chdir(remotedir)
    remote_item_list = sftp.listdir()
    # Go through items on server. Get Files Recursive Get Directories
    for remote_item in remote_item_list:
        # Directory ... Sigh
        if S_ISDIR(sftp.stat(remote_item).st_mode):
            recurse_local = localdir + '/' + remote_item
            recurse_remote = remotedir + '/' + remote_item
            recursive_get(sftp, recurse_remote, recurse_local)
            sftp.chdir(remotedir)
        else:
            local_item = localdir + '/' + remote_item
            if os.path.exists(local_item):
                print('Already Exists: ' + remote_item)
            else:
                sftp.get(remote_item, local_item)
                print('Grabbing ' + remote_item)
    sftp.chdir(cwd)


if not os.path.exists(hwdir):
    os.mkdir(hwdir)
#user = usernames.split('\n')[1]
for user in usernames.split('\n'):
    if len(user) == 0:
        continue
    user_dir = hwdir + '/' + user
    try:
        os.mkdir(user_dir)
    except Exception:
        pass
    remote_dir = dir_format % (user)
    try:
        print("Changing to " + remote_dir)
        sftp.chdir(remote_dir)
    except Exception:
        print("User: " + user + " did not submit")
        continue
    submissions = sftp.listdir()
    if 'LAST' in submissions:
        sel_sub = 'LAST'
    else:
        # Last doesn't exist. Get it yourself
        int_sub = []
        for sub in submissions:
            try:
                int_sub.append(int(sub))
            except Exception:
                pass
        int_sub.sort()
        sel_sub = str(int_sub[-1])

    remote_dir = remote_dir + '/' + sel_sub
    print("Changing to " + remote_dir)
    sftp.chdir(remote_dir)

    local_dir = 'C:/Users/jon.crall/Dropbox/TAing/AdvancedGraphics/' + user_dir
    recursive_get(sftp, remote_dir, local_dir)
    shutil.copy(gradesheet, user_dir + '/' + user + '_report.txt')
