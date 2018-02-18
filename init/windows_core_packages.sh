install_drp_wrapper(){
    # Enable remote desktop server in windows home. 
    # https://github.com/stascorp/rdpwrap/releases
    # https://www.ctrl.blog/entry/how-to-rdpwrapper-win10-home

    mkdir -p ~/tmp
    cd ~/tmp
    #wget https://github.com/stascorp/rdpwrap/releases/download/v1.6.2/RDPWInst-v1.6.2.msi

    python -c "import ubelt as ub; ub.download('https://github.com/stascorp/rdpwrap/releases/download/v1.6.2/RDPWrap-v1.6.2.zip', fpath='RDPWrap-v1.6.2.zip')"
    unzip RDPWrap-v1.6.2.zip -d RDPWrap
    cd RDPWrap

    # You will need to click a confirmation, but other than that this works
    cmd "/C install.bat"
}
