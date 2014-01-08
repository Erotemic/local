if [[ "$OSTYPE" == "darwin"* ]]; then
    source ~/local/mac_profile.sh
else
    source ~/local/ubuntu_profile.sh
fi

# Git
alias gcwip='git commit -am "wip"; git push'
alias gp='git pull'

# Navigation
alias data='cd ~/data'
alias code='cd ~/code'
alias loc='cd ~/local'
alias hs='cd ~/code/hotspotter'
alias lt='cd ~/latex'

# ROB
alias nr='rob grepnr'
