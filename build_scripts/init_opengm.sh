#git clone https://github.com/opengm/opengm.git
#git clone https://github.com/ukoethe/vigra.git

sudo apt-get install sphinxsearch -y
sudo apt-get install mysql-server -y
#pip install sphinx
#sudo apt-get install glpk -y
sudo apt-get install -y libhdf5-serial-dev
sudo apt-get install -y libhdf5-openmpi-dev
#h5cc -showconfig
sudo apt-get install hdf5-tools


# Get newest boost
sudo add-apt-repository ppa:boost-latest/ppa
sudo apt-get update


first_exists()
{
    for dpath in $@; do
        if [ -d "$dpath" ]; then
            echo $dpath
            break
        fi
    done
}


install_vigra()
{

    export PYEXE=$(which python2.7)
    export PYTHON_EXECUTABLE=$($PYEXE -c "import sys; print(sys.executable)")
    if [[ "$VIRTUAL_ENV" == ""  ]]; then
        export LOCAL_PREFIX=/usr/local
        export _SUDO="sudo"
    else
        export LOCAL_PREFIX=$($PYEXE -c "import sys; print(sys.prefix)")/local
        export _SUDO=""
    fi
    #sudo chown -R $USER:$USER ~/code/vigra/build

    CMAKE_OPTS=""
    CMAKE_OPTS="$CMAKE_OPTS -DCMAKE_INSTALL_PREFIX=$LOCAL_PREFIX"
    echo $CMAKE_OPTS

    # Vision with Generic Algorithms
    cd ~/code
    git clone https://github.com/ukoethe/vigra.git
    mkdir -p ~/code/vigra/build
    cd ~/code/vigra/build


    cmake $CMAKE_OPTS ..
    make -j9
    $_SUDO make install

    # HACK
    sed -i '60s/.*/    if (0)/' ../config/FindVIGRANUMPY_DEPENDENCIES.cmake 

    #sudo mv /usr/local/lib/python2.7/site-packages/vigra $VIRTUAL_ENV/lib/python2.7/site-packages/
    #sudo mv $LOCAL_PREFIX/../lib/python2.7/site-packages/vigra $VIRTUAL_ENV/lib/python2.7/site-packages/
    #HDF5_INCLUDE_DIR=first_exists '/usr/include/hdf5/serial' '/usr/include' 
    #CMAKE_OPTS="$CMAKE_OPTS -DHDF5_INCLUDE_DIR=$HDF5_INCLUDE_DIR"
    #sudo chown -R $USER:$USER $VIRTUAL_ENV/lib/python2.7/site-packages/vigra

    ln -s $VIRTUAL_ENV/lib/libvigraimpex.so $VIRTUAL_ENV/lib/python2.7/site-packages/vigra/libvigraimpex.so
    ln -s $VIRTUAL_ENV/lib/libvigraimpex* $VIRTUAL_ENV/lib/python2.7/site-packages/vigra/
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$VIRTUAL_ENV/lib
    python -c "import vigra"
    #pip install pyVIGRA
}


install_opengm()
{
    co
    # http://hci.iwr.uni-heidelberg.de/opengm2/
    # http://www-304.ibm.com/ibm/university/academic/pub/page/ban_prescriptive_analytics?
    cd ~/code
    git clone https://github.com/opengm/opengm.git
    cd ~/code/opengm/
    mkdir -p ~/code/opengm/build
    cd ~/code/opengm/build

    export PYEXE=$(which python2.7)
    if [[ "$VIRTUAL_ENV" == ""  ]]; then
        export LOCAL_PREFIX=/usr/local
        export _SUDO="sudo"
    else
        export LOCAL_PREFIX=$($PYEXE -c "import sys; print(sys.prefix)")/local
        export _SUDO=""
    fi
    #CMAKE_OPTS=""
    #CMAKE_OPTS="$CMAKE_OPTS -DPYTHON_EXECUTABLE=$PYEXE" 
    #CMAKE_OPTS="$CMAKE_OPTS -DCMAKE_CXX_FLAGS=-std=c++0x" 
    #CMAKE_OPTS="$CMAKE_OPTS -DWITH_BOOST=On -DWITH_HDF5=On -DBUILD_PYTHON_WRAPPER=On"
    #CMAKE_OPTS="$CMAKE_OPTS -DWITH_CPLEX=On -DWITH_OPENMP=On"
    #CMAKE_OPTS="$CMAKE_OPTS -DWITH_MAXFLOW=On -DWITH_MPLP=On -DWITH_MRF=On -DWITH_MAXFLOW_IBFS=On"
    #CMAKE_OPTS="$CMAKE_OPTS -DWITH_AD3=On -DWITH_QPBO=On -DWITH_TRWS=On -DWITH_GCO=On -DWITH_CONICBUNDLE=On"
    #CMAKE_OPTS="$CMAKE_OPTS -DBUILD_EXAMPLES=Off -DWITH_PLANARITY=Off -DWITH_SRMP=Off -DWITH_BLOSSOM5=Off  -DWITH_DAOOPT=Off"
    #CMAKE_OPTS="$CMAKE_OPTS -DBUILD_TESTING=Off -DBUILD_TUTORIALS=Off"
    #echo $CMAKE_OPTS

    CMAKE_OPTS=""
    CMAKE_OPTS="$CMAKE_OPTS -DPYTHON_EXECUTABLE=$PYEXE" 
    CMAKE_OPTS="$CMAKE_OPTS -DCMAKE_CXX_FLAGS=-std=c++0x\ -Wno-cpp" 
    CMAKE_OPTS="$CMAKE_OPTS -DWITH_BOOST=On -DWITH_HDF5=On -DBUILD_PYTHON_WRAPPER=On"
    CMAKE_OPTS="$CMAKE_OPTS -DWITH_CPLEX=On -DWITH_OPENMP=Off"
    CMAKE_OPTS="$CMAKE_OPTS -DWITH_MAXFLOW=Off -DWITH_MPLP=Off -DWITH_MRF=Off -DWITH_MAXFLOW_IBFS=Off"
    CMAKE_OPTS="$CMAKE_OPTS -DWITH_AD3=Off -DWITH_QPBO=Off -DWITH_TRWS=Off -DWITH_GCO=Off -DWITH_CONICBUNDLE=Off"
    CMAKE_OPTS="$CMAKE_OPTS -DBUILD_EXAMPLES=Off -DWITH_PLANARITY=Off -DWITH_SRMP=Off -DWITH_BLOSSOM5=Off  -DWITH_DAOOPT=Off"
    CMAKE_OPTS="$CMAKE_OPTS -DBUILD_TESTING=Off -DBUILD_TUTORIALS=Off"
    echo $CMAKE_OPTS

    rm CMakeCache.txt
    cmake $CMAKE_OPTS -DCMAKE_INSTALL_PREFIX=$LOCAL_PREFIX ..

    make externalLibs
    make -j9

    $_SUDO make install

    #-DLIBDAI_INCLUDE_DIR=~/code/libDAI/include
    #-DLIBDAI_LIBRARY=~/code/libDAI/lib/libdai.a
    #mkdir build
    #cd build
    #cmake -G "Unix Makefiles" -DWITH_BOOST=TRUE -DWITH_HDF5=TRUE -DWITH_AD3=FALSE -DWITH_TRWS=FALSE  -DWITH_QPBO=FALSE -DWITH_MRF=FALSE -DBUILD_PYTHON_WRAPPER=TRUE ..
    #make -j$NCPUS || { echo "FAILED MAKE" ; exit 1; }
    #sudo make install

    #CMAKE_OPTS="$CMAKE_OPTS -DPYTHON_EXECUTABLE=$PYTHON_EXECUTABLE -DPYTHON_LIBRARY=$PYTHON_LIBRARY" 
    #CMAKE_OPTS="$CMAKE_OPTS -DPYTHON_INCLUDE_DIR=$PYTHON_INCLUDE_DIR"
    #export PYEXE=$(which python2.7)
    #export PYTHON_EXECUTABLE=$($PYEXE -c "import sys; print(sys.executable)")
    #export PYTHON_PREFIX=$($PYEXE -c "import sys; print(sys.prefix)")
    #export PYTHON_LIBRARY=/usr/lib/x86_64-linux-gnu/libpython2.7.so
    #export PYTHON_INCLUDE_DIR=$VIRTUAL_ENV/include/python2.7
    #export PYTHON_LIBRARY=$($PYEXE -c "import utool; print(utool.get_system_python_library())")
    #python -c "import utool; print(utool.get_system_python_library())"

    # Hack into virtualenv
    #rm -rf $VIRTUAL_ENV/lib/python2.7/site-packages/opengm
    #sudo mv /usr/local/lib/python2.7/site-packages/opengm $VIRTUAL_ENV/lib/python2.7/site-packages/
    #sudo chown -R $USER:$USER $VIRTUAL_ENV/lib/python2.7/site-packages/opengm

    python -c "import opengm"
    python -c "import opengm; print(opengm.inference.Multicut)"
    python -c "import opengm, utool; print(utool.get_func_sourcecode(opengm.PottsGFunction.__repr__))"

    # ~/code/opengm/src/interfaces/python/opengm/opengmcore/function_injector.py
    #cat /home/joncrall/code/opengm/build/src/interfaces/python/opengm/opengmcore/function_injector.py
    #cat /home/joncrall/venv/local/lib/python2.7/site-packages/opengm/opengmcore/function_injector.py

    # Uninstall
    sudo rm -rf /usr/local/include/opengm
    sudo rm -rf /usr/local/lib/python2.7/site-packages/opengm 

    # Info
    python -m utool.util_dev --exec-search_module --show --mod=opengm --pat=multi
    python -m utool.util_dev --exec-search_module --show --mod=opengm --pat=bayes
    python -m utool.util_dev --exec-search_module --show --mod=opengm --pat=net

    # Libdai
    sudo apt-get install g++ make doxygen graphviz libboost-dev libboost-graph-dev libboost-program-options-dev libboost-test-dev -y
    sudo apt-get install libgmp-dev -y
    sudo apt-get install cimg-dev -y
    
    co
    git clone https://github.com/dbtsai/libDAI.git
    cp Makefile.LINUX Makefile.conf
    make -j7
}

install_cplex()
{
    sudo apt-get install openjdk-7-jre -y
    sudo apt-get install openjdk-7-jdk -y
    cd ~/Downloads
    # Need to get an acount and licence from IBM
    # http://www.maplesoft.com/support/faqs/detail.aspx?sid=35272
    # https://www-01.ibm.com/marketing/iwm/iwm/web/reg/signup.do?source=ESD-ILOG-OPST-EVAL&S_TACT=M161008W&S_CMP=web_ibm_ws_ilg-opt_bod_cospreviewedition-ov&lang=en_US&S_PKG=CRY7XML
    export PS1=">"
    chmod +x COSCE1262LIN64.bin.bin
    sudo ./COSCE1262LIN64.bin.bin 
    scp ~/Downloads/COSCE1262LIN64.bin.bin joncrall@lev.cs.rpi.edu:Downloads
    # Silent Installation: 
    # -r "./myresponse.properties"
    #INSTALLER_UI silent 
    #LICENSE_ACCEPTED true
    #INSTALLER_LOCALE en	
    #USER_INSTALL_DIR /opt/
    # http://www-01.ibm.com/support/knowledgecenter/SSSA5P_12.6.3/ilog.odms.studio.help/Optimization_Studio/topics/td_silent_install.html
    # Follow instructions to install into /opt/ibm

    /opt/ibm/ILOG/CPLEX_Studio_Community1263/cplex/bin/x86-64_linux
    /opt/ibm/ILOG/CPLEX_Studio_Community1263/concert/lib/x86-64_linux/static_pic

    export CPLEX_PREFIX=/opt/ibm/ILOG/CPLEX_Studio_Community1263
    export PATH=$PATH:$CPLEX_PREFIX/cplex/bin/x86-64_linux/
    export PATH=$PATH:$CPLEX_PREFIX/opl/oplide/
    export PATH=$PATH:$CPLEX_PREFIX/cplex/include/
    export PATH=$PATH:$CPLEX_PREFIX/opl/include/
    export PATH=$PATH:$CPLEX_PREFIX/opl/

    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$CPLEX_PREFIX/cplex/lib/x86-64_linux/static_pic
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$CPLEX_PREFIX/cplex/bin/x86-64_linux/
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$CPLEX_PREFIX/opl/bin/x86-64_linux
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$CPLEX_PREFIX/opl/lib/x86-64_linux/static_pic
}

install_gurobi(){
    cd ~/Downloads

    sudo cp gurobi6.5.0_linux64.tar.gz /opt/
    cd /opt
    sudo chmod -R 755 gurobi6.5.0_linux64.tar.gz
    sudo tar xvfz gurobi6.5.0_linux64.tar.gz 
    sudo chmod -R 777 /opt/gurobi650
    cd /opt/gurobi650/linux64
    python setup.py install
    # setup bashrc

    export PATH=$PATH:/opt/gurobi650/linux64/bin
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/gurobi650/linux64/lib

    rrr
    cd
    python -c "import gurobipy; print(gurobipy.__file__)"

    grbgetkey xxxxxxxxxxx

    sudo updatedb
    locate gurobipy

    cd ~/venv/local/lib/python2.7/site-packages/gurobipy/

    # UNINSTALL
    echo $VIRTUAL_ENV
    sudo rm -rf $VIRTUAL_ENV/lib/python2.7/site-packages/gurobipy
    sudo rm -rf /lib/python2.7/site-packages/gurobipy
}


