git-recover()
{
    git checkout $(git rev-list -n 1 HEAD -- "$1")^ -- "$1"
}

git-mypull()
{
    cd ~/local
    git pull
    cd ~/code/hotspotter
    git pull github jon
    git pull 
    cd ~/code/hesaff
    git pull
    cd ~/code/opencv
    git pull
    cd ~/code/flann
    git pull
}
