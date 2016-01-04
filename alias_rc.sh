# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

# Unix aliases

alias activate_py3env='source ~/py3env/bin/activate'

alias pytree='tree -P "*.py" --dirsfirst'
alias ls='ls --color --human-readable --group-directories-first --hide="*.pyc" --hide="*.pyo"'
alias pygrep='grep -r --include "*.py"'
alias clean_python='rm -rf *.pyc && rm -rf *.pyo'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
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


# Git
alias gcwip='git commit -am "wip" && git push'
alias gp='git pull'

hyrule_get(){
    git clone git@hyrule.cs.rpi.edu:$1
}
alias hyrule='hyrule.sh'

# General navigation
alias home='cd ~'
alias data='cd ~/data'
alias loc='cd ~/local'
alias lc='cd ~/local'
alias vf='cd ~/local/vim/vimfiles'
alias vfb='cd ~/local/vim/vimfiles/bundle'
alias lb='cd ~/latex/crall-lab-notebook/'
alias lt='cd ~/latex/'
alias cand='cd ~/latex/crall-candidacy-2015/'
alias ca='cd ~/latex/crall-candidacy-2015/'
alias scr='cd ~/scripts'
# Special navigation
alias s='git status'
alias code='cd $CODE_DIR'
alias co='cd $CODE_DIR'
alias cv='cd $CODE_DIR/opencv'
alias fl='cd $CODE_DIR/flann/'
#alias cv='cd $CODE_DIR/opencv3'
alias hs='cd $CODE_DIR/ibeis/ibeis/algo/hots'
alias smk='cd $CODE_DIR/ibeis/ibeis/algo/hots/smk'
alias ju='cd ~/.config/ibeis_cnn/training_junction'
alias ib='cd $CODE_DIR/ibeis/'
alias gn='cd $CODE_DIR/Lasagne/'
alias cn='cd $CODE_DIR/ibeis_cnn/'
alias db='cd ~/Dropbox/'
alias cy='cd $CODE_DIR/cyth/'
alias rf='cd $CODE_DIR/pyrf/'
alias gi='cd $CODE_DIR/pygist/'
alias dt='cd $CODE_DIR/detecttools/'
alias mtg='cd $CODE_DIR/mtgmonte/'

#python -c "import site; print(site.getusersitepackages())"
#python -c "import site; print(site.getsitepackages())"

# https://github.com/pypa/virtualenv/issues/355
# ['/usr/local/lib/python2.7/dist-packages', '/usr/lib/python2.7/dist-packages']
alias pysite='cd $(python -c "import site; print(site.getsitepackages()[0])")'
#alias vrc='cd $(python -c "import site; print(site.getsitepackages()[0]))"'


alias pydist='cd $CODE_DIR/pyrf/'

alias ya='cd $CODE_DIR/yael'
alias ut='cd $CODE_DIR/utool'
alias uts='cd $CODE_DIR/utool/utool/util_scripts'
alias vt='cd $CODE_DIR/vtool'
alias gt='cd $CODE_DIR/guitool'
alias pt='cd $CODE_DIR/plottool'
alias ibi='cd $CODE_DIR/ibeis/ibeis'
alias ibc='cd $CODE_DIR/ibeis/ibeis/control'
alias ibv='cd $CODE_DIR/ibeis/ibeis/view'
alias iba='cd $CODE_DIR/ibeis/ibeis/algo'
alias ibg='cd $CODE_DIR/ibeis/ibeis/gui'
alias hshs='cd $CODE_DIR/hotspotter/hotspotter'
alias hshsviz='cd $CODE_DIR/hotspotter/hsviz'
alias hshscom='cd $CODE_DIR/hotspotter/hscom'
alias hshsgui='cd $CODE_DIR/hotspotter/hsgui'
alias hes='cd $CODE_DIR/hesaff'
alias work='cd ~/work'
alias lnote='cd ~/latex/crall-lab-notebook'
alias cvp='cd ~/latex/crall-cvpr-15'
alias cvpr='cd ~/latex/crall-cvpr-15'

alias vdd='vd ~/data'
#alias ..="cd .."
#alias l='ls $LS_OPTIONS -lAhF'
alias gits='git status'


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
alias ebrc='gvim ~/local/bashrc.sh'
alias ea='gvim ~/local/alias_rc.sh'
alias emc='gvim ~/local/modulechanges.sh'
alias sbrc='source ~/local/bashrc.sh' # Refresh
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
alias rrr='source ~/.profile'
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


alias vimhs='gvim -S ~/vim_hotspotter_session.vim'


cls()
{
    for i in {1..100}
    do
        echo ""
    done
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



alias dmsg=dmesg
alias dmsgt='dmesg | tail'


pyfile()
{
    python -c "import $1; print($1.__file__.replace(\".pyc\", \".py\"))"
}
