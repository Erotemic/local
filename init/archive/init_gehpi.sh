#wget https://launchpad.net/gephi/0.8/0.8.2beta/+download/gephi-0.8.2-beta.tar.gz
#wget https://launchpad.net/gephi/toolkit/toolkit-0.8.7/+download/gephi-toolkit-0.8.7-all.zip
#mv gephi-0.8.2-beta.tar.gz

cd ~/tmp
unzip gephi-toolkit-0.8.7-all.zip



jython -Dpython.path=gephi-toolkit.jar

sudo add-apt-repository ppa:rockclimb/gephi-daily


cd Downloads

sudo apt-get install jython
