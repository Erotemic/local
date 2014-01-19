#!/usr/bin/env python

############################################################################
# 
#  Copyright (C) 2004-2005 Trolltech AS. All rights reserved.
# 
#  This file is part of the example classes of the Qt Toolkit.
# 
#  This file may be used under the terms of the GNU General Public
#  License version 2.0 as published by the Free Software Foundation
#  and appearing in the file LICENSE.GPL included in the packaging of
#  self file.  Please review the following information to ensure GNU
#  General Public Licensing requirements will be met:
#  http://www.trolltech.com/products/qt/opensource.html
# 
#  If you are unsure which license is appropriate for your use, please
#  review the following information:
#  http://www.trolltech.com/products/qt/licensing.html or contact the
#  sales department at sales@trolltech.com.
# 
#  This file is provided AS IS with NO WARRANTY OF ANY KIND, INCLUDING THE
#  WARRANTY OF DESIGN, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
# 
############################################################################

import sys
from PySide import QtCore, QtGui


class MainWindow(QtGui.QMainWindow):
    def __init__(self, parent=None):
        QtGui.QMainWindow.__init__(self, parent)
        
        w = QtGui.QWidget()
        self.setCentralWidget(w)
        
        topFiller = QtGui.QWidget()
        topFiller.setSizePolicy(QtGui.QSizePolicy.Expanding,
                                QtGui.QSizePolicy.Expanding)

        self.infoLabel = QtGui.QLabel(self.tr("<i>Choose a menu option, or "
                                              "right-click to invoke a "
                                              "context menu</i>"))
        self.infoLabel.setFrameStyle(QtGui.QFrame.StyledPanel | QtGui.QFrame.Sunken)
        self.infoLabel.setAlignment(QtCore.Qt.AlignCenter)
        
        bottomFiller = QtGui.QWidget()
        bottomFiller.setSizePolicy(QtGui.QSizePolicy.Expanding, QtGui.QSizePolicy.Expanding)

        vbox = QtGui.QVBoxLayout()
        vbox.setMargin(5)
        vbox.addWidget(topFiller)
        vbox.addWidget(self.infoLabel)
        vbox.addWidget(bottomFiller)
        w.setLayout(vbox)

        self.createActions()
        self.createMenus()
        
        self.statusBar().showMessage(self.tr("A context menu is available by right-clicking"))
        self.setWindowTitle(self.tr("Menus"))
        self.setMinimumSize(160,160)
        self.resize(480,320)
        
    def contextMenuEvent(self, event):
        menu = QtGui.QMenu(self)
        menu.addAction(self.cutAct)
        menu.addAction(self.copyAct)
        menu.addAction(self.pasteAct)
        menu.exec_(event.globalPos())
        
    def newFile(self):
        self.infoLabel.setText(self.tr("Invoked <b>File|New</b>"))
            
    def open(self):
        self.infoLabel.setText(self.tr("Invoked <b>File|Open</b>"))
        	
    def save(self):
        self.infoLabel.setText(self.tr("Invoked <b>File|Save</b>"))
        
    def print_(self):
        self.infoLabel.setText(self.tr("Invoked <b>File|Print</b>"))
    
    def undo(self):
        self.infoLabel.setText(self.tr("Invoked <b>Edit|Undo</b>"))
    
    def redo(self):
        self.infoLabel.setText(self.tr("Invoked <b>Edit|Redo</b>"))
    
    def cut(self):
        self.infoLabel.setText(self.tr("Invoked <b>Edit|Cut</b>"))
    
    def copy(self):
        self.infoLabel.setText(self.tr("Invoked <b>Edit|Copy</b>"))
    
    def paste(self):
        self.infoLabel.setText(self.tr("Invoked <b>Edit|Paste</b>"))
    
    def bold(self):
        self.infoLabel.setText(self.tr("Invoked <b>Edit|Format|Bold</b>"))
    
    def italic(self):
        self.infoLabel.setText(self.tr("Invoked <b>Edit|Format|Italic</b>"))
    
    def leftAlign(self):
        self.infoLabel.setText(self.tr("Invoked <b>Edit|Format|Left Align</b>"))
    
    def rightAlign(self):
        self.infoLabel.setText(self.tr("Invoked <b>Edit|Format|Right Align</b>"))
    
    def justify(self):
        self.infoLabel.setText(self.tr("Invoked <b>Edit|Format|Justify</b>"))
    
    def center(self):
        self.infoLabel.setText(self.tr("Invoked <b>Edit|Format|Center</b>"))
    
    def setLineSpacing(self):
        self.infoLabel.setText(self.tr("Invoked <b>Edit|Format|Set Line Spacing</b>"))
    
    def setParagraphSpacing(self):
        self.infoLabel.setText(self.tr("Invoked <b>Edit|Format|Set Paragraph Spacing</b>"))
                                       
    def about(self):
        self.infoLabel.setText(self.tr("Invoked <b>Help|About</b>"))
        QtGui.QMessageBox.about(self, self.tr("About Menu"),
                self.tr("The <b>Menu</b> example shows how to create "
                        "menu-bar menus and context menus."))
               
    def aboutQt(self):
        self.infoLabel.setText(self.tr("Invoked <b>Help|About Qt</b>"))
        
    def createActions(self):
        self.newAct = QtGui.QAction(self.tr("&New"), self)
        self.newAct.setShortcut(self.tr("Ctrl+N"))
        self.newAct.setStatusTip(self.tr("Create a new file"))
        self.connect(self.newAct, QtCore.SIGNAL("triggered()"), self.newFile)

        self.openAct = QtGui.QAction(self.tr("&Open..."), self)
        self.openAct.setShortcut(self.tr("Ctrl+O"))
        self.openAct.setStatusTip(self.tr("Open an existing file"))
        self.connect(self.openAct, QtCore.SIGNAL("triggered()"), self.open)

        self.saveAct = QtGui.QAction(self.tr("&Save"), self)
        self.saveAct.setShortcut(self.tr("Ctrl+S"))
        self.saveAct.setStatusTip(self.tr("Save the document to disk"))
        self.connect(self.saveAct, QtCore.SIGNAL("triggered()"), self.save)

        self.printAct = QtGui.QAction(self.tr("&Print..."), self)
        self.printAct.setShortcut(self.tr("Ctrl+P"))
        self.printAct.setStatusTip(self.tr("Print the document"))
        self.connect(self.printAct, QtCore.SIGNAL("triggered()"), self.print_)

        self.exitAct = QtGui.QAction(self.tr("E&xit"), self)
        self.exitAct.setShortcut(self.tr("Ctrl+Q"))
        self.exitAct.setStatusTip(self.tr("Exit the application"))
        self.connect(self.exitAct, QtCore.SIGNAL("triggered()"), self.close)

        self.undoAct = QtGui.QAction(self.tr("&Undo"), self)
        self.undoAct.setShortcut(self.tr("Ctrl+Z"))
        self.undoAct.setStatusTip(self.tr("Undo the last operation"))
        self.connect(self.undoAct, QtCore.SIGNAL("triggered()"), self.undo)
        
        self.redoAct = QtGui.QAction(self.tr("&Redo"), self)
        self.redoAct.setShortcut(self.tr("Ctrl+Y"))
        self.redoAct.setStatusTip(self.tr("Redo the last operation"))
        self.connect(self.redoAct, QtCore.SIGNAL("triggered()"), self.redo)

        self.cutAct = QtGui.QAction(self.tr("Cu&t"), self)
        self.cutAct.setShortcut(self.tr("Ctrl+X"))
        self.cutAct.setStatusTip(self.tr("Cut the current selection's "
                                         "contents to the clipboard"))
        self.connect(self.cutAct, QtCore.SIGNAL("triggered()"), self.cut)

        self.copyAct = QtGui.QAction(self.tr("&Copy"), self)
        self.copyAct.setShortcut(self.tr("Ctrl+C"))
        self.copyAct.setStatusTip(self.tr("Copy the current selection's "
                                          "contents to the clipboard"))
        self.connect(self.copyAct, QtCore.SIGNAL("triggered()"), self.copy)

        self.pasteAct = QtGui.QAction(self.tr("&Paste"), self)
        self.pasteAct.setShortcut(self.tr("Ctrl+V"))
        self.pasteAct.setStatusTip(self.tr("Paste the clipboard's contents "
                                           "into the current selection"))
        self.connect(self.pasteAct, QtCore.SIGNAL("triggered()"), self.paste)
        
        self.boldAct = QtGui.QAction(self.tr("&Bold"), self)
        self.boldAct.setCheckable(True)
        self.boldAct.setShortcut(self.tr("Ctrl+B"))
        self.boldAct.setStatusTip(self.tr("Make the text bold"))
        self.connect(self.boldAct, QtCore.SIGNAL("triggered()"), self.bold)
        
        boldFont = self.boldAct.font()
        boldFont.setBold(True)
        self.boldAct.setFont(boldFont)
        
        self.italicAct = QtGui.QAction(self.tr("&Italic"), self)
        self.italicAct.setCheckable(True)
        self.italicAct.setShortcut(self.tr("Ctrl+I"))
        self.italicAct.setStatusTip(self.tr("Make the text italic"))
        self.connect(self.italicAct, QtCore.SIGNAL("triggered()"), self.italic)
        
        italicFont = self.italicAct.font()
        italicFont.setItalic(True)
        self.italicAct.setFont(italicFont)
        
        self.leftAlignAct = QtGui.QAction(self.tr("&Left Align"), self)
        self.leftAlignAct.setCheckable(True)
        self.leftAlignAct.setShortcut(self.tr("Ctrl+L"))
        self.leftAlignAct.setStatusTip(self.tr("Left align the selected text"))
        self.connect(self.leftAlignAct, QtCore.SIGNAL("triggered()"), self.leftAlign)
        
        self.rightAlignAct = QtGui.QAction(self.tr("&Right Align"), self)
        self.rightAlignAct.setCheckable(True)
        self.rightAlignAct.setShortcut(self.tr("Ctrl+R"))
        self.rightAlignAct.setStatusTip(self.tr("Right align the selected text"))
        self.connect(self.rightAlignAct, QtCore.SIGNAL("triggered()"), self.rightAlign)
        
        self.justifyAct = QtGui.QAction(self.tr("&Justify"), self)
        self.justifyAct.setCheckable(True)
        self.justifyAct.setShortcut(self.tr("Ctrl+J"))
        self.justifyAct.setStatusTip(self.tr("Justify the selected text"))
        self.connect(self.justifyAct, QtCore.SIGNAL("triggered()"), self.justify)
        
        self.centerAct = QtGui.QAction(self.tr("&Center"), self)
        self.centerAct.setCheckable(True)
        self.centerAct.setShortcut(self.tr("Ctrl+C"))
        self.centerAct.setStatusTip(self.tr("Center the selected text"))
        self.connect(self.centerAct, QtCore.SIGNAL("triggered()"), self.center)
        
        self.alignmentGroup = QtGui.QActionGroup(self)
        self.alignmentGroup.addAction(self.leftAlignAct)
        self.alignmentGroup.addAction(self.rightAlignAct)
        self.alignmentGroup.addAction(self.justifyAct)
        self.alignmentGroup.addAction(self.centerAct)
        self.leftAlignAct.setChecked(True)
        
        self.setLineSpacingAct = QtGui.QAction(self.tr("Set &Line Spacing..."), self)
        self.setLineSpacingAct.setStatusTip(self.tr("Change the gap between "
                                                    "the lines of a paragraph"))
        self.connect(self.setLineSpacingAct, QtCore.SIGNAL("triggered()"), self.setLineSpacing)
        
        self.setParagraphSpacingAct = QtGui.QAction(self.tr("Set &Paragraph "
                                                            "Spacing..."), self)
        self.setParagraphSpacingAct.setStatusTip(self.tr("Change the gap "
                                                         "between paragraphs"))
        self.connect(self.setParagraphSpacingAct, QtCore.SIGNAL("triggered()"), self.setParagraphSpacing)
        
        self.aboutAct = QtGui.QAction(self.tr("&About"), self)
        self.aboutAct.setStatusTip(self.tr("Show the application's About box"))
        self.connect(self.aboutAct, QtCore.SIGNAL("triggered()"), self.about)

        self.aboutQtAct = QtGui.QAction(self.tr("About &Qt"), self)
        self.aboutQtAct.setStatusTip(self.tr("Show the Qt library's About box"))
        self.connect(self.aboutQtAct, QtCore.SIGNAL("triggered()"), QtGui.qApp.aboutQt)
        self.connect(self.aboutQtAct, QtCore.SIGNAL("triggered()"), self.aboutQt)

    def createMenus(self):
        self.fileMenu = self.menuBar().addMenu(self.tr("&File"))
        self.fileMenu.addAction(self.newAct)
        self.fileMenu.addAction(self.openAct)
        self.fileMenu.addAction(self.saveAct)
        self.fileMenu.addAction(self.printAct)
        self.fileMenu.addSeparator()
        self.fileMenu.addAction(self.exitAct)

        self.editMenu = self.menuBar().addMenu(self.tr("&Edit"))
        self.editMenu.addAction(self.undoAct)
        self.editMenu.addAction(self.redoAct)
        self.editMenu.addSeparator()
        self.editMenu.addAction(self.cutAct)
        self.editMenu.addAction(self.copyAct)
        self.editMenu.addAction(self.pasteAct)
        self.editMenu.addSeparator()
        
        self.formatMenu = self.editMenu.addMenu(self.tr("&Format"))
        self.formatMenu.addAction(self.boldAct)
        self.formatMenu.addAction(self.italicAct)
        self.formatMenu.addSeparator().setText(self.tr("Alignment"))
        self.formatMenu.addAction(self.leftAlignAct)
        self.formatMenu.addAction(self.rightAlignAct)
        self.formatMenu.addAction(self.justifyAct)
        self.formatMenu.addAction(self.centerAct)
        self.formatMenu.addSeparator()
        self.formatMenu.addAction(self.setLineSpacingAct)
        self.formatMenu.addAction(self.setParagraphSpacingAct)

        self.helpMenu = self.menuBar().addMenu(self.tr("&Help"))
        self.helpMenu.addAction(self.aboutAct)
        self.helpMenu.addAction(self.aboutQtAct)


if __name__ == "__main__":
    app = QtGui.QApplication(sys.argv)
    mainwindow = MainWindow()
    mainwindow.show()
    sys.exit(app.exec_())
