cd $CODE_DIR 
svn co svn://mygforgelogin@scm.gforge.inria.fr/svn/yael/trunk yael

export NCPUS=$(grep -c ^processor /proc/cpuinfo)


download_url_repo()
{ 
    export $URL=$1
    export $VERSION=$2
    mkdir ~/tmp
    cd ~/tmp
    wget $URL/$VERSION.tar.gz
    gunzip -f $VERSION.tar.gz && tar -xvf $VERSION.tar
}


download_url_repo2()
{ 
    export $URL=$1
    export $VERSION=$2
    mkdir ~/tmp
    cd ~/tmp
    wget $URL/$VERSION.tar.gz
    #gunzip -f $VERSION.tar.gz && tar -xvf $VERSION.tar
    gunzip -f $VERSION.tar.gz 
    mkdir $VERSION
    mv $VERSION.tar $VERSION
    cd $VERSION
    tar -xvf $VERSION.tar 
    cd ..
}
  


#====================
# SOURCE BUILD: YAEL
export URL=https://gforge.inria.fr/frs/download.php/file/33810/
export VERSION=yael_v401
download_url_repo $URL $VERSION
mv $VERSION ~/srcdistro 
cd ~/srcdistro/$VERSION
./configure
gmake -j$NCPUS
#====================


#====================
# SOURCE BUILD: YAEL DEMO
export URL=https://gforge.inria.fr/frs/download.php/file/33650/
export VERSION=yael_mini_demo_v0.2
download_url_repo $URL $VERSION
mv $VERSION ~/srcdistro 
cd ~/srcdistro/$VERSION
#====================


#====================
# SOURCE BUILD: SMK
export URL=https://gforge.inria.fr/frs/download.php/file/33244/
export VERSION=selective_match_kernel_v289
download_url_repo2 $URL $VERSION
./configure
gmake -j$NCPUS
#====================
