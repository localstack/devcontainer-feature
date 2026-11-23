#!/bin/bash
set -e

source dev-container-features-test-lib

check "distro is noble" bash -c "grep VERSION_CODENAME=noble /etc/os-release"
check "lstk is 1.4.5" bash -c "lstk --version | grep -w 1.4.5"

reportResults
