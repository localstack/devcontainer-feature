#!/bin/bash
set -e

source dev-container-features-test-lib

check "user is vscode" bash -c "whoami | grep vscode"
check "lstk version" lstk --version
check "lstk links into the install dir" bash -c "readlink -f \$(command -v lstk) | grep '^/usr/local/lib/lstk/lstk\$'"
check "bundled extensions shipped next to lstk" test -x /usr/local/lib/lstk/bundled-extensions
check "bundled doctor extension resolves" bash -c "lstk doctor --help"
check "bash completion installed" test -f /usr/share/bash-completion/completions/lstk
check "zsh completion installed" test -f /usr/local/share/zsh/site-functions/_lstk
check "man page installed" test -f /usr/local/share/man/man1/lstk.1
check "install dir owned by remote user" bash -c "stat -c %U /usr/local/lib/lstk/lstk | grep vscode"
check "config lives in the user's home" bash -c "lstk config path | grep '^/home/vscode/'"
check "no deprecated wrappers" bash -c "! command -v localstack && ! command -v awslocal && ! command -v tflocal && ! command -v cdklocal && ! command -v samlocal"
check "pulumilocal not installed by default" bash -c "! command -v pulumilocal"

reportResults
