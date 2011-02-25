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


# --[ TYPE HANDLING ]----------------------------------------------------------
(defun list: (seq...) ->
    (seq))