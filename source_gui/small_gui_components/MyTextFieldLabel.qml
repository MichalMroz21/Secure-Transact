import QtQuick 2.15
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.3
import Qt5Compat.GraphicalEffects

import "../app_style"

Item {
    id: textField
    ColorPalette { id: colorPalette }
    FontStyle { id: fontStyle }

    property string upText: ""
    property alias downText: downTextField.text

    property int parentWidth
    property int parentHeight

    implicitWidth: parentWidth
    implicitHeight: parentHeight

    ColumnLayout {
        implicitWidth: parentWidth
        implicitHeight: parentHeight

        id: layout

        Text {
            text: upText
            font.pixelSize: fontStyle.paragraph_large
            color: colorPalette.primary300
        }

        TextField {
            id: downTextField
            font.pixelSize: fontStyle.paragraph_large
            color: colorPalette.primary300

            implicitWidth: parent.width

            background: Rectangle {
                color: "transparent"
                border.color: colorPalette.primary300
                border.width: 1
                radius: 2

                width: parent.width
            }
        }
    }
}
