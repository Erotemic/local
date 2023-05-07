mkdir -p "$HOME/tmp/install-lf"
cd "$HOME/tmp/install-lf"
curl -LJO https://github.com/gokcehan/lf/releases/download/r28/lf-linux-amd64.tar.gz
tar xvf lf-linux-amd64.tar.gz
cp lf "$HOME"/.local/bin

# TODO: also need to setup lfcd
