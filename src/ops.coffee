###############################################################################
# ~ latte/ops.coffee ~                                                        #
#                                                                             #
# Defines general operators for handling data.                                #
#                                                                             #
#                                                                             #
# --------------------------------------------------------------------------- #
#         Copyright (c) Quildreen Motta <http://www.mottaweb.com.br/>         #
#                                                                             #
#  Licenced under MIT/X11. See ``LICENCE.txt`` in the root directory of the   #
#                        package for more information.                        #
###############################################################################


# --[ CONDITIONALS ]-----------------------------------------------------------
###############################################################################
# Makes a truth tests, calls ``pass`` if it passes, ``fail`` otherwise.       #
#                                                                             #
# YepNope will check whether the given test is *truthy* in JavaScript. The    #
# language defines a few values that are *falsy*, whereas all the others are  #
# considered *truthy*.                                                        #
#                                                                             #
# The following is a list of JavaScript's *falsy* values:                     #
#                                                                             #
# - empty string ``""``                                                       #
# - the Number ``0``                                                          #
# - the boolean primitive ``false``                                           #
# - ``null``                                                                  #
# - ``undefined``                                                             #
#                                                                             #
# Everything else is considered *truthy*, including empty lists (``[]``) or   #
# empty objects (``{}``).                                                     #
#                                                                             #
# .. warning::                                                                #
#    ``new Boolean(false)`` is an Object and therefore considered **truthy**, #
#    same goes for ``new Number(0)``, ``new String("")``.                     #
#                                                                             #
# :param          test: The value to test.                                    #
# :param Function pass: The function to call if the test passes.              #
# :param Function fail: The function to call if the test fails.               #
#                                                                             #
# :returns: the result of ``pass`` if the test passes, the result of ``fail`` #
#           otherwise.                                                        #
###############################################################################
(defun yn: (test, pass, fail) ->
    (if test then pass?() else fail?()))


###############################################################################
# Alias for ``yn`` that only cares about the test failing                     #
#                                                                             #
# See :js:func:`yn` for more information.                                     #
#                                                                             #
# :param          test: The value to test.                                    #
# :param Function fn:   The function to call if the test fails.               #
#                                                                             #
# :returns: ``undefined`` if the test passes, the result of ``fn`` otherwise. #
###############################################################################
(defun n: (test, fn) ->
    (yn test, null, fn))


###############################################################################
# Tests for the conditions in order until something is truth.                 #
#                                                                             #
# The ``cond`` operator is the answer for all those stuff you'd do with a     #
# if/else if/else block in JavaScript. It takes as many positional functions  #
# as you need, and starts calling these functions in order.                   #
#                                                                             #
# When a function returns anything other than ``null`` or ``undefined`` that  #
# value is then returned from the condition and the iteration is stopped.     #
#                                                                             #
# Since all of the positional arguments are functions that are called in      #
# order to decide if they should be used as the return value, you have to use #
# another thing for testing your expressions (if you want to). The YepNope    #
# (:js:func:`yn`) is pretty useful for that!                                  #
#                                                                             #
# Example::                                                                   #
#                                                                             #
#     >>> (letb (x = "bar") ->                                                #
#     ...  (cond (-> (yn x == "foo", -> "x is foo!"))                         #
#     ...      , (-> (yn x == "bar", -> "x is bar!"))                         #
#     ...      , (-> (yn y == x, -> "nowai!"))))                              #
#     ...                                                                     #
#     "x is bar!"                                                             #
#                                                                             #
# Note that there's no problem in the next function comparing ``y`` to ``x``, #
# even though ``y`` is not defined in that context. This is because since the #
# previous test passes, the ``cond`` function doesn't even bother with the    #
# other ones.                                                                 #
#                                                                             #
# :param Function tests: Positional functions to test.                        #
#                                                                             #
# :returns: Whatever the first function to pass the nullable test returns.    #
###############################################################################
(defun cond: (tests...) ->
    (call (first tests, ((test) -> test()?))))


# --[ COMPARISON FUNCTIONS ]---------------------------------------------------
###############################################################################
# Compares a list using the given function.                                   #
#                                                                             #
# This is a general comparison function, that takes a sequence as the first   #
# argument and a function as the second.                                      #
#                                                                             #
# The sequence is iterated using `all`. For each pair of items in the         #
# sequence the callback function is called and expected to return whether the #
# comparison for the given pair succeeds or fails.                            #
#                                                                             #
# If said callback returns any falsy value, the iteration is stopped and the  #
# comparison fails — false is returned. Otherwise, if the iteration completes #
# successfully, the comparison succeeds — true is returned.                   #
#                                                                             #
# Example::                                                                   #
#                                                                             #
#     >>> (cmp (list 1, 2, 3, 4), ((left, right) -> left < right))            #
#     true                                                                    #
#                                                                             #
# Is the equivalent of::                                                      #
#                                                                             #
#     >>> 1 < 2 < 3 < 4                                                       #
#     true                                                                    #
#                                                                             #
# Or in plain JavaScript, which reproduces better (and more explicitly) what  #
# actually happens::                                                          #
#                                                                             #
#     >>> (1 < 2) && (2 < 3) && (3 < 4)                                       #
#     true                                                                    #
#                                                                             #
# :param Array seq: The sequence to test.                                     #
# :param Function fn: The function to test the pairs in the sequence          #
#                                                                             #
# :results: ``true`` or ``false``, depending on the success of the            #
#           comparison.                                                       #
###############################################################################
(defun cmp: (seq, fn) ->
    (letb (slen = (len seq)) ->
        (all seq, ((prev, idx) ->
            (yn (idx + 1 >= slen), (-> true)
                                 , (-> fn prev, (car (nth idx + 1, seq))))))))


###############################################################################
# Compares if all items on the list are loosely equal `l == r`.               #
#                                                                             #
# On each pair, type coercion is performed as needed — that is, if the items  #
# being tested are not of the same type, JavaScript will convert them to a    #
# common format that it can use to compare both.                              #
#                                                                             #
# JavaScript's type coercion is regarded by many (myself included) as weird,  #
# but the rules are well defined, of course. The following table tries to     #
# summarise it, but you can always check ECMAScript's algorithm for abstract  #
# equality.                                                                   #
#                                                                             #
# +---------------+----------------+-----------------------------------+      #
# |     Type A    |     Type B     |              Result               |      #
# +===============+================+===================================+      #
# | null          | undefined      | true                              |      #
# +---------------+----------------+-----------------------------------+      #
# | undefined     | null           | true                              |      #
# +---------------+----------------+-----------------------------------+      #
# | Number        | String         | A == ToNumber(B)                  |      #
# +---------------+----------------+-----------------------------------+      #
# | String        | Number         | ToNumber(A) == B                  |      #
# +---------------+----------------+-----------------------------------+      #
# | Boolean       | Any            | ToNumber(A) == B                  |      #
# +---------------+----------------+-----------------------------------+      #
# | Any           | Boolean        | A == ToNumber(B)                  |      #
# +---------------+----------------+-----------------------------------+      #
# | String|Number | Object         | A == ToPrimitive(B)               |      #
# +---------------+----------------+-----------------------------------+      #
# | Object        | String|Number  | ToPrimitive(A) == B               |      #
# +---------------+----------------+-----------------------------------+      #
#                                                                             #
# For more information on Type conversion algorithms, you should check the    #
# `ECMASpecs`_.                                                               #
#                                                                             #
# .. _ECMAScpecs: http://bclary.com/2004/11/07/#a-9                           #
#                                                                             #
# For more information on how the comparison is performed, see :js:func:`cmp` #
#                                                                             #
# :param seq: Positional arguments with the items to compare.                 #
#                                                                             #
# :returns: ``true`` if all items are abstractly equal, ``false`` otherwise.  #
###############################################################################
(defun eq: (seq...) ->
    (cmp seq, ((l, r) -> `l == r`)))


###############################################################################
# Compares if all items on the list are strictly equal `l === r`              #
#                                                                             #
# The strict comparison function is rather easier than the abstract equality  #
# function, since there's no type coercion involved. For each pair of items,  #
# it returns ``true`` if all items are of the same type and equal to each     #
# other, and ``false`` if they aren't.                                        #
#                                                                             #
# Note that this functions doesn't do deep comparisons for Objects. In this   #
# case, one object will only be considered equal to another where they're     #
# exactly the same — they refer to the same object.                           #
#                                                                             #
# For example, the following would actually yield ``false``::                 #
#                                                                             #
#     >>> (seq (list 1, 2, 3), (list 1, 2, 3))                                #
#     false                                                                   #
#                                                                             #
# Since the lists points to distinct objects, despite having being            #
# equivalent.                                                                 #
#                                                                             #
# :param seq: Positional arguments for each item to compare.                  #
#                                                                             #
# :returns: ``true`` if all items are equal, ``false`` otherwise.             #
###############################################################################
(defun eqs: (seq...) ->
    (cmp seq, ((l, r) -> l is r)))


# Compares if all preceding items are greater than their successors
(defun gt: (seq...) ->
    (cmp seq, ((l, r) -> l > r)))

# Compares if all prec items are greater or loosely equal to their successors
(defun gte: (seq...) ->
    (cmp seq, ((l, r) -> (l >= r))))

# Compares if all preceding items are lower than their sucessors
(defun lt: (seq...) ->
    (cmp seq, ((l, r) -> l < r)))

# Compares fi all prec items are lower or loosely equal to their successors
(defun lte: (seq...) ->
    (cmp seq, ((l, r) -> (l <= r))))

