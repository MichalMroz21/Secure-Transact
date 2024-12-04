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
    property alias placeholder: downTextField.placeholderText
    property alias placeholderColor: downTextField.placeholderTextColor

    property color textFieldColor: "transparent"
    property color borderColor: settings.light_mode ? colorPalette.primary600 : colorPalette.primary300
    property color textColor: settings.light_mode ? colorPalette.primary600 : colorPalette.primary300

    property bool enablePlaceholderWhenTyping: false
    property bool visibleUpText: true

    property int borderWidth: 1
    property int parentWidth
    property int parentHeight

    implicitWidth: parentWidth
    implicitHeight: upTextVar.height + downTextField.height

    ColumnLayout {
        id: layout
        implicitWidth: textField.implicitWidth

        Text {
            id: upTextVar
            text: textField.upText
            color: settings.light_mode ? colorPalette.primary600 : colorPalette.primary300
            visible: textField.visibleUpText

            font.pixelSize: fontStyle.paragraph_large
        }

        TextField {
            id: downTextField
            color: textField.textColor
            implicitWidth: parent.width

            font.pixelSize: fontStyle.paragraph_large

            background: Rectangle {
                color: textField.textFieldColor
                radius: spacingObjects.preserveSpacingProportion(spacingObjects.spacing_xxx_sm, root.width, root.height, false)
                width: parent.width

                border.color: textField.borderColor
                border.width: textField.borderWidth
            }
        }
    }
}
