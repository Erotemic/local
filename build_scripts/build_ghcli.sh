install_go(){
    source ~/local/init/utils.sh

    mkdir -p $HOME/tmp/install_go
    cd $HOME/tmp/install_go
    URL="https://golang.org/dl/go1.17.linux-amd64.tar.gz"
    BASENAME=$(basename $URL)
    curl_verify_hash $URL $BASENAME "6bf89fc4f5ad763871cf7eac80a2d594492de7a818303283f1366a7f6a30372d" sha256sum "-L"

    mkdir -p $HOME/.local
    tar -C $HOME/.local -xzf $BASENAME
    # Add $HOME/.local/go to your path or make symlinks
    ln -s $HOME/.local/go/bin/go $HOME/.local/bin/go 
    ln -s $HOME/.local/go/bin/gofmt $HOME/.local/bin/gofmt
}


mkdir -p $HOME/tmp/build_sandbox
git clone https://github.com/cli/cli.git $HOME/tmp/build_sandbox/gh-cli
cd $HOME/tmp/build_sandbox/gh-cli

make install prefix=$HOME/.local


test_list_all_repos(){

    gh auth login
    gh api repos/Erotemic

    RESULTS=$(gh api graphql --paginate -f query='
        query($endCursor: String) {
          viewer {
            repositories(first: 100, after: $endCursor) {
              nodes { nameWithOwner }
              pageInfo {
                hasNextPage
                endCursor
              }
            }
          }
        }
    ')

    echo $RESULTS | jq '. | .data.viewer.repositories.nodes | .[] | .nameWithOwner'
    echo $RESULTS | jq

    gh repo list Erotemic --source -L 300 

}
