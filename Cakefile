{spawn, exec} = require 'child_process'

task 'build', 'Continually build Latte with --watch', ->
    coffee = spawn 'cofee', ['-cw', '-o', 'lib', 'src']
    coffee.stdout.on 'data', (data) ->
        console.log data.toString().trim()


task 'doc', 'Rebuild the Latte\'s documentation.', ->
    exec([
        'vendor/docco/bin/docco src/*.coffee'
        'sed "s/docco.css/docs\\/docco.css/" < docs/latte.html > index.html'
        'rm docs/latte.html'
        ].join(' && '), (err) ->
            throw err if err
    )


task 'test', 'Runs the test cases.', ->
    exec 'cd tests && coffee suite.coffee', (err, stdout) ->
        throw err if err
        console.log stdout


task 'up:pages', 'Updates the GitHub pages for the project', ->
    # This is just because I don't push directly from mercurial to git (since
    # it has to pull from the remote repo, import, then push back), instead
    # I keep my git repositories locally... so I don't think anyone using `git`
    # will need this.
    exec([
        'cp index.html ignore/pages'
        'cp -R docs    ignore/pages'
        'cd ignore/pages'           # ignore/pages is a repo on gh-pages branch
        'git push origin gh-pages'
    ].join(' && '), (err) ->
        throw err if err
    )