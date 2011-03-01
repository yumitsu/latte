#
# Test suite for Latte
#

{exec} = require 'child_process'
fs = require 'fs'

require '../../claire/src/claire'
require '../src/latte'

all_tests = ['core']

for testcase in all_tests
    console.log "Running tests for #{testcase}::"
    exec "coffee #{testcase}.coffee", (err, stdout) ->
        throw err if err
        console.log stdout


