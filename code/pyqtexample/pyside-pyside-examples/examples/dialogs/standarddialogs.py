#!/usr/bin/env python

"""PySide port of the dialogs/standarddialogs example from Qt v4.x"""

import sys
from PySide import QtCore, QtGui


class Dialog(QtGui.QDialog):
    MESSAGE = QtCore.QT_TR_NOOP("<p>Message boxes have a caption, a text, and up to "
                                "three buttons, each with standard or custom texts.</p>"
                                "<p>Click a button or press Esc.</p>")

    def __init__(self, parent=None):
        QtGui.QDialog.__init__(self, parent)
        
        self.openFilesPath = QtCore.QString()
        
        self.errorMessageDialog = QtGui.QErrorMessage(self)
    
        frameStyle = QtGui.QFrame.Sunken | QtGui.QFrame.Panel
    
        self.integerLabel = QtGui.QLabel()
        self.integerLabel.setFrameStyle(frameStyle)
        self.integerButton = QtGui.QPushButton(self.tr("QInputDialog.get&Integer()"))
    
        self.doubleLabel = QtGui.QLabel()
        self.doubleLabel.setFrameStyle(frameStyle)
        self.doubleButton = QtGui.QPushButton(self.tr("QInputDialog.get&Double()"))
    
        self.itemLabel = QtGui.QLabel()
        self.itemLabel.setFrameStyle(frameStyle)
        self.itemButton = QtGui.QPushButton(self.tr("QInputDialog.getIte&m()"))
    
        self.textLabel = QtGui.QLabel()
        self.textLabel.setFrameStyle(frameStyle)
        self.textButton = QtGui.QPushButton(self.tr("QInputDialog.get&Text()"))
    
        self.colorLabel = QtGui.QLabel()
        self.colorLabel.setFrameStyle(frameStyle)
        self.colorButton = QtGui.QPushButton(self.tr("QColorDialog.get&Color()"))
    
        self.fontLabel = QtGui.QLabel()
        self.fontLabel.setFrameStyle(frameStyle)
        self.fontButton = QtGui.QPushButton(self.tr("QFontDialog.get&Font()"))
    
        self.directoryLabel = QtGui.QLabel()
        self.directoryLabel.setFrameStyle(frameStyle)
        self.directoryButton = QtGui.QPushButton(self.tr("QFileDialog.getE&xistingDirectory()"))
    
        self.openFileNameLabel = QtGui.QLabel()
        self.openFileNameLabel.setFrameStyle(frameStyle)
        self.openFileNameButton = QtGui.QPushButton(self.tr("QFileDialog.get&OpenFileName()"))
    
        self.openFileNamesLabel = QtGui.QLabel()
        self.openFileNamesLabel.setFrameStyle(frameStyle)
        self.openFileNamesButton = QtGui.QPushButton(self.tr("QFileDialog.&getOpenFileNames()"))
    
        self.saveFileNameLabel = QtGui.QLabel()
        self.saveFileNameLabel.setFrameStyle(frameStyle)
        self.saveFileNameButton = QtGui.QPushButton(self.tr("QFileDialog.get&SaveFileName()"))
    
        self.criticalLabel = QtGui.QLabel()
        self.criticalLabel.setFrameStyle(frameStyle)
        self.criticalButton = QtGui.QPushButton(self.tr("QMessageBox.critica&l()"))
    
        self.informationLabel = QtGui.QLabel()
        self.informationLabel.setFrameStyle(frameStyle)
        self.informationButton = QtGui.QPushButton(self.tr("QMessageBox.i&nformation()"))
    
        self.questionLabel = QtGui.QLabel()
        self.questionLabel.setFrameStyle(frameStyle)
        self.questionButton = QtGui.QPushButton(self.tr("QMessageBox.&question()"))
    
        self.warningLabel = QtGui.QLabel()
        self.warningLabel.setFrameStyle(frameStyle)
        self.warningButton = QtGui.QPushButton(self.tr("QMessageBox.&warning()"))
    
        self.errorLabel = QtGui.QLabel()
        self.errorLabel.setFrameStyle(frameStyle)
        self.errorButton = QtGui.QPushButton(self.tr("QErrorMessage.show&M&essage()"))
    
        self.connect(self.integerButton, QtCore.SIGNAL("clicked()"), self.setInteger)
        self.connect(self.doubleButton, QtCore.SIGNAL("clicked()"), self.setDouble)
        self.connect(self.itemButton, QtCore.SIGNAL("clicked()"), self.setItem)
        self.connect(self.textButton, QtCore.SIGNAL("clicked()"), self.setText)
        self.connect(self.colorButton, QtCore.SIGNAL("clicked()"), self.setColor)
        self.connect(self.fontButton, QtCore.SIGNAL("clicked()"), self.setFont)
        self.connect(self.directoryButton, QtCore.SIGNAL("clicked()"), self.setExistingDirectory)
        self.connect(self.openFileNameButton, QtCore.SIGNAL("clicked()"), self.setOpenFileName)
        self.connect(self.openFileNamesButton, QtCore.SIGNAL("clicked()"), self.setOpenFileNames)
        self.connect(self.saveFileNameButton, QtCore.SIGNAL("clicked()"), self.setSaveFileName)
        self.connect(self.criticalButton, QtCore.SIGNAL("clicked()"), self.criticalMessage)
        self.connect(self.informationButton, QtCore.SIGNAL("clicked()"), self.informationMessage)
        self.connect(self.questionButton, QtCore.SIGNAL("clicked()"), self.questionMessage)
        self.connect(self.warningButton, QtCore.SIGNAL("clicked()"), self.warningMessage)
        self.connect(self.errorButton, QtCore.SIGNAL("clicked()"), self.errorMessage)
    
        layout = QtGui.QGridLayout()
        layout.setColumnStretch(1, 1)
        layout.setColumnMinimumWidth(1, 250)
        layout.addWidget(self.integerButton, 0, 0)
        layout.addWidget(self.integerLabel, 0, 1)
        layout.addWidget(self.doubleButton, 1, 0)
        layout.addWidget(self.doubleLabel, 1, 1)
        layout.addWidget(self.itemButton, 2, 0)
        layout.addWidget(self.itemLabel, 2, 1)
        layout.addWidget(self.textButton, 3, 0)
        layout.addWidget(self.textLabel, 3, 1)
        layout.addWidget(self.colorButton, 4, 0)
        layout.addWidget(self.colorLabel, 4, 1)
        layout.addWidget(self.fontButton, 5, 0)
        layout.addWidget(self.fontLabel, 5, 1)
        layout.addWidget(self.directoryButton, 6, 0)
        layout.addWidget(self.directoryLabel, 6, 1)
        layout.addWidget(self.openFileNameButton, 7, 0)
        layout.addWidget(self.openFileNameLabel, 7, 1)
        layout.addWidget(self.openFileNamesButton, 8, 0)
        layout.addWidget(self.openFileNamesLabel, 8, 1)
        layout.addWidget(self.saveFileNameButton, 9, 0)
        layout.addWidget(self.saveFileNameLabel, 9, 1)
        layout.addWidget(self.criticalButton, 10, 0)
        layout.addWidget(self.criticalLabel, 10, 1)
        layout.addWidget(self.informationButton, 11, 0)
        layout.addWidget(self.informationLabel, 11, 1)
        layout.addWidget(self.questionButton, 12, 0)
        layout.addWidget(self.questionLabel, 12, 1)
        layout.addWidget(self.warningButton, 13, 0)
        layout.addWidget(self.warningLabel, 13, 1)
        layout.addWidget(self.errorButton, 14, 0)
        layout.addWidget(self.errorLabel, 14, 1)
        self.setLayout(layout)
    
        self.setWindowTitle(self.tr("Standard Dialogs"))

    def setInteger(self):    
        i, ok = QtGui.QInputDialog.getInteger(self, self.tr("QInputDialog.getInteger()"),
                                              self.tr("Percentage:"), 25, 0, 100, 1)
        if ok:
            self.integerLabel.setText(self.tr("%1%").arg(i))

    def setDouble(self):    
        d, ok = QtGui.QInputDialog.getDouble(self, self.tr("QInputDialog.getDouble()"),
                                             self.tr("Amount:"), 37.56, -10000, 10000, 2)
        if ok:
            self.doubleLabel.setText(QtCore.QString("$%1").arg(d))

    def setItem(self):    
        items = QtCore.QStringList()
        items << self.tr("Spring") << self.tr("Summer") << self.tr("Fall") << self.tr("Winter")
    
        item, ok = QtGui.QInputDialog.getItem(self, self.tr("QInputDialog.getItem()"),
                                              self.tr("Season:"), items, 0, False)
        if ok and not item.isEmpty():
            self.itemLabel.setText(item)

    def setText(self):
        text, ok = QtGui.QInputDialog.getText(self, self.tr("QInputDialog.getText()"),
                                              self.tr("User name:"), QtGui.QLineEdit.Normal,
                                              QtCore.QDir.home().dirName())
        if ok and not text.isEmpty():
            self.textLabel.setText(text)

    def setColor(self):    
        color = QtGui.QColorDialog.getColor(QtCore.Qt.green, self)
        if color.isValid(): 
            self.colorLabel.setText(color.name())
            self.colorLabel.setPalette(QtGui.QPalette(color))

    def setFont(self):    
        font, ok = QtGui.QFontDialog.getFont(QtGui.QFont(self.fontLabel.text()), self)
        if ok:
            self.fontLabel.setText(font.key())

    def setExistingDirectory(self):    
        directory = QtGui.QFileDialog.getExistingDirectory(self,
                                          self.tr("QFileDialog.getExistingDirectory()"),
                                          self.directoryLabel.text(),
                                          QtGui.QFileDialog.DontResolveSymlinks | QtGui.QFileDialog.ShowDirsOnly)
        if not directory.isEmpty():
            self.directoryLabel.setText(directory)

    def setOpenFileName(self):    
        fileName = QtGui.QFileDialog.getOpenFileName(self,
                                         self.tr("QFileDialog.getOpenFileName()"),
                                         self.openFileNameLabel.text(),
                                         self.tr("All Files (*);;Text Files (*.txt)"))
        if not fileName.isEmpty():
            self.openFileNameLabel.setText(fileName)

    def setOpenFileNames(self):    
        files = QtGui.QFileDialog.getOpenFileNames(self,
                                      self.tr("QFileDialog.getOpenFileNames()"),
                                      self.openFilesPath,
                                      self.tr("All Files (*);;Text Files (*.txt)"))
        if files.count():
            self.openFilesPath = files[0]
            self.openFileNamesLabel.setText(QtCore.QString("[%1]").arg(files.join(", ")))

    def setSaveFileName(self):    
        fileName = QtGui.QFileDialog.getSaveFileName(self,
                                         self.tr("QFileDialog.getSaveFileName()"),
                                         self.saveFileNameLabel.text(),
                                         self.tr("All Files (*);;Text Files (*.txt)"))
        if not fileName.isEmpty():
            self.saveFileNameLabel.setText(fileName)

    def criticalMessage(self):    
        reply = QtGui.QMessageBox.critical(self, self.tr("QMessageBox.showCritical()"),
                                           Dialog.MESSAGE, QtGui.QMessageBox.Abort|
                                           QtGui.QMessageBox.StandardButton.Retry|
                                           QtGui.QMessageBox.StandardButton.Ignore)
        if reply == QtGui.QMessageBox.Abort:
            self.criticalLabel.setText(self.tr("Abort"))
        elif reply == QtGui.QMessageBox.Retry:
            self.criticalLabel.setText(self.tr("Retry"))
        else:
            self.criticalLabel.setText(self.tr("Ignore"))

    def informationMessage(self):    
        QtGui.QMessageBox.information(self, self.tr("QMessageBox.showInformation()"), Dialog.MESSAGE)
        self.informationLabel.setText(self.tr("Closed with OK or Esc"))

    def questionMessage(self):    
        reply = QtGui.QMessageBox.question(self, self.tr("QMessageBox.showQuestion()"),
                                           Dialog.MESSAGE, QtGui.QMessageBox.StandardButton.Yes | QtGui.QMessageBox.StandardButton.No)
        if reply == QtGui.QMessageBox.Yes:
            self.questionLabel.setText(self.tr("Yes"))
        elif reply == QtGui.QMessageBox.No:
            self.questionLabel.setText(self.tr("No"))
        else:
            self.questionLabel.setText(self.tr("Cancel"))

    def warningMessage(self):    
        reply = QtGui.QMessageBox.warning(self, self.tr("QMessageBox.showWarning()"),
                                          Dialog.MESSAGE, QtGui.QMessageBox.StandardButton.Ok | QtGui.QMessageBox.StandardButton.Discard )
        if reply == 0:
            self.warningLabel.setText(self.tr("Save Again"))
        else:
            self.warningLabel.setText(self.tr("Continue"))

    def errorMessage(self):    
        self.errorMessageDialog.showMessage(self.tr(
                                    "This dialog shows and remembers error messages. "
                                    "If the checkbox is checked (as it is by default), "
                                    "the shown message will be shown again, "
                                    "but if the user unchecks the box the message "
                                    "will not appear again if QErrorMessage.showMessage() "
                                    "is called with the same message."))
        self.errorLabel.setText(self.tr("If the box is unchecked, the "
                                        "message won't appear again."))


if __name__ == '__main__':
    app = QtGui.QApplication(sys.argv)
    dialog = Dialog()
    sys.exit(dialog.exec_())
