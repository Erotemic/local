source $HOME/local/init/utils.sh


setup_gitserver()
{
    # https://git-scm.com/book/en/v2/Git-on-the-Server-Setting-Up-the-Server
    sudo adduser git
    # Set git user password
    sudo passwd git

    # Make git .ssh dir
    sudo mkdir -p ~git/.ssh
    # add yourself as an authorized user
    sudo touch ~git/.ssh/authorized_keys
    sudo sh -c "cat $HOME/.ssh/id_rsa.pub >> ~git/.ssh/authorized_keys"
    sudo sh -c "cat $HOME/.ssh/id_joncrall_kitware_rsa.pub >> ~git/.ssh/authorized_keys"

    # Change shell so nasty things can't happen on the relatively open git server
    sudo chsh -s /bin/rbash git

    # Fix git ssh permissions and ownerships
    sudo chown -R git:git ~git/*
    sudo chown -R git:git ~git/.ssh

    sudo chmod 700 ~git/.ssh
    sudo chmod 600 ~git/.ssh/authorized_keys
    sudo chmod 600 ~git/.ssh/known_hosts
    sudo chmod 600 ~git/.ssh/config
    sudo chmod 400 ~git/.ssh/id_rsa*
}


clone_bare_repo(){
    NARGS=$#
    if [ "$NARGS" == "0" ]; then
        REPO_DIR=$(pwd)
    else
        REPO_DIR=$1
    fi
    echo "REPO_DIR = $REPO_DIR"
    REPO_NAME=$(python -c "import os; print(os.path.basename('$REPO_DIR'))")
    if [ ! -d ~git/$REPO_NAME.git ]; then
        sudo git clone --bare $REPO_DIR ~git/$REPO_NAME.git
    else
        echo "Bare repo already exists"
    fi
    sudo chown -R git:git ~git/$REPO_NAME.git

    echo "
    Dont forget to add the repo as a remote:
    E.G.
    git remote add <hostname> git@<hostaddr>:$REPO_NAME.git
    git remote add calculex git@calculex.kitware.com:$REPO_NAME.git
    git remote add hyrule git@hyrule.cs.rpi.edu::$REPO_NAME.git

    Also make sure you append your <client>:.ssh/id_rsa.pub to the remote
    <server>:~git/.ssh/authorized_keys. This can be done via ssh-copy-id
    E.G.
    ssh-copy-id git@<hostaddr>
    ssh-copy-id git@calculex.kitware.com
    "
}

init_bare_repo(){ 
    REPONAME=$1
    cd ~git
    sudo git init --bare $REPONAME.git 
    sudo touch $REPONAME.git/git-daemon-export-ok
    sudo chown -R git:git $REPONAME.git 
}

setup_unauthenticated_access(){
    # allow checkout via http
    # https://git-scm.com/book/en/v2/Git-on-the-Server-Git-Daemon

    source $HOME/local/init/utils.sh
    sudo_writeto /etc/systemd/system/git-daemon.service "
        [Unit]
        Description=Start Git Daemon

        [Service]
        ExecStart=/usr/bin/git daemon --reuseaddr --base-path=/home/git/ /home/git/

        Restart=always
        RestartSec=500ms

        StandardOutput=syslog
        StandardError=syslog
        SyslogIdentifier=git-daemon

        User=git
        Group=git

        [Install]
        WantedBy=multi-user.target
    "
    sudo systemctl enable git-daemon
    sudo service git-daemon start
    #sudo systemctl start git-daemon

    cd ~git
    # for each repo create this file
    touch git-daemon-export-ok


    # _----------------------
    # Ignore the following, it is incomplete
    ## At this point we can now clone with
    ## git clone git://remote:repo.git

    ## Now enable http checkout 
    #sudo apt install apache2 apache2-utils -y
    #sudo a2enmod cgi alias env
    #sudo service apache2 restart
    #sudo chgrp -R www-data ~git

    ## Is this the right place for a CGI script? I dont know what I'm doing here
    #sudo_appendto /etc/apache2/apache2.conf "
    #    SetEnv GIT_PROJECT_ROOT /home/git
    #    ScriptAlias /git/ /usr/lib/git-core/git-http-backend/
    #"
    #sudo ln -s /home/git /srv/git
    ## meh I couldn't get this working. 
}


make_bare_repos(){
    # References:
    # http://www.saintsjd.com/2011/01/what-is-a-bare-git-repository/
    # http://stackoverflow.com/questions/2888029/how-to-push-a-local-git-repository-to-another-computer

    clone_bare_repo ~joncrall/code/ibeis
    clone_bare_repo ~joncrall/code/utool

    sudo git clone --bare ~joncrall/code/ibeis ~git/ibeis.git
    sudo git clone --bare ~joncrall/code/utool ~git/utool.git
    sudo chown -R git:git ~git/ibeis.git
    sudo chown -R git:git ~git/utool.git
    
    # Add these new remotes to your local repos
    #git remote add hyrule git@hyrule.cs.rpi.edu:ibeis.git
    #git remote add hyrule git@hyrule.cs.rpi.edu:utool.git
}

