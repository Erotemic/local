#!/usr/bin/env python

#############################################################################
##
## Copyright (C) 2007-2008 Trolltech ASA. All rights reserved.
##
## This file is part of the example classes of the Qt Toolkit.
##
## Licensees holding a valid Qt License Agreement may use this file in
## accordance with the rights, responsibilities and obligations
## contained therein.  Please consult your licensing agreement or
## contact sales@trolltech.com if any conditions of this licensing
## agreement are not clear to you.
##
## Further information about Qt licensing is available at:
## http://www.trolltech.com/products/qt/licensing.html or by
## contacting info@trolltech.com.
##
## This file is provided AS IS with NO WARRANTY OF ANY KIND, INCLUDING THE
## WARRANTY OF DESIGN, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
##
#############################################################################

import sys
from PySide import QtCore, QtGui

try:
    from PySide.phonon import Phonon
except ImportError:
    app = QtGui.QApplication(sys.argv)
    QtGui.QMessageBox.critical(None, "Phonon Capabilities",
            "Your Qt installation does not have Phonon support.",
            QtGui.QMessageBox.Ok | QtGui.QMessageBox.Default,
            QtGui.QMessageBox.NoButton)
    sys.exit(1)


class Window(QtGui.QWidget):
    def __init__(self):
        QtGui.QWidget.__init__(self)

        self.setupUi()
        self.updateWidgets()

        self.connect(Phonon.BackendCapabilities.notifier(),
                QtCore.SIGNAL('capabilitiesChanged()'), self.updateWidgets)
        self.connect(Phonon.BackendCapabilities.notifier(),
                QtCore.SIGNAL('availableAudioOutputDevicesChanged()'),
                self.updateWidgets)

    def updateWidgets(self):
        # Output devices.
        devices = Phonon.BackendCapabilities.availableAudioOutputDevices()
        model = Phonon.AudioOutputDeviceModel(devices, self)
        self.devicesListView.setModel(model)

        # MIME types.
        self.mimeListWidget.clear()

        for mimeType in Phonon.BackendCapabilities.availableMimeTypes():
            item = QtGui.QListWidgetItem(self.mimeListWidget)
            item.setText(mimeType)

        # Effects.
        self.effectsTreeWidget.clear()

        for effect in Phonon.BackendCapabilities.availableAudioEffects():
            item = QtGui.QTreeWidgetItem(self.effectsTreeWidget)
            item.setText(0, self.tr("Effect"))
            item.setText(1, effect.name())
            item.setText(2, effect.description())

            # Effects parameters.
            for parameter in Phonon.Effect(effect, self).parameters():
                defaultValue = parameter.defaultValue()
                minimumValue = parameter.minimumValue()
                maximumValue = parameter.maximumValue()

                valueString = QtCore.QString("%1 / %2 / %3").arg(defaultValue.toString()).arg(minimumValue.toString()).arg(maximumValue.toString())

                parameterItem = QtGui.QTreeWidgetItem(item)
                parameterItem.setText(0, self.tr("Parameter"))
                parameterItem.setText(1, parameter.name())
                parameterItem.setText(2, parameter.description())
                parameterItem.setText(3, QtCore.QVariant.typeToName(parameter.type()))
                parameterItem.setText(4, valueString)

        for i in range(self.effectsTreeWidget.columnCount()):
            if i == 0:
                self.effectsTreeWidget.setColumnWidth(0, 150)
            elif i == 2:
                self.effectsTreeWidget.setColumnWidth(2, 350)
            else:
                self.effectsTreeWidget.resizeColumnToContents(i)

    def setupUi(self):
        self.setupBackendBox()

        layout = QtGui.QVBoxLayout()
        layout.addWidget(self.backendBox)

        self.setLayout(layout)
        self.setWindowTitle(self.tr("Backend Capabilities Example"))

    def setupBackendBox(self):
        self.devicesLabel = QtGui.QLabel(self.tr("Available Audio Devices:"))
        self.devicesListView = QtGui.QListView()

        self.mimeTypesLabel = QtGui.QLabel(self.tr("Supported MIME Types:"))
        self.mimeListWidget = QtGui.QListWidget()

        self.effectsLabel = QtGui.QLabel(self.tr("Available Audio Effects:"))

        headerLabels = [self.tr("Type"), self.tr("Name"),
                self.tr("Description"), self.tr("Value Type"),
                self.tr("Default/Min/Max Values")]

        self.effectsTreeWidget = QtGui.QTreeWidget()
        self.effectsTreeWidget.setHeaderLabels(headerLabels)
        self.effectsTreeWidget.setColumnCount(5)

        layout = QtGui.QGridLayout()
        layout.addWidget(self.devicesLabel, 0, 0)
        layout.addWidget(self.devicesListView, 1, 0)
        layout.addWidget(self.mimeTypesLabel, 0, 1)
        layout.addWidget(self.mimeListWidget, 1, 1)
        layout.addWidget(self.effectsLabel, 2, 0)
        layout.addWidget(self.effectsTreeWidget, 3, 0, 2, 2)
        layout.setRowStretch(3, 100)

        self.backendBox = QtGui.QGroupBox(self.tr("Backend Capabilities"))
        self.backendBox.setLayout(layout)


if __name__ == '__main__':
    app = QtGui.QApplication(sys.argv)
    app.setApplicationName("Phonon Capabilities Example")

    window = Window()
    window.show()

    sys.exit(app.exec_())
