gg-recover()
{
    git checkout $(git rev-list -n 1 HEAD -- "$1")^ -- "$1"
}

gg-stats()
{
    echo ""
    echo "************"
    echo "~/code/opencv"
    cd ~/code/opencv
    git status
    echo "************"

    echo ""
    echo "************"
    echo "~/code/flann"
    cd ~/code/flann
    git status
    echo "************"

    echo ""
    echo "************"
    echo "~/latex/crall-lab-notebook"
    cd ~/latex/crall-lab-notebook
    git status
    echo "************"

    echo ""
    echo "************"
    echo "~/latex/crall-candidacy-2013"
    cd ~/latex/crall-candidacy-2013
    git status
    echo "************"

    echo ""
    echo "************"
    echo "~/local"
    cd ~/local
    git status
    echo "************"

    echo ""
    echo "************"
    echo "~/code/hesaff"
    cd ~/code/hesaff
    git status
    echo "************"

    echo ""
    echo "************"
    echo "~/code/hotspotter"
    cd ~/code/hotspotter
    git status
    echo "************"
}

gg-pull()
{
    cd ~/latex/crall-lab-notebook
    git pull
    echo ""
    echo "************"
    cd ~/latex/crall-candidacy-2013
    git pull
    echo ""
    echo "************"
    cd ~/local
    git pull
    echo ""
    echo "************"
    cd ~/code/hotspotter
    git pull github jon
    git pull 
    echo ""
    echo "************"
    cd ~/code/hesaff
    git pull
    echo ""
    echo "************"
    cd ~/code/opencv
    git pull
    echo ""
    echo "************"
    cd ~/code/flann
    git pull
}

gg-push()
{
    cd ~/latex/crall-lab-notebook
    git push
    echo ""
    echo "************"
    cd ~/latex/crall-candidacy-2013
    git push
    echo ""
    echo "************"
    cd ~/local
    git push
    echo ""
    echo "************"
    cd ~/code/hotspotter
    git push github jon
    git push 
    echo ""
    echo "************"
    cd ~/code/hesaff
    git push
    echo ""
    echo "************"
    cd ~/code/opencv
    git push
    echo ""
    echo "************"
    cd ~/code/flann
    git push
}
