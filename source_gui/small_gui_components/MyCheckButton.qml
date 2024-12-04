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
    property bool autoScale: true

    property string text

    property color textColor: settings.light_mode ? colorPalette.primary700 : colorPalette.primary400
    property color boxColor: settings.light_mode ? colorPalette.primary700 : colorPalette.primary400
    property color tickColor: colorPalette.primary50

    property int size: spacingObjects.preserveSpacingProportion(spacingObjects.spacing_xx_big, root.width, root.height, false)

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
            radius: spacingObjects.preserveSpacingProportion(spacingObjects.spacing_xx_sm, root.width, root.height, false)
            color: myCheckBox.isToggled ? myCheckBox.boxColor : colorPalette.generic00

            border.color: myCheckBox.boxColor
            border.width: spacingObjects.preserveSpacingProportion(spacingObjects.spacing_xxx_sm, root.width, root.height, false)
            anchors.verticalCenter: parent.verticalCenter

            // Checkbox icon
            Text {
                color: myCheckBox.isToggled ? myCheckBox.tickColor : myCheckBox.boxColor
                text: myCheckBox.isToggled ? "✓" : ""

                anchors.centerIn: parent
                font.family: fontStyle.contentLatoLight.name
                font.pixelSize: myCheckBox.autoScale ? fontStyle.getFontSize(root.width, root.height) : myCheckBox.size
            }
        }

        // Checkbox text
        Text {
            color: "#222"
            text: "<font color=\""+ myCheckBox.textColor +"\">" + myCheckBox.text + "</font>"

            font.family: fontStyle.contentLatoLight.name
            font.pixelSize: myCheckBox.autoScale ? fontStyle.getFontSize(root.width, root.height) : myCheckBox.size
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
