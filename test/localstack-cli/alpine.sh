#!/bin/bash
set -e

source dev-container-features-test-lib

check "distro is alpine" bash -c "grep ID=alpine /etc/os-release"
check "lstk version" lstk --version
check "bundled doctor extension resolves" bash -c "lstk doctor --help"

reportResults
