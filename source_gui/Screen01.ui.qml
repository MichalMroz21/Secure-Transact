
/*
This is a UI file (.ui.qml) that is intended to be edited in Qt Design Studio only.
It is supposed to be strictly declarative and only uses a subset of QML. If you edit
this file manually, you might introduce QML code that is not supported by Qt Design Studio.
Check out https://doc.qt.io/qtcreator/creator-quick-ui-forms.html for details on .ui.qml files.
*/
import QtQuick 6.2
import QtQuick.Controls 6.2
import SecureTransact
import QtQuick.Scene3D 2.15
import QtQuick3D 6.2
import Quick3DAssets.Bitcoin

Rectangle {
    id: rectangle
    width: Constants.width
    height: Constants.height

    color: Constants.backgroundColor

    StackView {
        id: stackView
        width: 200
        height: 200

        LoginPage {
            id: startPage
        }
    }

    Item {
        id: __materialLibrary__
    }
}
