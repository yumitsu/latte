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


# Takes advantage of CoffeeScript's default arguments and parameter closure for
# faking a `let block` thingie
(defun letb: (fn) ->
    (fn()))


# --[ CONSTANTS ]--------------------------------------------------------------
(set $break: {})


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
                (n >= slen and (list n, $break)) \
                           or  (list n, item)))))

# Arbitrary iterator over a sequence using a stepper generator
(defun iter: (seq, stepper, fn) ->
    (step = (stepper seq))
    (until step() is $break
        (apply step.item, fn)))


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