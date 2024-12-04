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
    property bool visibleUpText: true
    property alias downText: downTextField.text
    property alias placeholder: downTextField.placeholderText
    property alias placeholderColor: downTextField.placeholderTextColor
    property color textFieldColor: "transparent"
    property color borderColor: settings.light_mode ? colorPalette.primary600 : colorPalette.primary300
    property color textColor: settings.light_mode ? colorPalette.primary600 : colorPalette.primary300
    property bool enablePlaceholderWhenTyping: false
    property int borderWidth: 1
    property alias upTextFontSize: upTextVar.font.pixelSize
    property alias downTextFontSize: downTextField.font.pixelSize
    property alias downTextFieldHeight: downTextField.implicitHeight

    property int parentWidth
    property int parentHeight

    implicitWidth: parentWidth
    implicitHeight: upTextVar.height + downTextField.height

    ColumnLayout {
        implicitWidth: textField.implicitWidth
        id: layout

        Text {
            id: upTextVar
            text: textField.upText
            color: settings.light_mode ? colorPalette.primary600 : colorPalette.primary300
            visible: textField.visibleUpText
        }

        TextField {
            id: downTextField
            //font.pixelSize: fontStyle.paragraph_large
            color: textField.textColor

            implicitWidth: parent.width
            //implicitHeight: tu zmiana wysokosci textfielda

            background: Rectangle {
                color: textField.textFieldColor
                border.color: textField.borderColor
                border.width: textField.borderWidth
                radius: 2

                width: parent.width
            }
        }
    }
}
