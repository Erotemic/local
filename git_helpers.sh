
git-recover()
{
git checkout $(git rev-list -n 1 HEAD -- "$1")^ -- "$1"
}
