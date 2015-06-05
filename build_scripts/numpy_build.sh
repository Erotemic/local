code 
git clone git@github.com:numpy/numpy.git
cd numpy
# Refernces:
# http://docs.scipy.org/doc/numpy/user/install.html

python setup.py build -j 4 --fcompiler=gnu95 
python3 setup.py build -j 4 --fcompiler=gnu95 
install 
