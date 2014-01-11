# if running bash
#if [ -n "$BASH_VERSION" ]; then
    ## include .bashrc if it exists
    #if [ -f "$HOME/.bashrc" ]; then
	#. "$HOME/.bashrc"
    #fi
#fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

#http://stackoverflow.com/questions/7031126/switching-between-gcc-and-clang-llvm-using-cmake
#export CC=/usr/local/bin/clang
#export CXX=/usr/local/bin/clang++
#alias cmake="cmake -DCMAKE_USER_MAKE_RULES_OVERRIDE=~/local/ClangOverrides.txt -D_CMAKE_TOOLCHAIN_PREFIX=llvm-"
 
alias explorer=nautilus
alias start=nautilus
alias cmd=bash


alias gvim=gvim_ubuntu_hack 
gvim_ubuntu_hack()
{
    /usr/bin/gvim -f $@ 2> /dev/null &
}

export SITE_PACKAGES=/usr/local/lib/python2.7/dist-packages/

alias resetftp='/etc/init.d/vsftpd restart'
alias noip='/usr/local/bin/noip2'


alias say='espeak -v en '


#alias sumatrapdf='wine "C:\Program Files (x86)\SumatraPDF\SumatraPDF"'
alias diskutility='palimpsest'
alias realrm='/bin/rm'
alias rm='trash-put'

alias viewimage='eog'

source ~/scripts/install_llvm.sh
