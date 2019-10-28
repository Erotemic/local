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
