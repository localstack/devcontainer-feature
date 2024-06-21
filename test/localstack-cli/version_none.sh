#!/bin/bash

set -e

# Import test library for `check` command
source dev-container-features-test-lib

# Check to make sure the user is vscode
check "user is vscode" whoami | grep vscode

check "version" localstack  --version

check "version is none (3.5.0)" localstack --version | grep "3.5.0"

# Report result
reportResults