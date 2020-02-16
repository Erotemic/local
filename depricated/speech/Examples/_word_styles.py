﻿#
# This file is a command-module for Dragonfly.
# (c) Copyright 2008 by Christo Butcher
# Licensed under the LGPL, see <http://www.gnu.org/licenses/>
#

"""
Command-module for styles in **Microsoft Word**
===============================================
This command module controls styles in Microsoft Word.  It 
allows a Word style to be applied directly to the current 
selection or current paragraph by saying "set style 
<style>".  It automatically updates the list of available 
styles within the active document every time Word comes to 
the foreground.

Commands
--------
The following commands are available:

Command: **"set style <style>"**
    Formats the current selection with the given style. 
    The *<style>* extra is the literal name of the style 
    as is visible within Word.

Command: **"(update | synchronize) styles"**
    Refresh the list of styles known to this grammar. 
    This refresh action is also done automatically every 
    time the Word application comes to the foreground.

Customization
-------------
Users can customize the spoken-forms of this module's 
commands in its configuration file.  This is useful for 
translations, for example.

"""

import pkg_resources
pkg_resources.require("dragonfly >= 0.6.5beta1.dev-r76")

import os.path
from win32com.client  import Dispatch
from pywintypes       import com_error

from dragonfly import (ConnectionGrammar, AppContext, DictListRef,
                       CompoundRule, DictList, Config, Section, Item)


#---------------------------------------------------------------------------
# Set up this module's configuration.

config = Config("Microsoft Word styles control")
config.lang                = Section("Language section")
config.lang.set_style      = Item("set style <style>", doc="Spec for setting a style; must contain the <style> extra.")
config.lang.update_styles  = Item("(update | synchronize) styles", doc="Spec for updating style list.")
#config.generate_config_file()
config.load()


#---------------------------------------------------------------------------
# StyleRule which keeps track of and can set available styles.

class StyleRule(CompoundRule):

    spec   = config.lang.set_style
    styles = DictList("styles")
    extras = [DictListRef("style", styles)]

    def _process_recognition(self, node, extras):
        try:
            document = self.grammar.application.ActiveDocument
            document.ActiveWindow.Selection.Style = extras["style"]
        except com_error, e:
            if self._log_proc: self._log_proc.warning("Rule %s:"
                    " failed to set style: %s." % (self, e))

    def reset_styles(self):
        self.styles.set({})

    def update_styles(self):
        # Retrieve available styles.
        try:
            document = self.grammar.application.ActiveDocument
            style_map = [(str(s), s) for s in  document.Styles]
            self.styles.set(dict(style_map))
        except com_error, e:
            if self._log_begin: self._log_begin.warning("Rule %s:"
                    " failed to retrieve styles: %s." % (self, e))
            self.styles.set({})

style_rule = StyleRule()


#---------------------------------------------------------------------------
# Synchronize styles rule for explicitly updating style list.

class SynchronizeStylesRule(CompoundRule):

    spec = config.lang.update_styles

    def _process_recognition(self, node, extras):
        style_rule.update_styles()


#---------------------------------------------------------------------------
# This module's main grammar.

class WordStylesGrammar(ConnectionGrammar):

    def __init__(self):
        name = self.__class__.__name__
        context = AppContext(executable="winword")
        app_name = "Word.Application"
        ConnectionGrammar.__init__(self, name=name,
            context=context, app_name=app_name)

    def connection_up(self):
        # Made connection with word -> retrieve available styles.
        style_rule.update_styles()

    def connection_down(self):
        # Lost connection with word -> empty style list.
        style_rule.reset_styles()

grammar = WordStylesGrammar()
grammar.add_rule(style_rule)
grammar.add_rule(SynchronizeStylesRule())


#---------------------------------------------------------------------------
# Load the grammar instance and define how to unload it.

grammar.load()

# Unload function which will be called by natlink at unload time.
def unload():
    global grammar
    if grammar: grammar.unload()
    grammar = None
