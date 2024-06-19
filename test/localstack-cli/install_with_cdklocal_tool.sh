#!/bin/bash

set -e

# Import test library for `check` command
source dev-container-features-test-lib

# Check to make sure the user is vscode
check "user is vscode" whoami | grep vscode
check "version" localstack  --version
check "cdklocal" type cdklocal
check "cdklocal via npm" npm list -g --depth=0 | grep aws-cdk-local

# Report result
reportResults