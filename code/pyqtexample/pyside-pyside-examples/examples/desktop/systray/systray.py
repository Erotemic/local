#!/usr/bin/env python

############################################################################
#
#  Copyright (C) 2006-2007 Trolltech ASA. All rights reserved.
#
#  This file is part of the example classes of the Qt Toolkit.
#
#  This file may be used under the terms of the GNU General Public
#  License version 2.0 as published by the Free Software Foundation
#  and appearing in the file LICENSE.GPL included in the packaging of
#  this file.  Please review the following information to ensure GNU
#  General Public Licensing requirements will be met:
#  http://trolltech.com/products/qt/licenses/licensing/opensource/
#
#  If you are unsure which license is appropriate for your use, please
#  review the following information:
#  http://trolltech.com/products/qt/licenses/licensing/licensingoverview
#  or contact the sales department at sales@trolltech.com.
#
#  In addition, as a special exception, Trolltech gives you certain
#  additional rights. These rights are described in the Trolltech GPL
#  Exception version 1.0, which can be found at
#  http://www.trolltech.com/products/qt/gplexception/ and in the file
#  GPL_EXCEPTION.txt in this package.
#
#  In addition, as a special exception, Trolltech, as the sole copyright
#  holder for Qt Designer, grants users of the Qt/Eclipse Integration
#  plug-in the right for the Qt/Eclipse Integration to link to
#  functionality provided by Qt Designer and its related libraries.
#
#  Trolltech reserves all rights not expressly granted herein.
#
#  Trolltech ASA (c) 2007
#
#  This file is provided AS IS with NO WARRANTY OF ANY KIND, INCLUDING THE
#  WARRANTY OF DESIGN, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
#
############################################################################

import sys
from PySide import QtCore, QtGui

import systray_rc


class Window(QtGui.QWidget):
    def __init__(self):
        QtGui.QWidget.__init__(self)

        self.createIconGroupBox()
        self.createMessageGroupBox()

        self.iconLabel.setMinimumWidth(self.durationLabel.sizeHint().width())

        self.createActions()
        self.createTrayIcon()

        QtCore.QObject.connect(self.showMessageButton,
                QtCore.SIGNAL("clicked()"), self.showMessage)
        QtCore.QObject.connect(self.showIconCheckBox,
                QtCore.SIGNAL("toggled(bool)"), self.trayIcon,
                QtCore.SLOT("setVisible(bool)"))
        QtCore.QObject.connect(self.iconComboBox,
                QtCore.SIGNAL("currentIndexChanged(int)"), self.setIcon)
        QtCore.QObject.connect(self.trayIcon,
                QtCore.SIGNAL("messageClicked()"), self.messageClicked)
        QtCore.QObject.connect(self.trayIcon,
                QtCore.SIGNAL("activated(QSystemTrayIcon::ActivationReason)"),
                self.iconActivated)

        mainLayout = QtGui.QVBoxLayout()
        mainLayout.addWidget(self.iconGroupBox)
        mainLayout.addWidget(self.messageGroupBox)
        self.setLayout(mainLayout)

        self.iconComboBox.setCurrentIndex(1)
        self.trayIcon.show()

        self.setWindowTitle(self.tr("Systray"))
        self.resize(400, 300)

    def setVisible(self, visible):
        self.minimizeAction.setEnabled(visible)
        self.maximizeAction.setEnabled(not self.isMaximized())
        self.restoreAction.setEnabled(self.isMaximized() or not visible)
        QtGui.QWidget.setVisible(self, visible)

    def closeEvent(self, event):
        if self.trayIcon.isVisible():
            QtGui.QMessageBox.information(self, self.tr("Systray"),
                    self.tr("The program will keep running in the system "
                        "tray. To terminate the program, choose <b>Quit</b> "
                        "in the context menu of the system tray entry."))
            self.hide()
            event.ignore()

    def setIcon(self, index):
        icon = self.iconComboBox.itemIcon(index)
        self.trayIcon.setIcon(icon)
        self.setWindowIcon(icon)

        self.trayIcon.setToolTip(self.iconComboBox.itemText(index))

    def iconActivated(self, reason):
        if reason == QtGui.QSystemTrayIcon.Trigger \
                or reason == QtGui.QSystemTrayIcon.DoubleClick:
            self.iconComboBox.setCurrentIndex(
                    (self.iconComboBox.currentIndex() + 1)
                    % self.iconComboBox.count())
        elif reason == QtGui.QSystemTrayIcon.MiddleClick:
            self.showMessage()

    def showMessage(self):
        icon = QtGui.QSystemTrayIcon.MessageIcon(
             self.typeComboBox.itemData(
                 self.typeComboBox.currentIndex()).toInt()[0])
        self.trayIcon.showMessage(self.titleEdit.text(),
                self.bodyEdit.toPlainText(), icon,
                self.durationSpinBox.value() * 1000)

    def messageClicked(self):
        QtGui.QMessageBox.information(None, self.tr("Systray"),
                self.tr("Sorry, I already gave what help I could.\nMaybe you "
                    "should try asking a human?"))

    def createIconGroupBox(self):
        self.iconGroupBox = QtGui.QGroupBox(self.tr("Tray Icon"))

        self.iconLabel = QtGui.QLabel("Icon:")

        self.iconComboBox = QtGui.QComboBox()
        self.iconComboBox.addItem(QtGui.QIcon(":/images/bad.svg"),
                self.tr("Bad"))
        self.iconComboBox.addItem(QtGui.QIcon(":/images/heart.svg"),
                self.tr("Heart"))
        self.iconComboBox.addItem(QtGui.QIcon(":/images/trash.svg"),
                self.tr("Trash"))

        self.showIconCheckBox = QtGui.QCheckBox(self.tr("Show icon"))
        self.showIconCheckBox.setChecked(True)

        iconLayout = QtGui.QHBoxLayout()
        iconLayout.addWidget(self.iconLabel)
        iconLayout.addWidget(self.iconComboBox)
        iconLayout.addStretch()
        iconLayout.addWidget(self.showIconCheckBox)
        self.iconGroupBox.setLayout(iconLayout)

    def createMessageGroupBox(self):
        self.messageGroupBox = QtGui.QGroupBox(self.tr("Balloon Message"))

        self.typeLabel = QtGui.QLabel(self.tr("Type:"))

        self.typeComboBox = QtGui.QComboBox()
        self.typeComboBox.addItem(self.tr("None"),
                QtCore.QVariant(QtGui.QSystemTrayIcon.NoIcon))
        self.typeComboBox.addItem(self.style().standardIcon(
                QtGui.QStyle.SP_MessageBoxInformation), self.tr("Information"),
                QtCore.QVariant(QtGui.QSystemTrayIcon.Information))
        self.typeComboBox.addItem(self.style().standardIcon(
                QtGui.QStyle.SP_MessageBoxWarning), self.tr("Warning"),
                QtCore.QVariant(QtGui.QSystemTrayIcon.Warning))
        self.typeComboBox.addItem(self.style().standardIcon(
                QtGui.QStyle.SP_MessageBoxCritical), self.tr("Critical"),
                QtCore.QVariant(QtGui.QSystemTrayIcon.Critical))
        self.typeComboBox.setCurrentIndex(1)

        self.durationLabel = QtGui.QLabel(self.tr("Duration:"))

        self.durationSpinBox = QtGui.QSpinBox()
        self.durationSpinBox.setRange(5, 60)
        self.durationSpinBox.setSuffix(" s")
        self.durationSpinBox.setValue(15)

        self.durationWarningLabel = QtGui.QLabel(self.tr("(some systems might "
                "ignore this hint)"))
        self.durationWarningLabel.setIndent(10)

        self.titleLabel = QtGui.QLabel(self.tr("Title:"))

        self.titleEdit = QtGui.QLineEdit(self.tr("Cannot connect to network"))

        self.bodyLabel = QtGui.QLabel(self.tr("Body:"))

        self.bodyEdit = QtGui.QTextEdit()
        self.bodyEdit.setPlainText(self.tr("Don't believe me. Honestly, I "
                "don't have a clue.\nClick this balloon for details."))

        self.showMessageButton = QtGui.QPushButton(self.tr("Show Message"))
        self.showMessageButton.setDefault(True)

        messageLayout = QtGui.QGridLayout()
        messageLayout.addWidget(self.typeLabel, 0, 0)
        messageLayout.addWidget(self.typeComboBox, 0, 1, 1, 2)
        messageLayout.addWidget(self.durationLabel, 1, 0)
        messageLayout.addWidget(self.durationSpinBox, 1, 1)
        messageLayout.addWidget(self.durationWarningLabel, 1, 2, 1, 3)
        messageLayout.addWidget(self.titleLabel, 2, 0)
        messageLayout.addWidget(self.titleEdit, 2, 1, 1, 4)
        messageLayout.addWidget(self.bodyLabel, 3, 0)
        messageLayout.addWidget(self.bodyEdit, 3, 1, 2, 4)
        messageLayout.addWidget(self.showMessageButton, 5, 4)
        messageLayout.setColumnStretch(3, 1)
        messageLayout.setRowStretch(4, 1)
        self.messageGroupBox.setLayout(messageLayout)

    def createActions(self):
        self.minimizeAction = QtGui.QAction(self.tr("Mi&nimize"), self)
        QtCore.QObject.connect(self.minimizeAction,
                QtCore.SIGNAL("triggered()"), self, QtCore.SLOT("hide()"))

        self.maximizeAction = QtGui.QAction(self.tr("Ma&ximize"), self)
        QtCore.QObject.connect(self.maximizeAction,
                QtCore.SIGNAL("triggered()"), self,
                QtCore.SLOT("showMaximized()"))

        self.restoreAction = QtGui.QAction(self.tr("&Restore"), self)
        QtCore.QObject.connect(self.restoreAction,
                QtCore.SIGNAL("triggered()"), self,
                QtCore.SLOT("showNormal()"))

        self.quitAction = QtGui.QAction(self.tr("&Quit"), self)
        QtCore.QObject.connect(self.quitAction, QtCore.SIGNAL("triggered()"),
                QtGui.qApp, QtCore.SLOT("quit()"))

    def createTrayIcon(self):
         self.trayIconMenu = QtGui.QMenu(self)
         self.trayIconMenu.addAction(self.minimizeAction)
         self.trayIconMenu.addAction(self.maximizeAction)
         self.trayIconMenu.addAction(self.restoreAction)
         self.trayIconMenu.addSeparator()
         self.trayIconMenu.addAction(self.quitAction)

         self.trayIcon = QtGui.QSystemTrayIcon(self)
         self.trayIcon.setContextMenu(self.trayIconMenu)


if __name__=='__main__':
    app = QtGui.QApplication(sys.argv)

    if not QtGui.QSystemTrayIcon.isSystemTrayAvailable():
        QtGui.QMessageBox.critical(None, QtCore.QObject.tr(app, "Systray"),
                QtCore.QObject.tr(app, "I couldn't detect any system tray on "
                    "this system."))
        sys.exit(1)

    window = Window()
    window.show()
    sys.exit(app.exec_())
