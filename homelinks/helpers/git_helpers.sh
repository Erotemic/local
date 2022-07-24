#!/bin/bash
__doc__="""
Git helpers

Depends on ~/local/init/util_git1.py
"""
#source $HOME/local/init/utils.sh


#gg-recover()
#{
#    git checkout $(git rev-list -n 1 HEAD -- "$1")^ -- "$1" == @a
#}

gg-status()
{
    $(system_python) ~/local/init/util_git1.py 'git status' == "$@"
    #python -m utool.util_git 
}

gg-pull()
{
    $(system_python) ~/local/init/util_git1.py 'git pull' == "$@"
}

gg-push()
{
    $(system_python) ~/local/init/util_git1.py 'git push' == "$@"
}

gg-clone()
{
    $(system_python) ~/local/init/util_git1.py 'clone_repos'
}

#gg-cmd()
#{
#    $(system_python) ~/local/init/util_git1.py $@
#}

alias ggs=gg-status
alias ggp=gg-pull
alias gs=gg-status
#alias ggcmd=gg-cmd

alias s='git status'
alias b='git branch'
alias r='git branch -r'
#alias gits='git status'

# Git
alias gcwip='git commit -am "wip" && git push'
alias gp='git pull'

gg-short-status()
{
    $(system_python) ~/local/init/util_git1.py 'short_status'
}

alias ggss=gg-short-status



# This is probably slow for bashrc sourcing, can we lazy compute this?

#if [[ "1" == "2" ]]; then
#    # TODO: this is slow, dont do that
#    source $HOME/local/init/utils.sh
#    _PYEXE=$(system_python)

#    USER_SSH_HOSTS=$($_PYEXE -c "
#    # READ known hostnames from ~/.ssh/config
#    from os.path import expanduser, exists
#    ssh_config_path = expanduser('~/.ssh/config')
#    if exists(ssh_config_path):
#        lines = open(ssh_config_path, 'r').read().split('\n')
#        lines = [line for line in lines if line.startswith('Host ')]
#        hosts = [line.split(' ')[1] for line in lines]
#        print(' '.join(sorted(hosts)))
#    ")
#    #echo "USER_SSH_HOSTS = $USER_SSH_HOSTS"

#    complete -W "$USER_SSH_HOSTS" "git-sync"
#    complete -W "$USER_SSH_HOSTS" "mount-remotes.sh"
#fi


#git_lev_sync()
#{
#    git-sync lev
#}

#git_hyrule_sync()
#{
#    git-sync hyrule
#}

#git_remote_sync()
#{
#    if [[ "$HOSTNAME" == "hyrule"  ]]; then 
#        gcwip ; ssh lev "cd $(pwd) && git pull"
#    else
#        gcwip ; ssh lev "cd $(pwd) && git pull" ; ssh hyrule "cd $(pwd) && git pull"
#    fi
#}
#alias grs='git_remote_sync'


git-pullreq-url(){
    DEPLOY_REMOTE=origin
    #CURRENT_REMOTE=$(git remote --show-current)
    CURRENT_BRANCH=$(git branch --show-current)
    GROUP_NAME=$(git remote get-url "$DEPLOY_REMOTE" | cut -d ":" -f 2 | cut -d "/" -f 1)
    REPO_NAME=$(git remote get-url "$DEPLOY_REMOTE" | cut -d ":" -f 2 | cut -d "/" -f 2 | cut -d "." -f 1)
    HOST=https://$(git remote get-url "$DEPLOY_REMOTE" | cut -d "/" -f 1 | cut -d "@" -f 2 | cut -d ":" -f 1)
    echo "REPO_NAME = $REPO_NAME"
    echo "CURRENT_BRANCH = $CURRENT_BRANCH"
    echo "GROUP_NAME = $GROUP_NAME"
    echo "HOST = $HOST"
    REPO_URL="https://github.com/${GROUP_NAME}/$REPO_NAME"
    echo "$REPO_URL/pull/"
}
alias gitpr=git-pullreq-url


#git-update-branch(){
#}
alias gup='python ~/local/git_tools/git_devbranch.py update'
