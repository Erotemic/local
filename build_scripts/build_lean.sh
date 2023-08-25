#git clone https://github.com/leanprover/lean4.git

mkdir -p "$HOME"/tmp
cd "$HOME"/tmp
curl -L https://github.com/leanprover/lean4/releases/download/v4.0.0-m5/lean-4.0.0-linux.zip -o "$HOME/tmp/lean4.zip"
curl -L https://github.com/leanprover/lean4/releases/download/v4.0.0-m5/lean-4.0.0-linux.tar.zst -o "$HOME/tmp/lean4.tar.zst"

7z x lean-4.0.0-linux.zip

mv lean-4.0.0-linux "$HOME/.local/lean4"
ln -s "$HOME/.local/lean4/bin/lean" "$HOME/.local/bin/lean"
ln -s "$HOME/.local/lean4/bin/leanmake" "$HOME/.local/bin/leanmake"
ln -s "$HOME/.local/lean4/bin/lake" "$HOME/.local/bin/lake"
