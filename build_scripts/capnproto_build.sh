code
python -c "import utool as ut; ut.grab_zipped_url('https://capnproto.org/capnproto-c++-0.4.1.tar.gz', download_dir='.')"
cd capnproto-c++-0.4.1

sh -c "./configure"
sh -c "make -j6 check"


# mingw-get.exe

mingw32-make
