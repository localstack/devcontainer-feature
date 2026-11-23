#!/bin/bash
set -e

source dev-container-features-test-lib

check "lstk is on PATH" bash -c "command -v lstk"
check "lstk version" lstk --version
check "lstk help lists tool proxies" bash -c "lstk --help | grep -E '^ +terraform '"
check "legacy localstack CLI is not installed" bash -c "! command -v localstack"

reportResults
