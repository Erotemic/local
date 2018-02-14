

make_sshkey(){
    echo "Making an SSH RSA key if needed"
    ID_RSA_PUB_FPATH="$HOME/.ssh/id_rsa.pub"
    if [ -f $ID_RSA_PUB_FPATH ]; then
        echo "Already have an rsa key"
        echo "Please register your rsa key with github at this URL: https://github.com/settings/keys"
        echo ""
        cat $ID_RSA_PUB_FPATH
    else
        #echo "Need an RSA key"
        #EMAIL=$(git config --global user.email)
        #if [[ "$EMAIL" == "" ]]; then
        #    echo "Need to set email via: git config --global user.email <youremail>"
        #else
            echo "Generating a new RSA KEY"
            #ssh-keygen -t rsa -b 4096 -C "$EMAIL"
            ssh-keygen -t rsa -b 4096
            echo "Please register your rsa key with github at this URL: https://github.com/settings/keys"
            echo ""
            cat $ID_RSA_PUB_FPATH
        #fi
    fi
}
