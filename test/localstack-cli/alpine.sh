#!/bin/bash
set -e

source dev-container-features-test-lib

check "distro is alpine" bash -c "grep ID=alpine /etc/os-release"
check "lstk version" lstk --version
check "bundled doctor extension resolves" bash -c "lstk doctor --help"
check "remote user is in the lstk group" bash -c "id -nG | grep -qw lstk"
check "install dir writable by the lstk group" bash -c "test -w /usr/local/lib/lstk && test -w /usr/local/lib/lstk/lstk"

reportResults
