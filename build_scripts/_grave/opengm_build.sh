#git clone https://github.com/opengm/opengm.git
cd opengm
python2.7 -c "import utool as ut; print('keeping build dir' if ut.get_argflag('--no-rmbuild') else ut.delete('build'))" $@

mkdir build
cd build

cmake -G "Unix Makefiles" -DWITH_BOOST=TRUE -DWITH_HDF5=TRUE -DWITH_AD3=FALSE -DWITH_TRWS=FALSE  -DWITH_QPBO=FALSE -DWITH_MRF=FALSE -DBUILD_PYTHON_WRAPPER=TRUE ..
make -j$NCPUS || { echo "FAILED MAKE" ; exit 1; }
sudo make install
