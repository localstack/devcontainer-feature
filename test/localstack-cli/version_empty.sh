#!/bin/bash

set -e

# Import test library for `check` command
source dev-container-features-test-lib

check "user is vscode" whoami | grep vscode
check "lstk version" lstk --version

# Report result
reportResults
