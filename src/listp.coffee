###############################################################################
# ~ latte/listp.coffee ~                                                      #
#                                                                             #
# General manipulation functions for list objects.                            #
#                                                                             #
#                                                                             #
# --------------------------------------------------------------------------- #
#         Copyright (c) Quildreen Motta <http://www.mottaweb.com.br/>         #
#                                                                             #
#  Licenced under MIT/X11. See ``LICENCE.txt`` in the root directory of the   #
#                        package for more information.                        #
###############################################################################

_ = require 'underscore'


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


