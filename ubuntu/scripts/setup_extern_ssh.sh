cd ~/.ssh
ssh-keygen

# TODO Find a way to get the right public keys
echo " " >> authorized_keys

chmod 644 authorized_keys
