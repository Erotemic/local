#!/bin/bash
__doc__="

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
    .. [11] https://illuad.fr/2020/10/06/build-an-openpgp-key-based-on-ecc.html
    .. [12] https://security.stackexchange.com/questions/169538/generate-subkeys-based-on-less-secure-openpgp-primary-key
    .. [13] https://security.stackexchange.com/questions/255358/why-does-ecc-not-have-an-encrypt-capability-in-gpg-but-rsa-does
    .. [14] https://davesteele.github.io/gpg/2014/09/20/anatomy-of-a-gpg-key/
    .. [15] https://www.gnupg.org/documentation/manuals/gnupg/Specify-a-User-ID.html
    .. [16] https://gitlab.com/biomedit/gpg-lite/-/issues/28
    .. [17] https://wiki.debian.org/Subkeys
    .. [19] https://incenp.org/notes/2015/using-an-offline-gnupg-master-key.html

See Also
========
pip install gpg-lite
python -m pip install git+https://gitlab.com/biomedit/gpg-lite.git
"

__gpg_notes__(){
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
    gpg --send-keys --keyserver hkp://pgp.mit.edu "$KEYID"
    # Upload to a large keyserver pool
    gpg --send-keys --keyserver hkp://pool.sks-keyservers.net "$KEYID"
    gpg --send-keys --keyserver https://keyserver.ubuntu.com/ 4AC8B478335ED6ED667715F3622BE571405441B4

    ##########
    # Configure a git repo to autosign with a specific GPG key

    # https://help.github.com/en/articles/signing-commits
    git config --local commit.gpgsign true
    # Note the GPG key needs to match the email
    git config --local user.email $UserEmail
    # Tell git which key to sign
    git config --local user.signingkey "$KEYID"

    # List Git configs to verify changes
    git config --local -l

    ##########
    ### Sign and Verify Python Wheels ###
    gpg --detach-sign -a "$WHEEL_PATH"
    gpg --verify "$WHEEL_PATH".asc "$WHEEL_PATH"
    twine check "$WHEEL_PATH" "$WHEEL_PATH".asc
}


__building_gpg__(){
    # See Also:
    # .. [9] https://gist.github.com/romen/b7bac24d679d91acabb27bfcdabbee01
    # https://gnupg.org/download/
    #mkdir -p $PREFIX
    #echo $PREFIX
    #OLD=$(pwd)
    # No longer needed with recent GPG / os
    PREFIX=$HOME/.local
    cd "$PREFIX"
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
    (cd libgpg-error-1.36 && ./configure --prefix="$PREFIX" && make install)
    (cd libgcrypt-1.8.5 && ./configure --prefix="$PREFIX" && make install)
    (cd libksba-1.3.5 && ./configure --prefix="$PREFIX" && make install)
    (cd libassuan-2.5.3 && ./configure --prefix="$PREFIX" && make install)
    (cd ntbtls-0.1.2 && ./configure --prefix="$PREFIX" && make install)
    (cd npth-1.6 && ./configure --prefix="$PREFIX" && make install)
    (cd gnupg-2.2.17 && ./configure --prefix="$PREFIX" && make install)
}


send-me-an-encrypted-message(){

    # If you are me, then setup a temporary GPG home directory so we are
    # working in a clean environment for testing
    TEMP_WORKDIR=$HOME/tmp/gpg-spawning-pool
    mkdir -p "$TEMP_WORKDIR"
    export GNUPGHOME=$TEMP_WORKDIR
    cd "$TEMP_WORKDIR"

    RECPIENT_FINGERPRINT=4AC8B478335ED6ED667715F3622BE571405441B4
    gpg --recv-keys --keyserver hkps://keyserver.ubuntu.com $RECPIENT_FINGERPRINT
    echo $RECPIENT_FINGERPRINT

    # Write your secret message in plain text in a file.
    SECRET_TEXT_FPATH=secret-plain-text.txt
    echo "
    hello world, super secret message
    Make it as long as you'd like
    " > $SECRET_TEXT_FPATH

    # Now encrypt the plain text using my public gpg key (only I will be able
    # to decrypt it)
    ENCRYPTED_FPATH=encrypted-message.asc
    # Unless you have marked my public key as trusted  (i.e. you are sure that
    # it came from me) you will be warned. You can say yes, unless you think
    # this message might have been modified by a man in the middle.
    gpg --output $ENCRYPTED_FPATH --encrypt --armor --recipient $RECPIENT_FINGERPRINT  $SECRET_TEXT_FPATH
    cat $ENCRYPTED_FPATH

    # now send the contents of "encrypted-message.asc" over a plain text channel

    ####
    # Now on my end, I will decrypt

    # Test that the recpiant can read it (this also should verify the sender)
    # Its not possible to verify a message without decrypting it
    ENCRYPTED_FPATH=code.asc
    DECRYPT_FPATH=decrypted-message.txt
    gpg --decrypt --output $DECRYPT_FPATH $ENCRYPTED_FPATH
    cat decrypted-message.txt
}


autoconfigure_local_git_autosign(){
    __heredoc_="
    It should be possible to run this in a repo and have it 'just work' as long as

    (1) you have enabled push authentication via ssh keys
    (2) you have a have an ssh key registered with the git-remote
    (3) that ssh key uses the same email as your gpg key (which should always be the case)
    "

    git config --local --list | grep "gpg\|sign\|email"

    # First find which remote URL we are pushing to
    REMOTE_URL=$(git remote -v | grep push | cut -d$'\t' -f2 | cut -d" " -f1)
    echo "REMOTE_URL = $REMOTE_URL"

    # List ssh identities
    #ssh-add -L

    # Use verbose ssh to determine which identity is being used to connect to a remote
    #GIT_SSH_COMMAND="ssh -v" git ls-remote $REMOTE_URL
    #GIT_SSH_COMMAND="ssh -v" git ls-remote $REMOTE_URL 2>&1 >/dev/null | grep "identity file"

    GIT_SSH_COMMAND="ssh -v" git ls-remote "$REMOTE_URL" 2> /tmp/my_ssh_stderr_file
    PUBLIC_KEY_LINE=$(cat /tmp/my_ssh_stderr_file | grep "Offering public key")
    PUBLIC_KEY_LINE=$(python -c "print(chr(10).join([x for x in open('/tmp/my_ssh_stderr_file').read().split('\n') if 'identity file' in x][0:1]))")
    # note sure why a regular grep doesn't work
    #PUBLIC_KEY_LINE="$(cat /tmp/my_ssh_stderr_file | grep --color=never "identity file" | head -n1 | xargs)"
    # Parse the path to the private key
    PRIVATE_KEY_FPATH=$(echo "$PUBLIC_KEY_LINE" | cut -d" " -f 4)
    # hack to find public key (not sure how robust this is)
    PUBLIC_KEY_FPATH="${PRIVATE_KEY_FPATH}.pub"
    PUBLIC_KEY_EMAIL=$(cat "$PUBLIC_KEY_FPATH" | cut -d" " -f3)

    # We found the public key email
    echo "
    REMOTE_URL = $REMOTE_URL
    PUBLIC_KEY_LINE = '${PUBLIC_KEY_LINE}'
    PRIVATE_KEY_FPATH = '$PRIVATE_KEY_FPATH'
    PUBLIC_KEY_FPATH = ${PUBLIC_KEY_FPATH}
    PUBLIC_KEY_EMAIL = $PUBLIC_KEY_EMAIL
    "

    # Find the key-id corresponding to that email
    KEYID=$(gpg --list-keys --keyid-format LONG "$PUBLIC_KEY_EMAIL" | head -n 2 | tail -n 1 | awk '{print $1}' | tail -c 9)
    echo "KEYID = '$KEYID'"

    UserEmail="$PUBLIC_KEY_EMAIL"
    echo "UserEmail = $UserEmail"

    # https://help.github.com/en/articles/signing-commits
    git config --local commit.gpgsign true
    # Note the GPG key needs to match the email
    git config --local user.email "$UserEmail"
    # Tell git which key to sign
    git config --local user.signingkey "$KEYID"

    git config --global --list | grep "gpg\|sign\|email"
    git config --local --list | grep "gpg\|sign\|email"
}
