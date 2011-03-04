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
# As a weak typed language, most of the comparison functions in JavaScript
# involves some  kind of implicit type coercion. And this is not really a
# problem, as the rules are pretty well defined.
#
# Comparison in Latte is done in pairs. All items of a given list are compared
# to their successors, and succeed if all of the pairs passes the
# comparison. If any of the pair's comparison fails, the entire comparison
# fails and the function returns `false`.
#
# For example, to test if a list contain values that are equivalent to each
# other, you'd use the following:
#
#     >>> (eq 1, "1", 1)
#     true
#
# Which is mapped to something like the following JavaScript:
#
#     >>> (1 == "1") && ("1" == 1)
#     true
#
# Note that the rules of type coercion apply for each pair in this case, so the
# following would fail:
#
#     >>> (eq 1, "1", "001")
#     false
#
# But this would pass:
#
#     >>> (eq "1", 1, "001")
#     true
#
# To force your comparison to be done in a common type, just coerce the types
# in the list:
#
#     >>> (apply eq (map (list 1, "1", "001"), int))
#     true


#### Function `cmp` ###########################################################
#
#     fun cmp list:seq, fun:fn → bool
#
#
# The `cmp` function is the basis of the other comparison functions. It
# compares each pair in the list using the given function.
#
# Since the sequence is iterated using `all`, if the comparison for any pair
# fails the function promptly returns false and doesn't iterates the entire
# sequence. If all of the pairs passes the comparison function, `true` is
# returned.
#
# The callback function doesn't need to explicitly return a boolean. Any falsy
# value indicates that the comparison failed, and truthy values indicates that
# the comparison has succeeded.
#
# Example:
#
#     >>> (cmp (list 1, 2, 3, 4), ((left, right) -> left < right))
#     true
#
#     >>> (cmp (list 2, 4, 8, 12), ((left, right) -> right % left))
#     false  // 12 isn't divisible by 8
###############################################################################
(defun cmp: (seq, fn) ->
    (letb (slen = (len seq)) ->
        (all seq, ((prev, idx) ->
            (yn (idx + 1 >= slen), (-> true)
                                 , (-> fn prev, (car (nth idx + 1, seq))))))))


## Equality ###################################################################
#
# Most of the JavaScript comparison operators are `abstract`. That is, they try
# to convert your data to a common denominator and perform the comparison. This
# can lead to some interesting (and frustrating) stuff, so it's better to know
# the rules of type coercion that are used in JavaScript before diving into the
# possibilities.
#
# As you should know (I really hope you're reading this with a JavaScript
# background...), JavaScript has two equality operators: `==` and `===`; where
# the former one performs type coercion as needed, and the latter returns true
# only when both values have the same type and value.
#
# Unless the functions state otherwise, you should assume that none of them are
# deep-recursive. That is, they don't check the members of an object or of an
# array to compare them. In fact, object comparisons will only use the Object's
# reference.


#### Function `eq` ###########################################################
#
#     fun eq seq... → bool
#
#
# The `eq` function uses ECMAScript's abstract equality algorithm, that is,
# there are implicit type coercions involved. The following table summarises
# what conversions are performed:
#
#
#     ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
#     ┃     Type A    ┃     Type B     ┃              Result               ┃
#     ┣━━━━━━━━━━━━━━━╋━━━━━━━━━━━━━━━━╋━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫
#     ┃ null          ┃ undefined      ┃ true                              ┃
#     ┣━━━━━━━━━━━━━━━╋━━━━━━━━━━━━━━━━╋━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫
#     ┃ undefined     ┃ null           ┃ true                              ┃
#     ┣━━━━━━━━━━━━━━━╋━━━━━━━━━━━━━━━━╋━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫
#     ┃ Number        ┃ String         ┃ A == ToNumber(B)                  ┃
#     ┣━━━━━━━━━━━━━━━╋━━━━━━━━━━━━━━━━╋━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫
#     ┃ String        ┃ Number         ┃ ToNumber(A) == B                  ┃
#     ┣━━━━━━━━━━━━━━━╋━━━━━━━━━━━━━━━━╋━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫
#     ┃ Boolean       ┃ Any            ┃ ToNumber(A) == B                  ┃
#     ┣━━━━━━━━━━━━━━━╋━━━━━━━━━━━━━━━━╋━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫
#     ┃ Any           ┃ Boolean        ┃ A == ToNumber(B)                  ┃
#     ┣━━━━━━━━━━━━━━━╋━━━━━━━━━━━━━━━━╋━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫
#     ┃ String|Number ┃ Object         ┃ A == ToPrimitive(B)               ┃
#     ┣━━━━━━━━━━━━━━━╋━━━━━━━━━━━━━━━━╋━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫
#     ┃ Object        ┃ String|Number  ┃ ToPrimitive(A) == B               ┃
#     ┗━━━━━━━━━━━━━━━┻━━━━━━━━━━━━━━━━┻━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
#
# For more information on Type conversion algorithms, you should check the
# [ECMASpecs][]
#
# [ECMAScpecs]: http://bclary.com/2004/11/07/#a-9
###############################################################################
(defun eq: (seq...) ->
    (cmp seq, ((l, r) -> `l == r`)))


#### Function `eqs` ###########################################################
#
#     fun eqs... → bool
#
#
# For strict comparisons, JavaScript provides the strictly equal operator
# (`===`), which we alias here as the function `eqs`. The algorithm that
# performs the comparison is far simpler than the abstract equality one: for
# each pair of items, they're considered equal if they have the same type and
# the same value.
#
# This doesn't hold true for object comparisons, though. In this case, they'll
# only be considered equal to another object if both items of the pair refer to
# the exactly same object.
#
# For example, the following would actually yield `false`, even though they're
# of the same type and have the same value:
#
#     >>> (seq (list 1, 2, 3), (list 1, 2, 3))
#     false
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