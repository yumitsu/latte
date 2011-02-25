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
# Makes a truthy tests, calls pass if it passes, fail otherwise
(defun yn: (test, pass, fail) ->
    (if test then pass?() else fail?()))

# Tests for the conditions in order until something is truthy
(defun cond: (tests...) ->
    (call (first tests, ((test) -> test()))))


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

# Returns the first value that passes a truthy test
(defun first: _.detect)


# --[ LIST PROCESSING ]--------------------------------------------------------
# Returns the first element of a cons cell
(defun car: (seq) ->
    (_.first seq))

# Returns the last element of a cons cell
(defun cdr: (seq) ->
    (_.rest seq))

# Returns the nth element of a sequence
(defun nth: (idx, seq, count = 1) ->
    (seq.slice idx, idx + count))

# Returns the length of a sequence
(defun len: (seq) ->
    (seq.length))


# --[ TYPE HANDLING ]----------------------------------------------------------
(defun list: (seq...) ->
    (seq))