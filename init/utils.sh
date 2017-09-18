

make_sshkey(){
    echo "Making an SSH RSA key if needed"
    if [ -f "$HOME/id_rsa.pub" ]; then
        echo "Already have an rsa key"
        cat ~/id_rsa.pub
        ssh-keygen -t rsa -b 4096 
    else:
        echo "Need an RSA key"
        EMAIL=$(git config --global user.email)
        if [[ "$EMAIL" == "" ]]; then
            echo "Need to set email via: git config --global user.email <youremail>"
        else
            echo "Generating a new RSA KEY"
            ssh-keygen -t rsa -b 4096 -C "$EMAIL"
            cat ~/id_rsa.pub
        fi
    fi
    echo "Please register your rsa key with github at this URL: https://github.com/settings/keys"
}
