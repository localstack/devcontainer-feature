#!/bin/bash

set -e

# Import test library for `check` command
source dev-container-features-test-lib

check "user is vscode" whoami | grep vscode
check "lstk 1.5.0" bash -c "lstk --version | grep 1.5.0"

# Report result
reportResults
