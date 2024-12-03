import QtQuick 2.15
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.3
import Qt5Compat.GraphicalEffects

import "../app_style"

Button {
    id: control

    ColorPalette { id: colorPalette }
    FontStyle { id: fontStyle }

    property int buttonWidth: 46
    property int buttonHeight: 46
    property real radius: 5
    property real borderWidth: 0
    property color borderColor: "transparent"
    property color backgroundColor: settings.light_mode ? colorPalette.primary600 : colorPalette.primary300
    property string setIcon: ""
    property color textColor: settings.light_mode ? colorPalette.background50 : colorPalette.background800
    property int fontSize: fontStyle.display_h6
    property bool autoScale: true
    property real textWidthFill: 0.75
    property real textHeightFill: 0.75

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
        if (!autoScale) return fontSize; // Jeśli skalowanie wyłączone, zwracamy domyślny rozmiar.

        let testFontSize = fontStyle.mobile_h6; // Ustawiamy początkowy rozmiar.
        let tempText = Qt.createQmlObject(
            'import QtQuick 2.15; Text { visible: false; font.family: "' + label.font.family + '"; text: "' + label.text + '"; }',
            label,
            "TempText"
        );

        while (true) {
            tempText.font.pixelSize = testFontSize; // Ustawiamy testowy rozmiar czcionki.

            if (tempText.width <= buttonWidth * control.textWidthFill || tempText.height <= buttonHeight * control.textHeightFill) {
                testFontSize += 2; // Jeśli mieści się, zwiększamy rozmiar czcionki.
            } else {
                tempText.destroy(); // Usuwamy dynamicznie stworzony Text.
                return testFontSize - 2; // Zwracamy ostatni pasujący rozmiar.
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

    contentItem:ColumnLayout{
        z: 2
        height: control.implicitHeight
        width: control.implicitWidth
        anchors.horizontalCenter: parent.horizontalCenter

        Label {
            id: label
            z: 3
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            font: control.font
            text: control.text
            color: control.textColor
            visible: !setIcon
        }

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
        border.width: control.borderWidth
        border.color: control.borderColor

        visible: false

        Behavior on color {
            ColorAnimation {
                easing.type: Easing.Linear
                duration: 200
            }
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
        anchors.fill: parent
        visible: false
    }

    OpacityMask {
        anchors.fill: background
        source: background
        maskSource: mask
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
