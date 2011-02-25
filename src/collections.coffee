###############################################################################
# ~ latte/collections.coffee ~                                                #
#                                                                             #
# A handful of functions to deal with iterating over and manipulating general #
# collections, which include both Objects and Lists (Arrays).                 #
#                                                                             #
#                                                                             #
# --------------------------------------------------------------------------- #
#         Copyright (c) Quildreen Motta <http://www.mottaweb.com.br/>         #
#                                                                             #
#  Licenced under MIT/X11. See ``LICENCE.txt`` in the root directory of the   #
#                        package for more information.                        #
###############################################################################

_ = require 'underscore'


# --[ CONSTANTS ]--------------------------------------------------------------
# Used to indicate a given iteration should be stopped.
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


