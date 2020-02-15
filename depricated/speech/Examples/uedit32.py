#
# This file is a command-module for Dragonfly.
# (c) Copyright 2008 by Christo Butcher
# Licensed under the LGPL, see <http://www.gnu.org/licenses/>
#

"""
Command-module for **UltraEdit** editor
=======================================

This module offers various commands for `UltraEdit
<http://www.ultraedit.com/products/ultraedit.html>`_,
a powerful text and source code editor.

"""


#---------------------------------------------------------------------------

from dragonfly import (Grammar, AppContext, MappingRule,
                       Dictation, Choice, IntegerRef, NumberRef,
                       Key, Text, Repeat)


#---------------------------------------------------------------------------
# Create the main command rule.

class CommandRule(MappingRule):

    mapping = {
        "menu file":                    Key("a-f"),
        "menu edit":                    Key("a-e"),
        "menu search":                  Key("a-s"),
        "menu project":                 Key("a-p"),
        "menu view":                    Key("a-v"),
        "menu format":                  Key("a-t"),
        "menu column":                  Key("a-l"),
        "menu macro":                   Key("a-m"),
        "menu scripting":               Key("a-i"),
        "menu advance":                 Key("a-a"),
        "menu window":                  Key("a-w"),
        "menu help":                    Key("a-h"),

        # File menu.
        "new file":                     Key("c-n"),
        "open file":                    Key("c-o, s-tab"),
        "open filename <dict>":         Key("c-o") + Text("%(dict)s\n"),
        "close file":                   Key("a-f, c"),
        "close <1to9> files":           Key("a-f, c") * Repeat(extra="1to9"),
        "close window <1to9>":          Key("a-w, %(1to9)d/20, a-f, c"),
        "save file":                    Key("c-s"),
        "save file as":                 Key("a-f, a"),
        "save backup":                  Key("a-f, y"),
        "revert to saved":              Key("a-f, d"),
        "revert to saved force":        Key("a-f, d, enter"),
        "print file":                   Key("c-p"),
        "page setup":                   Key("a-f, g, t"),
        "print setup":                  Key("a-f, g, u"),
        "recent files":                 Key("a-f, l"),
        "recent projects":              Key("a-f, k"),
        "recent project <1to9>":        Key("a-f, k/20, %(1to9)d"),

        # Edit menu.
        "copy file path":               Key("a-e, f"),
        "copy this word":               Key("c-j, c-c"),

        # Search menu.
        "search find":                  Key("c-f"),
        "search find <dict>":           Key("c-f") + Text("%(dict)s\n"),
        "search next":                  Key("f3"),
        "search replace":               Key("c-r"),
        "search replace <dict> with <dict2>": Key("c-r") \
                                        + Text("%(dict)s\t%(dict2)s"),
        "find in files":                Key("a-s, i"),
        "find this word in files":      Key("c-j, a-s, i"),
        "phi phi this word":            Key("c-j, a-s, i/20, enter"),

        # Format menu.
        "convert tabs to spaces":       Key("a-t, s"),
        "format paragraph":             Key("c-t"),
        "paragraph formatting":         Key("a-t, f, s"),

        # Advanced menu.
        "run command":                  Key("c-f9"),
        "run command in window <1to9>": Key("c-s, a-w, %(1to9)d/40, c-f9"),
        "run [command] in window <1to9>": Key("c-s, a-w, %(1to9)d/40, c-f9"),
        "run command menu":             Key("f9"),
        "advanced configuration":       Key("a-a, c"),
        "set tab stop to <1to9> [spaces]": Key("a-a, c/20, home/20, down:7/10, tab/5:8")
                                         + Text("%(1to9)d\t%(1to9)d\n"),

        # Window menu.
        "window <1to9>":                Key("a-w, %(1to9)d"),
        "window list":                  Key("a-w, w"),

        # Miscellaneous shortcuts.
        "center cursor":                Key("a-npmul"),
        "cursor to top":                Key("a-npsub"),
        "cursor to bottom":             Key("a-npadd"),
        "[go to] line <int>":           Key("c-g")
                                         + Text("%(int)d") + Key("enter"),
        "[mark] lines <int> through <int2>":
                                        Key("c-g") + Text("%(int)d\n")
                                         + Key("c-g") + Text("%(int2)d")
                                         + Key("s-enter"),
        }
    extras = [
              Dictation("dict"),
              Dictation("dict2"),
              IntegerRef("1to9", 1, 10),
              NumberRef("int"),
              NumberRef("int2"),
              Choice("zoom",
                    {"75": "7", "100": "1", "page width": "p",
                     "text width": "t", "whole page": "w",
                    }),
             ]


#---------------------------------------------------------------------------

context = AppContext(executable="uedit32")
grammar = Grammar("UltraEdit", context=context)
grammar.add_rule(CommandRule())
grammar.load()

def unload():
    global grammar
    if grammar: grammar.unload()
    grammar = None
