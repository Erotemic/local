export NCPUS=$(grep -c ^processor /proc/cpuinfo)


cd ~/tmp
#export HDF5_VER_MAJOR=19
#export HDF5_VER_MINOR=1.9.72
#wget ftp://ftp.hdfgroup.uiuc.edu/pub/outgoing/hdf5/snapshots/v$HDF5_VER_MAJOR/hdf5-$HDF5_VER_MINOR.tar.gz
#tar -zxvf hdf5-$HDF5_VER_MINOR.tar.gz
svn co http://svn.hdfgroup.uiuc.edu/hdf5/trunk
mv trunk hdf5_src
cd hdf5_src
#cd hdf5-$HDF5_VER_MINOR



export CPPFLAGS="$CPPFLAGS -I/usr/lib/openmpi/include/"
./configure --enable-parallel --enable-shared --with-pic --with-default-api-version=v16 --with-gnu-ld --prefix=$HOME/usr --libdir=$HOME/usr/lib$CLUSTER --bindir=$HOME/usr/bin$CLUSTER 
make -j$NCPUS

remove_hdf5()
{
    rm -rf ~/usr/include/H5* ~/usr/include/hdf5* ~/usr/lib/libhdf5* ~/usr/bin/h5*
}
