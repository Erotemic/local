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

import pixelator_rc


ItemSize = 256


class PixelDelegate(QtGui.QAbstractItemDelegate):
    def __init__(self, parent=None):
        QtGui.QAbstractItemDelegate.__init__(self,parent)

        self.pixelSize = 12
    
    def paint(self, painter, option, index):
        painter.setRenderHint(QtGui.QPainter.Antialiasing)
        painter.setPen(QtCore.Qt.NoPen)

        if option.state & QtGui.QStyle.State_Selected:
            painter.setBrush(option.palette.highlight())
        else:
            painter.setBrush(QtGui.QBrush(QtCore.Qt.white))
        
        painter.drawRect(option.rect)
        
        if option.state & QtGui.QStyle.State_Selected:
            painter.setBrush(option.palette.highlightedText())
        else:
            painter.setBrush(QtGui.QBrush(QtCore.Qt.black))

        size = min(option.rect.width(), option.rect.height())
        brightness, ok = index.model().data(index, QtCore.Qt.DisplayRole).toInt()
        radius = (size/2.0) - (brightness/255.0 * size/2.0)
        painter.drawEllipse(QtCore.QRectF(
                            option.rect.x() + option.rect.width()/2 - radius,
                            option.rect.y() + option.rect.height()/2 - radius,
                            2*radius, 2*radius))
    
    def sizeHint(self, option, index):
        return QtCore.QSize(self.pixelSize, self.pixelSize)
    
    def setPixelSize(self, size):
        self.pixelSize = size


class ImageModel(QtCore.QAbstractTableModel):
    def __init__(self, image, parent=None):
        QtCore.QAbstractTableModel.__init__(self, parent)

        self.modelImage = QtGui.QImage(image)

    def rowCount(self, parent):
        return self.modelImage.height()

    def columnCount(self, parent):
        return self.modelImage.width()

    def data(self, index, role):
        if not index.isValid():
            return QtCore.QVariant()
        elif role != QtCore.Qt.DisplayRole:
            return QtCore.QVariant()
        
        return QtCore.QVariant(QtGui.qGray(self.modelImage.pixel(index.column(), index.row())))


class MainWindow(QtGui.QMainWindow):
    def __init__(self, parent=None):
        QtGui.QMainWindow.__init__(self, parent)
        
        self.currentPath = QtCore.QDir.home().absolutePath()
        self.model = ImageModel(QtGui.QImage(), self)
        
        centralWidget = QtGui.QWidget()
        
        self.view = QtGui.QTableView()
        self.view.setShowGrid(False)
        self.view.horizontalHeader().hide()
        self.view.verticalHeader().hide()
        
        delegate = PixelDelegate(self)
        self.view.setItemDelegate(delegate)
        
        pixelSizeLabel = QtGui.QLabel(self.tr("Pixel size:"))
        pixelSizeSpinBox = QtGui.QSpinBox()
        pixelSizeSpinBox.setMinimum(1)
        pixelSizeSpinBox.setMaximum(32)
        pixelSizeSpinBox.setValue(12)
        
        fileMenu = QtGui.QMenu(self.tr("&File"), self)
        openAction = fileMenu.addAction(self.tr("&Open..."))
        openAction.setShortcut(QtGui.QKeySequence(self.tr("Ctrl+O")))
        
        self.printAction = fileMenu.addAction(self.tr("&Print..."))
        self.printAction.setEnabled(False)
        self.printAction.setShortcut(QtGui.QKeySequence(self.tr("Ctrl+P")))
        
        quitAction = fileMenu.addAction(self.tr("E&xit"))
        quitAction.setShortcut(QtGui.QKeySequence(self.tr("Ctrl+Q")))
        
        helpMenu = QtGui.QMenu(self.tr("&Help"), self)
        aboutAction = helpMenu.addAction(self.tr("&About"))
        
        self.menuBar().addMenu(fileMenu)
        self.menuBar().addSeparator()
        self.menuBar().addMenu(helpMenu)
        
        self.connect(openAction, QtCore.SIGNAL("triggered()"),
                     self.chooseImage)
        self.connect(self.printAction, QtCore.SIGNAL("triggered()"),
                     self.printImage)
        self.connect(quitAction, QtCore.SIGNAL("triggered()"),
                     QtGui.qApp, QtCore.SLOT("quit()"))
        self.connect(aboutAction, QtCore.SIGNAL("triggered()"),
                     self.showAboutBox)
        self.connect(pixelSizeSpinBox, QtCore.SIGNAL("valueChanged(int)"), 
                     delegate.setPixelSize)
        self.connect(pixelSizeSpinBox, QtCore.SIGNAL("valueChanged(int)"), 
                     self.updateView)
        
        controlsLayout = QtGui.QHBoxLayout()
        controlsLayout.addWidget(pixelSizeLabel)
        controlsLayout.addWidget(pixelSizeSpinBox)
        controlsLayout.addStretch(1)

        mainLayout = QtGui.QVBoxLayout()
        mainLayout.addWidget(self.view)
        mainLayout.addLayout(controlsLayout)
        centralWidget.setLayout(mainLayout)
        
        self.setCentralWidget(centralWidget)
        
        self.setWindowTitle(self.tr("Pixelator"))
        self.resize(640,480)
        
    def chooseImage(self):
        fileName = QtGui.QFileDialog.getOpenFileName(self, self.tr("Choose an Image"),
                                                     self.currentPath, "*")

        if not fileName.isEmpty():
            self.openImage(fileName)
            
    def openImage(self, fileName):
        image = QtGui.QImage()

        if image.load(fileName):
            newModel = ImageModel(image, self)
            self.view.setModel(newModel)
            self.model = newModel
            
            if not fileName.startsWith(":/"):
                self.currentPath = fileName
                self.setWindowTitle(self.tr("%1 - Pixelator").arg(self.currentPath))

            self.printAction.setEnabled(True)
            self.updateView()

    def printImage(self):
        if self.model.rowCount(QtCore.QModelIndex()) * self.model.columnCount(QtCore.QModelIndex()) > 90000:
            answer = QtGui.QMessageBox.question(self, self.tr("Large Image Size"),
                                  self.tr("The printed image may be very "
                                          "large. Are you sure that you want "
                                          "to print it?"),
                                  QtGui.QMessageBox.Yes, QtGui.QMessageBox.No)
            if answer == QtGui.QMessageBox.No:
                return

        printer = QtGui.QPrinter(QtGui.QPrinter.HighResolution)

        dlg = QtGui.QPrintDialog(printer, self)
        dlg.setWindowTitle(self.tr("Print Image"))
        
        if dlg.exec_() != QtGui.QDialog.Accepted:
            return
        
        painter = QtGui.QPainter()
        painter.begin(printer)
        
        rows = self.model.rowCount(QtCore.QModelIndex())
        columns = self.model.columnCount(QtCore.QModelIndex())
        sourceWidth = (columns+1) * ItemSize
        sourceHeight = (rows+1) * ItemSize
        
        painter.save()
        
        xscale = printer.pageRect().width() / float(sourceWidth)
        yscale = printer.pageRect().height() / float(sourceHeight)
        scale = min(xscale, yscale)
        
        painter.translate(printer.pageRect().x()+printer.pageRect().width()/2,
                          printer.pageRect().y()+printer.pageRect().height()/2)
        painter.scale(scale, scale)
        painter.translate(-sourceWidt/2, -sourceHeight/2)
        
        option = QtGui.QStyleOptionViewItem()
        parent = QtCore.QModelIndex()
         
        progress = QtGui.QProgressDialog(self.tr("Printing..."), self.tr("Cancel..."), 0, rows, self)
        y = ItemSize / 2.0
        
        for row in range(rows):
            progress.setValue(row)
            QtGui.qApp.processEvents()
            if progress.wasCanceled():
                break
            
            x = ItemSize / 2.0
            
            for col in range(columns):
                option.rect = QtCore.QRect(x, y, ItemSize, ItemSize)
                self.view.itemDelegate.paint(painter, option, 
                                             self.model.index(row, column, parent))
                x = x + ItemSize

            y = y + ItemSize
        
        progress.setValue(rows)
        
        painter.restore()
        painter.end()
        
        if progress.wasCanceled():
            QtGui.QMessageBox.information(self, self.tr("Printing canceled"),
                                          self.tr("The printing process was canceled."),
                                          QtGui.QMessageBox.Cancel)
        
    def showAboutBox(self):
        QtGui.QMessageBox.about(self, self.tr("About the Pixelator example"),
            self.tr("This example demonstrates how a standard view and a custom\n"
                    "delegate can be used to produce a specialized representation\n"
                    "of data in a simple custom model."))

    def updateView(self):
        for row in range(self.model.rowCount(QtCore.QModelIndex())):
            self.view.resizeRowToContents(row)
        for column in range(self.model.columnCount(QtCore.QModelIndex())):
            self.view.resizeColumnToContents(column)
    

if __name__ == "__main__":
    app = QtGui.QApplication(sys.argv)
    window = MainWindow()
    window.show()
    window.openImage(QtCore.QString(":/images/qt.png"))
    sys.exit(app.exec_())
