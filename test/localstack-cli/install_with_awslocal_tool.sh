#!/bin/bash

set -e

# Import test library for `check` command
source dev-container-features-test-lib

# Check to make sure the user is vscode
check "user is vscode" whoami | grep vscode
check "version" localstack  --version
check "awslocal" which awslocal
check "awslocal via pipx" sudo pipx list > tmp_file && cat tmp_file | grep "package awscli-local"

# Report result
reportResults