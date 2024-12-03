// https://medium.com/@eduard.metzger/how-to-make-a-quick-custom-qml-checkbox-using-icon-fonts-b2ffbd651144

import QtQuick 2.15
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.3
import Qt5Compat.GraphicalEffects

import "../app_style"

Rectangle {

    FontStyle { id: fontStyle }
    ColorPalette { id: colorPalette }

    id: myCheckBox

    property bool isToggled: true
    property string text
    property color textColor: settings.light_mode ? colorPalette.primary700 : colorPalette.primary400
    property color boxColor: settings.light_mode ? colorPalette.primary700 : colorPalette.primary400
    property color tickColor: colorPalette.primary50
    property bool autoScale: true
    property int size: 30

    width: childrenRect.width
    height: childrenRect.height
    color: "transparent"

    Row {
        spacing: spacingObjects.preserveSpacingProportion(spacingObjects.spacing_xx_sm, root.width, root.height, false)
        // Checkbox icons
        Rectangle {
            id: checkboxRect
            width: myCheckBox.autoScale ? fontStyle.getFontSize(root.width, root.height) : myCheckBox.size
            height: myCheckBox.autoScale ? fontStyle.getFontSize(root.width, root.height) : myCheckBox.size
            radius: 3
            color: myCheckBox.isToggled ? myCheckBox.boxColor : "#FFFFFF"
            border.color: myCheckBox.boxColor
            border.width: 2
            anchors.verticalCenter: parent.verticalCenter

            // Checkbox icon
            Text {
                anchors.centerIn: parent
                font.family: fontStyle.contentLatoLight.name
                color: myCheckBox.isToggled ? myCheckBox.tickColor : myCheckBox.boxColor
                font.pixelSize: myCheckBox.autoScale ? fontStyle.getFontSize(root.width, root.height) : myCheckBox.size
                text: myCheckBox.isToggled ? "✓" : ""
            }
        }
        // Checkbox text
        Text {
            color: "#222"
            font.family: fontStyle.contentLatoLight.name
            font.pixelSize: myCheckBox.autoScale ? fontStyle.getFontSize(root.width, root.height) : myCheckBox.size
            text: "<font color=\""+ myCheckBox.textColor +"\">" + myCheckBox.text + "</font>"
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            myCheckBox.isToggled = !myCheckBox.isToggled
        }
    }
}
