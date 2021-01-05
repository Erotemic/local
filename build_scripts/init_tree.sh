build_tree(){

    # Homepage: http://mama.indstate.edu/users/ice/tree/
    # https://packages.ubuntu.com/source/focal/tree

    mkdir -p $HOME/code
    cd $HOME/code
    git clone https://github.com/kddeisz/tree.git
    cd  $HOME/code/tree

    mkdir -p $HOME/tmp
    cd $HOME/tmp
    curl http://mama.indstate.edu/users/ice/tree/src/tree-1.8.0.tgz --output tree-1.8.0.tgz
    GOT_HASH=$(md5sum tree-1.8.0.tgz | cut -d" " -f 1)
    echo "GOT_HASH = $GOT_HASH"
    if [ "$GOT_HASH" == "715191c7f369be377fc7cc8ce0ccd835" ]; then 
        tar -zxvf tree-1.8.0.tgz
        cd tree-1.8.0

        # Lovely, absolutely no modern build system
        PREFIX=$HOME/.local
        sed -i "s|prefix = /usr|prefix = $PREFIX|g" Makefile
        make 
        make install
    else
        echo "Bad hash"
        return 1
    fi
}
