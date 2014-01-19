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


class Dialog(QtGui.QDialog):
    TotalBytes = 50 * 1024 * 1024
    PayloadSize = 65536

    def __init__(self, parent=None):
        QtGui.QDialog.__init__(self, parent)
        
        self.tcpServer = QtNetwork.QTcpServer()
        self.tcpClient = QtNetwork.QTcpSocket()
        self.bytesToWrite = 0
        self.bytesWritten = 0
        self.bytesReceived = 0
        
        self.clientProgressBar = QtGui.QProgressBar()
        self.clientStatusLabel = QtGui.QLabel(self.tr("Client ready"))
        self.serverProgressBar = QtGui.QProgressBar()
        self.serverStatusLabel = QtGui.QLabel(self.tr("Server ready"))
        
        self.startButton = QtGui.QPushButton(self.tr("&Start"))
        self.quitButton = QtGui.QPushButton(self.tr("&Quit"))
        
        self.connect(self.startButton, QtCore.SIGNAL("clicked()"), self.start)
        self.connect(self.quitButton, QtCore.SIGNAL("clicked()"),
                     self, QtCore.SLOT("close()"))
        self.connect(self.tcpServer, QtCore.SIGNAL("newConnection()"),
                     self.acceptConnection)
        self.connect(self.tcpClient, QtCore.SIGNAL("connected()"), 
                     self.startTransfer)
        self.connect(self.tcpClient, QtCore.SIGNAL("bytesWritten(qint64)"),     
                     self.updateClientProgress)
        self.connect(self.tcpClient, 
                     QtCore.SIGNAL("error(QAbstractSocket::SocketError)"), 
                     self.displayError)
        
        buttonLayout = QtGui.QHBoxLayout()
        buttonLayout.addStretch(1)
        buttonLayout.addWidget(self.startButton)
        buttonLayout.addWidget(self.quitButton)
        
        mainLayout = QtGui.QVBoxLayout()
        mainLayout.addWidget(self.clientProgressBar)
        mainLayout.addWidget(self.clientStatusLabel)
        mainLayout.addWidget(self.serverProgressBar)
        mainLayout.addWidget(self.serverStatusLabel)
        mainLayout.addLayout(buttonLayout)
        self.setLayout(mainLayout)
        
        self.setWindowTitle(self.tr("Loopback"))
        
    def start(self):
        self.startButton.setEnabled(False)
        
        QtGui.QApplication.setOverrideCursor(QtCore.Qt.WaitCursor)
        
        self.bytesWritten = 0
        self.bytesReceived = 0
        
        while not self.tcpServer.isListening() and not self.tcpServer.listen():
            ret = QtGui.QMessageBox.critical(self, self.tr("Loopback"),
                            self.tr("Unable to start the test: %1.").arg(
                                    self.tcpServer.errorString()),
                            QtGui.QMessageBox.Retry,
                            QtGui.QMessageBox.Cancel)
            if ret == QtGui.QMessageBox.Cancel:
                return
        
        self.serverStatusLabel.setText(self.tr("Listening"))
        self.clientStatusLabel.setText(self.tr("Connecting"))
        
        self.tcpClient.connectToHost(QtNetwork.QHostAddress(QtNetwork.QHostAddress.LocalHost), self.tcpServer.serverPort())

    def acceptConnection(self):
        self.tcpServerConnection = self.tcpServer.nextPendingConnection()
        self.connect(self.tcpServerConnection, QtCore.SIGNAL("readyRead()"),
                     self.updateServerProgress)
        self.connect(self.tcpServerConnection, 
                     QtCore.SIGNAL("error(QAbstractSocket::SocketError)"),
                     self.displayError)
        
        self.serverStatusLabel.setText(self.tr("Accepted connection"))
        self.tcpServer.close()
        
    def startTransfer(self):
        self.bytesToWrite = Dialog.TotalBytes - self.tcpClient.write(QtCore.QByteArray(Dialog.PayloadSize, '@'))
        self.clientStatusLabel.setText(self.tr("Connected"))
        
    def updateServerProgress(self):
        self.bytesReceived += self.tcpServerConnection.bytesAvailable()
        self.tcpServerConnection.readAll()

        self.serverProgressBar.setMaximum(Dialog.TotalBytes)
        self.serverProgressBar.setValue(self.bytesReceived)
        self.serverStatusLabel.setText(self.tr("Received %1MB")
                                       .arg(self.bytesReceived / (1024 * 1024)))
        
        if self.bytesReceived == Dialog.TotalBytes:
            self.tcpServerConnection.close()
            self.startButton.setEnabled(True)
            QtGui.QApplication.restoreOverrideCursor()
            
    def updateClientProgress(self, numBytes):
        self.bytesWritten += numBytes
        if self.bytesToWrite > 0:
            self.bytesToWrite -= self.tcpClient.write(QtCore.QByteArray(
                                        min(self.bytesToWrite, Dialog.PayloadSize), '@'))

        self.clientProgressBar.setMaximum(Dialog.TotalBytes)
        self.clientProgressBar.setValue(self.bytesWritten)
        self.clientStatusLabel.setText(self.tr("Sent %1MB")
                                       .arg(self.bytesWritten / (1024 * 1024)))
        
    def displayError(self, socketError):
        if socketError == QtNetwork.QTcpSocket.RemoteHostClosedError:
            return
        
        QtGui.QMessageBox.information(self, self.tr("Network error"),
                                      self.tr("The following error occured: "\
                                              "%1.")
                                      .arg(self.tcpClient.errorString()))

        self.tcpClient.close()
        self.tcpServer.close()
        self.clientProgressBar.reset()
        self.serverProgressBar.reset()
        self.clientStatusLabel.setText(self.tr("Client ready"))
        self.serverStatusLabel.setText(self.tr("Server ready"))
        self.startButton.setEnabled(True)
        QtGui.QApplication.restoreOverrideCursor()


if __name__ == "__main__":
    app = QtGui.QApplication(sys.argv)
    dialog = Dialog()
    dialog.show()
    sys.exit(dialog.exec_())
