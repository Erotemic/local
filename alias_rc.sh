# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

# Unix aliases

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

# General navigation
alias home='cd ~'
alias data='cd ~/data'
alias code='cd ~/code'
alias loc='cd ~/local'
alias lc='cd ~/local'
alias vf='cd ~/local/vim/vimfiles'
alias vfb='cd ~/local/vim/vimfiles/bundle'
alias lt='cd ~/latex'
alias scr='cd ~/scripts'
# Special navigation
alias s='git status'
alias cv='cd ~/code/opencv'
alias hs='cd ~/code/ibeis/ibeis/model/hots'
alias ib='cd ~/code/ibeis/'
alias rf='cd ~/code/pyrf/'
alias gi='cd ~/code/pygist/'
alias dt='cd ~/code/detecttools/'


alias pydist='cd ~/code/pyrf/'

alias ut='cd ~/code/utool'
alias vt='cd ~/code/vtool'
alias gt='cd ~/code/guitool'
alias pt='cd ~/code/plottool'
alias ibi='cd ~/code/ibeis/ibeis'
alias ibc='cd ~/code/ibeis/ibeis/control'
alias ibv='cd ~/code/ibeis/ibeis/view'
alias ibm='cd ~/code/ibeis/ibeis/model'
alias ibg='cd ~/code/ibeis/ibeis/gui'
alias work='cd ~/data/work'
alias hshs='cd ~/code/hotspotter/hotspotter'
alias hshsviz='cd ~/code/hotspotter/hsviz'
alias hshscom='cd ~/code/hotspotter/hscom'
alias hshsgui='cd ~/code/hotspotter/hsgui'
alias lnote='cd ~/latex/crall-lab-notebook'
alias hes='cd ~/code/hesaff'
alias cand='cd ~/latex/crall-candidacy-2013/'

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
alias ebrc='gvim ~/local/bashrc.sh'
alias emc='gvim ~/local/modulechanges.sh'
alias sbrc='source ~/local/bashrc.sh' # Refresh
alias todo='gvim ~/Dropbox/Notes/TODO.txt'
alias edutool='gvim ~/code/ibeis/utool'

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
    ssh -t cralljp@linux.cs.rpi.edu "ssh -t joncrall@hyrule.cs.rpi.edu \"cd ~/code/hotspotter; git commit -am 'hyhs wip'; git push\""
    
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
