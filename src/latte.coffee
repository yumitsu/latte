###############################################################################
# ~ latte.coffee ~                                                            #
#                                                                             #
# A small Lispey dialect of coffee. Just for the sake of it :D                #
#                                                                             #
# Yes, the library leaks everything to globals, ain't that delicious? :3      #
#                                                                             #
#                                                                             #
# --------------------------------------------------------------------------- #
#         Copyright (c) Quildreen Motta <http://www.mottaweb.com.br/>         #
#                                                                             #
#  Licenced under MIT/X11. See ``LICENCE.txt`` in the root directory of the   #
#                        package for more information.                        #
###############################################################################

_    = require 'underscore'
root = global ? window


# Some meta information about the library
latte =
    version: '0.1.0'


# --[ CORE ]-------------------------------------------------------------------
###############################################################################
# Defines global variables.                                                   #
#                                                                             #
# The function takes a JavaScript object, mapping keys to arbitrary values,   #
# and unpacks everything in the global escope, depending on the environment.  #
#                                                                             #
# :param Object obj: object to unpack properties.                             #
#                                                                             #
# :returns: A list of all the values in the object.                           #
###############################################################################
(root.set = (obj) ->
    ((root[name] = value) for name, value of obj))


###############################################################################
# Defines named global functions.                                             #
#                                                                             #
# This is just a alias for :js:func:`set`, intended to make distinguishing    #
# function definitions from general variable definitions easier and more      #
# readable.                                                                   #
###############################################################################
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


# --[ CONSTANTS ]--------------------------------------------------------------
###############################################################################
# Used to indicate a given iteration should be stopped.                       #
###############################################################################
(set $break: {})


require './ops'


# --[ ITERATION ]--------------------------------------------------------------
# Stepper generator
(defun stepper: (seq, fn) ->
    (letb (idx = 0, item, next) ->
        (next = ->
            [idx, item] = fn(idx, seq)
            next.item   = item)
        (next)))

# Pair stepper generator
(defun pair_stepper: (seq) ->
    (letb (slen = (len seq)) ->
        (stepper seq, (idx) ->
            (letb (n = idx + 1, item = (nth  idx, seq, 2)) ->
                (yn (n >= slen), (-> list n, $break)
                               , (-> list n, item))))))

# Arbitrary iterator over a sequence using a stepper generator
(defun iter: (seq, stepper, fn) ->
    (step = (stepper seq))
    (until step() is $break
        (apply step.item, fn)))

# Iterates over the list of items calling the iterator function on all
(defun each: _.each)

# Maps the values in the list according to the iterator function
(defun map: _.map)


# --[ GENERAL COLLECTION HANDLING ]--------------------------------------------
# Folds a list from top-down
(defun fd: _.reduce)

# Folds a list from bottom-up
(defun fu: _.reduceRight)

# Returns the first value that passes a truth test
(defun first: _.detect)

# Returns only values that pass a truth test in the given sequence
(defun filter: _.select)

# Returns a list without items that pass a truth test
(defun reject: _.reject)

# Returns true if all elements pass a truth test
(defun all: _.all)

# Returns true if at least one value pass a truth test
(defun any: _.any)

# Returns true if the sequence contains a value
(defun has: _.include)

# Returns the maximum value in the list
(defun max: _.max)

# Returns the minimum value in the list
(defun min: _.min)

# Returns a sorted list
(defun sort: (seq, fn = (x) -> x) ->
    (_.sort seq, fn))

# Calls the a method in all items of the sequence
(defun invoke: _.invoke)



# --[ LIST PROCESSING ]--------------------------------------------------------
# Returns the first element of a cons cell
(defun car: _.first)

# Returns the last element of a cons cell
(defun cdr: _.rest)

# Returns the nth element of a sequence
(defun nth: (idx, seq, count = 1) ->
    (seq.slice idx, idx + count))

# Returns the length of a sequence
(defun len: _.size)



# --[ TYPE HANDLING ]----------------------------------------------------------
(defun list: (seq...) ->
    (seq))