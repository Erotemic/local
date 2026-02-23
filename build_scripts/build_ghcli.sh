#!/usr/bin/env bash
__doc__="
Build and install GitHub CLI (gh) from source into ~/.local/bin.
"

# If running as a script, fail fast. If sourcing / copy-pasting, don't change your shell options.
if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
    set -e
    set -o pipefail
fi

# ---------- config (edit these if you want) ----------
PREFIX="$HOME/.local"
BIN_DIR="$PREFIX/bin"
GO_ROOT="$PREFIX/go"
GO_TARBALL_ARCH="linux-amd64"
GO_VERSION_DEFAULT="1.22.4"   # pick a modern version; adjust as desired
BUILD_ROOT="$HOME/tmp/build_sandbox"
GH_SRC_DIR="$BUILD_ROOT/gh-cli"
# ----------------------------------------------------

ensure_local_prefix(){
    __doc__="
    Ensure ~/.local/bin exists and other required dirs exist.
    "
    mkdir -p "$BIN_DIR"
    mkdir -p "$BUILD_ROOT"
}

ensure_path(){
    __doc__="
    Ensure this shell session can see ~/.local/bin and ~/.local/go/bin.
    (Does not edit shell rc files.)
    "
    export PATH="$BIN_DIR:$GO_ROOT/bin:$PATH"
}

install_go_local(){
    __doc__="
    Install Go into ~/.local/go (no sudo). Also symlink go & gofmt into ~/.local/bin.

    Usage:
        install_go_local                 # uses GO_VERSION_DEFAULT
        install_go_local 1.22.4
    "
    ensure_local_prefix

    GO_VERSION="${1:-$GO_VERSION_DEFAULT}"
    TMPDIR="$HOME/tmp/install_go"
    URL="https://go.dev/dl/go${GO_VERSION}.${GO_TARBALL_ARCH}.tar.gz"
    BASENAME="$(basename "$URL")"

    mkdir -p "$TMPDIR"
    cd "$TMPDIR"

    echo "Downloading: $URL"
    curl -fL "$URL" -o "$BASENAME"

    # Replace existing Go tree (keeps it simple / deterministic)
    rm -rf "$GO_ROOT"
    tar -C "$PREFIX" -xzf "$BASENAME"

    ln -sf "$GO_ROOT/bin/go"    "$BIN_DIR/go"
    ln -sf "$GO_ROOT/bin/gofmt" "$BIN_DIR/gofmt"

    ensure_path
    echo "Go installed: $(go version)"
}

clone_or_update_gh_repo(){
    __doc__="
    Clone or update the GitHub CLI source repo.
    "
    ensure_local_prefix

    if [[ -d "$GH_SRC_DIR/.git" ]]; then
        echo "Updating existing repo at: $GH_SRC_DIR"
        git -C "$GH_SRC_DIR" fetch --prune
        # prefer main if present; otherwise just stay on current branch
        git -C "$GH_SRC_DIR" show-ref --verify --quiet refs/remotes/origin/main && \
            git -C "$GH_SRC_DIR" checkout main
        git -C "$GH_SRC_DIR" pull --ff-only || true
    else
        echo "Cloning into: $GH_SRC_DIR"
        git clone https://github.com/cli/cli.git "$GH_SRC_DIR"
    fi
}

build_gh_from_source(){
    __doc__="
    Build gh from source and install into ~/.local/bin/gh.

    Notes:
    - Requires a modern Go in PATH (Go 1.21+ recommended).
    - Uses Go modules; no Makefile required.
    "
    ensure_path
    clone_or_update_gh_repo

    cd "$GH_SRC_DIR"

    make install prefix="$HOME/.local"

    echo "Built: $("$BIN_DIR/gh" --version | head -n 1)"
}

test_gh_basic(){
    __doc__="
    Smoke test for gh.
    "
    ensure_path
    gh --version
    gh --help | head -n 20
}

test_list_all_repos(){
    __doc__="
    Your original test, lightly cleaned up.

    Notes:
    - The GraphQL query uses viewer, so it lists repos for the *authenticated user*.
    - If you want repos under an org/user like Erotemic, use gh repo list Erotemic ...
    "
    ensure_path

    gh auth login

    # Lists *your* repos (authenticated user) via REST
    gh api /users/Erotemic
    gh api /users/Erotemic/repos

    RESULTS="$(gh api --paginate "/users/Erotemic/repos?per_page=100")"
    echo "$RESULTS" | jq -r '.[].full_name'

    # simple REST call example (this endpoint expects owner/repo; leaving here as a placeholder)
    # gh api repos/Erotemic/ubelt

    # OLD METHOD
    #RESULTS="$(gh api graphql --paginate -f query='
    #    query($endCursor: String) {
    #      viewer {
    #        repositories(first: 100, after: $endCursor) {
    #          nodes { nameWithOwner }
    #          pageInfo { hasNextPage endCursor }
    #        }
    #      }
    #    }')"

    #echo "$RESULTS" | jq -r '.data.viewer.repositories.nodes[].nameWithOwner'
    # echo "$RESULTS" | jq

    gh repo list Erotemic --source -L 300
}

main(){
    __doc__="
    End-to-end entry point.

    Usage:
        ./build_gh.sh
        ./build_gh.sh --install-go
        ./build_gh.sh --install-go 1.22.4
    "
    ensure_local_prefix
    ensure_path

    if [[ "${1:-}" == "--install-go" ]]; then
        install_go_local "${2:-$GO_VERSION_DEFAULT}"
    fi

    build_gh_from_source
    test_gh_basic
}

# bpkg convention
# https://github.com/bpkg/bpkg
if [[ ${BASH_SOURCE[0]} != "$0" ]]; then
    echo "Sourcing ${BASH_SOURCE[0]} as a library"
else
    main "$@"
    exit $?
fi
