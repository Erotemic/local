__gpg_notes__(){
    __heredoc__="""

    Notes about how to create, export/import, and use GPG keys

    References:
         .. [1] https://realpython.com/pypi-publish-python-package/
         .. [2] https://www.andreagrandi.it/2016/04/10/how-to-publish-a-python-package-to-pypi/
         .. [3] http://www.koozie.org/blog/2014/07/migrating-gnupg-keys-from-one-computer-to-another/
         .. [4] https://help.github.com/en/articles/signing-commits
         .. [5] https://thoughtbot.com/blog/pgp-and-you
         .. [6] https://packaging.python.org/tutorials/packaging-projects/#uploading-your-project-to-pypi
         .. [7] https://python-security.readthedocs.io/packages.html
         .. [8] https://github.com/cristal-ise/kernel/wiki/Maven-Deploy-Travis-GPG2
         .. [9] https://gist.github.com/romen/b7bac24d679d91acabb27bfcdabbee01
         .. [10] https://github.com/drduh/YubiKey-Guide
    """

    UserName="<firstname> <lastname>"
    UserEmail="<username>@<domain>.com"

    ##########
    # Generate a new GPG Key via `gpg --full-generate-key --expert`
    # Expect script to go through the interactive process of GPG selection.
    # Chooses ECC Curve 25519 cyphers, and expires after 1 year.
    expect -c '
spawn gpg --full-generate-key --expert
expect "Your selection? "
send "9\r";
expect "Your selection? "
send "1\r";
expect "Key is valid for? (0) "
send "1y\r"
expect "Is this correct? (y/N) "
send "y\r"
expect "Real name: "
send "<firstname> <lastname>\r"
expect "Email address: "
send "<username>@<domain>.com\r"
expect "Comment: "
send "<some comment>\r"
expect "Change (N)ame, (C)omment, (E)mail or (O)kay/(Q)uit? "
send "O\r"
interact
'

    ##########
    # Print status about your GPG Keys
    gpg --list-keys
    gpg --list-secret-keys

    #########
    # Get a KEYID environ reference to a specific public key.
    KEYID=$(gpg --list-secret-keys --keyid-format LONG "$UserName" | head -n 2 | tail -n 1 | awk '{print $1}' | tail -c 9)
    echo "KEYID = '$KEYID'"

    ##########
    # Export your keys to files to transfer them between computers
    gpg --armor --export > public_keys.pgp
    gpg --armor --export-secret-key > private_keys.pgp

    # Import GPG Keys from another machine
    gpg --import public_keys.pgp
    gpg --import private_keys.pgp

    # Add public gpg keys to github / gitlab
    cat public_keys.pgp
    https://github.com/settings/gpg/new
    https://gitlab.com/profile/gpg_keys

    ###########
    # Let the public know about your keys
    # Upload public key to the MIT server (not sure if this is the best server, but lets get it out there)
    gpg --send-keys --keyserver hkp://pgp.mit.edu $KEYID
    # Upload to a large keyserver pool
    gpg --send-keys --keyserver hkp://pool.sks-keyservers.net $KEYID

    ##########
    # Configure a git repo to autosign with a specific GPG key

    # https://help.github.com/en/articles/signing-commits
    git config --local commit.gpgsign true
    # Note the GPG key needs to match the email
    git config --local user.email $UserEmail
    # Tell git which key to sign
    git config --local user.signingkey $KEYID

    # List Git configs to verify changes
    git config --local -l

    ##########
    ### Sign and Verify Python Wheels ###
    gpg --detach-sign -a $WHEEL_PATH
    gpg --verify $WHEEL_PATH.asc $WHEEL_PATH
    twine check $WHEEL_PATH $WHEEL_PATH.asc
}


__building_gpg__(){
    # See Also:
    # .. [9] https://gist.github.com/romen/b7bac24d679d91acabb27bfcdabbee01
    # https://gnupg.org/download/
    #mkdir -p $PREFIX
    #echo $PREFIX
    #OLD=$(pwd)
    PREFIX=$HOME/.local
    cd $PREFIX
    mkdir -p tmp
    cd tmp
    wget https://gnupg.org/ftp/gcrypt/libgpg-error/libgpg-error-1.36.tar.bz2
    wget https://gnupg.org/ftp/gcrypt/libgcrypt/libgcrypt-1.8.5.tar.bz2
    wget https://gnupg.org/ftp/gcrypt/libksba/libksba-1.3.5.tar.bz2
    wget https://gnupg.org/ftp/gcrypt/libassuan/libassuan-2.5.3.tar.bz2
    wget https://gnupg.org/ftp/gcrypt/ntbtls/ntbtls-0.1.2.tar.bz2
    wget https://gnupg.org/ftp/gcrypt/npth/npth-1.6.tar.bz2
    wget https://gnupg.org/ftp/gcrypt/gnupg/gnupg-2.2.17.tar.bz2
    tar xjf libgpg-error-1.36.tar.bz2
    tar xjf libgcrypt-1.8.5.tar.bz2
    tar xjf libksba-1.3.5.tar.bz2
    tar xjf libassuan-2.5.3.tar.bz2
    tar xjf ntbtls-0.1.2.tar.bz2
    tar xjf npth-1.6.tar.bz2
    tar xjf gnupg-2.2.17.tar.bz2
    (cd libgpg-error-1.36 && ./configure --prefix=$PREFIX && make install)
    (cd libgcrypt-1.8.5 && ./configure --prefix=$PREFIX && make install)
    (cd libksba-1.3.5 && ./configure --prefix=$PREFIX && make install)
    (cd libassuan-2.5.3 && ./configure --prefix=$PREFIX && make install)
    (cd ntbtls-0.1.2 && ./configure --prefix=$PREFIX && make install)
    (cd npth-1.6 && ./configure --prefix=$PREFIX && make install)
    (cd gnupg-2.2.17 && ./configure --prefix=$PREFIX && make install)
}
