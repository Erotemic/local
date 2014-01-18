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
    MaxRecentFiles = 5
    windowList = []

    def __init__(self, parent=None):
        QtGui.QMainWindow.__init__(self, parent)
        
        self.recentFileActs = []

        self.setAttribute(QtCore.Qt.WA_DeleteOnClose)
        
        self.textEdit = QtGui.QTextEdit()
        self.setCentralWidget(self.textEdit)
        
        self.createActions()
        self.createMenus()
        self.statusBar()

        self.setWindowTitle(self.tr("Recent Files"))
        self.resize(400,300)
            
    def newFile(self):
        other = MainWindow()
        MainWindow.windowList.append(other)
        other.show()
            
    def open(self):
        fileName = QtGui.QFileDialog.getOpenFileName(self)
        if not fileName.isEmpty():
            self.loadFile(fileName)
        	
    def save(self):
        if self.curFile.isEmpty():
            return self.saveAs()
        else:
            return self.saveFile(self.curFile)
            
    def saveAs(self):
        fileName = QtGui.QFileDialog.getSaveFileName(self)
        if fileName.isEmpty():
            return False
        
        if QtCore.QFile.exists(fileName):
            ret = QtGui.QMessageBox.warning(self, self.tr("Recent Files"),
                            self.tr("File &1 already exists.\n"
                                    "Do you want to overwrite it?")
                                .arg(QtCore.QDir.convertSeparators(fileName)),
                                QtGui.QMessageBox.Yes | QtGui.QMessageBox.Default,
                                QtGui.QMessageBox.No | QtGui.QMessageBox.Escape)
            if ret == QtGui.QMessageBox.No:
                return
        self.saveFile(fileName)
    
    def openRecentFile(self):
        action = self.sender()
        if action:
            self.loadFile(action.data().toString())
            
    def about(self):
        QtGui.QMessageBox.about(self, self.tr("About Recent Files"),
            self.tr("The <b>Recent Files</b> example demonstrates how to provide a "
               "recently used file menu in a Qt application."))
        
    def createActions(self):
        self.newAct = QtGui.QAction(QtGui.QIcon(":/images/new.png"),self.tr("&New"), self)
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

        self.saveAsAct = QtGui.QAction(self.tr("Save &As..."), self)
        self.saveAsAct.setStatusTip(self.tr("Save the document under a new name"))
        self.connect(self.saveAsAct, QtCore.SIGNAL("triggered()"), self.saveAs)
        
        for i in range(MainWindow.MaxRecentFiles):
            self.recentFileActs.append(QtGui.QAction(self))
            self.recentFileActs[i].setVisible(False)
            self.connect(self.recentFileActs[i], QtCore.SIGNAL("triggered()"),
                         self.openRecentFile)
        
        self.closeAct = QtGui.QAction(self.tr("&Close"), self)
        self.closeAct.setShortcut(self.tr("Ctrl+W"))
        self.closeAct.setStatusTip(self.tr("Close this window"))
        self.connect(self.closeAct, QtCore.SIGNAL("triggered()"), self.close)
        
        self.exitAct = QtGui.QAction(self.tr("E&xit"), self)
        self.exitAct.setShortcut(self.tr("Ctrl+Q"))
        self.exitAct.setStatusTip(self.tr("Exit the application"))
        self.connect(self.exitAct, QtCore.SIGNAL("triggered()"), 
                     QtGui.qApp.closeAllWindows)
        
        self.aboutAct = QtGui.QAction(self.tr("&About"), self)
        self.aboutAct.setStatusTip(self.tr("Show the application's About box"))
        self.connect(self.aboutAct, QtCore.SIGNAL("triggered()"), self.about)

        self.aboutQtAct = QtGui.QAction(self.tr("About &Qt"), self)
        self.aboutQtAct.setStatusTip(self.tr("Show the Qt library's About box"))
        self.connect(self.aboutQtAct, QtCore.SIGNAL("triggered()"), QtGui.qApp.aboutQt)

    def createMenus(self):
        self.fileMenu = self.menuBar().addMenu(self.tr("&File"))
        self.fileMenu.addAction(self.newAct)
        self.fileMenu.addAction(self.openAct)
        self.fileMenu.addAction(self.saveAct)
        self.fileMenu.addAction(self.saveAsAct)
        self.separatorAct = self.fileMenu.addSeparator()
        for i in range(MainWindow.MaxRecentFiles):
            self.fileMenu.addAction(self.recentFileActs[i])
        self.fileMenu.addSeparator()
        self.fileMenu.addAction(self.closeAct)
        self.fileMenu.addAction(self.exitAct)
        self.updateRecentFileActions()
        
        self.menuBar().addSeparator()

        self.helpMenu = self.menuBar().addMenu(self.tr("&Help"))
        self.helpMenu.addAction(self.aboutAct)
        self.helpMenu.addAction(self.aboutQtAct)
        
    def loadFile(self, fileName):
        file = QtCore.QFile(fileName)
        if not file.open( QtCore.QFile.ReadOnly | QtCore.QFile.Text):
            QtGui.QMessageBox.warning(self, self.tr("Recent Files"),
                    self.tr("Cannot read file %1:\n%2.").arg(fileName).arg(file.errorString()))
            return
        instr = QtCore.QTextStream(file)
        QtGui.QApplication.setOverrideCursor(QtCore.Qt.WaitCursor)
        self.textEdit.setPlainText(instr.readAll())
        QtGui.QApplication.restoreOverrideCursor()
        
        self.setCurrentFile(fileName)
        self.statusBar().showMessage(self.tr("File loaded"), 2000)
        
    def saveFile(self, fileName):
        file = QtCore.QFile(fileName)
        if not file.open( QtCore.QFile.WriteOnly | QtCore.QFile.Text):
            QtGui.QMessageBox.warning(self, self.tr("Recent Files"),
                    self.tr("Cannot write file %1:\n%2.").arg(fileName).arg(file.errorString()))
            return False
        outstr = QtCore.QTextStream(file)
        QtGui.QApplication.setOverrideCursor(QtCore.Qt.WaitCursor)
        outstr << self.textEdit.toPlainText()
        QtGui.QApplication.restoreOverrideCursor()
        
        self.setCurrentFile(fileName)
        self.statusBar().showMessage(self.tr("File saved"), 2000)
        return True
    
    def setCurrentFile(self, fileName):
        self.curFile = fileName
        if self.curFile.isEmpty():
            self.setWindowTitle(self.tr("Recent Files"))
        else:
            self.setWindowTitle(self.tr("%1 - %2").arg(self.strippedName(self.curFile))
                                .arg(self.tr("Recent Files")))
        
        settings = QtCore.QSettings("Trolltech", "Recent Files Example")
        files = settings.value("recentFileList").toStringList()
        files.removeAll(fileName)
        files.prepend(fileName)
        while files.count() > MainWindow.MaxRecentFiles:
            files.removeAt(files.count()-1)
        
        settings.setValue("recentFileList", QtCore.QVariant(files))
        
        for widget in QtGui.QApplication.topLevelWidgets():
            if isinstance(widget, MainWindow):
                widget.updateRecentFileActions()

    def updateRecentFileActions(self):
        settings = QtCore.QSettings("Trolltech", "Recent Files Example")
        files = settings.value("recentFileList").toStringList()
        
        numRecentFiles = min(files.count(), MainWindow.MaxRecentFiles)
        
        for i in range(numRecentFiles):
            text = self.tr("&%1 %2").arg(i+1).arg(self.strippedName(files[i]))
            self.recentFileActs[i].setText(text)
            self.recentFileActs[i].setData(QtCore.QVariant(files[i]))
            self.recentFileActs[i].setVisible(True)
            
        for j in range(numRecentFiles, MainWindow.MaxRecentFiles):
            self.recentFileActs[j].setVisible(False)
        
        self.separatorAct.setVisible((numRecentFiles > 0))
        
    def strippedName(self, fullFileName):
        return QtCore.QFileInfo(fullFileName).fileName()

if __name__ == "__main__":
    app = QtGui.QApplication(sys.argv)
    mainwindow = MainWindow()
    mainwindow.show()
    sys.exit(app.exec_())
