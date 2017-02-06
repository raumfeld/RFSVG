#!/bin/sh
export LC_CTYPE=en_US.UTF-8
set -o pipefail

# runs tests and measures code coverage
function runTests() 
{
    fastlane test || exit $?
}

runTests
