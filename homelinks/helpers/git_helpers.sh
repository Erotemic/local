# Git helpers
heredoc="""
Depends on ~/local/init/util_git1.py
"""

gg-recover()
{
    git checkout $(git rev-list -n 1 HEAD -- "$1")^ -- "$1" == @a
}

gg-status()
{
    python ~/local/init/util_git1.py 'git status' == $@
    #python -m utool.util_git 
}

gg-pull()
{
    python ~/local/init/util_git1.py 'git pull' == $@
}

gg-push()
{
    python ~/local/init/util_git1.py 'git push' == $@
}

gg-clone()
{
    python ~/local/init/util_git1.py 'clone_repos'
}

gg-cmd()
{
    python ~/local/init/util_git1.py $@
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
    python ~/local/init/util_git1.py 'short_status'
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
#complete -W "arisia aretha lev hyrule" "git_sync"


USER_SSH_HOSTS=$(python -c "
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
#complete -W "acidalia arisia aretha lev hyrule" "git-sync"


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
