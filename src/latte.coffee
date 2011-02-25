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