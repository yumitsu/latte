#
# Core tests
#

require '../../claire/src/claire'
require '../src/latte'

global._       = require 'underscore'
global.test    = claire.test
global.__slice = Array.prototype.slice

test 'Setting variables — fun set', ->
    assert `set({foo: "bar"}) <eq> ["bar"]`
    assert `set() <eq> []`
    assert `foo <eq> "bar"`


test 'Setting functions — fun defun', ->
    x = -> x
    assert `defun({bar: x}) <eq> [x]`
    assert `x() <eq> x`


test 'Applying contexts — fun capply', ->
    x = -> this
    y = -> this

    assert (capply null, null, x) is global
    assert (capply null, x,    y) is x


test 'Passing positional arguments — fun apply / fun call', ->
    x = (seq...) -> seq
    l = [1,2,3,4]

    assert `apply([1,2,3,4], x) <has> 1`
    assert `apply(l, x) <eq> [1,2,3,4]`
    assert `call(x, 1, 2, 3, 4) <eq> l`


test 'Local variables — fun letb', ->
    (set __local: "foo")

    letb (__local = "bar") ->
        assert __local is "bar"
        refute __local is "foo"


claire.run()