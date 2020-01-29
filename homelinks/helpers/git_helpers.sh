# Git helpers
heredoc="""
Depends on ~/local/init/util_git1.py
"""

source $HOME/local/init/utils.sh


gg-recover()
{
    git checkout $(git rev-list -n 1 HEAD -- "$1")^ -- "$1" == @a
}

gg-status()
{
    $(system_python) ~/local/init/util_git1.py 'git status' == $@
    #python -m utool.util_git 
}

gg-pull()
{
    $(system_python) ~/local/init/util_git1.py 'git pull' == $@
}

gg-push()
{
    $(system_python) ~/local/init/util_git1.py 'git push' == $@
}

gg-clone()
{
    $(system_python) ~/local/init/util_git1.py 'clone_repos'
}

gg-cmd()
{
    $(system_python) ~/local/init/util_git1.py $@
}

alias ggs=gg-status
alias ggp=gg-pull
alias gs=gg-status
alias ggcmd=gg-cmd

alias s='git status'
alias b='git branch'
alias r='git branch -r'
alias gits='git status'

# Git
alias gcwip='git commit -am "wip" && git push'
alias gp='git pull'

gg-short-status()
{
    $(system_python) ~/local/init/util_git1.py 'short_status'
}

alias ggss=gg-short-status

# MOVED TO ~/misc/git (probably will move to ~/local/git)
#git_sync()
#{
#    REMOTE=$1
#    RELPWD=$(python -c "import os; print(os.path.relpath('$(pwd)', os.path.expanduser('~')))")

#    # Safe version
#    gcwip && ssh $REMOTE "cd $RELPWD && git pull"

#    # Fast, but unsafe version
#    #gcwip& 
#    #ssh $REMOTE "cd $RELPWD && git pull"
#}
#alias git-sync='git_sync'
#complete -W "remote1 remote2 remote3 remote4" "git_sync"


_system_python(){
    __heredoc__="""
    Return name of system python
    """
    if [ "$(type -P python)" != "" ]; then
        echo "python"
    elif [ "$(type -P python3)" != "" ]; then
        echo "python3"
    else
        echo "python"
    fi 
}



_PYEXE=$(_system_python)
USER_SSH_HOSTS=$($_PYEXE -c "
# READ known hostnames from ~/.ssh/config
from os.path import expanduser, exists
ssh_config_path = expanduser('~/.ssh/config')
if exists(ssh_config_path):
    lines = open(ssh_config_path, 'r').read().split('\n')
    lines = [line for line in lines if line.startswith('Host ')]
    hosts = [line.split(' ')[1] for line in lines]
    print(' '.join(sorted(hosts)))
")
#echo "USER_SSH_HOSTS = $USER_SSH_HOSTS"

complete -W "$USER_SSH_HOSTS" "git-sync"
#complete -W "remote1 remote2 remote3 " "git-sync"


git_lev_sync()
{
    git-sync lev
}

git_hyrule_sync()
{
    git-sync hyrule
}

git_remote_sync()
{
    if [[ "$HOSTNAME" == "hyrule"  ]]; then 
        gcwip ; ssh lev "cd $(pwd) && git pull"
    else
        gcwip ; ssh lev "cd $(pwd) && git pull" ; ssh hyrule "cd $(pwd) && git pull"
    fi
}
alias grs='git_remote_sync'
