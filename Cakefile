{spawn, exec} = require 'child_process'

task 'build', 'Continually build Latte with --watch', ->
    coffee = spawn 'cofee', ['-cw', '-o', 'lib', 'src']
    coffee.stdout.on 'data', (data) ->
        console.log data.toString().trim()

task 'doc', 'Rebuild the Latte\'s documentation.', ->
    exec 'vendor/docco/bin/docco src/*.coffee', (err) ->
        throw err if err

task 'test', 'Runs the test cases.', ->
    exec 'cd tests && coffee suite.coffee', (err, stdout) ->
        throw err if err
        console.log stdout