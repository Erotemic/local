export NCPUS=$(grep -c ^processor /proc/cpuinfo)
sudo apt-get install build-essentials bzip2 curl
sudo apt-get install ssh expat zlib1g zlib1g-dev tk

cd ~/code
git clone https://github.com/git/git.git

make
make install

#make configure
#./configure --prefix=/usr/local
#make all doc

#         Git installation
# 
# Normally you can just do "make" followed by "make install", and that
# will install the git programs in your own ~/bin/ directory.  If you want
# to do a global install, you can do
# 
#     $ make prefix=/usr all doc info ;# as yourself
#     # make prefix=/usr install install-doc install-html install-info ;# as root
# 
# (or prefix=/usr/local, of course).  Just like any program suite
# that uses $prefix, the built results have some paths encoded,
# which are derived from $prefix, so "make all; make prefix=/usr
# install" would not work.
# 
# The beginning of the Makefile documents many variables that affect the way
# git is built.  You can override them either from the command line, or in a
# config.mak file.
# 
# Alternatively you can use autoconf generated ./configure script to
# set up install paths (via config.mak.autogen), so you can write instead
# 
#     $ make configure ;# as yourself
#     $ ./configure --prefix=/usr ;# as yourself
#     $ make all doc ;# as yourself
#     # make install install-doc install-html;# as root
# 
# If you're willing to trade off (much) longer build time for a later
# faster git you can also do a profile feedback build with
# 
#     $ make prefix=/usr profile
#     # make prefix=/usr PROFILE=BUILD install
# 
# This will run the complete test suite as training workload and then
# rebuild git with the generated profile feedback. This results in a git
# which is a few percent faster on CPU intensive workloads.  This
# may be a good tradeoff for distribution packagers.
# 
# Alternatively you can run profile feedback only with the git benchmark
# suite. This runs significantly faster than the full test suite, but
# has less coverage:
# 
#     $ make prefix=/usr profile-fast
#     # make prefix=/usr PROFILE=BUILD install
# 
# Or if you just want to install a profile-optimized version of git into
# your home directory, you could run:
# 
#     $ make profile-install
# 
# or
#     $ make profile-fast-install
# 
# As a caveat: a profile-optimized build takes a *lot* longer since the
# git tree must be built twice, and in order for the profiling
# measurements to work properly, ccache must be disabled and the test
# suite has to be run using only a single CPU.  In addition, the profile
# feedback build stage currently generates a lot of additional compiler
# warnings.
