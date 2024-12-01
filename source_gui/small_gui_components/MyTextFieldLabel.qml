import QtQuick 2.15
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.3
import Qt5Compat.GraphicalEffects

import "../app_style"

Item {
    ColorPalette { id: colorPalette }
    FontStyle { id: fontStyle }

    property string upText: ""
    property string downText: ""

    property int parentWidth
    property int parentHeight

    ColumnLayout {
        Layout.minimumWidth: parentWidth * 1 / 4
        Layout.minimumHeight: parentHeight
        implicitWidth: parentWidth
        implicitHeight: parentHeight

        id: layout

        Text {
            text: upText
            font.pixelSize: fontStyle.paragraph_large
            color: colorPalette.primary300
        }

        TextField {
            text: downText
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
