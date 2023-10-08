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
cd /home/joncrall/code/paper-g1-and-mcc
lake +leanprover/lean4:nightly-2023-02-04 new mcc-proof math
cd mcc-proof
lake update
lake exe cache get


# MWE
PARENT_DPATH="$HOME"/code
PROJECT_NAME="lean-mwe-project"
cd "$PARENT_DPATH"
lake +leanprover/lean4:nightly-2023-02-04 new "$PROJECT_NAME" math
cd "$PARENT_DPATH/$PROJECT_NAME"
lake update
lake exe cache get

echo '
import Mathlib

#eval "Hello, World!"

def comm_and_assoc_example (a b c : ℝ) : a * b * c = b * (a * c) := by
  rw [mul_comm a b]
  rw [mul_assoc b a c]

#check comm_and_assoc_example
' > LeanMweProject.lean


# Running lake build on the CLI works fine
lake build

# Open VScode
code .

# Click, yes I trust authors. This puts me in the welcome page and the
# workspace seems to be the project directory.
#
#
# #


__doc__="
For some reason my VSCode Lean Infoview pannel is no longer working.


I've installed


I do see an error:

    Error loading webview: Error: Could not register service worker:
    InvalidStateError: Failed to register a ServiceWorker: The document is in an
    invalid state..

    # https://leanprover-community.github.io/archive/stream/270676-lean4/topic/InfoView.20failing.html

When I hover over the #eval or #check it does show me the relevant output / type
but the infoview is completely blank.


In the VSCode output tab under Lean Editor It reports:

Lean (version 4.0.0-nightly-2023-02-04, commit 4b974fd60b9f, Release)


The solution was to delete the cache.
https://stackoverflow.com/questions/67698176/error-loading-webview-error-could-not-register-service-workers-typeerror-fai
"


# References:
# https://lean-lang.org/reference/tactics.html
