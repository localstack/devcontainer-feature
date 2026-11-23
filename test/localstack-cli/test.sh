#!/bin/bash

set -e

# Import test library for `check` command
source dev-container-features-test-lib

check "lstk" type lstk
check "lstk version" lstk --version
check "no localstack python cli" bash -c "! type localstack"

# Report result
reportResults
