if [[ "$OSTYPE" == "darwin"* ]]; then
    source mac_profile
else
    source ubuntu_profile
fi

# Git
alias gcwip='git commit -am "wip"; git push'
alias gp='git pull'

# Navigation
alias data='cd ~/data'
alias code='cd ~/code'
alias hs='cd ~/code/hotspotter'
alias lt='cd ~/latex'

# ROB
alias nr='rob grepnr'
