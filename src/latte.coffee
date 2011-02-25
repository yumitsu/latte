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

_ = require 'underscore'

# Some meta information about the library
latte =
    version: '0.1.0'


# --[ LATTE MODULES ]----------------------------------------------------------
require './core'
require './ops'
require './collections'


# --[ CONSTANTS ]--------------------------------------------------------------
# Used to indicate a given iteration should be stopped.
(set $break: {})


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