gg-recover()
{
    git checkout $(git rev-list -n 1 HEAD -- "$1")^ -- "$1"
}

gg-stats()
{
    python ~/local/pygit_helpers.py 'git status'
}

gg-pull()
{
    python ~/local/pygit_helpers.py 'git pull'
}

gg-push()
{
    python ~/local/pygit_helpers.py 'git push'
}

alias ggs=gg-stats
