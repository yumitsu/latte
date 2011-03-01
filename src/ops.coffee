###############################################################################
#
# As an imperative language, JavaScript (and CoffeeScript) define operators to
# handle data. But these operators are nowhere as powerful as their Lisp
# counterpart, and they don't feel `functional` as well.
#
# To solve this minor nitpicking of mine, all general operators are rewritten
# as functions by this module. While certainly slower than the built-in
# symbols, they are more convenient and blend in better with the flow of the
# code.


## Conditionals ###############################################################
#
# In order to map our truth testing constructs to functions in CoffeeScript we
# first have to solve the problem of controlling the flow of the program. So,
# where a construct would execute code `x` when a test passes, or test `y` when
# a test fails, the program must be able to manipulate this control flow.
#
# Given they would be simple expressions passed in the parameters, the only way
# this could work would be by wrapping each possible branch of the flow in a
# function, this way it wouldn't be evaluated right after the definition.
#
# The following functions all rely on this workaround to manipulate
# JavaScript's control flow, taking advantage of the sweet syntax for defining
# anonymous function in CoffeeScript.
#
# The most common case of branching is an `if-else` construct, that defines a
# piece of code to be executed when an arbitrary condition passes a truth test,
# or another piece of code otherwise.
#
# For these Latte provides a simple `YepNope` function, that will take a
# boolean expression, and two functions. The first function (`pass`) will be
# called when the expression is **truthy**, and the second (`fail`) when the
# expression is **falsy**.
#
# JavaScript has the following values as **falsy** ones:
#
# - empty string (`""`)
# - the number `0`
# - the boolean primitive `false`
# - `null`
# - `undefined`
#
# Everything else is considered **truthy**, including empty lists (`[]`) and
# empty objects (`{}`)
#
# Note that `new Boolean(false)` is an Object, and therefore **truthy**. The
# same goes for `new Number(0)` and `new String("")`.


#### Function `yn` ############################################################
#
#     fun yn bool:test, fun:pass, fun:fail → pass() or fail() depending on test
#
#
# The function is the basic `YepNope` construct in Latte. It'll call the
# function passed in the `pass` argument when `test` is truthy and `false`
# otherwise, returning the values of those calls:
#
#     >>> (yn [], (-> "yay"), (-> "nay"))
#     "yay"
#     >>> (yn "", (-> "yay"), (-> "nay"))
#     "nay"
#
###############################################################################
(defun yn: (test, pass, fail) ->
    (if test then pass?() else fail?()))


#### Function `n` #############################################################
#
#     fun n bool:test, fun:fn → fn() if test is falsy, undefined otherwise
#
#
# If you only care about failing though, you don't need to go through the whole
# `YepNope` construct. In this case the `n` function works as an `unless`
# clause. That is, it calls the function only if the test fails:
#
#     >>> (n 0 (-> "foo"))
#     "foo"
#     >>> (n 1 (-> "foo"))
#     undefined
#
###############################################################################
(defun n: (test, fn) ->
    (yn test, null, fn))


#### Function `cond` ##########################################################
#
#     fun cond tests... → the result of the first condition to pass
#
#
# When you need to test for several different conditions, the `YepNope` pattern
# obviously gets out of hand. The Shceme's `cond` construct was also ported to
# Latte, using the same premises as the above functions.
#
# It accepts any number of `test conditions` — functions that return null or
# undefined if the condition fails, or anything else if it passes. All of the
# conditions are evaluated in order, and when one of the test passes it's
# return value is returned from the function and iteration stops.
#
# Since all of the positional arguments are just functions to be called, in
# order to decide if they should be used as the return value you'll often need
# to test another arbitrary condition. The `YepNope` pattern is pretty useful
# here:
#
#     >>> (letb (x = "bar") ->
#     ...   (cond (-> (yn (eq x, "foo"), -> "x is foo!"))
#     ...       , (-> (yn (eq x, "bar"), -> "x is bar!"))
#     ...       , (-> (yn (eq y, x),     -> "nowai!"))))
#     ...
#     "x is bar!"
#
#
# Note that since iteration stops after the first match (`x == bar`), there's
# no problem in having the next function compare `y` to `x`, even though `y` is
# not defined in the context — `cond` won't even bother calling the other
# functions.
###############################################################################
(defun cond: (tests...) ->
    (call (first tests, ((test) -> test()?))))


## Comparison #################################################################
#
#
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