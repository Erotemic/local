#!/usr/bin/env python

############################################################################*
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
############################################################################/

import sys
from PySide import QtCore, QtGui


class ScribbleArea(QtGui.QWidget):
    def __init__(self, parent = None):
        QtGui.QWidget.__init__(self, parent)

        self.setAttribute(QtCore.Qt.WA_StaticContents)
        self.modified = False
        self.scribbling = False
        self.myPenWidth = 1
        self.myPenColor = QtCore.Qt.blue
        self.image = QtGui.QImage()
        self.lastPoint = QtCore.QPoint()

    def openImage(self, fileName):
        loadedImage = QtGui.QImage()
        if not loadedImage.load(fileName):
            return False

        newSize = loadedImage.size().expandedTo(size())
        self.resizeImage(loadedImage, newSize)
        self.image = loadedImage
        self.modified = False
        self.update()
        return True

    def saveImage(self, fileName, fileFormat):
        visibleImage = self.image
        self.resizeImage(visibleImage, size())

        if visibleImage.save(fileName, fileFormat):
            self.modified = False
            return True
        else:
            return False

    def setPenColor(self, newColor):
        self.myPenColor = newColor

    def setPenWidth(self, newWidth):
        self.myPenWidth = newWidth

    def clearImage(self):
        self.image.fill(QtGui.qRgb(255, 255, 255))
        self.modified = True
        self.update()

    def mousePressEvent(self, event):
        if event.button() == QtCore.Qt.LeftButton:
            self.lastPoint = event.pos()
            self.scribbling = True

    def mouseMoveEvent(self, event):
        if (event.buttons() & QtCore.Qt.LeftButton) and self.scribbling:
            self.drawLineTo(event.pos())

    def mouseReleaseEvent(self, event):
        if event.button() == QtCore.Qt.LeftButton and self.scribbling:
            self.drawLineTo(event.pos())
            self.scribbling = False

    def paintEvent(self, event):
        painter = QtGui.QPainter()
        painter.begin(self)
        painter.drawImage(QtCore.QPoint(0, 0), self.image)
        painter.end()

    def resizeEvent(self, event):
        if self.width() > self.image.width() or self.height() > self.image.height():
            newWidth = max(self.width() + 128, self.image.width())
            newHeight = max(self.height() + 128, self.image.height())
            self.resizeImage(self.image, QtCore.QSize(newWidth, newHeight))
            self.update()

        QtGui.QWidget.resizeEvent(self, event)

    def drawLineTo(self, endPoint):
        painter = QtGui.QPainter()
        painter.begin(self.image)
        painter.setPen(QtGui.QPen(self.myPenColor, self.myPenWidth,
                                  QtCore.Qt.SolidLine, QtCore.Qt.RoundCap,
                                  QtCore.Qt.RoundJoin))
        painter.drawLine(self.lastPoint, endPoint)
        painter.end()
        self.modified = True

        rad = self.myPenWidth / 2 + 2
        self.update(QtCore.QRect(self.lastPoint, endPoint).normalized()
                                         .adjusted(-rad, -rad, +rad, +rad))
        self.lastPoint = QtCore.QPoint(endPoint)

    def resizeImage(self, image, newSize):
        if image.size() == newSize:
            return

        newImage = QtGui.QImage(newSize, QtGui.QImage.Format_RGB32)
        newImage.fill(QtGui.qRgb(255, 255, 255))
        painter = QtGui.QPainter()
        painter.begin(newImage)
        painter.drawImage(QtCore.QPoint(0, 0), image)
        painter.end()
        self.image = newImage
    
    def isModified(self):
        return self.modified

    def penColor(self):
        return self.myPenColor

    def penWidth(self):
        return self.myPenWidth


class MainWindow(QtGui.QMainWindow):
    def __init__(self, parent = None):
        QtGui.QMainWindow.__init__(self, parent)

        self.saveAsActs = []

        self.scribbleArea = ScribbleArea()
        self.setCentralWidget(self.scribbleArea)

        self.createActions()
        self.createMenus()

        self.setWindowTitle(self.tr("Scribble"))
        self.resize(500, 500)

    def closeEvent(self, event):
        if self.maybeSave():
            event.accept()
        else:
            event.ignore()

    def open(self):
        if self.maybeSave():
            fileName = QtGui.QFileDialog.getOpenFileName(self,
                                                         self.tr("Open File"),
                                                         QtCore.QDir.currentPath())
            if not fileName.isEmpty():
                self.scribbleArea.openImage(fileName)

    def save(self):
        action = self.sender()
        fileFormat = action.data().toByteArray()
        self.saveFile(fileFormat)

    def penColor(self):
        newColor = QtGui.QColorDialog.getColor(self.scribbleArea.penColor())
        if newColor.isValid():
            self.scribbleArea.setPenColor(newColor)

    def penWidth(self):
        newWidth, ok = QtGui.QInputDialog.getInteger(self, self.tr("Scribble"),
                                               self.tr("Select pen width:"),
                                               self.scribbleArea.penWidth(),
                                               1, 50, 1)
        if ok:
            self.scribbleArea.setPenWidth(newWidth)

    def about(self):
        QtGui.QMessageBox.about(self, self.tr("About Scribble"), self.tr(
          "<p>The <b>Scribble</b> example shows how to use QMainWindow as the "
          "base widget for an application, and how to reimplement some of "
          "QWidget's event handlers to receive the events generated for "
          "the application's widgets:</p><p> We reimplement the mouse event "
          "handlers to facilitate drawing, the paint event handler to "
          "update the application and the resize event handler to optimize "
          "the application's appearance. In addition we reimplement the "
          "close event handler to intercept the close events before "
          "terminating the application.</p><p> The example also demonstrates "
          "how to use QPainter to draw an image in real time, as well as "
          "to repaint widgets.</p>"))

    def createActions(self):
        self.openAct = QtGui.QAction(self.tr("&Open..."), self)
        self.openAct.setShortcut(self.tr("Ctrl+O"))
        self.connect(self.openAct, QtCore.SIGNAL("triggered()"), self.open)

        for format in QtGui.QImageWriter.supportedImageFormats():
            text = self.tr("%1...").arg(QtCore.QString(format).toUpper())

            action = QtGui.QAction(text, self)
            action.setData(QtCore.QVariant(format))
            self.connect(action, QtCore.SIGNAL("triggered()"), self.save)
            self.saveAsActs.append(action)

        self.exitAct = QtGui.QAction(self.tr("E&xit"), self)
        self.exitAct.setShortcut(self.tr("Ctrl+Q"))
        self.connect(self.exitAct, QtCore.SIGNAL("triggered()"),
                     self, QtCore.SLOT("close()"))

        self.penColorAct = QtGui.QAction(self.tr("&Pen Color..."), self)
        self.connect(self.penColorAct, QtCore.SIGNAL("triggered()"),
                     self.penColor)

        self.penWidthAct = QtGui.QAction(self.tr("Pen &Width..."), self)
        self.connect(self.penWidthAct, QtCore.SIGNAL("triggered()"),
                     self.penWidth)

        self.clearScreenAct = QtGui.QAction(self.tr("&Clear Screen"), self)
        self.clearScreenAct.setShortcut(self.tr("Ctrl+L"))
        self.connect(self.clearScreenAct, QtCore.SIGNAL("triggered()"),
                     self.scribbleArea.clearImage)

        self.aboutAct = QtGui.QAction(self.tr("&About"), self)
        self.connect(self.aboutAct, QtCore.SIGNAL("triggered()"), self.about)

        self.aboutQtAct = QtGui.QAction(self.tr("About &Qt"), self)
        self.connect(self.aboutQtAct, QtCore.SIGNAL("triggered()"),
                     QtGui.qApp, QtCore.SLOT("aboutQt()"))

    def createMenus(self):
        self.saveAsMenu = QtGui.QMenu(self.tr("&Save As"), self)
        for action in self.saveAsActs:
            self.saveAsMenu.addAction(action)

        self.fileMenu = QtGui.QMenu(self.tr("&File"), self)
        self.fileMenu.addAction(self.openAct)
        self.fileMenu.addMenu(self.saveAsMenu)
        self.fileMenu.addSeparator()
        self.fileMenu.addAction(self.exitAct)

        self.optionMenu = QtGui.QMenu(self.tr("&Options"), self)
        self.optionMenu.addAction(self.penColorAct)
        self.optionMenu.addAction(self.penWidthAct)
        self.optionMenu.addSeparator()
        self.optionMenu.addAction(self.clearScreenAct)

        self.helpMenu = QtGui.QMenu(self.tr("&Help"), self)
        self.helpMenu.addAction(self.aboutAct)
        self.helpMenu.addAction(self.aboutQtAct)

        self.menuBar().addMenu(self.fileMenu)
        self.menuBar().addMenu(self.optionMenu)
        self.menuBar().addMenu(self.helpMenu)

    def maybeSave(self):
        if self.scribbleArea.isModified():
            ret = QtGui.QMessageBox.warning(self, self.tr("Scribble"),
                                            self.tr("The image has been modified.\n"
                                                    "Do you want to save your changes?"),
                                            QtGui.QMessageBox.Yes | QtGui.QMessageBox.Default,
                                            QtGui.QMessageBox.No)
            if ret == QtGui.QMessageBox.Yes:
                return self.saveFile("png")
            elif ret == QtGui.QMessageBox.Cancel:
                return False

        return True

    def saveFile(self, fileFormat):
        initialPath = QtCore.QDir.currentPath() + "/untitled." + fileFormat

        fileName = QtGui.QFileDialog.getSaveFileName(self, self.tr("Save As"),
                                    initialPath,
                                    self.tr("%1 Files (*.%2);;All Files (*)")
                                    .arg(QtCore.QString(fileFormat.toUpper()))
                                    .arg(QtCore.QString(fileFormat)))
        if fileName.isEmpty():
            return False
        else:
            return self.scribbleArea.saveImage(fileName, fileFormat)


if __name__ == "__main__":
    app = QtGui.QApplication(sys.argv)
    window = MainWindow()
    window.show()
    sys.exit(app.exec_())
