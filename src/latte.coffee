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

latte =
    version: '0.1.0'


# --[ CORE ]-------------------------------------------------------------------
# Defines global variables
(root.set = (obj) ->
    ((root[name] = value) for name, value of obj))

# Defines named global functions
(set defun: (obj) ->
    (set obj))

# Calls a function with an explicit context
(defun capply: (args, ctx, fn) ->
    (fn.apply ctx, args))

# Applies a list of arguments to a function
(defun apply: (args, fn) ->
    (capply args, null, fn))

# Calls a function
(defun call: (args..., fn) ->
    (fn.call args))


# Takes advantage of CoffeeScript's default arguments and parameter closure for
# faking a `let block` thingie
(defun letb: (fn) ->
    (fn()))

# --[ CONSTANTS ]--------------------------------------------------------------
(set $break: {})


# --[ CONDITIONALS ]-----------------------------------------------------------
# Makes a truth tests, calls pass if it passes, fail otherwise
(defun yn: (test, pass, fail) ->
    (if test then pass?() else fail?()))

# Alias for yn that only cares about the test failing
(defun n: (test, fn) ->
    (yn test, null, fn))

# Tests for the conditions in order until something is truth
(defun cond: (tests...) ->
    (call (first tests, ((test) -> test()))))


# --[ COMPARISON FUNCTIONS ]---------------------------------------------------
# Compares a list using the given function.
(defun cmp: (seq, fn) ->
    (letb (slen = (len seq)) ->
        (all seq, ((prev, idx) ->
            (yn (idx + 1 >= slen), (-> true)
                                 , (-> fn prev, (nth idx, seq)))))))

(defun eq: (seq...) ->
    (cmp seq, ((l, r) -> `l == r`)))


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