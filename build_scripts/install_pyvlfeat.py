# Cleanup 
sudo pip uninstall pyvlfeat
sudo rm -rf /tmp/pip-build-root/pyvlfeat
sudo rm -rf /tmp/pip-build-joncrall/pyvlfeat

# Download
sudo pip install pyvlfeat --no-install --force-reinstall

# Change LinkArgs -lboost_python-mt-py26 to -lboost_python-mt-py27
sudo sed s/26/27/g /tmp/pip-build-root/pyvlfeat/setup.py > ~joncrall/sed_out
sudo mv ~joncrall/sed_out /tmp/pip-build-root/pyvlfeat/setup.py

sudo pip install pyvlfeat --no-download --force-reinstall


# http://askubuntu.com/questions/123546/usr-bin-ld-cannot-find-lboost-python-mt-error-when-installing-pycuda-2011-2
# get lboost_python-mt-27

#sudo apt-get install build-essential python-dev python-setuptools libboost-python-dev libboost-thread-dev -y

#python setup.py install

#LinkArgs = ['-msse', '-shared', '-lboost_python-mt-py27']
