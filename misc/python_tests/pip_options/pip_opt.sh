

# SPECIFYING ROOT SEEMS TO DO NOTHING TO INSTALL OF PACKAGE
# IN VENV CASES INSTALL TO VENV
pip install --root $HOME/local/misc/python_tests/pip_options/root -e .
pip install --root $HOME/local/misc/python_tests/pip_options/root file://subdir#egg=testpkg


# OUTSIDE VENV: makes ./root/usr/local/lib/python3.5/dist-packages/testpkg
pip install --root $HOME/local/misc/python_tests/pip_options/root ./subdir
# INSIDE VENV: makes ./root/home/joncrall/venv3/... 
pip install --root $HOME/local/misc/python_tests/pip_options/root ./subdir


# OUTSIDE VENV: makes ./root/usr/local/lib/python3.5/dist-packages/testpkg
pip install --target $HOME/local/misc/python_tests/pip_options/target ./subdir
# INSIDE VENV: does the same thing. (VERY GOOD)
pip install --target $HOME/local/misc/python_tests/pip_options/target ./subdir

# OUTSIDE VENV: FAILS
pip install --target $HOME/local/misc/python_tests/pip_options/target -e ./subdir
# INSIDE VENV: FAILS
pip install --target $HOME/local/misc/python_tests/pip_options/target -e ./subdir


# OUTSIDE VENV: makes prefix/lib/python3.5/site-packages/testpkg
pip install --install-option="--prefix=$HOME/local/misc/python_tests/pip_options/prefix" ./subdir
# INSIDE VENV: same thing (VERY GOOD)
pip install --install-option="--prefix=$HOME/local/misc/python_tests/pip_options/prefix" ./subdir


# THE FOLLOWING WILL FAIL UNLESS YOU ADD TO YOUR PYTHON PATH (to support .pth files)
export PYTHONPATH=$PYTHONPATH:$HOME/local/misc/python_tests/pip_options/prefix/lib/python3.5/site-packages

# OUTSIDE VENV: MAKES prefix/lib/python3.5/site-packages/testpkg.egg-link
pip install --install-option="--prefix=$HOME/local/misc/python_tests/pip_options/prefix" -e ./subdir
# INSIDE VENV: SAME THING (VERY VERY GOOD) 
pip install --install-option="--prefix=$HOME/local/misc/python_tests/pip_options/prefix" -e ./subdir



# CLEANING
rm -rf target/testpkg*
rm -rf prefix/lib*
rm -rf subdir/testpkg.egg-info/

pip uninstall testpkg


#pip install ./subdir
#pip install -e subdir

#pip install --target $HOME/local/misc/python_tests/pip_options/target -e .

#pip install --root=root file://${VIAME_PACKAGES_DIR}/testpkg\#egg=testpkg[postgres]

# TESTING
python -c "import testpkg.testmod; print(testpkg.__file__)"
python -c "import testpkg.testmod; print(testpkg.__file__)"
