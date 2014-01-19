#!/usr/bin/env python

"""***************************************************************************
**
** Copyright (C) 2006-2007 Trolltech ASA. All rights reserved.
**
** This file is part of the example classes of the Qt Toolkit.
**
** Licensees holding a valid Qt License Agreement may use this file in
** accordance with the rights, responsibilities and obligations
** contained therein.  Please consult your licensing agreement or
** contact sales@trolltech.com if any conditions of this licensing
** agreement are not clear to you.
**
** Further information about Qt licensing is available at:
** http://www.trolltech.com/products/qt/licensing.html or by
** contacting info@trolltech.com.
**
** This file is provided AS IS with NO WARRANTY OF ANY KIND, INCLUDING THE
** WARRANTY OF DESIGN, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
**
***************************************************************************"""

import sys
from PySide import QtCore, QtGui


class Window(QtGui.QWidget):
    def __init__(self):
        QtGui.QWidget.__init__(self)

        self.proxyModel = QtGui.QSortFilterProxyModel()
        self.proxyModel.setDynamicSortFilter(True)

        self.sourceGroupBox = QtGui.QGroupBox("Original Model")
        self.proxyGroupBox = QtGui.QGroupBox("Sorted/Filtered Model")

        self.sourceView = QtGui.QTreeView()
        self.sourceView.setRootIsDecorated(False)
        self.sourceView.setAlternatingRowColors(True)

        self.proxyView = QtGui.QTreeView()
        self.proxyView.setRootIsDecorated(False)
        self.proxyView.setAlternatingRowColors(True)
        self.proxyView.setModel(self.proxyModel)
        self.proxyView.setSortingEnabled(True)

        self.sortCaseSensitivityCheckBox = QtGui.QCheckBox("Case sensitive sorting")
        self.filterCaseSensitivityCheckBox = QtGui.QCheckBox("Case sensitive filter")

        self.filterPatternLineEdit = QtGui.QLineEdit()
        self.filterPatternLabel = QtGui.QLabel("&Filter pattern:")
        self.filterPatternLabel.setBuddy(self.filterPatternLineEdit)

        self.filterSyntaxComboBox = QtGui.QComboBox()
        self.filterSyntaxComboBox.addItem("Regular expression", QtCore.QVariant(QtCore.QRegExp.RegExp))
        self.filterSyntaxComboBox.addItem("Wildcard", QtCore.QVariant(QtCore.QRegExp.Wildcard))
        self.filterSyntaxComboBox.addItem("Fixed string", QtCore.QVariant(QtCore.QRegExp.FixedString))
        self.filterSyntaxLabel = QtGui.QLabel("Filter &syntax:")
        self.filterSyntaxLabel.setBuddy(self.filterSyntaxComboBox)

        self.filterColumnComboBox = QtGui.QComboBox()
        self.filterColumnComboBox.addItem("Subject")
        self.filterColumnComboBox.addItem("Sender")
        self.filterColumnComboBox.addItem("Date")
        self.filterColumnLabel = QtGui.QLabel("Filter &column:")
        self.filterColumnLabel.setBuddy(self.filterColumnComboBox)

        self.connect(self.filterPatternLineEdit,
                QtCore.SIGNAL('textChanged(const QString &)'),
                self.filterRegExpChanged)
        self.connect(self.filterSyntaxComboBox,
                QtCore.SIGNAL('currentIndexChanged(int)'),
                self.filterRegExpChanged)
        self.connect(self.filterColumnComboBox,
                QtCore.SIGNAL('currentIndexChanged(int)'),
                self.filterColumnChanged)
        self.connect(self.filterCaseSensitivityCheckBox,
                QtCore.SIGNAL('toggled(bool)'),
                self.filterRegExpChanged)
        self.connect(self.sortCaseSensitivityCheckBox,
                QtCore.SIGNAL('toggled(bool)'),
                self.sortChanged)

        sourceLayout = QtGui.QHBoxLayout()
        sourceLayout.addWidget(self.sourceView)
        self.sourceGroupBox.setLayout(sourceLayout)

        proxyLayout = QtGui.QGridLayout()
        proxyLayout.addWidget(self.proxyView, 0, 0, 1, 3)
        proxyLayout.addWidget(self.filterPatternLabel, 1, 0)
        proxyLayout.addWidget(self.filterPatternLineEdit, 1, 1, 1, 2)
        proxyLayout.addWidget(self.filterSyntaxLabel, 2, 0)
        proxyLayout.addWidget(self.filterSyntaxComboBox, 2, 1, 1, 2)
        proxyLayout.addWidget(self.filterColumnLabel, 3, 0)
        proxyLayout.addWidget(self.filterColumnComboBox, 3, 1, 1, 2)
        proxyLayout.addWidget(self.filterCaseSensitivityCheckBox, 4, 0, 1, 2)
        proxyLayout.addWidget(self.sortCaseSensitivityCheckBox, 4, 2)
        self.proxyGroupBox.setLayout(proxyLayout)

        mainLayout = QtGui.QVBoxLayout()
        mainLayout.addWidget(self.sourceGroupBox)
        mainLayout.addWidget(self.proxyGroupBox)
        self.setLayout(mainLayout)

        self.setWindowTitle("Basic Sort/Filter Model")
        self.resize(500, 450)

        self.proxyView.sortByColumn(1, QtCore.Qt.AscendingOrder)
        self.filterColumnComboBox.setCurrentIndex(1)

        self.filterPatternLineEdit.setText("Andy|Grace")
        self.filterCaseSensitivityCheckBox.setChecked(True)
        self.sortCaseSensitivityCheckBox.setChecked(True)

    def setSourceModel(self, model):
        self.proxyModel.setSourceModel(model)
        self.sourceView.setModel(model)

    def filterRegExpChanged(self):
        syntax_nr, _ = self.filterSyntaxComboBox.itemData(self.filterSyntaxComboBox.currentIndex()).toInt()
        syntax = QtCore.QRegExp.PatternSyntax(syntax_nr)

        if self.filterCaseSensitivityCheckBox.isChecked():
            caseSensitivity = QtCore.Qt.CaseSensitive
        else:
            caseSensitivity = QtCore.Qt.CaseInsensitive

        regExp = QtCore.QRegExp(self.filterPatternLineEdit.text(), caseSensitivity, syntax)
        self.proxyModel.setFilterRegExp(regExp)

    def filterColumnChanged(self):
        self.proxyModel.setFilterKeyColumn(self.filterColumnComboBox.currentIndex())

    def sortChanged(self):
        if self.sortCaseSensitivityCheckBox.isChecked():
            caseSensitivity = QtCore.Qt.CaseSensitive
        else:
            caseSensitivity = QtCore.Qt.CaseInsensitive

        self.proxyModel.setSortCaseSensitivity(caseSensitivity)


def addMail(model, subject, sender, date):
    model.insertRow(0)
    model.setData(model.index(0, 0), QtCore.QVariant(subject))
    model.setData(model.index(0, 1), QtCore.QVariant(sender))
    model.setData(model.index(0, 2), QtCore.QVariant(date))


def createMailModel(parent):
    model = QtGui.QStandardItemModel(0, 3, parent)

    model.setHeaderData(0, QtCore.Qt.Horizontal, QtCore.QVariant("Subject"))
    model.setHeaderData(1, QtCore.Qt.Horizontal, QtCore.QVariant("Sender"))
    model.setHeaderData(2, QtCore.Qt.Horizontal, QtCore.QVariant("Date"))

    addMail(model, "Happy New Year!", "Grace K. <grace@software-inc.com>",
            QtCore.QDateTime(QtCore.QDate(2006, 12, 31), QtCore.QTime(17, 03)))
    addMail(model, "Radically new concept", "Grace K. <grace@software-inc.com>",
            QtCore.QDateTime(QtCore.QDate(2006, 12, 22), QtCore.QTime(9, 44)))
    addMail(model, "Accounts", "pascale@nospam.com",
            QtCore.QDateTime(QtCore.QDate(2006, 12, 31), QtCore.QTime(12, 50)))
    addMail(model, "Expenses", "Joe Bloggs <joe@bloggs.com>",
            QtCore.QDateTime(QtCore.QDate(2006, 12, 25), QtCore.QTime(11, 39)))
    addMail(model, "Re: Expenses", "Andy <andy@nospam.com>",
            QtCore.QDateTime(QtCore.QDate(2007, 01, 02), QtCore.QTime(16, 05)))
    addMail(model, "Re: Accounts", "Joe Bloggs <joe@bloggs.com>",
            QtCore.QDateTime(QtCore.QDate(2007, 01, 03), QtCore.QTime(14, 18)))
    addMail(model, "Re: Accounts", "Andy <andy@nospam.com>",
            QtCore.QDateTime(QtCore.QDate(2007, 01, 03), QtCore.QTime(14, 26)))
    addMail(model, "Sports", "Linda Smith <linda.smith@nospam.com>",
            QtCore.QDateTime(QtCore.QDate(2007, 01, 05), QtCore.QTime(11, 33)))
    addMail(model, "AW: Sports", "Rolf Newschweinstein <rolfn@nospam.com>",
            QtCore.QDateTime(QtCore.QDate(2007, 01, 05), QtCore.QTime(12, 00)))
    addMail(model, "RE: Sports", "Petra Schmidt <petras@nospam.com>",
            QtCore.QDateTime(QtCore.QDate(2007, 01, 05), QtCore.QTime(12, 01)))

    return model


app = QtGui.QApplication(sys.argv)
window = Window()
window.setSourceModel(createMailModel(window))
window.show()
sys.exit(app.exec_())
