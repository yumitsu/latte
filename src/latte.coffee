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


# --[ CORE ]-------------------------------------------------------------------
# Defines a global variable
root.setq = (name, value) ->
    root[name] = value


# Defines a named global function
(setq "defun", (obj) ->
    ((setq name, fn) for name, fn of obj))


# Calls a function with an explicit context
(defun capply: (ctx, fn, args) ->
    (fn.apply ctx, args))

# Applies a list of arguments to a function
(defun apply:  (fn, args) ->
    (capply null, fn, args))


# --[ LIST PROCESSING ]--------------------------------------------------------
# Concatenates a sequence
(defun cat: (seq...) ->
    (reduce append, seq, []))

# Folds a sequence from left to right
(defun reduce: (fn, seq, sval) ->
    (_.reduce seq, fn, sval))

# Folds a sequence from right to left
(defun reduce_right: (fn, seq, sval) ->
    (_.reduceRight seq, fn, sval))

# Maps a sequence using a helper function
(defun map: (fn, seq) ->
    (_.map seq, fn))

# Appends an item to a sequence
(defun append: (seq, item) ->
    (seq.push item))

# Returns the first item of a sequence
(defun car:  _.first)

# Returns the rest of items of a sequence (everything but first)
(defun cdr:  _.rest)

# Creates a cons using given car and cdr values
(defun cons: (left, right) ->
    (cat (list left), right))


# --[ TYPE HANDLING ]----------------------------------------------------------
# Casts any object to a list
(defun list: (obj...) -> obj)