

# SPECIFYING ROOT SEEMS TO DO NOTHING TO INSTALL OF PACKAGE
# IN VENV CASES INSTALL TO VENV
pip install --root $HOME/local/misc/python_tests/pip_options/root -e .

pip install --root $HOME/local/misc/python_tests/pip_options/root file://testpkg

pip install --target $HOME/local/misc/python_tests/pip_options/target -e .

pip install --root=root file://${VIAME_PACKAGES_DIR}/testpkg\#egg=testpkg[postgres]


python -c "import testpkg.testmod; print(testpkg.__file__)"
pip uninstall testpkg

python -c "import testpkg.testmod; print(testpkg.__file__)"
