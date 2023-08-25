#!/bin/bash
__doc__="
Git helpers

Depends on ~/local/init/util_git1.py

SeeAlso:
    ~/local/repos.yaml
"
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

gg-list()
{
    $(system_python) ~/local/init/util_git1.py 'list'
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
#alias grs='git_remote_synco


# shellcheck disable=SC2120
git-hosturl(){
    __doc__="
    Get the host url associated with the remote

    Args:
        remote : specify the remote of interest, defaults to origin
    "
    local _DEPLOY_REMOTE=${1:-${DEPLOY_REMOTE:-"origin"}}
    # shellcheck disable=SC2155
    local _REMOTE_URL=$(git remote get-url "$_DEPLOY_REMOTE")

    if string_contains "$_REMOTE_URL" "https://" ; then
        echo "$_REMOTE_URL" "$_DEPLOY_REMOTE" | cut -d "/" -f 1,2,3
    else
        # shellcheck disable=SC2155
        local _suffix=$(echo "$_REMOTE_URL" "$_DEPLOY_REMOTE" | cut -d "/" -f 1 | cut -d "@" -f 2 | cut -d ":" -f 1)
        echo "https://${_suffix}"
    fi
}


# shellcheck disable=SC2120
git-gropuname(){
    __doc__="
    Get the username or groupname associated with the remote

    Args:
        remote : specify the remote of interest, defaults to origin
    "
    local _DEPLOY_REMOTE=${1:-${DEPLOY_REMOTE:-"origin"}}
    # shellcheck disable=SC2155
    local _REMOTE_URL=$(git remote get-url "$_DEPLOY_REMOTE")

    if string_contains "$_REMOTE_URL" "https://" ; then
        echo "$_REMOTE_URL" "$_DEPLOY_REMOTE" | cut -d "/" -f 4 | cut -d "/" -f 1
    else
        echo "$_REMOTE_URL" "$_DEPLOY_REMOTE" | cut -d ":" -f 2 | cut -d "/" -f 1
    fi
}


# shellcheck disable=SC2120
git-reponame(){
    __doc__="
    Get the repo name associated with a remote

    Args:
        remote : specify the remote of interest, defaults to origin
    "
    local _DEPLOY_REMOTE=${1:-${DEPLOY_REMOTE:-"origin"}}
    # shellcheck disable=SC2155
    _REMOTE_URL=$(git remote get-url "$_DEPLOY_REMOTE")

    if string_contains "$_REMOTE_URL" "https://" ; then
        echo "$_REMOTE_URL" "$_DEPLOY_REMOTE" | cut -d "/" -f 5 | cut -d "." -f 1
    else
        echo "$_REMOTE_URL" "$_DEPLOY_REMOTE" | cut -d ":" -f 2 | cut -d "/" -f 2 | cut -d "." -f 1 | cut -d " " -f 1
    fi
}


git-pullreq-url(){
    __doc__="
    Get url close to what the PR for this branch might be.


    git-hosturl
    git-gropuname
    git-reponame
    "
    DEPLOY_REMOTE=origin
    CURRENT_BRANCH=$(git branch --show-current)
    HOST_URL=$(git-hosturl)
    GROUP_NAME=$(git-gropuname)
    REPO_NAME=$(git-reponame)
    echo "REPO_NAME = $REPO_NAME"
    echo "GROUP_NAME = $GROUP_NAME"
    echo "HOST_URL = $HOST_URL"
    echo "CURRENT_BRANCH = $CURRENT_BRANCH"
    REPO_URL="${HOST_URL}/${GROUP_NAME}/$REPO_NAME"

    if [[ "$HOST_URL" == *"github"* ]]; then
        #echo "github"
        echo "$REPO_URL/pulls/"
    elif [[ "$HOST_URL" == *"gitlab"* ]]; then
        #echo "gitlab"
        echo "$REPO_URL/-/merge_requests/"
    else
        echo "unknown host"
    fi
}
alias gitpr=git-pullreq-url


#git-update-branch(){
#}
#alias gup='python ~/local/git_tools/git_devbranch.py update'
alias gup='python -m git_well branch_upgrade'


git-diff-branch(){
    __doc__="

    Args:
        FPATH
        OLD_BRANCH
        NEW_BRANCH

    source ~/local/homelinks/helpers/git_helpers.sh
    git-diff-branch README.rst HEAD main
    FPATH=predict.py
    OLD_BRANCH=landcover-fix
    "
    _handle_help "$@" || return 0
    FPATH=$1
    OLD_BRANCH=$2
    NEW_BRANCH=${3:-HEAD}

    GIT_ROOT=$(git rev-parse --show-toplevel)
    TMP_OLD_FPATH=$(mktemp /tmp/git-branch-diff.XXXXXX)
    TMP_NEW_FPATH=$(mktemp /tmp/git-branch-diff.XXXXXX)
    REL_PATH=$(realpath --relative-to="$GIT_ROOT" "$FPATH")
    echo "OLD_BRANCH = $OLD_BRANCH"
    echo "NEW_BRANCH = $NEW_BRANCH"
    echo "GIT_ROOT = $GIT_ROOT"
    echo "TMP_OLD_FPATH = $TMP_OLD_FPATH"
    echo "REL_PATH = $REL_PATH"
    git show "${OLD_BRANCH}:${REL_PATH}" > "$TMP_OLD_FPATH" && \
    git show "${NEW_BRANCH}:${REL_PATH}" > "$TMP_NEW_FPATH" && \
        colordiff -U 3 "$TMP_OLD_FPATH" "${TMP_NEW_FPATH}"
}


git-branch-cat(){
    __doc__="
    source ~/local/homelinks/helpers/alias_helpers.sh
    git-branch-cat detector.py dev/flow28
    git-branch-cat predict.py dev/flow28
    FPATH=predict.py
    BRANCH_NAME=landcover-fix
    "
    _handle_help "$@" || return 0
    FPATH=$1
    BRANCH_NAME=$2

    GIT_ROOT=$(git rev-parse --show-toplevel)
    REL_PATH=$(realpath --relative-to="$GIT_ROOT" "$FPATH")
    git show "${BRANCH_NAME}:${REL_PATH}"
}


git-clean-repo(){
    __doc__="
    Get rid of everything except referenced data.
    "
    git stash clear

    git reflog expire --expire-unreachable=now --all
    git gc --prune=now

}
