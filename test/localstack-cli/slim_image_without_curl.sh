#!/bin/bash
set -e

source dev-container-features-test-lib

check "distro is trixie" bash -c "grep VERSION_CODENAME=trixie /etc/os-release"
check "lstk version" lstk --version
check "curl was installed as a prerequisite" bash -c "command -v curl"

reportResults
