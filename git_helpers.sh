gg-recover()
{
    git checkout $(git rev-list -n 1 HEAD -- "$1")^ -- "$1"
}

gg-stats()
{
    python ~/local/util_git.py 'git status'
}

gg-pull()
{
    python ~/local/util_git.py 'git pull'
}

gg-push()
{
    python ~/local/util_git.py 'git push'
}

gg-cmd()
{
    python ~/local/util_git.py $@
}

alias ggs=gg-stats
alias ggp=gg-pull
alias gs=gg-stats
alias ggcmd=gg-cmd
