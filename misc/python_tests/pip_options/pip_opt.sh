

# SPECIFYING ROOT SEEMS TO DO NOTHING TO INSTALL OF PACKAGE
# IN VENV CASES INSTALL TO VENV
pip install --root $HOME/local/misc/python_tests/pip_options/root -e .

pip install --root $HOME/local/misc/python_tests/pip_options/root file://subdir#egg=testpkg
pip install file://subdir#egg=testpkg


# INSIDE VENV: make a home/joncrall/venv3/... inside of the root dir (not good)
pip install --root $HOME/local/misc/python_tests/pip_options/root ./subdir
# OUTSIDE VENV: make a home/joncrall/venv3/... inside of the root dir (not good)
pip install --root $HOME/local/misc/python_tests/pip_options/root ./subdir

pip install ./subdir
pip install -e subdir

pip install --target $HOME/local/misc/python_tests/pip_options/target -e .

pip install --root=root file://${VIAME_PACKAGES_DIR}/testpkg\#egg=testpkg[postgres]


python -c "import testpkg.testmod; print(testpkg.__file__)"
pip uninstall testpkg

python -c "import testpkg.testmod; print(testpkg.__file__)"
