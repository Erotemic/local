
sync_tpl_push(){
    remote=acidalia
    REMOTES=( aretha arisia hermes klendathu acidalia )
    for remote in "${REMOTES[@]}"
    do
        rsync -auzpvR $HOME/./tpl-archive/ $remote:.
    done
}


sync_tpl_pull(){
    REMOTE=aretha
    # specify base relative to home
    BASE="."
    # specify the directory name to pull
    DNAME=tpl-archive
    rsync -auzpvR $REMOTE:$BASE/./$DNAME/ $HOME/$BASE/.
}

install_tpl_synergy(){
    sudo apt install qml-module-qtquick2

    md5sum $HOME/tpl-archive/synergy/synergy_2.0.5.stable_b1345+3f23b557_amd64.deb
    sudo dpkg -i $HOME/tpl-archive/synergy/synergy_2.0.5.stable_b1345+3f23b557_amd64.deb

}
