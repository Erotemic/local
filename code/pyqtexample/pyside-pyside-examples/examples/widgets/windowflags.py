#!/usr/bin/env python

#############################################################################
##
## Copyright (C) 2004-2005 Trolltech AS. All rights reserved.
##
## This file is part of the example classes of the Qt Toolkit.
##
## This file may be used under the terms of the GNU General Public
## License version 2.0 as published by the Free Software Foundation
## and appearing in the file LICENSE.GPL included in the packaging of
## this file.  Please review the following information to ensure GNU
## General Public Licensing requirements will be met:
## http://www.trolltech.com/products/qt/opensource.html
##
## If you are unsure which license is appropriate for your use, please
## review the following information:
## http://www.trolltech.com/products/qt/licensing.html or contact the
## sales department at sales@trolltech.com.
##
## This file is provided AS IS with NO WARRANTY OF ANY KIND, INCLUDING THE
## WARRANTY OF DESIGN, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
##
#############################################################################

import sys
from PySide import QtCore, QtGui


class PreviewWindow(QtGui.QWidget):
    def __init__(self, parent=None):
        QtGui.QWidget.__init__(self, parent)
        
        self.textEdit = QtGui.QTextEdit()
        self.textEdit.setReadOnly(True)
        self.textEdit.setLineWrapMode(QtGui.QTextEdit.NoWrap)

        closeButton = QtGui.QPushButton(self.tr("&Close"))
        self.connect(closeButton, QtCore.SIGNAL("clicked()"), self, QtCore.SLOT("close()"))

        layout = QtGui.QVBoxLayout()
        layout.addWidget(self.textEdit)
        layout.addWidget(closeButton)
        self.setLayout(layout)

        self.setWindowTitle(self.tr("Preview"))

    def setWindowFlags(self, flags):
        QtGui.QWidget.setWindowFlags(self, flags)
        
        text = QtCore.QString()

        flag_type = (flags & QtCore.Qt.WindowType_Mask)

        if flag_type == QtCore.Qt.Window:
            text = "QtCore.Qt.Window"
        elif flag_type == QtCore.Qt.Dialog:
            text = "QtCore.Qt.Dialog"
        elif flag_type == QtCore.Qt.Sheet:
            text = "QtCore.Qt.Sheet"
        elif flag_type == QtCore.Qt.Drawer:
            text = "QtCore.Qt.Drawer"
        elif flag_type == QtCore.Qt.Popup:
            text = "QtCore.Qt.Popup"
        elif flag_type == QtCore.Qt.Tool:
            text = "QtCore.Qt.Tool"
        elif flag_type == QtCore.Qt.ToolTip:
            text = "QtCore.Qt.ToolTip"
        elif flag_type == QtCore.Qt.SplashScreen:
            text = "QtCore.Qt.SplashScreen"
        
        if flags & QtCore.Qt.MSWindowsFixedSizeDialogHint:
            text += "\n| QtCore.Qt.MSWindowsFixedSizeDialogHint"
        if flags & QtCore.Qt.X11BypassWindowManagerHint:
            text += "\n| QtCore.Qt.X11BypassWindowManagerHint"
        if flags & QtCore.Qt.FramelessWindowHint:
            text += "\n| QtCore.Qt.FramelessWindowHint"
        if flags & QtCore.Qt.WindowTitleHint:
            text += "\n| QtCore.Qt.WindowTitleHint"
        if flags & QtCore.Qt.WindowSystemMenuHint:
            text += "\n| QtCore.Qt.WindowSystemMenuHint"
        if flags & QtCore.Qt.WindowMinimizeButtonHint:
            text += "\n| QtCore.Qt.WindowMinimizeButtonHint"
        if flags & QtCore.Qt.WindowMaximizeButtonHint:
            text += "\n| QtCore.Qt.WindowMaximizeButtonHint"
        if flags & QtCore.Qt.WindowContextHelpButtonHint:
            text += "\n| QtCore.Qt.WindowContextHelpButtonHint"
        if flags & QtCore.Qt.WindowShadeButtonHint:
            text += "\n| QtCore.Qt.WindowShadeButtonHint"
        if flags & QtCore.Qt.WindowStaysOnTopHint:
            text += "\n| QtCore.Qt.WindowStaysOnTopHint"
    
        self.textEdit.setPlainText(text)


class ControllerWindow(QtGui.QWidget):
    def __init__(self, parent=None):  
        QtGui.QWidget.__init__(self, parent)
  
        self.previewWindow = PreviewWindow(self)
        
        self.createTypeGroupBox()
        self.createHintsGroupBox()
        
        quitButton = QtGui.QPushButton(self.tr("&Quit"))
        self.connect(quitButton, QtCore.SIGNAL("clicked()"), self, QtCore.SLOT("close()"))
    
        bottomLayout = QtGui.QHBoxLayout()
        bottomLayout.addStretch()
        bottomLayout.addWidget(quitButton)
    
        mainLayout = QtGui.QVBoxLayout()
        mainLayout.addWidget(self.typeGroupBox)
        mainLayout.addWidget(self.hintsGroupBox)
        mainLayout.addLayout(bottomLayout)
        self.setLayout(mainLayout)

        self.setWindowTitle(self.tr("Window Flags"))
        self.updatePreview()

    def updatePreview(self):
        flags = QtCore.Qt.WindowFlags()

        if self.windowRadioButton.isChecked():
            flags = QtCore.Qt.Window
        elif self.dialogRadioButton.isChecked():
            flags = QtCore.Qt.Dialog
        elif self.sheetRadioButton.isChecked():
            flags = QtCore.Qt.Sheet
        elif self.drawerRadioButton.isChecked():
            flags = QtCore.Qt.Drawer
        elif self.popupRadioButton.isChecked():
            flags = QtCore.Qt.Popup
        elif self.toolRadioButton.isChecked():
            flags = QtCore.Qt.Tool
        elif self.toolTipRadioButton.isChecked():
            flags = QtCore.Qt.ToolTip
        elif self.splashScreenRadioButton.isChecked():
            flags = QtCore.Qt.SplashScreen
    
        if self.msWindowsFixedSizeDialogCheckBox.isChecked():
            flags |= QtCore.Qt.MSWindowsFixedSizeDialogHint            
        if self.x11BypassWindowManagerCheckBox.isChecked():
            flags |= QtCore.Qt.X11BypassWindowManagerHint
        if self.framelessWindowCheckBox.isChecked():
            flags |= QtCore.Qt.FramelessWindowHint
        if self.windowTitleCheckBox.isChecked():
            flags |= QtCore.Qt.WindowTitleHint
        if self.windowSystemMenuCheckBox.isChecked():
            flags |= QtCore.Qt.WindowSystemMenuHint
        if self.windowMinimizeButtonCheckBox.isChecked():
            flags |= QtCore.Qt.WindowMinimizeButtonHint
        if self.windowMaximizeButtonCheckBox.isChecked():
            flags |= QtCore.Qt.WindowMaximizeButtonHint
        if self.windowContextHelpButtonCheckBox.isChecked():
            flags |= QtCore.Qt.WindowContextHelpButtonHint
        if self.windowShadeButtonCheckBox.isChecked():
            flags |= QtCore.Qt.WindowShadeButtonHint
        if self.windowStaysOnTopCheckBox.isChecked():
            flags |= QtCore.Qt.WindowStaysOnTopHint
        
        self.previewWindow.setWindowFlags(flags)
        self.previewWindow.show()
    
        pos = self.previewWindow.pos()
        
        if pos.x() < 0:
            pos.setX(0)
            
        if pos.y() < 0:
            pos.setY(0)
            
        self.previewWindow.move(pos)

    def createTypeGroupBox(self):
        self.typeGroupBox = QtGui.QGroupBox(self.tr("Type"))

        self.windowRadioButton = self.createRadioButton(self.tr("Window"))
        self.dialogRadioButton = self.createRadioButton(self.tr("Dialog"))
        self.sheetRadioButton = self.createRadioButton(self.tr("Sheet"))
        self.drawerRadioButton = self.createRadioButton(self.tr("Drawer"))
        self.popupRadioButton = self.createRadioButton(self.tr("Popup"))
        self.toolRadioButton = self.createRadioButton(self.tr("Tool"))
        self.toolTipRadioButton = self.createRadioButton(self.tr("Tooltip"))
        self.splashScreenRadioButton = self.createRadioButton(self.tr("Splash screen"))
        self.windowRadioButton.setChecked(True)
    
        layout = QtGui.QGridLayout()
        layout.addWidget(self.windowRadioButton, 0, 0)
        layout.addWidget(self.dialogRadioButton, 1, 0)
        layout.addWidget(self.sheetRadioButton, 2, 0)
        layout.addWidget(self.drawerRadioButton, 3, 0)
        layout.addWidget(self.popupRadioButton, 0, 1)
        layout.addWidget(self.toolRadioButton, 1, 1)
        layout.addWidget(self.toolTipRadioButton, 2, 1)
        layout.addWidget(self.splashScreenRadioButton, 3, 1)
        self.typeGroupBox.setLayout(layout)
    
    def createHintsGroupBox(self):
        self.hintsGroupBox = QtGui.QGroupBox(self.tr("Hints"))

        self.msWindowsFixedSizeDialogCheckBox = self.createCheckBox(self.tr("MS Windows fixed size dialog"))
        self.x11BypassWindowManagerCheckBox = self.createCheckBox(self.tr("X11 bypass window manager"))
        self.framelessWindowCheckBox = self.createCheckBox(self.tr("Frameless window"))
        self.windowTitleCheckBox = self.createCheckBox(self.tr("Window title"))
        self.windowSystemMenuCheckBox = self.createCheckBox(self.tr("Window system menu"))
        self.windowMinimizeButtonCheckBox = self.createCheckBox(self.tr("Window minimize button"))
        self.windowMaximizeButtonCheckBox = self.createCheckBox(self.tr("Window maximize button"))
        self.windowContextHelpButtonCheckBox = self.createCheckBox(self.tr("Window context help button"))
        self.windowShadeButtonCheckBox = self.createCheckBox(self.tr("Window shade button"))
        self.windowStaysOnTopCheckBox = self.createCheckBox(self.tr("Window stays on top"))
    
        layout = QtGui.QGridLayout()
        layout.addWidget(self.msWindowsFixedSizeDialogCheckBox, 0, 0)
        layout.addWidget(self.x11BypassWindowManagerCheckBox, 1, 0)
        layout.addWidget(self.framelessWindowCheckBox, 2, 0)
        layout.addWidget(self.windowTitleCheckBox, 3, 0)
        layout.addWidget(self.windowSystemMenuCheckBox, 4, 0)
        layout.addWidget(self.windowMinimizeButtonCheckBox, 0, 1)
        layout.addWidget(self.windowMaximizeButtonCheckBox, 1, 1)
        layout.addWidget(self.windowContextHelpButtonCheckBox, 2, 1)
        layout.addWidget(self.windowShadeButtonCheckBox, 3, 1)
        layout.addWidget(self.windowStaysOnTopCheckBox, 4, 1)
        self.hintsGroupBox.setLayout(layout)

    def createCheckBox(self, text):
        checkBox = QtGui.QCheckBox(text)
        self.connect(checkBox, QtCore.SIGNAL("clicked()"), self.updatePreview)
        return checkBox
    
    def createRadioButton(self, text):
        button = QtGui.QRadioButton(text)
        self.connect(button, QtCore.SIGNAL("clicked()"), self.updatePreview)
        return button

 
if __name__ == "__main__":
    app = QtGui.QApplication(sys.argv)
    controller = ControllerWindow()
    controller.show()
    sys.exit(app.exec_())
