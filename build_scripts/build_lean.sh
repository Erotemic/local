#git clone https://github.com/leanprover/lean4.git

mkdir -p "$HOME"/tmp
cd "$HOME"/tmp
curl -L https://github.com/leanprover/lean4/releases/download/v4.0.0-m5/lean-4.0.0-linux.zip -o "$HOME/tmp/lean4.zip"
curl -L https://github.com/leanprover/lean4/releases/download/v4.0.0-m5/lean-4.0.0-linux.tar.zst -o "$HOME/tmp/lean4.tar.zst"

7z x lean-4.0.0-linux.zip

#mv lean-4.0.0-linux "$HOME/.local/lean4"
#ln -s "$HOME/.local/lean4/bin/lean" "$HOME/.local/bin/lean"
#ln -s "$HOME/.local/lean4/bin/leanmake" "$HOME/.local/bin/leanmake"
#ln -s "$HOME/.local/lean4/bin/lake" "$HOME/.local/bin/lake"


# https://gist.github.com/jcommelin/1d45a0ea7a84a87db8a28a12e93cac32
mkdir -p "$HOME"/tmp
cd "$HOME"/tmp
curl https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh -sSf > elan-init.sh
chmod +x elan-init.sh
./elan-init.sh


cd /home/joncrall/code/paper-g1-and-mcc
elan run --install nightly leanpkg new myfirstproof

elan self update

elan default stable
elan run --install stable lake new myfirstproof


cd /home/joncrall/code/paper-g1-and-mcc/myfirstproof
lake update
lake exe cache get
lake build


# https://leanprover-community.github.io/install/project.html
lake +leanprover/lean4:nightly-2023-02-04 new my_project math
cd my_project
lake update
lake exe cache get
