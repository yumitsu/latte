###############################################################################
# The core module provides the most basic functionality in which everything
# else relies on. The goal of this module is abstracting usual JavaScript and
# CoffeeScript constructs, which use an imperative programming structure, like
# assignments, function definitions and so on, to conform with Lisp's DSL
# syntax.
###############################################################################
root = global ? window


## Defining variables #########################################################
#
# Since you don't have pointers in JavaScript and can't really dynamically set
# variables in the local scope, Latte leaks everything into the global object
# (which can be either `global` or `window`), depending on the environment in
# which the library is running.
#
# For handling these assignments to the global scope, Latte provides two
# basic functions:
#
#
#### Function `set` ###########################################################
#
#     fun set obj:obj → list
#
#
# The `set` function is used to define global variables. It accepts a single
# argument: a JavaScript object, and unpacks all of it's properties in the
# global scope, that is, every key=value pair in the given object is placed in
# the global object.
#
# Take the following example. It receives an object containing two properties:
# `foo` and `bar`, and unpacks them to the global scope:
#
#     >>> (set foo: 1, bar: -1)
#     [1, -1]
#
# After executing this snippet, we'll have two new properties in the global
# scope: `foo=1` and `bar=-1`. They're accessible as any other global variable
# in javascript, no explicit prefixing needed:
#
#     >>> foo
#     1
#     >>> bar
#     -1
#     >>> (global ? window).foo
#     1
#
# As an effect of the way CoffeeScript is structured — implicit return
# statements are placed at the end of the function — the `set` function will
# also return a list with all the values in the given object.
#
# Lists in Latte are exactly the same thing as JavaScript's Arrays. They're
# not real Lisp lists, although still referred as such.
###############################################################################
(root.set = (obj) ->
    ((root[name] = value) for name, value of obj))


#### Function `defun` #########################################################
#
#     fun defun obj:obj → list
#
#
# And the `defun` function, which is just an alias for `set`, intended to
# distinguish function definitions from general variable definitions, thus
# making the source code more readable — hell yeah semantics!
###############################################################################
(set defun: set)


## Calling functions ##########################################################
#
# Functions in CoffeeScript can be called in two ways, either by surrounding
# the parameters in parenthesis, or by omitting the parenthesis altogether.
#
#     >>> [1, 2, 3].slice 1
#     [2, 3]
#
#     >>> [1, 2, 3].slice(1)
#     [2, 3]
#
# There's however some problems with the no-parens syntax: conflicts. And you
# don't know whether you'd like to actually call a function or return a
# reference to it.
#
# CoffeeScript handles this by requiring function calls with no parameters to
# be explicit:
#
#     >>> set
#     function(obj) { var name, value, _results; ... }
#
#     >>> set()
#     []
#
# To conform a bit more with Lisp's DSL, Latte uses the same parenthesis
# conventions. Basically, all function calls are wrapped in parenthesis:
#
#     >>> (set x: 1)
#     [1]
#
# This also removes all the problems that comes with conflicts by omitting
# parenthesis in JavaScript, and makes the code more consistent:
#
#     >>> nth 1, list 1, 2, 3, 4, 2
#     [2]
#
#     >>> (nth 1, (list 1, 2, 3, 4), 2)
#     [2, 3]
#
# The downside of the syntax is that you still can't omit the commas in your
# parameters, which sometimes can lead to fairly cluttered syntax.
#
# Then we get down to what execution context is used in the function being
# called. By JavaScript's rules, whenever a function is called as anything
# besides a `method`, the execution context will be the global scope (or `null`
# in strict mode).
#
#     >>> (defun stuff: this == global)
#     >>> (stuff)
#     true
#
# However, sometimes you want to apply a function to another object. Latte
# offers some syntax for this as well:
#
#
#### Function `capply` ########################################################
#
#     fun capply list:args, obj: ctx, fun:fn → result of calling fn
#
#
# The `capply` function calls a function and assigns an explicit execution
# context to it — that is, in the function being called, `this` will refer to
# any object that `capply` received as context.
#
# Where a context object is not given, the same context rules above apply.
#
# Additionally, the function accepts a list as its first argument, which will
# be passed as positional arguments for the function to be called. If you don't
# want to set the context of the function, however, you can read up to the
# `apply` function.
###############################################################################
(defun capply: (args, ctx, fn) ->
    (fn.apply ctx, args))


#### Function `apply` #########################################################
#
#     fun apply list:args, fun:fn → result of calling fn
#
#
# Apply is used to apply a list of arguments to a function, rather than an
# execution context. It's basically an alias to `capply`, but using a null
# context.
###############################################################################
(defun apply: (args, fn) ->
    (capply args, null, fn))


#### Function `call` ##########################################################
#
#     fun call fun:fn, args... → result of calling fn
#
#
# And last, but not least, there is `call`. Which was only introduced to get
# rid of the fugly, fugly function calls that doesn't use parameters.
#
# Take a look at the following example and see how the explicit `call` function
# is more readable, and blends better with the overall syntax:
#
#     >>> (defun get_list: -> (list "foo", "bar"))
#     >>> (car (get_list()))
#     "foo"
#
#     >>> (car (call get_list))
#     "foo"
#
#
###############################################################################
(defun call: (fn, args...) ->
    (apply args, fn))


## Local variables ############################################################
#
# So, `set` and `defun` are great constructs, but they have a big flaw: they
# can only create global variables and functions. Sometimes you just want to
# name a rather long (or expensive) expression that you'll be using on more
# than one place.
#
# In Lisp you have the `let` constructs, which creates variables that are local
# to the block they define.
#
# In JavaScript/CoffeeScript, you have lexically scoped variables. That is,
# local functions can only be local in a function-basis, and sometimes you'd
# need to use them in a block-basis. Worse still, in CoffeeScript you have no
# way of **explicitly** declarating a variable as only local to the current
# scope, since it'll use any variable in the enclosing scopes if they're
# available (at compile time).
#
# Now, while this may be okay for most of the CoffeeScript things, it would
# just go plain wrong with Latte and any more functional-centered programming.
#
# The solution was to fake this `let` construct in Lisp languages, taking
# advantage of CoffeeScript's default arguments for functions, and JavaScript's
# closures (hey, function parameters are all local :D)
#
#
#### Function `letb` ##########################################################
#
#     fun letb fun:fn → result of calling fn
#
#
# The `letb` function is basically a function that takes another function and
# calls it immediately, with no arguments — thus all the arguments will
# fallback to their default values.
#
# As an example, the call `letb (x=2) -> x * x` is expanded in the following:
#
#     letb(function(x) {
#         if (x == null) x = 2
#         return x * x
#     })
###############################################################################
(defun letb: (fn) ->
    (call fn))

