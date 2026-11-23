#!/bin/bash
set -e

source dev-container-features-test-lib

check "docker is reachable" bash -c "timeout 60 bash -c 'until docker info > /dev/null 2>&1; do sleep 1; done'"
check "aws cli available" aws --version
check "lstk reports a stopped emulator" bash -c "lstk --non-interactive status 2>&1 | grep -i 'not running'"
check "lstk setup aws writes a localstack profile" bash -c "lstk --non-interactive setup aws && aws configure get endpoint_url --profile localstack | grep localhost.localstack.cloud:4566"

reportResults
