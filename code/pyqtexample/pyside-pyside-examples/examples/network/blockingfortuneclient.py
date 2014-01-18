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
from PySide import QtCore, QtGui, QtNetwork


class FortuneThread(QtCore.QThread):
    def __init__(self, parent=None):
        QtCore.QThread.__init__(self, parent)

        self.quit = False
        self.hostName = QtCore.QString()
        self.cond = QtCore.QWaitCondition()
        self.mutex = QtCore.QMutex()
        self.port = 0

    def __del__(self):
        self.quit = True
        self.cond.wakeOne()
        self.wait()

    def requestNewFortune(self, hostname, port):
        locker = QtCore.QMutexLocker(self.mutex)
        self.hostName = hostname
        self.port = port
        if not self.isRunning():
            self.start()
        else:
            self.cond.wakeOne()

    def run(self):
        self.mutex.lock()
        serverName = self.hostName
        serverPort = self.port
        self.mutex.unlock()

        while not self.quit:
            Timeout = 5 * 1000

            socket = QtNetwork.QTcpSocket()
            socket.connectToHost(serverName, serverPort)

            if not socket.waitForConnected(Timeout):
                self.emit(QtCore.SIGNAL("error(int, const QString &)"), 
                          socket.error(), socket.errorString())
                return

            while socket.bytesAvailable() < 2:
                if not socket.waitForReadyRead(Timeout):
                    self.emit(QtCore.SIGNAL("error(int, const QString &)"),
                              socket.error(), socket.errorString())
                    return 

            instr = QtCore.QDataStream(socket)
            instr.setVersion(QtCore.QDataStream.Qt_4_0)
            blockSize = instr.readUInt16()

            while socket.bytesAvailable() < blockSize:
                if not socket.waitForReadyRead(Timeout):
                    self.emit(QtCore.SIGNAL("error(int, const QString &)"),
                              socket.error(), socket.errorString())
                    return

            locker = QtCore.QMutexLocker(self.mutex)

            fortune = QtCore.QString()
            instr >> fortune
            self.emit(QtCore.SIGNAL("newFortune(const QString &)"), fortune)

            self.cond.wait(self.mutex)
            serverName = self.hostName
            serverPort = self.port
            del locker


class BlockingClient(QtGui.QDialog):
    def __init__(self, parent=None):
        QtGui.QDialog.__init__(self, parent)

        self._main = QtCore.QThread.currentThread()
        self.thread = FortuneThread()
        self.currentFortune = QtCore.QString()

        self.hostLabel = QtGui.QLabel(self.tr("&Server name:"))
        self.portLabel = QtGui.QLabel(self.tr("S&erver port:"))

        self.hostLineEdit = QtGui.QLineEdit("Localhost")
        self.portLineEdit = QtGui.QLineEdit()
        self.portLineEdit.setValidator(QtGui.QIntValidator(1, 65535, self))

        self.hostLabel.setBuddy(self.hostLineEdit)
        self.portLabel.setBuddy(self.portLineEdit)

        self.statusLabel = QtGui.QLabel(self.tr("This example requires that "
                                                "you run the Fortune Server "
                                                "example as well."))

        self.getFortuneButton = QtGui.QPushButton(self.tr("Get Fortune"))
        self.getFortuneButton.setDefault(True)
        self.getFortuneButton.setEnabled(False)

        self.quitButton = QtGui.QPushButton(self.tr("Quit"))

        self.connect(self.hostLineEdit,
                     QtCore.SIGNAL("textChanged(const QString &)"),
                     self.enableGetFortuneButton)
        self.connect(self.portLineEdit,
                     QtCore.SIGNAL("textChanged(const QString &)"),
                     self.enableGetFortuneButton)
        self.connect(self.getFortuneButton, QtCore.SIGNAL("clicked()"),
                     self.requestNewFortune)
        self.connect(self.quitButton, QtCore.SIGNAL("clicked()"),
                     self, QtCore.SLOT("close()"))
        self.connect(self.thread, QtCore.SIGNAL("newFortune(const QString &)"),
                     self.showFortune)
        self.connect(self.thread, QtCore.SIGNAL("error(int, const QString &)"),
                     self.displayError)

        buttonLayout = QtGui.QHBoxLayout()
        buttonLayout.addStretch(1)
        buttonLayout.addWidget(self.getFortuneButton)
        buttonLayout.addWidget(self.quitButton)

        mainLayout = QtGui.QGridLayout()
        mainLayout.addWidget(self.hostLabel, 0, 0)
        mainLayout.addWidget(self.hostLineEdit, 0, 1)
        mainLayout.addWidget(self.portLabel, 1, 0)
        mainLayout.addWidget(self.portLineEdit, 1, 1)
        mainLayout.addWidget(self.statusLabel, 2, 0, 1, 2)
        mainLayout.addLayout(buttonLayout, 3, 0, 1, 2)
        self.setLayout(mainLayout)

        self.setWindowTitle(self.tr("Blocking Fortune Client"))
        self.portLineEdit.setFocus()

    def requestNewFortune(self):
        self.getFortuneButton.setEnabled(False)
        self.thread.requestNewFortune(self.hostLineEdit.text(),
                                      self.portLineEdit.text().toInt()[0])

    def showFortune(self, nextFortune):
        if nextFortune == self.currentFortune:
            self.requestNewFortune()
            return

        self.currentFortune = QtCore.QString(nextFortune)
        self.statusLabel.setText(self.currentFortune)
        self.getFortuneButton.setEnabled(True)

    def displayError(self, socketError, message):
        if socketError == QtNetwork.QAbstractSocket.HostNotFoundError:
            QtGui.QMessageBox.information(self, 
                                          self.tr("Blocking Fortune Client"),
                                          self.tr("The host was not found. "
                                                  "Please check the host and "
                                                  "port settings."))
        elif socketError == QtNetwork.QAbstractSocket.ConnectionRefusedError:
            QtGui.QMessageBox.information(self,
                                          self.tr("Blocking Fortune Client"),
                                          self.tr("The connection was refused "
                                                  "by the peer. Make sure the "
                                                  "fortune server is running, "
                                                  "and check that the host "
                                                  "name and port settings are "
                                                  "correct."))
        else:
            QtGui.QMessageBox.information(self,
                                          self.tr("Blocking Fortune Client"),
                                          self.tr("The following error "
                                                  "occurred: %1.").arg(message))

        self.getFortuneButton.setEnabled(True)

    def enableGetFortuneButton(self):
        self.getFortuneButton.setEnabled( 
                        not self.hostLineEdit.text().isEmpty() and
                        not self.portLineEdit.text().isEmpty())


if __name__ == "__main__":
    app = QtGui.QApplication(sys.argv)
    client = BlockingClient()
    client.show()
    sys.exit(client.exec_())
