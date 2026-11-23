#!/bin/bash
set -e

source dev-container-features-test-lib

check "distro is jammy" bash -c "grep VERSION_CODENAME=jammy /etc/os-release"
check "lstk is 1.4.4" bash -c "lstk --version | grep -w 1.4.4"

reportResults
