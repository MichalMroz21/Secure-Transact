import QtQuick 2.15
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.3
import Qt5Compat.GraphicalEffects

import "../app_style"

Rectangle {
    id: control

    ColorPalette { id: colorPalette }
    FontStyle { id: fontStyle }

    property real widthHeightScale: 1

    //Expressions below are combinations of both settings above
    property int buttonWidth: root.width * 40 / 264 + 750 / 11 / widthHeightScale
    property int buttonHeight: root.height / 15 + 40 / 3 / widthHeightScale
    property int fontSize: fontStyle.display_h6

    property var onClickedFunction
    property string buttonText: "test"

    property bool richtext: false

    property real buttonRadius: spacingObjects.preserveSpacingProportion(spacingObjects.spacing_sm, root.width, root.height, false)
    property real borderWidth: 0

    property color borderColor: "transparent"
    property color backgroundColor: settings.light_mode ? colorPalette.primary600 : colorPalette.primary300
    property color textColor: settings.light_mode ? colorPalette.background50 : colorPalette.background800

    property string setIcon: ""

    property bool autoScale: true

    property real textWidthFill: 0.5
    property real textHeightFill: 0.5

    function getFontSize(autoScale) {
        if (!autoScale) return fontSize; // If scaling is disabled, return the default font size.

        let testFontSize = fontStyle.mobile_h6; // Set the initial font size.
        let tempText = Qt.createQmlObject(
            'import QtQuick 2.15; Text { visible: false; font.family: "' + label.font.family + '"; text: "' + label.text + '"; }',
            label,
            "TempText"
        );

        while (true) {
            tempText.font.pixelSize = testFontSize; // Set the test font size.

            if (tempText.width <= buttonWidth * control.textWidthFill || tempText.height <= buttonHeight * control.textHeightFill) {
                testFontSize += 2; // If it fits, increase the font size.
            } else {
                tempText.destroy(); // Dynamically remove the created Text object.
                return testFontSize - 2; // Return the last fitting font size.
            }
        }
    }

    onWidthChanged: {
        label.font.pixelSize = getFontSize(control.autoScale);
    }

    onHeightChanged: {
        label.font.pixelSize = getFontSize(control.autoScale);
    }

    implicitWidth: buttonWidth
    implicitHeight: buttonHeight

    color: control.backgroundColor
    radius: buttonRadius

    border.width: control.borderWidth
    border.color: control.borderColor

    Label {
        id: label
        font: control.font
        text: buttonText
        color: control.textColor
        visible: !setIcon
        textFormat: richtext ? Text.AutoText : Text.RichText

        anchors.centerIn: parent
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            onClickedFunction()
        }
    }
}
