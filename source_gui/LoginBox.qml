import QtQuick 2.15
import QtQuick.Layouts
import QtQuick.Controls 6.3

Rectangle {
    id: rectangle
    height: 50
    opacity: 0.516
    color: "#b3a8aa"
    radius: 20
    Layout.fillWidth: true

    TextField {
        id: textInput
        echoMode: showText ? TextField.Normal : TextField.Password
        width: 80
        height: 20
        placeholderText: initialText
        font.pixelSize: 24
        verticalAlignment: Text.AlignTop
        anchors.fill: parent
        anchors.leftMargin: 71
        background: Rectangle {
            border.width: 0
        }
        maximumLength: 16
        placeholderTextColor: textInput.activeFocus ? appName.color : "gray"
    }

    NumberAnimation {
        id: fadeInAnimation
        target: rectangle
        properties: "opacity"
        duration: 5000
        to: 0.516
        from: 0
    }

    Component.onCompleted: {
        fadeInAnimation.start();
    }
}
