autoconfigure_local_git_autosign(){
    __heredoc_="
    Attempts to autoconfigure your local git repo to use the appropriate GPG
    signing key. This key must already exist.

    It should be possible to run this in a repo and have it 'just work' as long as

    (1) your private ssh and gpg keys are registered with your local ssh and gpg agent.
    (2) you have enabled push authentication via ssh keys
    (3) you have a have an ssh key registered with the git-remote
    (4) you have a have an gpg key registered with the git-remote
    (5) that ssh key uses the same email as your gpg key (which should always be the case)
    "

    echo " --- Begin AutoConfigure GPGSign --- "

    git config --local --list | grep "gpg\|sign\|email"

    # First find which remote URL we are pushing to
    REMOTE_URL=$(git remote -v | grep push | cut -d$'\t' -f2 | cut -d" " -f1)
    echo "REMOTE_URL = $REMOTE_URL"

    # List ssh identities
    #ssh-add -L

    # Use verbose ssh to determine which identity is being used to connect to a remote
    #GIT_SSH_COMMAND="ssh -v" git ls-remote $REMOTE_URL 
    #GIT_SSH_COMMAND="ssh -v" git ls-remote $REMOTE_URL 2>&1 >/dev/null | grep "identity file"

    GIT_SSH_COMMAND="ssh -v" git ls-remote $REMOTE_URL 2> /tmp/my_ssh_stderr_file
    PUBLIC_KEY_LINE=$(cat /tmp/my_ssh_stderr_file | grep "Offering public key")
    PUBLIC_KEY_LINE=$(python -c "print(chr(10).join([x for x in open('/tmp/my_ssh_stderr_file').read().split('\n') if 'identity file' in x][0:1]))")
    # note sure why a regular grep doesn't work
    #PUBLIC_KEY_LINE="$(cat /tmp/my_ssh_stderr_file | grep --color=never "identity file" | head -n1 | xargs)"
    # Parse the path to the private key
    PRIVATE_KEY_FPATH=$(echo "$PUBLIC_KEY_LINE" | cut -d" " -f 4)
    # hack to find public key (not sure how robust this is)
    PUBLIC_KEY_FPATH="${PRIVATE_KEY_FPATH}.pub"
    PUBLIC_KEY_EMAIL=$(cat $PUBLIC_KEY_FPATH | cut -d" " -f3)

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
    git config --local user.email $UserEmail
    # Tell git which key to sign
    git config --local user.signingkey $KEYID

    echo "
    CURRENT GLOBAL SETTINGS"
    git config --global --list | grep "gpg\|sign\|email"

    echo "
    CURRENT LOCAL SETTINGS"
    git config --local --list | grep "gpg\|sign\|email"
}


autoconfigure_local_git_autosign
