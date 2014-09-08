#
# This file is a command-module for Dragonfly.
# (c) Copyright 2008 by Christo Butcher
# Licensed under the LGPL, see <http://www.gnu.org/licenses/>
#

"""
Command-module to control **Windows Explorer**
============================================================================

This module defines various voice-commands for use with Windows Explorer.

.. note::

   This module is still under development.

Installation
----------------------------------------------------------------------------

If you are using DNS and Natlink, simply place this file in you Natlink 
macros directory.  It will then be automatically loaded by Natlink when 
you next toggle your microphone or restart Natlink.

"""

try:
    import pkg_resources
    pkg_resources.require("dragonfly >= 0.6.5beta1.dev-r76")
except ImportError:
    pass

import os.path
import string
import subprocess
import time
from urllib import unquote
from dragonfly import (ConnectionGrammar, AppContext, CompoundRule,
                       Choice, Window, Config, Section, Item)


#---------------------------------------------------------------------------

class SingleFile(object):

    def __init__(self, spec, command_line):
        self.spec = spec
        self.command_line = command_line

    def execute(self, paths, directory):
        for path in paths:
            self.execute_single(path, directory)

    def execute_single(self, path, directory):
        data = {"path": path, "dir": directory}
        arguments = [s % data for s in self.command_line]
        print "Arguments: %r" % arguments
        process = subprocess.Popen(arguments, stdout=subprocess.PIPE)
        out, err = process.communicate()
        print "Output:"; print out and out.strip()
        print "Error:"; print err and err.strip()


class MultiFile(object):

    def __init__(self, spec, command_line_pre, command_line_post):
        self.spec = spec
        self.command_line_pre  = command_line_pre
        self.command_line_post = command_line_post

    def execute(self, paths, directory):
        data = {"dir": directory}
        arguments_pre  = [s % data for s in self.command_line_pre]
        arguments_post = [s % data for s in self.command_line_post]
        arguments = arguments_pre + paths
        if arguments_post:
            arguments += arguments_post

        print "Arguments: %r" % arguments
        process = subprocess.Popen(arguments, stdout=subprocess.PIPE)
        out, err = process.communicate()
        print "Output:"; print out and out.strip()
        print "Error:"; print err and err.strip()


class CreateArchiveHere(object):

    def __init__(self, spec, extension):
        self.spec = spec
        self.extension = extension

    def execute(self, paths, directory):
        archive_path = os.path.splitext(os.path.basename(paths[0]))[0]
        archive_path = os.path.join(directory, archive_path)
        archive_path += time.strftime("-%y%m%d")

        def filenames(basename, extension):
#            yield basename + extension
            for letter in string.lowercase:
                yield basename + letter + extension

        available = False
        for archive_path in filenames(archive_path, self.extension):
            if not os.path.exists(archive_path):
                available = True
                break
        if not available:
            print "Warning: could not create archive."
            return

        arguments = [r"C:\Program Files\7-Zip\7z.exe", "a"]
        arguments.append("-o" + directory)
        arguments.append(archive_path)
#        arguments.append(os.path.splitext(archive_path)[0])
        arguments.extend(paths)

        print "Arguments: %r" % arguments
        process = subprocess.Popen(arguments, stdout=subprocess.PIPE)
        out, err = process.communicate()
        print "Output:"; print out and out.strip()
        print "Error:"; print err and err.strip()

class RenameFile(object):

    python_path = r"C:\Python25\python.exe"
    rename_dialog_path = os.path.join(os.path.dirname(__file__),
                                      "dialog_rename.py")

    def __init__(self, spec):
        self.spec = spec

    def execute(self, paths, directory):
        if len(paths) == 0:
            print "Rename file error: nothing selected."
            return
        path = paths[0]

        arguments = [self.python_path, self.rename_dialog_path, path]
        subprocess.Popen(arguments)


#---------------------------------------------------------------------------

commands = [
            SingleFile("open with ultra [edit]",
                       [r"C:\Program Files\IDM Computer Solutions\UltraEdit\Uedit32.exe", "%(path)s"]),
            MultiFile("scan for (virus | viruses) | virus scan",
                       [r"C:\Program Files\F-Secure\Anti-Virus\fsav.exe"], ["/list"]),
            SingleFile("extract archive here",
                       [r"C:\Program Files\7-Zip\7z.exe", "x", "-o%(dir)s", "%(path)s"]),
            CreateArchiveHere("create zip archive here", ".zip"),
            CreateArchiveHere("create [7] archive here", ".7z"),
            RenameFile("rename file dialog"),
           ]


#---------------------------------------------------------------------------
# Utility generator function for iterating over COM collections.

def collection_iter(collection):
    for index in xrange(collection.Count):
        yield collection.Item(index)


#---------------------------------------------------------------------------
# This module's main grammar.

class ControlGrammar(ConnectionGrammar):

    def __init__(self):
        ConnectionGrammar.__init__(
            self,
            name="Explorer control",
            context=AppContext(executable="explorer"),
            app_name="Shell.Application"
           )

    def get_active_explorer(self):
        handle = Window.get_foreground().handle
        for window in collection_iter(self.application.Windows()):
            if window.HWND == handle:
                return window
        self._log.warning("%s: no active explorer." % self)
        return None

    def get_selected_paths(self):
        window = self.get_active_explorer()
        items = window.Document.SelectedItems()
        paths = []
        for item in collection_iter(items):
            paths.append(item.Path)
        print "Selected paths: %r" % paths
        return paths

    def get_selected_filenames(self):
        paths = self.get_selected_paths()
        return [os.path.basename(p) for p in paths]

    def get_current_directory(self):
        window = self.get_active_explorer()
        path = window.LocationURL[8:]
        if path.startswith("file:///"):
            path = path[8:]
        return unquote(path)

grammar = ControlGrammar()


#---------------------------------------------------------------------------

class ListSelectionRule(CompoundRule):
    spec = "list current selection"
    def _process_recognition(self, node, extras):
        print "Current selection:"
        for filename in self.grammar.get_selected_filenames():
            print " - %r" % filename

grammar.add_rule(ListSelectionRule())


#---------------------------------------------------------------------------

class CommandRule(CompoundRule):

    spec = "[command] <command>"
    extras = [Choice("command", dict((c.spec, c) for c in commands))]

    def _process_recognition(self, node, extras):
        command = extras["command"]
        paths = self.grammar.get_selected_paths()
        directory = self.grammar.get_current_directory()
        print "Selected paths: %r" % paths
        command.execute(paths, directory)

grammar.add_rule(CommandRule())


#---------------------------------------------------------------------------
# Load the grammar instance and define how to unload it.

grammar.load()

# Unload function which will be called by natlink at unload time.
def unload():
    global grammar
    if grammar: grammar.unload()
    grammar = None
