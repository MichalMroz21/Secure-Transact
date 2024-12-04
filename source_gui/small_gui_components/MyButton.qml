import QtQuick 2.15
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.3
import Qt5Compat.GraphicalEffects

import "../app_style"

Button {
    id: control

    ColorPalette { id: colorPalette }
    FontStyle { id: fontStyle }

    //width: 600
    //buttonWidth: 125
    //buttonHeight: 40

    //width: 1920
    //buttonWidth: 250
    //buttonHeight: 80

    //Expressions below are combinations of both settings above
    property int buttonWidth: root.width * 40 / 264 + 750 / 11
    property int buttonHeight: root.height / 15 + 40 / 3
    property int fontSize: fontStyle.display_h6

    property real radius: spacingObjects.preserveSpacingProportion(spacingObjects.spacing_sm, root.width, root.height, false)
    property real borderWidth: 0

    property color borderColor: "transparent"
    property color backgroundColor: settings.light_mode ? colorPalette.primary600 : colorPalette.primary300
    property color textColor: settings.light_mode ? colorPalette.background50 : colorPalette.background800

    property string setIcon: ""

    property bool autoScale: true

    property real textWidthFill: 0.5
    property real textHeightFill: 0.5

    // function getFontSize(autoScale){
    //     if (!autoScale) return fontSize;
    //     label.font.pixelSize = fontStyle.mobile_h6
    //     while(true){
    //         if(label.width < buttonWidth - radius*2) {
    //             label.font.pixelSize += 2;
    //         }
    //         else{
    //             return label.font.pixelSize;
    //         }
    //     }
    // }

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

    font.family: fontStyle.getLatoRegular.name

    contentItem: ColumnLayout {
        z: 2
        height: control.implicitHeight
        width: control.implicitWidth

        anchors.horizontalCenter: parent.horizontalCenter

        Image {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            sourceSize: Qt.size(control.implicitWidth * 0.6, control.implicitHeight * 0.6)
            source: setIcon
        }
    }

    background: Rectangle {
        height: control.implicitHeight
        width: control.implicitWidth
        radius: control.radius
        color: control.backgroundColor
        visible: false

        border.width: control.borderWidth
        border.color: control.borderColor

        Behavior on color {
            ColorAnimation {
                easing.type: Easing.Linear
                duration: 200
            }
        }

        Label {
            id: label
            z: 3
            anchors.centerIn: parent
            font: control.font
            text: control.text
            color: control.textColor
            visible: !setIcon
        }

        Rectangle {
            id: indicator
            property int mx
            property int my
            x: mx-width  / 2
            y: my-height / 2
            height: width
            radius: control.radius
            color: Qt.darker(control.backgroundColor)
        }
    }

    Rectangle{
        id: mask
        radius: control.radius
        visible: false

        anchors.fill: parent
    }

    OpacityMask {
        source: background
        maskSource: mask

        anchors.fill: background
    }

    MouseArea {
        id: mouseArea
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
        cursorShape: Qt.PointingHandCursor

        anchors.fill: parent
    }

    ParallelAnimation{
        id: main

        NumberAnimation {
            target: indicator
            properties: 'width'
            from: 0
            to: control.width * 2.5
            duration: 200
        }

        NumberAnimation {
            target: indicator
            properties: 'opacity'
            from: 0.9
            to: 0
            duration: 200
        }
    }

    onPressed: {
        indicator.mx = mouseArea.mouseX
        indicator.my = mouseArea.mouseY
        main.restart()
    }
}
