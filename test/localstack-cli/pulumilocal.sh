#!/bin/bash
set -e

source dev-container-features-test-lib

check "lstk version" lstk --version
check "pulumi available" pulumi version
check "pulumilocal installed" bash -c "command -v pulumilocal"
check "pulumilocal wraps pulumi" pulumilocal version

reportResults
