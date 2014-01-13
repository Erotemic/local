if [[ "$OSTYPE" == "darwin"* ]]; then
    source ~/local/bashrc_mac.sh
else
    source ~/local/bashrc_ubuntu.sh
fi

# Unix aliases
alias ls='ls --hide="*.pyc"'
alias pygrep='grep -r --include "*.py"'
alias clean-python='rm -rf *.pyc'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias utarbz2='tar jxf'
alias clean-latex='clean_latex_fun'
clean_latex_fun()
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
alias gcwip='git commit -am "wip"; git push'
alias gp='git pull'
hyrule_get(){
    git clone git@hyrule.cs.rpi.edu:$1
}

# General navigation
alias home='cd ~'
alias data='cd ~/data'
alias code='cd ~/code'
alias loc='cd ~/local'
alias lt='cd ~/latex'
alias scr='cd ~/scripts'
# Special navigation
alias hs='cd ~/code/hotspotter'
alias cand='cd ~/latex/crall-candidacy-2013/'

alias vdd='vd ~/data'
alias ..="cd .."
alias l='ls $LS_OPTIONS -lAhF'
alias gits='git status'


# ROB
alias hskill='rob hskill'
alias nr='rob grepnr'
alias rgrep='rob grepnr'
alias rsc='rob research_clipboard None 3'


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
