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


# --[ TYPE HANDLING ]----------------------------------------------------------
# Returns a list with the given positional arguments as items
(defun list: (seq...) ->
    (seq))

# Converts something to an integer
(defun int: (item) ->
    (~~item))

# Converts something to a number
(defun num: (item) ->
    (Number item))

# Converts something to a string
(defun str: (item) ->
    (String item))

# Converts something to an object
(defun obj: (item) ->
    (Object item))

# Converts something to a list
(defun to_list: (item) ->
    (_.toArray item))


# --[ TYPE CHECKING ]----------------------------------------------------------
# Checks if something is NaN
(defun nanp: _.isNaN)

# Checks if something is an integer
(defun intp: (item) ->
    ((not (nanp item)) and (eq item, ~~item)))

# Checks if something is a number
(defun nump: _.isNumber)

# Checks if something is a string
(defun strp: _.isString)

# Checks if something is a function
(defun fnp: _.isFunction)

# Checks if something is a list
(defun listp: _.isArray)

# Checks if something is a boolean
(defun boolp: _.isBoolean)

# Checks if something is a RegExp
(defun rep: _.isRegExp)