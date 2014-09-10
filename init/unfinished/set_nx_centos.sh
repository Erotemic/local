sudo yum install nx freenx 

cd /etc/nxserver
sudo cp node.conf.sample node.conf 

nxserver --adduser jonathan 

cat > node.conf <<EOF
ENABLE_USERMODE_AUTHENTICATION="1"
ENABLE_PASSDB_AUTHENTICATION="1"
ENABLE_SSH_AUTHENTICATION="1"
EOF


#screen
#/etc/init.d/sshd restart 
