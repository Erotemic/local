#!/usr/bin/env python

#############################################################################
##
## Copyright (C) 2005-2005 Trolltech AS. All rights reserved.
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


class Screenshot(QtGui.QWidget):
    def __init__(self, parent = None):
        QtGui.QWidget.__init__(self, parent)

        self.screenshotLabel = QtGui.QLabel()
        self.screenshotLabel.setSizePolicy(QtGui.QSizePolicy.Expanding,
                                           QtGui.QSizePolicy.Expanding)
        self.screenshotLabel.setAlignment(QtCore.Qt.AlignCenter)
        self.screenshotLabel.setMinimumSize(240, 160)

        self.createOptionsGroupBox()
        self.createButtonsLayout()

        self.mainLayout = QtGui.QVBoxLayout()
        self.mainLayout.addWidget(self.screenshotLabel)
        self.mainLayout.addWidget(self.optionsGroupBox)
        self.mainLayout.addLayout(self.buttonsLayout)
        self.setLayout(self.mainLayout)

        self.shootScreen()
        self.delaySpinBox.setValue(5)

        self.setWindowTitle(self.tr("Screenshot"))
        self.resize(300, 200)

    def resizeEvent(self, event):
        scaledSize = self.originalPixmap.size()
        scaledSize.scale(self.screenshotLabel.size(), QtCore.Qt.KeepAspectRatio)
        if not self.screenshotLabel.pixmap() or scaledSize != self.screenshotLabel.pixmap().size():
            self.updateScreenshotLabel()

    def newScreenshot(self):
        if self.hideThisWindowCheckBox.isChecked():
            self.hide()
        self.newScreenshotButton.setDisabled(True)

        QtCore.QTimer.singleShot(self.delaySpinBox.value() * 1000, self.shootScreen)

    def saveScreenshot(self):
        format = QtCore.QString("png")
        initialPath = QtCore.QDir.currentPath() + self.tr("/untitled.") + format

        fileName = QtGui.QFileDialog.getSaveFileName(self, self.tr("Save As"),
                               initialPath,
                               self.tr("%1 Files (*.%2);;All Files (*)")
                                   .arg(format.toUpper())
                                   .arg(format))
        if not fileName.isEmpty():
            self.originalPixmap.save(fileName, str(format))

    def shootScreen(self):
        if self.delaySpinBox.value() != 0:
            QtGui.qApp.beep()

        self.originalPixmap = QtGui.QPixmap.grabWindow(QtGui.QApplication.desktop().winId())
        self.updateScreenshotLabel()

        self.newScreenshotButton.setDisabled(False)
        if self.hideThisWindowCheckBox.isChecked():
            self.show()

    def updateCheckBox(self):
        if self.delaySpinBox.value() == 0:
            self.hideThisWindowCheckBox.setDisabled(True)
        else:
            self.hideThisWindowCheckBox.setDisabled(False)

    def createOptionsGroupBox(self):
        self.optionsGroupBox = QtGui.QGroupBox(self.tr("Options"))

        self.delaySpinBox = QtGui.QSpinBox()
        self.delaySpinBox.setSuffix(self.tr(" s"))
        self.delaySpinBox.setMaximum(60)
        self.connect(self.delaySpinBox, QtCore.SIGNAL("valueChanged(int)"),
                     self.updateCheckBox)

        self.delaySpinBoxLabel = QtGui.QLabel(self.tr("Screenshot Delay:"))

        self.hideThisWindowCheckBox = QtGui.QCheckBox(self.tr("Hide This Window"))

        self.optionsGroupBoxLayout = QtGui.QGridLayout()
        self.optionsGroupBoxLayout.addWidget(self.delaySpinBoxLabel, 0, 0)
        self.optionsGroupBoxLayout.addWidget(self.delaySpinBox, 0, 1)
        self.optionsGroupBoxLayout.addWidget(self.hideThisWindowCheckBox, 1, 0, 1, 2)
        self.optionsGroupBox.setLayout(self.optionsGroupBoxLayout)

    def createButtonsLayout(self):
        self.newScreenshotButton = self.createButton(self.tr("New Screenshot"),
                                                     self.newScreenshot)

        self.saveScreenshotButton = self.createButton(self.tr("Save Screenshot"),
                                                      self.saveScreenshot)

        self.quitScreenshotButton = self.createButton(self.tr("Quit"),
                                                      self.close)

        self.buttonsLayout = QtGui.QHBoxLayout()
        self.buttonsLayout.addStretch()
        self.buttonsLayout.addWidget(self.newScreenshotButton)
        self.buttonsLayout.addWidget(self.saveScreenshotButton)
        self.buttonsLayout.addWidget(self.quitScreenshotButton)

    def createButton(self, text, member):
        button = QtGui.QPushButton(text)
        button.connect(button, QtCore.SIGNAL("clicked()"), member)
        return button

    def updateScreenshotLabel(self):
        self.screenshotLabel.setPixmap(self.originalPixmap.scaled(
            self.screenshotLabel.size(), QtCore.Qt.KeepAspectRatio, QtCore.Qt.SmoothTransformation))


if __name__ == "__main__":
    app = QtGui.QApplication(sys.argv)
    screenshot = Screenshot()
    screenshot.show()
    sys.exit(app.exec_())
