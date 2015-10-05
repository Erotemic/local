import utool as ut
import pipes

def send_public_key_to_server(username, server):
    """
    Can just use this instead

    ssh-copy-id id@server

    ssh-copy-id git@hyrule.cs.rpi.edu
    ssh-copy-id joncrall@128.213.17.87
    ssh-copy-id jonc@pachy.cs.uic.edu

    ut.copy_text_to_clipboard(remote_cmdstr)

    chmod 700 ~git/.ssh
    chmod 600 ~git/.ssh/authorized_keys

    """

    public_key = ut.read_from(ut.truepath('~/.ssh/id_rsa.pub'))
    fmtstr = 'ssh {user}@{server} "{remote_cmdstr}"'
    remote_cmdstr = 'echo {public_key} >> ~{username}/.ssh/authorized_keys'.format(public_key=public_key.replace(r'\', r'\\'), username=username)
    sshcmdstr = fmtstr.format(server=server, user=user, remote_cmdstr=remote_cmdstr)
    ut.copy_text_to_clipboard(sshcmdstr)
    print('You need to run the command in your clipboard')
#ut.cmd(sshcmdstr)

if __name__ == '__main__':
    #username = 'joncrall'
    username = 'git'
    server = 'hyrule.cs.rpi.edu'
    send_public_key_to_server(username, server)
