# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

# Unix aliases

alias pytree='tree -P "*.py" --dirsfirst'
alias ls='ls --color --human-readable --group-directories-first --hide="*.pyc" --hide="*.pyo"'
alias pygrep='grep -r --include "*.py"'
alias clean_python='find . -iname *.pyc -delete & find . -iname *.pyo -delete'

# watch with a higher frequency
alias watch='watch -n .5'

#alias cgrep='grep -I --exclude-dir "*build*" --exclude-dir .git -ER'
alias cgrep='grep -I -ER \
    --exclude-dir "*build*" \
    --exclude-dir .git \
    --exclude-dir .pytest_cache \
    --exclude-dir htmlcov \
    --exclude "*.dot*" \
    --exclude "*.rst*" \
    --exclude "*.html*" \
    --exclude "*.css*" \
    --exclude "*.pipe*" \
    --exclude "*.zip*" \
    --exclude "*.pkl*" \
    --exclude "*.pyc*" \
    --exclude "*.so*" \
    --exclude "*.o*" \
    --exclude "*.coverage*" \
    --exclude "tags"'


#alias cgrep='grep -I --exclude-dir "*build*" --exclude-dir .git -ER'
alias cmakecache_grep='grep -I -ER --exclude-dir .git --include "CMakeCache.txt"'

fzfind()
{
    #find . -iname "*$1*"
    #find . -type d \( -path "./build*" -o -path builds \) -prune -o -iname "*$1*"
    python -c "$(codeblock "
    import sys
    import os
    from fnmatch import fnmatch
    from os.path import join

    exclude = ['build*', '.git']
    patterns = ['*' + p + '*' for p in sys.argv[1:]]

    def imatches(patterns, strings):
        for item in strings:
            item = item.lower()
            if any(fnmatch(item, pat) for pat in patterns):
                yield item

    for root, dirs, files in os.walk('.'):
        # Prune any directory matching the bad pattern
        to_remove = [dx for dx, dname in enumerate(dirs) 
                     if any(fnmatch(dname, pat) for pat in exclude)]
        for dx in reversed(to_remove):
            del dirs[dx]

        # print any paths matching the name
        for dname in imatches(patterns, dirs):
            print(join(root, dname))
        for fname in imatches(patterns, files):
            print(join(root, fname))
    ")" "$@"
}

#clean_python(){
#    # Recursively delete compiled python files
#    find . -iname *.pyc -delete
#    find . -iname *.pyo -delete
#}
#find . | grep -E "(__pycache__|\.pyc|\.pyo$)" | xargs rm -rf

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias psu='ps -o uname:20,pid,pcpu,pmem,time,cmd'
alias utarbz2='tar jxf'
alias unzip-tar-gz='tar xvzf '
alias unzip-tar-bz='tar xvjf '
alias unzip-tar='tar xvf '
#ipython --pdb -c "%run report_results2.py --BOW --no-print-checks"

#x - extract
#v - verbose output (lists all files as they are extracted)
#j - deal with bzipped file
#f - read from a file, rather than a tape device

clean_latex()
{
    rm *.aux
    rm *.bbl
    rm *.brf 
    rm *.log 
    rm *.bak 
    rm *.blg 
    rm *.tips 
    rm *.synctex
    rm main.pdf
    rm main.dvi

    rm *.fdb_latexmk
    rm *.fls
    rm *.lof
    rm *.toc

    latexmk -c
}
alias ipy='ipython'
alias ipyk='ipython kernel'
#alias ipynb='ipython notebook'
alias pyl='pylint --disable=C'
alias pyf='pyflakes'
alias lls='ls -I *.aux -I *.bbl -I *.blg -I *.out -I *.log -I *.synctex'
pdbpython()
{
    ipython --pdb -c "\"%run $@\""
}
#Find and replace in dir
search_replace_dir()
{
    echo find ./ -type f -exec sed -i "s/$1/$2/g" {} \;
}
# Download entire webpage
alias wget_all='wget --mirror --no-parent'
# Convert images
alias png2jpg='for f in *.png; do ffmpeg -i "$f" "${f%.png}.jpg"; done'

hyrule_get(){
    git clone git@hyrule.cs.rpi.edu:$1
}
alias hyrule='hyrule.sh'

# General navigation
alias home='cd ~'
alias data='cd ~/data'
alias loc='cd ~/local'
alias lc='cd ~/local'
alias mi='cd ~/misc'
alias vf='cd ~/local/vim/vimfiles'
alias vfb='cd ~/local/vim/vimfiles/bundle'
alias lb='cd ~/latex/crall-lab-notebook/'
alias lt='cd ~/latex/'
alias ca='cd ~/latex/crall-thesis-2017/'
alias ic='cd ~/latex/crall-iccvw-2017/'
alias scr='cd ~/scripts'
# Special navigation
alias code='cd $CODE_DIR'
alias co='cd $CODE_DIR'
alias cl='cd $CODE_DIR/clab'
alias nh='cd $CODE_DIR/netharn'
alias clp='cd $CODE_DIR/clab-private'
alias ir='cd $CODE_DIR/irharn'
alias cv='cd $CODE_DIR/opencv'
#alias fl='cd $CODE_DIR/flann/'
alias fl='cd $CODE_DIR/fletch/'
alias flb='cd $CODE_DIR/fletch/build'
alias kw='cd $CODE_DIR/kwiver/'
alias kwb='cd $CODE_DIR/kwiver/build'
alias vi='cd $CODE_DIR/VIAME/'
alias vib='cd $CODE_DIR/VIAME/build'
alias vikw='cd $CODE_DIR/VIAME/packages/kwiver/'
alias sp='cd $CODE_DIR/VIAME/packages/kwiver/sprokit'
alias sseg='cd ~/sseg'
alias vikwb='cd $CODE_DIR/VIAME/build/build/src/kwiver-build/'
alias vikwi='cd /home/joncrall/code/VIAME/build/install/lib/python2.7/site-packages'
alias vicam='cd $CODE_DIR/VIAME/plugins/camtrawl/python'
#alias cv='cd $CODE_DIR/opencv3'
alias nx='cd $CODE_DIR/networkx'
alias hs='cd $CODE_DIR/ibeis/ibeis/algo/hots'
#alias gr='cd $CODE_DIR/ibeis/ibeis/algo/graph'
alias gr='cd $CODE_DIR/graphid'
alias smk='cd $CODE_DIR/ibeis/ibeis/algo/smk'
alias ju='cd ~/.config/ibeis_cnn/training_junction'
alias ib='cd $CODE_DIR/ibeis/'
alias gn='cd $CODE_DIR/Lasagne/'
alias sk='cd $CODE_DIR/scikit-learn/'
alias cn='cd $CODE_DIR/ibeis_cnn/'
alias db='cd ~/Dropbox/'
alias desk='cd ~/Desktop/'
alias dl='cd ~/Downloads/'
alias rf='cd $CODE_DIR/pyrf/'
#alias dt='cd $CODE_DIR/detecttools/'
alias dt='cd $CODE_DIR/dtool'
alias mtg='cd $CODE_DIR/mtgmonte/'

#python -c "import site; print(site.getusersitepackages())"
#python -c "import site; print(site.getsitepackages())"

# https://github.com/pypa/virtualenv/issues/355
# ['/usr/local/lib/python2.7/dist-packages', '/usr/lib/python2.7/dist-packages']
#alias pysite='cd $(python -c "import site; print(site.getsitepackages()[0])")'
alias pysite='cd $(python -c "import distutils.sysconfig; print(distutils.sysconfig.get_python_lib())")'
#alias vrc='cd $(python -c "import site; print(site.getsitepackages()[0]))"'


alias pydist='cd $CODE_DIR/pyrf/'

alias ya='cd $CODE_DIR/yael'
alias ub='cd $CODE_DIR/ubelt'
alias xo='cd $CODE_DIR/xdoctest'
alias ut='cd $CODE_DIR/utool'
alias uts='cd $CODE_DIR/utool/utool/util_scripts'
alias vt='cd $CODE_DIR/vtool'
alias gt='cd $CODE_DIR/guitool'
alias pt='cd $CODE_DIR/plottool'
alias fk='cd $CODE_DIR/ibeis-flukematch-module/'
alias ibi='cd $CODE_DIR/ibeis/ibeis'
alias ibc='cd $CODE_DIR/ibeis/ibeis/control'
alias ibv='cd $CODE_DIR/ibeis/ibeis/view'
alias iba='cd $CODE_DIR/ibeis/ibeis/algo'
alias ibs='cd $CODE_DIR/ibeis/ibeis/scripts'
#alias ibg='cd $CODE_DIR/graphid'
alias mk='cd $CODE_DIR/mkinit'
alias hes='cd $CODE_DIR/hesaff'
alias work='cd ~/work'
alias mtest='cd ~/work/PZ_MTEST/_ibsdb'
alias lnote='cd ~/latex/crall-lab-notebook'
alias cvp='cd ~/latex/crall-cvpr-15'
alias cvpr='cd ~/latex/crall-cvpr-15'

alias vdd='vd ~/work'
#alias ..="cd .."
#alias l='ls $LS_OPTIONS -lAhF'


# ROB
alias hskill='rob hskill'
alias nr='rob grepnr'
alias rgrep='rob grepnr'
alias rsc='rob research_clipboard None 3'
#alias rob='python $PORT_CODE/Rob/for f in *.png; do ffmpeg -i "$f" "${f%.png}.jpg"; done'
alias rob='python ~/local/rob/run_rob.py'
alias rls='rob ls'
alias er='gvim $prob'
alias v='gvim'
alias ebrc='gvim ~/.bashrc'
alias ea='gvim ~/local/homelinks/helpers/alias_helpers.sh'
alias emc='gvim ~/local/modulechanges.sh'
alias sbrc='source ~//local/homelinks/bashrc'
alias todo='gvim ~/Dropbox/Notes/TODO.txt'
alias ebs='gvim ~/local/build_scripts/'

# Edit Project
ep()
{
    #gvim
    wmctrl -a GVIM
    wmctrl -r GVIM -b "remove,maximized_vert,maximized_horz,fullscreen"
    wmctrl -r GVIM -e 0,1921,1,1220,1920
    wmctrl -r GVIM -b "add,maximized_vert,maximized_horz"
    #wmctrl -r ":ACTIVE:" -e 0,1920,0,100,100
    #wmctrl -r ":ACTIVE:" -b "remove,maximized_vert"
    #wmctrl -r ":ACTIVE:" -t 1  # move to desktop 1
}

hyhspull()
{
    echo "Pushing from Hyrule"
    #Outer quote = " (This marks the beginning and end of the string)
    #Inner quote = \" (Escaped as to not flag "beginning/end of string")
    #Third-tier quote = ' (Literal quote)
    #Fourth-tier quote = \' (Literal quote that will be generated as an escaped outer quote)
    ssh -t cralljp@linux.cs.rpi.edu "ssh -t joncrall@hyrule.cs.rpi.edu \"cd $CODE_DIR/hotspotter; git commit -am 'hyhs wip'; git push\""
    
    echo "Pulling from Local"
    git pull
}

# Reload profile
# FIXME if I work on a mac
#alias rrr='source ~/.profile'
alias rrr='source ~/.bashrc'
update_profile()
{
    pushd .
    loc
    git pull
    rrr
    popd
}
commit_profile()
{
    pushd .
    loc
    git commit -am "profile wip"
    git push
    popd
}
alias upp=update_profile
alias cop=commit_profile


cls()
{
    # References:
    # https://askubuntu.com/questions/25077/how-to-really-clear-the-terminal
    tput reset
    #for i in {1..100}
    #do
    #    echo ""
    #done
}


read_clip()
{
    xsel --clipboard < ~/clipboard.txt
}

utget()
{
    python -c "import utool; print(utool.grab_file_url(\"$@\", spoof=True))"
}

astyle_cpp()
{

    #'
    #--pad-oper, -p
    #      Insert  space  padding  around  operators.  Any end of line comments will remain in the
    #      original column, if possible. Note that there is no option to unpad. Once padded,  they
    #      stay padded.


    #   --add-brackets, -j
    #          Add brackets  to  unbracketed  one  line  conditional  statements  (e.g.  'if',  'for',
    #          'while'...).  The  statement  must  be  on  a  single line.  The brackets will be added
    #          according to the currently requested predefined style or bracket type. If no  style  or
    #          bracket  type is requested the brackets will be attached. If --add-one-line-brackets is
    #          also used the result will be one line brackets.
         
    #   --convert-tabs, -c
    #          Convert tabs to spaces in the non-indentation part of the line. The  number  of  spaces
    #          inserted  will  maintain the spacing of the tab. The current setting for spaces per tab
    #          is used. It may not produce the expected results if --convert-tabs is used when  chang‐
    #          ing spaces per tab. Tabs are not replaced in quotes.
              
    #   --max-code-length=#, -xC#
    #   --break-after-logical, -xL
    #          The  option  --max\[u2011]code\[u2011]length  will  break  a line if the code exceeds #
    #          characters. The valid values are 50 thru 200. Lines without logical  conditionals  will
    #          break on a logical conditional (||, &&, ...), comma, paren, semicolon, or space.

    #   --delete-empty-lines, -xe
    #          Delete  empty  lines  within  a function or method. Empty lines outside of functions or
    #          methods are NOT deleted. If used with  --break-blocks  or  --break-blocks=all  it  will
    #          delete all lines except the lines added by the --break-blocks options.

    #'
    #export ASTYLE_OPTIONS="--style=allman --indent=spaces --indent-preproc-cond --convert-tabs --indent-namespaces --indent-labels --indent-col1-comments --pad-oper --pad-header --unpad-paren --delete-empty-lines --add-brackets "
    
    #--attach-inlines 
    #--attach-extern-c
    #--indent-preproc-cond
    export ASTYLE_OPTIONS="--style=ansi --indent=spaces  --indent-classes  --indent-switches  --indent-col1-comments --pad-oper --unpad-paren --delete-empty-lines --add-brackets"
    astyle $ASTYLE_OPTIONS $@


    #"
    #{
    #'--style=ansi': '-A1',
    #'--indent=spaces': '-s'
    #'--attach-inlines': '-x1'
    #'--attach-extern-c': '-xk',
    #'--indent-classes': '-C',
    #'--indent-modifiers': '-xG',
    #'--indent-switches': '-S',
    #'--indent-preproc-cond ': '-xw',
    #'--indent-col1-comments': '-Y',
    #'--pad-oper': '-p', 
    #'--unpad-paren': '-U',
    #'-delete-empty-lines': '-xe',
    #'--add-brackets': '-j',
    #}
    #"
    ##-A1 -s -x1 -xw -xk -c -N -L -Y
    #--indent-cases

}


# Start TMUX session
# References: 
#     http://lukaszwrobel.pl/blog/tmux-tutorial-split-terminal-windows-easily
#     https://gist.github.com/MohamedAlaa/2961058
change_terminal_title()
    {
    echo -en "\033]0;$@\a"
    }

tmuxnew(){
    change_terminal_title "TMUX $HOSTNAME NEW"
    tmux new -s default_session
}
tmuxattach(){
    change_terminal_title "TMUX $HOSTNAME ATTACHED"
    tmux attach -t default_session
}


utzget()
{
python -c "import utool as ut; ut.grab_zipped_url(\"$1\", download_dir=\".\")"
}

tcp()
{
    cp $1 ../flann/$1
}


print_all_pathvars()
{
    python -c "$(codeblock "
    import os
    vars = ['PATH', 'LD_LIBRARY_PATH', 'CPATH', 'CMAKE_PREFIX_PATH']
    for v in vars:
        print('------')
        print(v)
        value = os.environ.get(v, '')
        plist = [p for p in value.split(os.pathsep) if p]
        print('    ' + (os.linesep + '    ').join(plist))
        print('------')
    ")"
}

pathvar_print(){
# pathvar_print LD_LIBRARY_PATH
# pathvar_print PATH
_VAR=$1
python -c "
if __name__ == '__main__':
    import os
    pathvar = [p for p in os.environ['$_VAR'].split(os.pathsep) if p]
    print('\n'.join(pathvar))
"
}
complete -W "PATH LD_LIBRARY_PATH CPATH CMAKE_PREFIX_PATH" "pathvar_print"


pathvar_clean()
{
# pathvar_clean LD_LIBRARY_PATH
# pathvar_clean PATH
_VAR=$1
python -c "
if __name__ == '__main__':
    import os
    parts = os.environ.get('$_VAR', '').split(os.pathsep)
    seen = set([])
    fixed = []
    for p in parts:
        if p and p not in seen:
            seen.add(p)
            fixed.append(p)
    print(os.pathsep.join(fixed))
"
}
complete -W "PATH LD_LIBRARY_PATH CPATH CMAKE_PREFIX_PATH" "pathvar_clean"

pathvar_remove()
{
# pathvar_clean LD_LIBRARY_PATH
# pathvar_clean PATH
_VAR=$1
_VAL=$2
python -c "
if __name__ == '__main__':
    import os
    from os.path import expanduser, abspath
    val = abspath(expanduser('$_VAL'))
    oldpathvar = os.environ['$_VAR'].split(os.pathsep)  
    newpathvar = [p for p in oldpathvar if p and abspath(p) != val]
    print(os.pathsep.join(newpathvar))
"
}
complete -W "PATH LD_LIBRARY_PATH CPATH CMAKE_PREFIX_PATH" "pathvar_remove"




remove_ld_library_path_entry()
{
# http://stackoverflow.com/questions/370047/what-is-the-most-elegant-way-to-remove-a-path-from-the-path-variable-in-bash
export LD_LIBRARY_PATH=$(pathvar_remove LD_LIBRARY_PATH $1)
}

remove_path_entry()
{
# http://stackoverflow.com/questions/370047/what-is-the-most-elegant-way-to-remove-a-path-from-the-path-variable-in-bash
#_PATHVAR=$1
#
export PATH=$(pathvar_remove PATH $1)
}


debug_paths(){
    python -c "import os; path = os.environ['LD_LIBRARY_PATH'].split(os.pathsep); print('\n'.join(path))"
    python -c "import os; path = os.environ['PATH'].split(os.pathsep); print('\n'.join(path))"

    python -c "import os; path = os.environ['LD_LIBRARY_PATH'].split(os.pathsep); print(os.pathsep.join(path))"
}


deactivate_venv()
{

    # https://stackoverflow.com/questions/85880/determine-if-a-function-exists-in-bash
    if [ -n "$(type -t conda)" ] && [ "$(type -t conda)" = function ]; then
        conda deactivate
    fi

    OLD_VENV=$VIRTUAL_ENV
    # echo "deactivate_venv OLD_VENV=$OLD_VENV"
    if [ "$OLD_VENV" != "" ]; then
        #if [ -n "$(type -t rvm)" ] && [ "$(type -t rvm)" = function ]; then
        #    echo rvm is a function; 
        #else
        #    echo rvm is NOT a function;
        #fi
        if [ -n "$(type -t deactivate)" ] && [ "$(type -t deactivate)" = function ]; then
            # deactivate bash function exists
            deactivate
            # reset LD_LIBRARY_PATH 
            remove_ld_library_path_entry $OLD_VENV/local/lib
            remove_ld_library_path_entry $OLD_VENV/lib
            remove_path_entry $OLD_VENV/bin
        fi
    fi
    # Hack for personal symlinks.  I'm not sure why these are populated
    remove_ld_library_path_entry ~/venv3/local/lib
    remove_ld_library_path_entry ~/venv3/lib
    remove_path_entry ~/venv3/bin
}

workon_py()
{
    NEW_VENV=$1

    if [ ! -d $NEW_VENV ]; then
        # Check if it is the name of a conda or virtual env
        # First try conda, then virtualenv
        TEMP_PATH=$_CONDA_ROOT/envs/$NEW_VENV
        if [ -d $TEMP_PATH ]; then
            NEW_VENV=$TEMP_PATH
        else
            TEMP_PATH=$HOME/$NEW_VENV
            if [ -d $TEMP_PATH ]; then
                NEW_VENV=$TEMP_PATH
            fi
        fi
    fi

    if [ -d $NEW_VENV ]; then
        # Ensure the old env is deactivated
        deactivate_venv

        if [ -d $NEW_VENV/conda-meta ]; then
            # Use a conda environment
            conda activate $NEW_VENV
        else
            # Use a virtualenv environment
            # Activate the new venv
            export LD_LIBRARY_PATH=$NEW_VENV/local/lib:$LD_LIBRARY_PATH
            export LD_LIBRARY_PATH=$NEW_VENV/lib:$LD_LIBRARY_PATH
            source $NEW_VENV/bin/activate
            # echo "activated NEW_VENV=$NEW_VENV"
        fi
    fi
    # echo "new venv doesn't exist"
}
alias we=workon_py

refresh_conda_autocomplete(){
    if [ -d "$_CONDA_ROOT" ]; then
        KNOWN_CONDA_ENVS="$(/bin/ls -1 $_CONDA_ROOT/envs | sort)"
    else
        KNOWN_CONDA_ENVS=""
    fi 
    KNOWN_VIRTUAL_ENVS="$(/bin/ls -1 $HOME | grep venv | sort)"
    #echo "KNOWN_VIRTUAL_ENVS = $KNOWN_VIRTUAL_ENVS"
    #echo "KNOWN_CONDA_ENVS = $KNOWN_CONDA_ENVS"
    # Remove newlines
    KNOWN_ENVS=$(echo "$KNOWN_CONDA_ENVS $KNOWN_VIRTUAL_ENVS" | tr '\n' ' ')
    complete -W "$KNOWN_ENVS" "workon_py"
    complete -W "$KNOWN_ENVS" "we"
}
refresh_conda_autocomplete


workon_pysys()
{
    deactivate_venv
}


workon_py2()
{
    workon_py "$HOME/venv2"
}
alias we-py2=workon_py2

workon_py2_debug()
{
    workon_py "$HOME/code/cpython-27/venvs/venv2-debug"
}
alias we-py2debug=workon_py2_debug


workon_py3()
{
    workon_py "$HOME/venv3"
}
alias we-py3=workon_py3


#workon_conda()
#{
#    # OLD: DEPRICATE

#    # Wrapper around conda activate that handles deactivating any existing
#    # python virtualenvs
#    NEW_VENV=$1
#    if [ -d $_CONDA_ROOT/envs/$NEW_VENV ]; then
#        # Ensure the old env is deactivated
#        deactivate_venv
#        # Activate the new venv
#        conda activate $NEW_VENV
#    fi
#}
#workon_conda3()
#{
#    __heredoc__ "
#    deactivate_venv
#    conda create -y -n cenv3 python=3
#    we-conda3
#    "
#    workon_conda cenv3
#}
#alias we-conda3=workon_conda3


workon_py37()
{
    workon_py "$HOME/venv3_7"
}

workon_pypy()
{
    workon_py "$HOME/venvpypy"
}


alias dmsg=dmesg
alias dmsgt='dmesg | tail'


pyfile()
{
    echo "python -c \"import $1; print($1.__file__)\""
    python -c "import $1; print($1.__file__.replace(\".pyc\", \".py\"))"
}

#alias rpivpn='sudo openconnect -b vpn.net.rpi.edu -uyour_school_username -ucrallj'
alias rpivpn='rpivpn.sh'
#sudo openconnect -b vpn.net.rpi.edu -ucrallj'
alias lev='lev.sh'


gte()
{
    python -m utool.util_ubuntu XCtrl.current_gvim_edit tabe $1
}

gvs()
{
    python -m utool.util_ubuntu XCtrl.current_gvim_edit vs $1
}

gsp()
{
    python -m utool.util_ubuntu XCtrl.current_gvim_edit sp $1
}

ge()
{
    python -m utool.util_ubuntu XCtrl.current_gvim_edit e $1
}

mylayout(){
python -m utool.util_ubuntu XCtrl.move_window GVIM special2
python -m utool.util_ubuntu XCtrl.move_window joncrall special2
}


codeblock()
{
    if [ "-h" == "$1" ] || [ "--help" == "$1" ]; then 
        # Use codeblock to show the usage of codeblock, so you can use
        # codeblock while you codeblock.
        echo "$(codeblock '
            Unindents code before its executed so you can maintain a pretty
            indentation in your code file. Multiline strings simply begin  
            with 
                "$(codeblock "
            and end with 
                ")"

            Example:
               echo "$(codeblock "
                    a long
                    multiline string.
                    this is the last line that will be considered.
                    ")"
        ')"
    else
        # Prevents python indentation errors in bash
        #python -c "from textwrap import dedent; print(dedent('''$1''').strip('\n'))"
        echo "$1" | python -c "import sys; from textwrap import dedent; print(dedent(sys.stdin.read()).strip('\n'))"
    fi
}

untilfail()
{
    while $@; do :; done
}



#export OMP_NUM_THREADS=7
 
permit_erotemic_gitrepo()
{ 
    #permit_gitrepo -i
    sed -i 's/https:\/\/github.com\/Erotemic/git@github.com:Erotemic/' .git/config
    sed -i 's/https:\/\/github.com\/WildbookOrg/git@github.com:WildbookOrg/' .git/config
    #sed -i 's/https:\/\/github.com\/bluemellophone/git@github.com:bluemellophone/' .git/config
    #sed -i 's/https:\/\/github.com\/zmjjmz/git@github.com:zmjjmz/' .git/config
    #sed -i 's/https:\/\/github.com\//git@github.com:' .git/config
}

normalize_line_endings(){
    __heredoc__ '''
    find . -not -type d -exec file "{}" ";" | grep CRLF
    sudo apt install dos2unix
    '''
    
    for fpath in "$@"
    do
    #echo "fpath = $fpath"
    tr -d '\r' < $fpath > _tempfile.out && mv _tempfile.out $fpath
    done
}

normalize_newline_eof()
{
    for fpath in "$@"
    do
        if [ -z "$(tail -c 1 "$fpath")" ]
        then
            NOOP=
        else
            echo "No newline at end of fpath = $fpath"
            echo "Fixing"
            echo "" >> $fpath
        fi
    done
}


gitk(){
    # always spawn gitk in the background 
    GITK_EXE="$(which gitk)"
    $GITK_EXE $@&
}
