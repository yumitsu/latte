###############################################################################
## Latte is a small "lispey" dialect of coffee, written just to test how
## flexible the language's syntax is.
##
## Since the goal of the project is just to test how far this flexibility goes
## without touching the compiler, the syntax will be slight (or a lot)
## different than your usual Lisp implementations. For example, parameters must
## be separated with a comma rather than just plain whitespace, conditionals
## have to use lambda functions for each case, and so on.
##
## There's also no macros, nor quasiquoting. One could implement such features
## on top of this sample impelementation, of course. Since all top-level
## functions are (or rather should be) defined through the `defun` function,
## one could write a hook that preprocesses the function code to implement real
## macros, or at least something closer to Lisp's one.
##
## A good example of such a system is the [Caterwaul][] library. It should work
## nicely with Latte, as long as you keep up the convention of using global
## variables and functions, since using such preprocessing would imply in
## loosing the closure in which the function was initially defined.
##
## [Caterwaul]: https://github.com/spencertipping/caterwaul
###############################################################################

latte =
    version: '0.1.0'


###############################################################################
## Modules
## =======
##
## As a modular library, Latte's functionality is separated by topics. At it's
## very core, the [core](core.html) module provides everything that's needed to
## change the JavaScript/CoffeeScript workflow to something closer to
## Lisp.
##
## Basically the core includes functionality that's shared and relied on by all
## the other modules, like function and variable definition, let blocks and so
## on.
##
## The following modules are included in Latte:
##
## - [core][]        — most basic functionality to abstract CoffeeScript.
## - [ops][]         — defines general operators as functions.
## - [collections][] — functions to iterate and manipulate collections.
## - [listp][]       — functions to manipulate vectors and lists.
## - [types][]       — functions to handle type checking and coercion.
##
## [core]:        core.html
## [ops]:         ops.html
## [collections]: collections.html
## [listp]:       listp.html
## [types]:       types.html
################################################################################
require './core'
require './ops'
require './collections'
require './listp'
require './types'