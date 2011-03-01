###############################################################################
# The core module provides the most basic functionality in which everything
# else relies on. The goal of this module is abstracting usual JavaScript and
# CoffeeScript constructs, which use an imperative programming structure, like
# assignments, function definitions and so on, to conform with Lisp's DLS
# syntax.
#
# Since you don't have pointers in JavaScript and can't really dynamically set
# variables in the local scope, Latte leaks everything into the global object
# (which can be either `global` or `window`), depending on the environment in
# which the library is running.
###############################################################################
root = global ? window


###############################################################################
# For handling these assignments to the global escope, Latte provides two
# basic functions:


### Function `set` ############################################################
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
# scope: `foo=1` and `bar=-1`. They're acessible as any other global variable
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


### Function `defun` ##########################################################
#
#     fun defun obj:obj → list
#
#
# And the `defun` function, which is just an alias for `set`, intended to
# distinguish function definitions from general variable definitions, thus
# making the source code more readable — hell yeah semantics!
##############################################################################
(set defun: set)


###############################################################################
# Calls a function with an explicit context and the given argument array.     #
#                                                                             #
# This will explicitly execute a function within the context of the given     #
# object, that is ``this`` inside the function will refer to that object.     #
#                                                                             #
# If the context object is null or undefined, the context will be either      #
# ``null`` or the global object, depending on the engine and whether it's     #
# running on ES5 strict mode or not.                                          #
#                                                                             #
# Additionally, the function takes an array as the first argument. The items  #
# of this array will be used as the positional arguments for the function.    #
#                                                                             #
# :param Array    args: Positional arguments to pass the function             #
# :param Object   ctx:  Execution context for the function.                   #
# :param Function fn:   Function to execute.                                  #
#                                                                             #
# :returns: Whatever ``fn`` returns.                                          #
###############################################################################
(defun capply: (args, ctx, fn) ->
    (fn.apply ctx, args))


###############################################################################
# Applies a list of arguments to a function.                                  #
#                                                                             #
# This does the same thing as :js:func:`capply`, except that it executes      #
# within a ``null`` context (see the :js:func:`capply` for the implications   #
# of this).                                                                   #
#                                                                             #
# :param Array    args: Positional arguments to pass the function.            #
# :param Function fn:   Function to execute.                                  #
#                                                                             #
# :returns: Whatever ``fn`` returns.                                          #
###############################################################################
(defun apply: (args, fn) ->
    (capply args, null, fn))


###############################################################################
# Calls a function with the given arguments.                                  #
#                                                                             #
# Does basically the same thing as ``apply``, except it accepts positional    #
# arguments rather than an array of parameters.                               #
###############################################################################
(defun call: (args..., fn) ->
    (apply args, fn))


###############################################################################
# Creates local variables, optionally assigning them some value.              #
#                                                                             #
# This is really necessary to have, because unlike JavaScript, CoffeeScript   #
# has just no way of explicitly setting local variables. Instead, it'll set   #
# the variable to local if it doesn't exist in any of the enclosing escopes,  #
# otherwise it'll just use the enclosing escope variable.                     #
#                                                                             #
# And this would do just so many wrong things in Latte...                     #
#                                                                             #
# At any rate, this takes advantage of CoffeeScript's default arguments and   #
# closures (hey, parameters are all local) for faking a ``let block``         #
# thingie.                                                                    #
#                                                                             #
# It's also not the same as ``do (x = 2) -> x * x``, do is used to            #
# automagically creating a closure using the variables in the current scope,  #
# whereas ``letb`` creates entire fresh variables.                            #
#                                                                             #
# ``do (x = 2) -> x * x`` is expanded in the following::                      #
#                                                                             #
#     (function(x) {                                                          #
#         if (x == null) x = 2                                                #
#         return x * x                                                        #
#     })(x)                                                                   #
#                                                                             #
# ``letb (x) -> x * x`` is expanded in the following::                        #
#                                                                             #
#     letb(function(x) {                                                      #
#         if (x == null) x = 2                                                #
#         return x * x                                                        #
#     })                                                                      #
#                                                                             #
# Since ``x`` inside that function will always be null, it effectively        #
# reproduces the behaviour of a ``let`` block.                                #
#                                                                             #
# :param Function fn: Function defining the new scope.                        #
#                                                                             #
# :returns: Whatever ``fn`` returns.                                          #
###############################################################################
(defun letb: (fn) ->
    (fn()))

